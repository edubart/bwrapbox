PREFIX=/usr/local
CC=gcc
APP_CFLAGS+=-Os -fwrapv -fno-strict-aliasing -DNDEBUG -D_GNU_SOURCE
APP_CFLAGS+=-Wall -Wno-missing-braces
APP_CFLAGS+=-D_FORTIFY_SOURCE=2 -fstack-clash-protection -fstack-protector-strong -fPIC
APP_LDFLAGS+=-Wl,-O1,--sort-common,--build-id=none,--hash-style=gnu
APP_LDFLAGS+=-Wl,--relax,--sort-common,--sort-section=name
APP_LDFLAGS+=-z relro -z now
APP_LDFLAGS+=-pie
APP_LDFLAGS+=-s
NELUA_FLAGS+=-Pnochecks -Pnoerrorloc -Pnocstaticassert -Pnocwarnpragmas -Pnocstaticassert -Pnocfeaturessetup -Pnogc

HARDEN_CFLAGS=-fPIE -pie -D_FORTIFY_SOURCE=2 -fstack-clash-protection -fstack-protector-strong
HARDEN_LDFLAGS=-pie -Wl,-z,now,-z,relro

all: bwrapbox seccomp-filter seccomp-filter.bpf

bwrapbox.c:
	nelua $(NELUA_FLAGS) --cc=$(CC) --output $@ bwrapbox.nelua

bwrapbox: bwrapbox.c
	$(CC) -o $@ $< $(APP_CFLAGS) $(CFLAGS) $(APP_LDFLAGS) $(LDFLAGS)

seccomp-filter: seccomp-filter.c seccomp-filter-rules.h
	$(CC) -o $@ $< $(APP_CFLAGS) $(CFLAGS) $(APP_LDFLAGS) -lseccomp $(LDFLAGS)

seccomp-filter.bpf: seccomp-filter
	./seccomp-filter $@

generate-seccomp-rules:
	lua generate-rules.lua

clean:
	rm -f bwrapbox seccomp-filter seccomp-filter.bpf bwrapbox.c

install: bwrapbox seccomp-filter.bpf
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m755 bwrapbox $(DESTDIR)$(PREFIX)/bin/bwrapbox
	mkdir -p $(DESTDIR)$(PREFIX)/lib/bwrapbox
	install -m644 seccomp-filter.bpf $(DESTDIR)$(PREFIX)/lib/bwrapbox/seccomp-filter.bpf
