# Targets:
#  default - build project executable (optimized)
#  debug - build project executable (debug)
#  grumpy - build project executable (with all warnings on)
#  tests - TEST the project executable on tests in test director
#  gen-test - Make the individual testfiles from 'all-tests'
#  expected - Make the expected versions of each test
#  clean - Remove excess files

# Project-specific settings
TARGET := Project5

# Identify compiler to use
CXX := c++

# Flags to ALWAYs use
CFLAGS_all := -Wall -Wextra -std=c++20

# Test file (wildcard to be found when used.)
TEST_FILES     := $(wildcard tests/*.strix)
EXPECTED_DIR   := tests/expected
EXPECTED_FILES := $(patsubst tests/%.strix,$(EXPECTED_DIR)/%.expected,$(TEST_FILES))

# Flags based on compilation type.
#   Default flags turn on optimizations
#   Use "make debug" to turn on debugger flag
#   Use "make grumpy" to get extra warnings during compilation
CFLAGS := -O3 -DNDEBUG $(CFLAGS_all)
CFLAGS_debug := -g $(CFLAGS_all)
CFLAGS_grumpy := -pedantic -Wconversion -Weffc++ $(CFLAGS_all)

default: $(TARGET)
all: $(TARGET)

debug:	CFLAGS := $(CFLAGS_debug)
debug:	$(TARGET)

grumpy:	CFLAGS := $(CFLAGS_grumpy)
grumpy:	$(TARGET)

tests: $(TARGET)
	@echo "Running tests..."
	@cd tests && ./run_tests.sh
	@echo "Tests completed."

# Always run the tests, even if nothing has changed
.PHONY: clean debug grumpy tests

# List any files here that should trigger full recompilation when they change.
KEY_FILES := 

$(TARGET):	$(TARGET).cpp $(KEY_FILES)
	$(CXX) $(CFLAGS) $(TARGET).cpp -o $(TARGET)

clean:
	rm -f $(TARGET) *.o tests/current/test-*

# Debugging information
print-%: ; @echo '$(subst ','\'',$*=$($*))'
