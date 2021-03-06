
YS          ?= $(YOSYS_ROOT)/yosys
YSMTBMC     ?= $(YOSYS_ROOT)/yosys-smtbmc
YS_SCRIPT   ?= write-smt-tb.tcl

BMC_STEPS   ?= 8

SRC_RTL     ?= $(shell find ../../ -path "*rtl/*.v") \
	           $(shell find ../../ -path "*rtl/*.vh")
SRC_VERIF   ?= $(shell find ../../ -path "*verif/*.vh") \
	           $(shell find ../../ -path "*verif/*.v") 
SRC_FORMAL  ?= $(REPO_HOME)/verif/tb/tb_formal.v \
               $(REPO_HOME)/verif/formal/fml_pack_widths.vh \
               $(REPO_HOME)/verif/formal/fml_common.vh \
               $(REPO_HOME)/verif/formal/fml_top.v

VLOG_out    = $(XC_WORK)/synth.v

LOG_SYNTH   = $(XC_WORK)/yosys-synth.log
LOG_SMT2    = $(XC_WORK)/smt2/synthesis.log

SMTDIR          ?= $(XC_WORK)/smt2
CHECKS_DIR       = $(REPO_HOME)/verif/formal

FML_TIMEOUT     ?= 36000
FML_ENGINE      ?= boolector
FML_CHECK_NAME  ?= correct_invalid_opcode_response \
                   correct_result_encodings \
                   instr_gpr2xcr \
                   instr_xcr2gpr

FML_CHECK_SRC = $(addsuffix .v,$(addprefix $(CHECKS_DIR)/fml_chk_, $(FML_CHECK_NAME)))

SMT2_out   ?= $(addsuffix .smt2,$(addprefix $(SMTDIR)/, $(FML_CHECK_NAME)))
SMT2_RPTS  ?= $(addsuffix .rpt ,$(addprefix $(SMTDIR)/, $(FML_CHECK_NAME)))
SMT2_COVER ?= $(addsuffix .cov ,$(addprefix $(SMTDIR)/, $(FML_CHECK_NAME)))
SMT2_TRACE ?= $(addsuffix .vcd ,$(addprefix $(SMTDIR)/, $(FML_CHECK_NAME)))
SMT2_VTB   ?= $(addsuffix .v   ,$(addprefix $(SMTDIR)/, $(FML_CHECK_NAME)))

SMT_FLAGS  = -t $(BMC_STEPS) --noprogress -s $(FML_ENGINE) -S "--time=$(FML_TIMEOUT)"

all: $(VLOG_out) formal-checks

formal-checks: $(SMT2_out)  $(SMT2_COVER) $(SMT2_RPTS)

synthesise-xcrypto: YS_SCRIPT = synth-xcrypto.tcl
synthesise-xcrypto: $(VLOG_out)
	cp $(VLOG_out) $(XC_WORK)/synth-xcrypto.v
	cp $(LOG_SYNTH) $(XC_WORK)/synth-xcrypto.rpt
	cp $(XC_WORK)/synth-statistics.rpt $(XC_WORK)/synth-xcrypto-stats.rpt

synthesise-subsystem: YS_SCRIPT = synth-subsystem.tcl
synthesise-subsystem: $(VLOG_out)
	cp $(VLOG_out) $(XC_WORK)/synth-subsys.v
	cp $(LOG_SYNTH) $(XC_WORK)/synth-subsys.rpt
	cp $(XC_WORK)/synth-statistics.rpt $(XC_WORK)/synth-subsys-stats.rpt

$(VLOG_out) : $(YS_SCRIPT) $(SRC_RTL)
	$(YS) -QT -l $(LOG_SYNTH) $(YS_SCRIPT)

.PHONY: adder
adder       : YS_SCRIPT = adder.tcl
adder       : ../../rtl/coprocessor/scarv_cop_palu_adder.v
	$(YS) -QT $(YS_SCRIPT)

.PHONY: smt2
smt2: $(SMT2_out)
$(SMTDIR)/%.smt2 : $(REPO_HOME)/verif/formal/fml_chk_%.v \
                   $(SRC_RTL) $(SRC_FORMAL)
	@mkdir -p $(word 1, $(dir $(SMT2_out)))
	$(YS) -qQT -l $@.log \
        -p"verilog_defaults -add -DFML_CHECK_NAME=$(basename $(notdir $@))" \
        -p"tcl $(YS_SCRIPT)" \
        -p"write_smt2 -wires $@"

include proof-depths.mk

#
# Check that every assertion is also coverable
#
$(SMTDIR)/%.cov  : SMT_FLAGS += -c
$(SMTDIR)/%.cov  : $(SMTDIR)/%.smt2
	echo "`date` Started $(notdir $(basename $@))" > $@
	$(YSMTBMC) $(SMT_FLAGS) $< | tee -a $@
	echo "`date` Finished $(notdir $(basename $@))" >> $@

#
# Run the bounded model checker
#
$(SMTDIR)/%.rpt  : $(SMTDIR)/%.cov
$(SMTDIR)/%.rpt  : $(SMTDIR)/%.smt2
	echo "`date` Started $(notdir $(basename $@))" > $@
	$(YSMTBMC) $(SMT_FLAGS) --dump-vcd $(basename $@).vcd $< | tee -a $@
	echo "`date` Finished $(notdir $(basename $@))" >> $@


.PHONY: formal
formal: $(SMT2_out)
	$(YSMTBMC) -t $(BMC_STEPS) \
               --presat \
               --dump-vcd $(SMT2_TRACE) \
               --dump-vlogtb $(SMT2_VTB) \
               -s z3 \
               $(SMT2_out)

clean:
	rm -rf $(XC_WORK)/smt2 $(SMT2_out) $(VLOG_out) $(SMT_VCD) $(LOG_SYNTH) \
        $(XC_WORK)/*.log $(COP_WORK)/*.rpt
