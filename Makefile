CC = gcc

CFLAGS =-std=gnu11 \
	-g \
	-I$(SRCDIR)/inc \
	-Wall \
	-Wextra \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-Wno-sign-compare \
	-Wno-unused-function

LDLIBS =-lzstd

SRCDIR = src
BUILDDIR = build
BINDIR = bin
TEMPDIR = temp

SOURCES = $(shell find $(SRCDIR) -name '*.c')

OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)

TARGET = $(BINDIR)/dbipatcher

all: $(TARGET)

$(TARGET): $(OBJECTS) | $(BUILDDIR) $(BINDIR)
	$(CC) $(OBJECTS) -o $@ $(LDLIBS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

$(BINDIR):
	@mkdir -p $(BINDIR)

$(TEMPDIR):
	@mkdir -p $(TEMPDIR)

clean:
	@rm -rf $(BUILDDIR) $(TEMPDIR)

run: $(TARGET)
	@$(TARGET)

translate-810: $(TARGET) | $(TEMPDIR)
	@$(TARGET) --extract dbi/DBI.810.ru.nro --output $(TEMPDIR)/DBI_810
	@$(TARGET) --convert $(TEMPDIR)/DBI_810/rec6.bin --output translate/rec6.810.ru.txt --keys $(TEMPDIR)/DBI_810/keys_ru.txt
	@$(TARGET) --extract-keys dbi/DBI.810.ru.nro --output $(TEMPDIR)/DBI_810/keys_$(LANG).txt --lang $(LANG)
	@$(TARGET) --convert translate/rec6.810.$(LANG).txt --output $(TEMPDIR)/DBI_810/rec6.$(LANG).bin --keys $(TEMPDIR)/DBI_810/keys_$(LANG).txt
	@$(TARGET) --patch $(TEMPDIR)/DBI_810/rec6.$(LANG).bin --binary dbi/DBI.810.ru.nro --output $(TEMPDIR)/DBI_810/bin/DBI.810.$(LANG).nro --slot 6

debug: $(TARGET)
	@valgrind $(TARGET)

.PHONY: all clean