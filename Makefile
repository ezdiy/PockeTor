CROSS=arm-obreey-linux-gnueabi
TOR=tor-0.4.1.6
LIBEVENT2=2.1.10-stable
LIBEVENT=libevent-$(LIBEVENT2)
CC=$(CROSS)-gcc
STRIP=$(CROSS)-strip
ver=$(shell git describe --tags)
CONFIGURE=\
	--disable-asciidoc \
	--disable-seccomp \
	--disable-libscrypt \
	--disable-unittests \
	--disable-zstd \
	--with-tor-user=reader \
	--with-tor-group=reader \
	--without-gnutls \
	--with-openssl \
	--disable-ipv6 \
	--localstatedir=/var/run \
	--sharedstatedir=/var \
	--prefix=/mnt/secure \
	--disable-shared \
	--sbindir=/mnt/secure/bin \
	--datarootdir=/mnt/secure \
	--disable-unicode \
	--host=$(CROSS) \
	--disable-tool-name-check \
	--with-libevent-dir=$(CURDIR)/$(LIBEVENT) \
	tor_cv_ldflags__pie=no \
	CC=$(CC)


pocketor/tor: $(TOR)/src/app/tor
	$(STRIP) $(TOR)/src/app/tor -o pocketor/tor

PockeTor-$(ver).zip: pocketor/tor $(LIBEVENT)/libevent.a proxy.so
	cp -f proxy.so pocketor/
	zip PockeTor-$(ver).zip PockeTor.app pocketor/*

clean:
	rm -rf $(TOR) $(LIBEVENT) proxy.so PockeTor-$(ver).zip

proxy.so: proxy.c
	$(CC) -shared -fPIC -o proxy.so -O2 -s proxy.c

$(LIBEVENT)/libevent.a: $(LIBEVENT)/configure
	#(cd $(LIBEVENT) && ./configure $(CONFIGURE))
	make -C $(LIBEVENT)
	cp -va $(LIBEVENT)/.libs/*.a $(LIBEVENT)

$(TOR)/configure:
	wget -c https://dist.torproject.org/$(TOR).tar.gz
	tar -xvzf $(TOR).tar.gz

$(TOR)/src/app/tor: $(TOR)/configure $(LIBEVENT)/libevent.a
	#(cd $(TOR) && ./configure $(CONFIGURE))
	make -C $(TOR)

$(LIBEVENT)/configure:
	wget -c https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT2)/$(LIBEVENT).tar.gz
	tar -xvzf $(LIBEVENT).tar.gz


