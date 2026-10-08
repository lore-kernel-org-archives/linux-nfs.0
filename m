Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DFFAA4BF931;
	Thu,  8 Oct 2026 18:36:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791484611; cv=none; b=DdD6xaNwUcAo1HAhLx+C8KdyH27QpSk5CWeNCbmeZrX3/z/ROxgke+EjxBthLXekuK6K4KtJKhvXt10SZa5TwJAt/vCIvo4EqmMe7XmoNwWThH0rTtfniSYG94bgPedl5Kgus1ET1QL10ZPKnB+41tzRKychf1dQmvZT19XrGWI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791484611; c=relaxed/simple;
	bh=1CJDWeVsw0rDhrg3ozPO1y4LKAIRWaAfUC8J48QLAz4=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=JKxSfWbvRENl5AHSQL95A6SW4la2L/1p9gSbAI/+qmkfg6Ai2cGUhEHiJWnIHB4MQIpX1Q0YkYmIB8BWHStfRhqUwNwY4y/buN7JntdJ8+NwZ4ZLdabKSwBIiNwl3HSyFq7Bh/+cT2/KvqP3fdcSHFjj+s80ydoC7YNYV3RrvTU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a4W3zuDZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a4W3zuDZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C056A1F000FF;
	Thu,  8 Oct 2026 18:36:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791484607;
	bh=asdSOph33E+1ljRHuGkcihmYt19J2O6THAuLHPYufO0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=a4W3zuDZWjIIjmBOZclEC0basCgOa7hmonbWfugudOX8rfngQHSct6TyvcmFY7jwV
	 eY/EucUd4TkPLKMokxrA+87VOdbkD+9D1IOYUo6TayfGFcKdvhHhNtGcMAgmKVYUI7
	 Uv3tftL8IuEf4dV4WMqWYnwVo0Y6Jmaw/zNqFP2h8KqRywxZAQ2vcNEZnd+rjEUBPL
	 HWIEwhgAUHct9sdW2xy+MXYR/PCAkElPkygkum47KFb6H+e+E/Ic6y1wFUxOMwBaII
	 Ho7l99784xKDdgmjlxZkiiUgU8S5CCYxmW6btkh6u+4t4iEizV4uhfk8wTTXtVhcDw
	 9gvuaO2m7L+aw==
Message-ID: <ff8194ac4128f0c972545ca19fc696aa064e68c9.camel@kernel.org>
Subject: Re: [PATCH RFC v2 8/9] tools/net/sunrpc: add svc-classify, a prefix
 classifier and its loader
From: Jeff Layton <jlayton@kernel.org>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Chuck Lever
	 <cel@kernel.org>, NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>, 
	bpf@vger.kernel.org, Martin KaFai Lau <martin.lau@linux.dev>
Date: Thu, 08 Oct 2026 20:36:44 +0200
In-Reply-To: <158d8194fc5ce6d1fb8fdd1196f53de7d3651d36.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
	 <158d8194fc5ce6d1fb8fdd1196f53de7d3651d36.1791402701.git.bcodding@hammerspace.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-10-07 at 15:59 -0400, Benjamin Coddington wrote:
> From: Benjamin Coddington <bcodding@hammerspace.com>
>=20
> An administrator who wants RPC service transports dispatched per client
> needs a classifier attached in the service's network namespace and a
> way to fill its map.  Add svc-classify: the prefix classifier from the
> BPF selftests, with its own type definitions in place of vmlinux.h,
> embedded in a loader as a skeleton so the binary stands alone.  load
> attaches it and pins the link and the map, replace swaps the program
> and keeps the map, unload detaches; add, del and list manage the map
> with address prefixes and class words written as N, N+addr or addr;
> status shows the link.  The Makefile builds the in-tree libbpf and
> bpftool it needs.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  tools/net/sunrpc/svc-classify/.gitignore      |   1 +
>  tools/net/sunrpc/svc-classify/Makefile        |  65 ++++
>  tools/net/sunrpc/svc-classify/svc-classify.c  | 357 ++++++++++++++++++
>  .../sunrpc/svc-classify/svc_classify.bpf.c    |  83 ++++
>  4 files changed, 506 insertions(+)
>  create mode 100644 tools/net/sunrpc/svc-classify/.gitignore
>  create mode 100644 tools/net/sunrpc/svc-classify/Makefile
>  create mode 100644 tools/net/sunrpc/svc-classify/svc-classify.c
>  create mode 100644 tools/net/sunrpc/svc-classify/svc_classify.bpf.c
>=20
> diff --git a/tools/net/sunrpc/svc-classify/.gitignore b/tools/net/sunrpc/=
svc-classify/.gitignore
> new file mode 100644
> index 000000000000..567609b1234a
> --- /dev/null
> +++ b/tools/net/sunrpc/svc-classify/.gitignore
> @@ -0,0 +1 @@
> +build/
> diff --git a/tools/net/sunrpc/svc-classify/Makefile b/tools/net/sunrpc/sv=
c-classify/Makefile
> new file mode 100644
> index 000000000000..9d86bc88417b
> --- /dev/null
> +++ b/tools/net/sunrpc/svc-classify/Makefile
> @@ -0,0 +1,65 @@
> +# SPDX-License-Identifier: GPL-2.0
> +OUTPUT ?=3D $(CURDIR)/build/
> +override OUTPUT :=3D $(abspath $(OUTPUT))/
> +$(shell mkdir -p $(OUTPUT))
> +
> +include ../../../build/Build.include
> +include ../../../scripts/Makefile.arch
> +include ../../../scripts/Makefile.include
> +
> +TOOLSDIR :=3D $(abspath ../../..)
> +BPFDIR :=3D $(TOOLSDIR)/lib/bpf
> +BPFTOOLDIR :=3D $(TOOLSDIR)/bpf/bpftool
> +APIDIR :=3D $(TOOLSDIR)/include/uapi
> +INCLUDE_DIR :=3D $(OUTPUT)include
> +BPFOBJ :=3D $(OUTPUT)libbpf/libbpf.a
> +DEFAULT_BPFTOOL :=3D $(OUTPUT)sbin/bpftool
> +BPFTOOL ?=3D $(DEFAULT_BPFTOOL)
> +CLANG ?=3D clang
> +msg =3D $(if $(Q),@printf '  %-8s %s\n' "$(1)" "$(3)";)
> +
> +prefix ?=3D /usr/local
> +sbindir ?=3D $(prefix)/sbin
> +INSTALL ?=3D install
> +
> +CFLAGS +=3D -g -O2 -Wall -I$(INCLUDE_DIR) -I$(OUTPUT)
> +LDLIBS +=3D -lelf -lz
> +BPF_CFLAGS :=3D -g -O2 -target bpf -D__TARGET_ARCH_$(SRCARCH) \
> +	      -I$(INCLUDE_DIR) -I$(APIDIR) -Wall
> +
> +all: $(OUTPUT)svc-classify
> +
> +$(OUTPUT)libbpf $(OUTPUT)bpftool:
> +	$(Q)mkdir -p $@
> +
> +$(BPFOBJ): $(wildcard $(BPFDIR)/*.[ch] $(BPFDIR)/Makefile) | $(OUTPUT)li=
bbpf
> +	$(Q)$(MAKE) $(submake_extras) -C $(BPFDIR) OUTPUT=3D$(OUTPUT)libbpf/ \
> +		    DESTDIR=3D$(OUTPUT) prefix=3D all install_headers
> +
> +$(DEFAULT_BPFTOOL): $(wildcard $(BPFTOOLDIR)/*.[ch] $(BPFTOOLDIR)/Makefi=
le) \
> +		    $(BPFOBJ) | $(OUTPUT)bpftool
> +	$(Q)$(MAKE) $(submake_extras) -C $(BPFTOOLDIR) OUTPUT=3D$(OUTPUT)bpftoo=
l/ \
> +		    LIBBPF_OUTPUT=3D$(OUTPUT)libbpf/ LIBBPF_DESTDIR=3D$(OUTPUT) \
> +		    prefix=3D DESTDIR=3D$(OUTPUT) install-bin
> +
> +$(OUTPUT)svc_classify.bpf.o: svc_classify.bpf.c $(BPFOBJ)
> +	$(call msg,CLNG-BPF,,$(notdir $@))
> +	$(Q)$(CLANG) $(BPF_CFLAGS) -c $< -o $@
> +
> +$(OUTPUT)svc_classify.skel.h: $(OUTPUT)svc_classify.bpf.o $(BPFTOOL)
> +	$(call msg,GEN-SKEL,,$(notdir $@))
> +	$(Q)$(BPFTOOL) gen skeleton $< name svc_classify > $@
> +
> +$(OUTPUT)svc-classify: svc-classify.c $(OUTPUT)svc_classify.skel.h $(BPF=
OBJ)
> +	$(call msg,CC,,$(notdir $@))
> +	$(Q)$(CC) $(CFLAGS) -o $@ $< $(BPFOBJ) $(LDLIBS)
> +
> +install: $(OUTPUT)svc-classify
> +	$(Q)$(INSTALL) -d $(DESTDIR)$(sbindir)
> +	$(Q)$(INSTALL) -m 755 $(OUTPUT)svc-classify $(DESTDIR)$(sbindir)/
> +
> +clean:
> +	$(Q)rm -rf $(OUTPUT)
> +
> +.PHONY: all install clean
> +.DELETE_ON_ERROR:
> diff --git a/tools/net/sunrpc/svc-classify/svc-classify.c b/tools/net/sun=
rpc/svc-classify/svc-classify.c
> new file mode 100644
> index 000000000000..f722b891be2c
> --- /dev/null
> +++ b/tools/net/sunrpc/svc-classify/svc-classify.c
> @@ -0,0 +1,357 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * svc-classify - attach the prefix classifier to the RPC services of th=
is
> + * network namespace and manage its prefix map.
> + *
> + *   svc-classify [-p DIR] load             attach; pin the link and the=
 map
> + *   svc-classify [-p DIR] replace          replace the program, keep th=
e map
> + *   svc-classify [-p DIR] unload           detach
> + *   svc-classify [-p DIR] add PREFIX CLASS
> + *   svc-classify [-p DIR] del PREFIX
> + *   svc-classify [-p DIR] list
> + *   svc-classify [-p DIR] status
> + *
> + * PREFIX is a.b.c.d[/len], x:y::z[/len], any, any4 or any6.  CLASS is N
> + * (one client for every peer that matches), N+addr (one client per peer
> + * address within class N), addr (the same as 0+addr) or 0 (the anonymou=
s
> + * client).  DIR, where the link and the map are pinned, defaults to
> + * /sys/fs/bpf/svc_classify.
> + */
> +#include <arpa/inet.h>
> +#include <errno.h>
> +#include <limits.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <sys/stat.h>
> +#include <unistd.h>
> +
> +#include <bpf/bpf.h>
> +#include <bpf/libbpf.h>
> +
> +#include "svc_classify.skel.h"
> +
> +#define PIN_DIR_DEFAULT	"/sys/fs/bpf/svc_classify"
> +#define SVC_CLASS_PER_ADDR	(1U << 31)
> +
> +struct prefix_key {
> +	__u32 prefixlen;
> +	__u8 family;
> +	__u8 addr[16];
> +};
> +
> +static const char *progname;
> +static char pin_link[PATH_MAX], pin_map[PATH_MAX];
> +static const char *pin_dir =3D PIN_DIR_DEFAULT;
> +
> +static void usage(void)
> +{
> +	fprintf(stderr,
> +		"usage: %s [-p DIR] load | replace | unload | list | status |\n"
> +		"       add PREFIX CLASS | del PREFIX\n"
> +		"PREFIX: a.b.c.d[/len], x:y::z[/len], any, any4, any6\n"
> +		"CLASS:  N, N+addr, addr, 0\n", progname);
> +	exit(2);
> +}
> +
> +static int do_load(void)
> +{
> +	struct svc_classify *skel;
> +	struct bpf_link *link;
> +	int err;
> +
> +	if (access(pin_link, F_OK) =3D=3D 0) {
> +		fprintf(stderr, "%s: already loaded (%s exists)\n", progname,
> +			pin_link);
> +		return 1;
> +	}
> +	mkdir(pin_dir, 0700);
> +
> +	skel =3D svc_classify__open_and_load();
> +	if (!skel) {
> +		fprintf(stderr, "%s: load: %s\n", progname, strerror(errno));
> +		rmdir(pin_dir);
> +		return 1;
> +	}
> +	link =3D bpf_map__attach_struct_ops(skel->maps.prefix);
> +	if (!link) {
> +		fprintf(stderr, "%s: attach: %s\n", progname, strerror(errno));
> +		rmdir(pin_dir);
> +		return 1;
> +	}
> +	err =3D bpf_link__pin(link, pin_link);
> +	if (!err)
> +		err =3D bpf_map__pin(skel->maps.prefixes, pin_map);
> +	if (err) {
> +		fprintf(stderr, "%s: pin: %s\n", progname, strerror(-err));
> +		bpf_link__destroy(link);
> +		unlink(pin_link);
> +		rmdir(pin_dir);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static int do_replace(void)
> +{
> +	struct svc_classify *skel;
> +	struct bpf_link *link;
> +	int link_fd, err;
> +
> +	link_fd =3D bpf_obj_get(pin_link);
> +	if (link_fd < 0) {
> +		fprintf(stderr, "%s: not loaded (%s)\n", progname,
> +			strerror(errno));
> +		return 1;
> +	}
> +	skel =3D svc_classify__open();
> +	if (!skel) {
> +		fprintf(stderr, "%s: open: %s\n", progname, strerror(errno));
> +		return 1;
> +	}
> +	/*
> +	 * Reuse the pinned map so the entries survive.  A build whose map
> +	 * definition differs fails here; unload and load then.
> +	 */
> +	err =3D bpf_map__set_pin_path(skel->maps.prefixes, pin_map);
> +	if (!err)
> +		err =3D svc_classify__load(skel);
> +	if (err) {
> +		fprintf(stderr, "%s: load: %s\n", progname, strerror(-err));
> +		return 1;
> +	}
> +	/*
> +	 * bpf_link__update_map() wants the link that attached the map, not
> +	 * one reopened from a pin.  bpf_map__attach_struct_ops() writes the
> +	 * program into the new map's value before it tries to create a link,
> +	 * and the link is refused with EBUSY while the old one is attached;
> +	 * the written map is what the link update needs.
> +	 */
> +	link =3D bpf_map__attach_struct_ops(skel->maps.prefix);
> +	if (link) {
> +		bpf_link__destroy(link);
> +		fprintf(stderr, "%s: nothing attached in this namespace; unload and lo=
ad\n",
> +			progname);
> +		return 1;
> +	}
> +	if (errno !=3D EBUSY) {
> +		fprintf(stderr, "%s: attach: %s\n", progname, strerror(errno));
> +		return 1;
> +	}
> +	err =3D bpf_link_update(link_fd, bpf_map__fd(skel->maps.prefix), NULL);
> +	if (err) {
> +		fprintf(stderr, "%s: replace: %s\n", progname, strerror(errno));
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static int do_unload(void)
> +{
> +	int ret =3D 0;
> +
> +	if (unlink(pin_link) && errno !=3D ENOENT) {
> +		perror(pin_link);
> +		ret =3D 1;
> +	}
> +	if (unlink(pin_map) && errno !=3D ENOENT) {
> +		perror(pin_map);
> +		ret =3D 1;
> +	}
> +	rmdir(pin_dir);
> +	return ret;
> +}
> +
> +static int parse_prefix(const char *s, struct prefix_key *key)
> +{
> +	char buf[64], *slash;
> +	int bits, max;
> +
> +	memset(key, 0, sizeof(*key));
> +	if (!strcmp(s, "any"))
> +		return 0;
> +	if (!strcmp(s, "any4")) {
> +		key->family =3D AF_INET;
> +		key->prefixlen =3D 8;
> +		return 0;
> +	}
> +	if (!strcmp(s, "any6")) {
> +		key->family =3D AF_INET6;
> +		key->prefixlen =3D 8;
> +		return 0;
> +	}
> +	if (strlen(s) >=3D sizeof(buf))
> +		return -1;
> +	strcpy(buf, s);
> +	slash =3D strchr(buf, '/');
> +	if (slash)
> +		*slash++ =3D '\0';
> +	if (inet_pton(AF_INET, buf, key->addr) =3D=3D 1) {
> +		key->family =3D AF_INET;
> +		max =3D 32;
> +	} else if (inet_pton(AF_INET6, buf, key->addr) =3D=3D 1) {
> +		key->family =3D AF_INET6;
> +		max =3D 128;
> +	} else {
> +		return -1;
> +	}
> +	bits =3D max;
> +	if (slash) {
> +		char *end;
> +
> +		if (*slash < '0' || *slash > '9')
> +			return -1;
> +		bits =3D strtoul(slash, &end, 10);
> +		if (*end || bits > max)
> +			return -1;
> +	}
> +	key->prefixlen =3D 8 + bits;
> +	return 0;
> +}
> +
> +static int parse_class(const char *s, __u32 *class)
> +{
> +	unsigned long n;
> +	char *end;
> +
> +	if (!strcmp(s, "addr")) {
> +		*class =3D SVC_CLASS_PER_ADDR;
> +		return 0;
> +	}
> +	n =3D strtoul(s, &end, 0);
> +	if (end =3D=3D s || n >=3D SVC_CLASS_PER_ADDR)
> +		return -1;
> +	*class =3D n;
> +	if (!strcmp(end, "+addr"))
> +		*class |=3D SVC_CLASS_PER_ADDR;
> +	else if (*end)
> +		return -1;
> +	return 0;
> +}
> +
> +static void print_entry(const struct prefix_key *key, __u32 class)
> +{
> +	char addr[INET6_ADDRSTRLEN];
> +
> +	if (key->prefixlen =3D=3D 0)
> +		printf("any");
> +	else if (key->prefixlen =3D=3D 8)
> +		printf("any%d", key->family =3D=3D AF_INET ? 4 : 6);
> +	else
> +		printf("%s/%u", inet_ntop(key->family, key->addr, addr,
> +					  sizeof(addr)), key->prefixlen - 8);
> +	printf(" -> %u%s\n", class & ~SVC_CLASS_PER_ADDR,
> +	       class & SVC_CLASS_PER_ADDR ? "+addr" : "");
> +}
> +
> +static int open_map(void)
> +{
> +	int fd =3D bpf_obj_get(pin_map);
> +
> +	if (fd < 0) {
> +		fprintf(stderr, "%s: not loaded (%s: %s)\n", progname, pin_map,
> +			strerror(errno));
> +		exit(1);
> +	}
> +	return fd;
> +}
> +
> +static int do_add(const char *prefix, const char *cls)
> +{
> +	struct prefix_key key;
> +	__u32 class;
> +
> +	if (parse_prefix(prefix, &key) || parse_class(cls, &class))
> +		usage();
> +	if (bpf_map_update_elem(open_map(), &key, &class, BPF_ANY)) {
> +		fprintf(stderr, "%s: add: %s\n", progname, strerror(errno));
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static int do_del(const char *prefix)
> +{
> +	struct prefix_key key;
> +
> +	if (parse_prefix(prefix, &key))
> +		usage();
> +	if (bpf_map_delete_elem(open_map(), &key)) {
> +		fprintf(stderr, "%s: del: %s\n", progname, strerror(errno));
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static int do_list(void)
> +{
> +	struct prefix_key key, next;
> +	__u32 class;
> +	int fd;
> +
> +	fd =3D open_map();
> +	if (bpf_map_get_next_key(fd, NULL, &next))
> +		return 0;
> +	do {
> +		key =3D next;
> +		if (!bpf_map_lookup_elem(fd, &key, &class))
> +			print_entry(&key, class);
> +	} while (!bpf_map_get_next_key(fd, &key, &next));
> +	return 0;
> +}
> +
> +static int do_status(void)
> +{
> +	struct bpf_link_info info =3D {};
> +	__u32 len =3D sizeof(info);
> +	int fd;
> +
> +	fd =3D bpf_obj_get(pin_link);
> +	if (fd < 0) {
> +		printf("not loaded\n");
> +		return 1;
> +	}
> +	if (bpf_link_get_info_by_fd(fd, &info, &len))
> +		printf("loaded\n");
> +	else
> +		printf("loaded, link id %u, struct_ops map id %u\n", info.id,
> +		       info.struct_ops.map_id);
> +	return 0;
> +}
> +
> +int main(int argc, char **argv)
> +{
> +	const char *cmd;
> +	int opt;
> +
> +	progname =3D argv[0];
> +	while ((opt =3D getopt(argc, argv, "p:")) !=3D -1) {
> +		if (opt !=3D 'p')
> +			usage();
> +		pin_dir =3D optarg;
> +	}
> +	argc -=3D optind;
> +	argv +=3D optind;
> +	if (argc < 1)
> +		usage();
> +	cmd =3D argv[0];
> +	snprintf(pin_link, sizeof(pin_link), "%s/link", pin_dir);
> +	snprintf(pin_map, sizeof(pin_map), "%s/prefixes", pin_dir);
> +
> +	if (!strcmp(cmd, "load") && argc =3D=3D 1)
> +		return do_load();
> +	if (!strcmp(cmd, "replace") && argc =3D=3D 1)
> +		return do_replace();
> +	if (!strcmp(cmd, "unload") && argc =3D=3D 1)
> +		return do_unload();
> +	if (!strcmp(cmd, "add") && argc =3D=3D 3)
> +		return do_add(argv[1], argv[2]);
> +	if (!strcmp(cmd, "del") && argc =3D=3D 2)
> +		return do_del(argv[1]);
> +	if (!strcmp(cmd, "list") && argc =3D=3D 1)
> +		return do_list();
> +	if (!strcmp(cmd, "status") && argc =3D=3D 1)
> +		return do_status();
> +	usage();
> +	return 2;
> +}
> diff --git a/tools/net/sunrpc/svc-classify/svc_classify.bpf.c b/tools/net=
/sunrpc/svc-classify/svc_classify.bpf.c
> new file mode 100644
> index 000000000000..3d012f102ec3
> --- /dev/null
> +++ b/tools/net/sunrpc/svc-classify/svc_classify.bpf.c
> @@ -0,0 +1,83 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * A svc_classifier for RPC service transports: the peer address is look=
ed
> + * up in an LPM trie keyed by {family, address}; a hit returns the class
> + * word stored there, a miss returns 0, the anonymous client.  A key of
> + * prefixlen 0 is the default for every family, 8 the default for one.
> + */
> +#include <linux/types.h>
> +#include <linux/bpf.h>
> +#include <bpf/bpf_helpers.h>
> +#include <bpf/bpf_tracing.h>
> +#include <bpf/bpf_core_read.h>
> +
> +char _license[] SEC("license") =3D "GPL";
> +
> +#define AF_INET			2
> +#define AF_INET6		10
> +
> +#define SVC_CLASSIFIER_NAME_MAX	16
> +
> +struct sockaddr_storage___local {
> +	unsigned short ss_family;
> +	char __data[126];
> +};
> +
> +struct svc_xprt___local {
> +	struct sockaddr_storage___local xpt_remote;
> +} __attribute__((preserve_access_index));
> +
> +struct svc_classifier___local {
> +	char name[SVC_CLASSIFIER_NAME_MAX];
> +	__u32 (*classify)(const struct svc_xprt___local *xprt);
> +};
> +
> +struct prefix_key {
> +	__u32 prefixlen;	/* 8 (the family byte) + address bits */
> +	__u8 family;
> +	__u8 addr[16];
> +};
> +
> +struct {
> +	__uint(type, BPF_MAP_TYPE_LPM_TRIE);
> +	__type(key, struct prefix_key);
> +	__type(value, __u32);
> +	__uint(max_entries, 1024);
> +	__uint(map_flags, BPF_F_NO_PREALLOC);
> +} prefixes SEC(".maps");
> +
> +SEC("struct_ops/classify")
> +__u32 BPF_PROG(prefix_classify, const struct svc_xprt___local *xprt)
> +{
> +	struct sockaddr_storage___local ss;
> +	struct prefix_key key =3D {};
> +	__u32 *class;
> +
> +	if (bpf_core_read(&ss, sizeof(ss), &xprt->xpt_remote))
> +		return 0;
> +
> +	key.family =3D ss.ss_family;
> +	switch (ss.ss_family) {
> +	case AF_INET:
> +		/* struct sockaddr_in: port at 2, address at 4 */
> +		__builtin_memcpy(key.addr, &ss.__data[2], 4);
> +		key.prefixlen =3D 8 + 32;
> +		break;
> +	case AF_INET6:
> +		/* struct sockaddr_in6: port at 2, flowinfo at 4, address at 8 */
> +		__builtin_memcpy(key.addr, &ss.__data[6], 16);
> +		key.prefixlen =3D 8 + 128;
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	class =3D bpf_map_lookup_elem(&prefixes, &key);
> +	return class ? *class : 0;
> +}
> +
> +SEC(".struct_ops.link")
> +struct svc_classifier___local prefix =3D {
> +	.name		=3D "prefix",
> +	.classify	=3D (void *)prefix_classify,
> +};

The userland programs in the kernel are often not packaged, so it seems
to me that svc-classify would be better integrated into nfs-utils. That
would allow you to more easily bundle it with the systemd service file.

It might even make sense to integrate this functionality into nfsdctl,
but I guess the classifier affects all rpc_serv objects as well (e.g.
NLM), so it may be best to keep it as its own thing.
--=20
Jeff Layton <jlayton@kernel.org>
