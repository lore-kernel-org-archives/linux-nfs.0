Received: from mail-oo1-f52.google.com (mail-oo1-f52.google.com [209.85.161.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7398A3DAABF
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403193; cv=none; b=K7HrnyiGgSknhujQNDCN8zCNJaM0EZZMcoPeerb7KYnnljSGQkKIly5adHycLbMkKbKmjxTsDNjUmdAuzaWfameRVqZSowXEYCFgy6VUEmUir1jTbLWPxorIBfINNodiobrX6rt7R4IIZRNzt0jDRfDS8ZF1tEe3+3k0RvXfAPg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403193; c=relaxed/simple;
	bh=ZJ0FBEEAk3lQ/anUoKP7dW8kkEQXPqIKPJ8M86lMUIo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ONVhRAUwyHWQQLL5xDYNskZt4DOKYkp2VlqGUKUyN3Zw8AXoAOaugR0e4ZlpAB6ob8/0yyXtas6r7aLH9gmO1pV3dL64dM9X7kD2cBfsTtXXAXUO58Yra6RRfteO9Aw0wDkMo/ynZw6ZX+ppericiVn7EJRUhm7QQ69Bl+AOLkU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=YPvjdbfj; arc=none smtp.client-ip=209.85.161.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YPvjdbfj"
Received: by mail-oo1-f52.google.com with SMTP id 006d021491bc7-6b19e291cc6so1839763eaf.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403190; x=1792007990; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TASzkFYkjJFtViaSUmjiYH80Tyjbxav29/9Zm5TqGVI=;
        b=YPvjdbfjqlcq7JWFOor74GIQRsPA7NMRzFeebG+An4mpdbmFjis7lhusH7SoEeZiSw
         RLHY7jpaMfzpLPVgBxgHHdzFcb99rvNKuQG0f0Dn2ljZRrt1mebJp2vUbjmrwvbZX6Jh
         P25ObQCXBUT0CrjW2avfe/i7zgoszsEE0So1A835FAJHvHA3AM9TgLzT0Zd/IhFM6Bbx
         R38F+n4seyzOMVldF/f9Qr4Yc6UmQzL36S4YSPiX/szYM0vz7hiM4f2++SsLW+c4QN+s
         oNr1a3N8AaB1zSbHcn8uClgyuKt4mzgGHFK4H5hkzL8PeBwyCcgYDft38C5PXZdQ8moh
         n7Bw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403190; x=1792007990;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=TASzkFYkjJFtViaSUmjiYH80Tyjbxav29/9Zm5TqGVI=;
        b=UCYANgZjKGbxOIsaFl1O31ANufCSq1Ikqd5QcOTcQCl20e4kSFnOx6091F9OLXW69K
         4NVqponHmcW+qb46Wo9hWJgycNbRqDrG67UNHdScwkkeFhovbPplar4Kq54oNpVyPgx9
         Ie7Jyg/3utuOlUebXwM8v4ntebojF7Pjx7S7yni5Iz7f/pjH7rM8AE0f9OmFF3a63Guy
         KWnQNbnBg52m6N2buu/qSIjArSrfYvqMP9Vyb8tQ3lA8FIvLQ4jUyVLtwOin0HSeRhfn
         mN6H9Tvcz5araIWPQeERtt6QIQutYdcLFESUmekTB2OrU2KHqCP6yuTxUjNMMk20JN61
         uKdw==
X-Gm-Message-State: AFuF++mfqcvTmdQq8gBC1LNfxZeYet/YyXaxRRIc1792Jwj33V0EuKbG
	SSKQ+w56Wz29cFqqpTmZ3+mwcBcgDq4+Dpec9mqWTgSIjkzdHMvdQrApRxR+pkpWLt8U/S7jZUf
	KRT+0
X-Gm-Gg: AYBFou08p6pSAxnFCsuu7tslYVpYsp+WJQGQZMcaF1Ai9YIS31O3Rx3jtJcQHc0Zo7h
	36Z7tkSa1cT83pDw2+pMR+UcgNTwhtoAW9DDJ83XW9CVpfLIVltoM2mwHKXVP05uGg3LmpLO8wT
	oPNT8/FEJumy6zFciXwhsNn02ndeHMkeVQldzMY3RlaZxXY+X/xpFku8/NgecwlyFbqtadu1V3L
	TlFhT6fwQgRCsJDIQruDxiujbCN4x3K59YtkYRUSDNi1v0LBFY1+vvVQUV8+bN3TIBiS1C/yHND
	To9nAgeAKVzjMUy/lIknVlq1Kzbkvm+r6fuFACBCP5Snk/fxERBjX5wvqmtyc85JAP6NlSQwKs9
	9M4S9w1ZIy6m8ASBeOFZRlONVLxozKZ6qYv2/1b4MF2EBNPfuNLaZ9whnltnQWqRHHeFxDG5LYf
	gNwk3p5EWVBsk7OThxAVp8nSeaYsttewAZhpA2hyEJYxGqeDtGwrQe4ry2hrkMJNLM3B1O+0qVh
	JYpktt0qKVyl//6cuQGm/lrx68OLGftjT6sfc18Qg==
X-Received: by 2002:a05:6820:618:b0:6dc:e1c3:b2d7 with SMTP id 006d021491bc7-6e7a912501emr3117357eaf.73.1791403190148;
        Wed, 07 Oct 2026 12:59:50 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:49 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 8/9] tools/net/sunrpc: add svc-classify, a prefix classifier and its loader
Date: Wed,  7 Oct 2026 15:59:33 -0400
Message-ID: <158d8194fc5ce6d1fb8fdd1196f53de7d3651d36.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

An administrator who wants RPC service transports dispatched per client
needs a classifier attached in the service's network namespace and a
way to fill its map.  Add svc-classify: the prefix classifier from the
BPF selftests, with its own type definitions in place of vmlinux.h,
embedded in a loader as a skeleton so the binary stands alone.  load
attaches it and pins the link and the map, replace swaps the program
and keeps the map, unload detaches; add, del and list manage the map
with address prefixes and class words written as N, N+addr or addr;
status shows the link.  The Makefile builds the in-tree libbpf and
bpftool it needs.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 tools/net/sunrpc/svc-classify/.gitignore      |   1 +
 tools/net/sunrpc/svc-classify/Makefile        |  65 ++++
 tools/net/sunrpc/svc-classify/svc-classify.c  | 357 ++++++++++++++++++
 .../sunrpc/svc-classify/svc_classify.bpf.c    |  83 ++++
 4 files changed, 506 insertions(+)
 create mode 100644 tools/net/sunrpc/svc-classify/.gitignore
 create mode 100644 tools/net/sunrpc/svc-classify/Makefile
 create mode 100644 tools/net/sunrpc/svc-classify/svc-classify.c
 create mode 100644 tools/net/sunrpc/svc-classify/svc_classify.bpf.c

diff --git a/tools/net/sunrpc/svc-classify/.gitignore b/tools/net/sunrpc/svc-classify/.gitignore
new file mode 100644
index 000000000000..567609b1234a
--- /dev/null
+++ b/tools/net/sunrpc/svc-classify/.gitignore
@@ -0,0 +1 @@
+build/
diff --git a/tools/net/sunrpc/svc-classify/Makefile b/tools/net/sunrpc/svc-classify/Makefile
new file mode 100644
index 000000000000..9d86bc88417b
--- /dev/null
+++ b/tools/net/sunrpc/svc-classify/Makefile
@@ -0,0 +1,65 @@
+# SPDX-License-Identifier: GPL-2.0
+OUTPUT ?= $(CURDIR)/build/
+override OUTPUT := $(abspath $(OUTPUT))/
+$(shell mkdir -p $(OUTPUT))
+
+include ../../../build/Build.include
+include ../../../scripts/Makefile.arch
+include ../../../scripts/Makefile.include
+
+TOOLSDIR := $(abspath ../../..)
+BPFDIR := $(TOOLSDIR)/lib/bpf
+BPFTOOLDIR := $(TOOLSDIR)/bpf/bpftool
+APIDIR := $(TOOLSDIR)/include/uapi
+INCLUDE_DIR := $(OUTPUT)include
+BPFOBJ := $(OUTPUT)libbpf/libbpf.a
+DEFAULT_BPFTOOL := $(OUTPUT)sbin/bpftool
+BPFTOOL ?= $(DEFAULT_BPFTOOL)
+CLANG ?= clang
+msg = $(if $(Q),@printf '  %-8s %s\n' "$(1)" "$(3)";)
+
+prefix ?= /usr/local
+sbindir ?= $(prefix)/sbin
+INSTALL ?= install
+
+CFLAGS += -g -O2 -Wall -I$(INCLUDE_DIR) -I$(OUTPUT)
+LDLIBS += -lelf -lz
+BPF_CFLAGS := -g -O2 -target bpf -D__TARGET_ARCH_$(SRCARCH) \
+	      -I$(INCLUDE_DIR) -I$(APIDIR) -Wall
+
+all: $(OUTPUT)svc-classify
+
+$(OUTPUT)libbpf $(OUTPUT)bpftool:
+	$(Q)mkdir -p $@
+
+$(BPFOBJ): $(wildcard $(BPFDIR)/*.[ch] $(BPFDIR)/Makefile) | $(OUTPUT)libbpf
+	$(Q)$(MAKE) $(submake_extras) -C $(BPFDIR) OUTPUT=$(OUTPUT)libbpf/ \
+		    DESTDIR=$(OUTPUT) prefix= all install_headers
+
+$(DEFAULT_BPFTOOL): $(wildcard $(BPFTOOLDIR)/*.[ch] $(BPFTOOLDIR)/Makefile) \
+		    $(BPFOBJ) | $(OUTPUT)bpftool
+	$(Q)$(MAKE) $(submake_extras) -C $(BPFTOOLDIR) OUTPUT=$(OUTPUT)bpftool/ \
+		    LIBBPF_OUTPUT=$(OUTPUT)libbpf/ LIBBPF_DESTDIR=$(OUTPUT) \
+		    prefix= DESTDIR=$(OUTPUT) install-bin
+
+$(OUTPUT)svc_classify.bpf.o: svc_classify.bpf.c $(BPFOBJ)
+	$(call msg,CLNG-BPF,,$(notdir $@))
+	$(Q)$(CLANG) $(BPF_CFLAGS) -c $< -o $@
+
+$(OUTPUT)svc_classify.skel.h: $(OUTPUT)svc_classify.bpf.o $(BPFTOOL)
+	$(call msg,GEN-SKEL,,$(notdir $@))
+	$(Q)$(BPFTOOL) gen skeleton $< name svc_classify > $@
+
+$(OUTPUT)svc-classify: svc-classify.c $(OUTPUT)svc_classify.skel.h $(BPFOBJ)
+	$(call msg,CC,,$(notdir $@))
+	$(Q)$(CC) $(CFLAGS) -o $@ $< $(BPFOBJ) $(LDLIBS)
+
+install: $(OUTPUT)svc-classify
+	$(Q)$(INSTALL) -d $(DESTDIR)$(sbindir)
+	$(Q)$(INSTALL) -m 755 $(OUTPUT)svc-classify $(DESTDIR)$(sbindir)/
+
+clean:
+	$(Q)rm -rf $(OUTPUT)
+
+.PHONY: all install clean
+.DELETE_ON_ERROR:
diff --git a/tools/net/sunrpc/svc-classify/svc-classify.c b/tools/net/sunrpc/svc-classify/svc-classify.c
new file mode 100644
index 000000000000..f722b891be2c
--- /dev/null
+++ b/tools/net/sunrpc/svc-classify/svc-classify.c
@@ -0,0 +1,357 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * svc-classify - attach the prefix classifier to the RPC services of this
+ * network namespace and manage its prefix map.
+ *
+ *   svc-classify [-p DIR] load             attach; pin the link and the map
+ *   svc-classify [-p DIR] replace          replace the program, keep the map
+ *   svc-classify [-p DIR] unload           detach
+ *   svc-classify [-p DIR] add PREFIX CLASS
+ *   svc-classify [-p DIR] del PREFIX
+ *   svc-classify [-p DIR] list
+ *   svc-classify [-p DIR] status
+ *
+ * PREFIX is a.b.c.d[/len], x:y::z[/len], any, any4 or any6.  CLASS is N
+ * (one client for every peer that matches), N+addr (one client per peer
+ * address within class N), addr (the same as 0+addr) or 0 (the anonymous
+ * client).  DIR, where the link and the map are pinned, defaults to
+ * /sys/fs/bpf/svc_classify.
+ */
+#include <arpa/inet.h>
+#include <errno.h>
+#include <limits.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+#include <bpf/bpf.h>
+#include <bpf/libbpf.h>
+
+#include "svc_classify.skel.h"
+
+#define PIN_DIR_DEFAULT	"/sys/fs/bpf/svc_classify"
+#define SVC_CLASS_PER_ADDR	(1U << 31)
+
+struct prefix_key {
+	__u32 prefixlen;
+	__u8 family;
+	__u8 addr[16];
+};
+
+static const char *progname;
+static char pin_link[PATH_MAX], pin_map[PATH_MAX];
+static const char *pin_dir = PIN_DIR_DEFAULT;
+
+static void usage(void)
+{
+	fprintf(stderr,
+		"usage: %s [-p DIR] load | replace | unload | list | status |\n"
+		"       add PREFIX CLASS | del PREFIX\n"
+		"PREFIX: a.b.c.d[/len], x:y::z[/len], any, any4, any6\n"
+		"CLASS:  N, N+addr, addr, 0\n", progname);
+	exit(2);
+}
+
+static int do_load(void)
+{
+	struct svc_classify *skel;
+	struct bpf_link *link;
+	int err;
+
+	if (access(pin_link, F_OK) == 0) {
+		fprintf(stderr, "%s: already loaded (%s exists)\n", progname,
+			pin_link);
+		return 1;
+	}
+	mkdir(pin_dir, 0700);
+
+	skel = svc_classify__open_and_load();
+	if (!skel) {
+		fprintf(stderr, "%s: load: %s\n", progname, strerror(errno));
+		rmdir(pin_dir);
+		return 1;
+	}
+	link = bpf_map__attach_struct_ops(skel->maps.prefix);
+	if (!link) {
+		fprintf(stderr, "%s: attach: %s\n", progname, strerror(errno));
+		rmdir(pin_dir);
+		return 1;
+	}
+	err = bpf_link__pin(link, pin_link);
+	if (!err)
+		err = bpf_map__pin(skel->maps.prefixes, pin_map);
+	if (err) {
+		fprintf(stderr, "%s: pin: %s\n", progname, strerror(-err));
+		bpf_link__destroy(link);
+		unlink(pin_link);
+		rmdir(pin_dir);
+		return 1;
+	}
+	return 0;
+}
+
+static int do_replace(void)
+{
+	struct svc_classify *skel;
+	struct bpf_link *link;
+	int link_fd, err;
+
+	link_fd = bpf_obj_get(pin_link);
+	if (link_fd < 0) {
+		fprintf(stderr, "%s: not loaded (%s)\n", progname,
+			strerror(errno));
+		return 1;
+	}
+	skel = svc_classify__open();
+	if (!skel) {
+		fprintf(stderr, "%s: open: %s\n", progname, strerror(errno));
+		return 1;
+	}
+	/*
+	 * Reuse the pinned map so the entries survive.  A build whose map
+	 * definition differs fails here; unload and load then.
+	 */
+	err = bpf_map__set_pin_path(skel->maps.prefixes, pin_map);
+	if (!err)
+		err = svc_classify__load(skel);
+	if (err) {
+		fprintf(stderr, "%s: load: %s\n", progname, strerror(-err));
+		return 1;
+	}
+	/*
+	 * bpf_link__update_map() wants the link that attached the map, not
+	 * one reopened from a pin.  bpf_map__attach_struct_ops() writes the
+	 * program into the new map's value before it tries to create a link,
+	 * and the link is refused with EBUSY while the old one is attached;
+	 * the written map is what the link update needs.
+	 */
+	link = bpf_map__attach_struct_ops(skel->maps.prefix);
+	if (link) {
+		bpf_link__destroy(link);
+		fprintf(stderr, "%s: nothing attached in this namespace; unload and load\n",
+			progname);
+		return 1;
+	}
+	if (errno != EBUSY) {
+		fprintf(stderr, "%s: attach: %s\n", progname, strerror(errno));
+		return 1;
+	}
+	err = bpf_link_update(link_fd, bpf_map__fd(skel->maps.prefix), NULL);
+	if (err) {
+		fprintf(stderr, "%s: replace: %s\n", progname, strerror(errno));
+		return 1;
+	}
+	return 0;
+}
+
+static int do_unload(void)
+{
+	int ret = 0;
+
+	if (unlink(pin_link) && errno != ENOENT) {
+		perror(pin_link);
+		ret = 1;
+	}
+	if (unlink(pin_map) && errno != ENOENT) {
+		perror(pin_map);
+		ret = 1;
+	}
+	rmdir(pin_dir);
+	return ret;
+}
+
+static int parse_prefix(const char *s, struct prefix_key *key)
+{
+	char buf[64], *slash;
+	int bits, max;
+
+	memset(key, 0, sizeof(*key));
+	if (!strcmp(s, "any"))
+		return 0;
+	if (!strcmp(s, "any4")) {
+		key->family = AF_INET;
+		key->prefixlen = 8;
+		return 0;
+	}
+	if (!strcmp(s, "any6")) {
+		key->family = AF_INET6;
+		key->prefixlen = 8;
+		return 0;
+	}
+	if (strlen(s) >= sizeof(buf))
+		return -1;
+	strcpy(buf, s);
+	slash = strchr(buf, '/');
+	if (slash)
+		*slash++ = '\0';
+	if (inet_pton(AF_INET, buf, key->addr) == 1) {
+		key->family = AF_INET;
+		max = 32;
+	} else if (inet_pton(AF_INET6, buf, key->addr) == 1) {
+		key->family = AF_INET6;
+		max = 128;
+	} else {
+		return -1;
+	}
+	bits = max;
+	if (slash) {
+		char *end;
+
+		if (*slash < '0' || *slash > '9')
+			return -1;
+		bits = strtoul(slash, &end, 10);
+		if (*end || bits > max)
+			return -1;
+	}
+	key->prefixlen = 8 + bits;
+	return 0;
+}
+
+static int parse_class(const char *s, __u32 *class)
+{
+	unsigned long n;
+	char *end;
+
+	if (!strcmp(s, "addr")) {
+		*class = SVC_CLASS_PER_ADDR;
+		return 0;
+	}
+	n = strtoul(s, &end, 0);
+	if (end == s || n >= SVC_CLASS_PER_ADDR)
+		return -1;
+	*class = n;
+	if (!strcmp(end, "+addr"))
+		*class |= SVC_CLASS_PER_ADDR;
+	else if (*end)
+		return -1;
+	return 0;
+}
+
+static void print_entry(const struct prefix_key *key, __u32 class)
+{
+	char addr[INET6_ADDRSTRLEN];
+
+	if (key->prefixlen == 0)
+		printf("any");
+	else if (key->prefixlen == 8)
+		printf("any%d", key->family == AF_INET ? 4 : 6);
+	else
+		printf("%s/%u", inet_ntop(key->family, key->addr, addr,
+					  sizeof(addr)), key->prefixlen - 8);
+	printf(" -> %u%s\n", class & ~SVC_CLASS_PER_ADDR,
+	       class & SVC_CLASS_PER_ADDR ? "+addr" : "");
+}
+
+static int open_map(void)
+{
+	int fd = bpf_obj_get(pin_map);
+
+	if (fd < 0) {
+		fprintf(stderr, "%s: not loaded (%s: %s)\n", progname, pin_map,
+			strerror(errno));
+		exit(1);
+	}
+	return fd;
+}
+
+static int do_add(const char *prefix, const char *cls)
+{
+	struct prefix_key key;
+	__u32 class;
+
+	if (parse_prefix(prefix, &key) || parse_class(cls, &class))
+		usage();
+	if (bpf_map_update_elem(open_map(), &key, &class, BPF_ANY)) {
+		fprintf(stderr, "%s: add: %s\n", progname, strerror(errno));
+		return 1;
+	}
+	return 0;
+}
+
+static int do_del(const char *prefix)
+{
+	struct prefix_key key;
+
+	if (parse_prefix(prefix, &key))
+		usage();
+	if (bpf_map_delete_elem(open_map(), &key)) {
+		fprintf(stderr, "%s: del: %s\n", progname, strerror(errno));
+		return 1;
+	}
+	return 0;
+}
+
+static int do_list(void)
+{
+	struct prefix_key key, next;
+	__u32 class;
+	int fd;
+
+	fd = open_map();
+	if (bpf_map_get_next_key(fd, NULL, &next))
+		return 0;
+	do {
+		key = next;
+		if (!bpf_map_lookup_elem(fd, &key, &class))
+			print_entry(&key, class);
+	} while (!bpf_map_get_next_key(fd, &key, &next));
+	return 0;
+}
+
+static int do_status(void)
+{
+	struct bpf_link_info info = {};
+	__u32 len = sizeof(info);
+	int fd;
+
+	fd = bpf_obj_get(pin_link);
+	if (fd < 0) {
+		printf("not loaded\n");
+		return 1;
+	}
+	if (bpf_link_get_info_by_fd(fd, &info, &len))
+		printf("loaded\n");
+	else
+		printf("loaded, link id %u, struct_ops map id %u\n", info.id,
+		       info.struct_ops.map_id);
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	const char *cmd;
+	int opt;
+
+	progname = argv[0];
+	while ((opt = getopt(argc, argv, "p:")) != -1) {
+		if (opt != 'p')
+			usage();
+		pin_dir = optarg;
+	}
+	argc -= optind;
+	argv += optind;
+	if (argc < 1)
+		usage();
+	cmd = argv[0];
+	snprintf(pin_link, sizeof(pin_link), "%s/link", pin_dir);
+	snprintf(pin_map, sizeof(pin_map), "%s/prefixes", pin_dir);
+
+	if (!strcmp(cmd, "load") && argc == 1)
+		return do_load();
+	if (!strcmp(cmd, "replace") && argc == 1)
+		return do_replace();
+	if (!strcmp(cmd, "unload") && argc == 1)
+		return do_unload();
+	if (!strcmp(cmd, "add") && argc == 3)
+		return do_add(argv[1], argv[2]);
+	if (!strcmp(cmd, "del") && argc == 2)
+		return do_del(argv[1]);
+	if (!strcmp(cmd, "list") && argc == 1)
+		return do_list();
+	if (!strcmp(cmd, "status") && argc == 1)
+		return do_status();
+	usage();
+	return 2;
+}
diff --git a/tools/net/sunrpc/svc-classify/svc_classify.bpf.c b/tools/net/sunrpc/svc-classify/svc_classify.bpf.c
new file mode 100644
index 000000000000..3d012f102ec3
--- /dev/null
+++ b/tools/net/sunrpc/svc-classify/svc_classify.bpf.c
@@ -0,0 +1,83 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A svc_classifier for RPC service transports: the peer address is looked
+ * up in an LPM trie keyed by {family, address}; a hit returns the class
+ * word stored there, a miss returns 0, the anonymous client.  A key of
+ * prefixlen 0 is the default for every family, 8 the default for one.
+ */
+#include <linux/types.h>
+#include <linux/bpf.h>
+#include <bpf/bpf_helpers.h>
+#include <bpf/bpf_tracing.h>
+#include <bpf/bpf_core_read.h>
+
+char _license[] SEC("license") = "GPL";
+
+#define AF_INET			2
+#define AF_INET6		10
+
+#define SVC_CLASSIFIER_NAME_MAX	16
+
+struct sockaddr_storage___local {
+	unsigned short ss_family;
+	char __data[126];
+};
+
+struct svc_xprt___local {
+	struct sockaddr_storage___local xpt_remote;
+} __attribute__((preserve_access_index));
+
+struct svc_classifier___local {
+	char name[SVC_CLASSIFIER_NAME_MAX];
+	__u32 (*classify)(const struct svc_xprt___local *xprt);
+};
+
+struct prefix_key {
+	__u32 prefixlen;	/* 8 (the family byte) + address bits */
+	__u8 family;
+	__u8 addr[16];
+};
+
+struct {
+	__uint(type, BPF_MAP_TYPE_LPM_TRIE);
+	__type(key, struct prefix_key);
+	__type(value, __u32);
+	__uint(max_entries, 1024);
+	__uint(map_flags, BPF_F_NO_PREALLOC);
+} prefixes SEC(".maps");
+
+SEC("struct_ops/classify")
+__u32 BPF_PROG(prefix_classify, const struct svc_xprt___local *xprt)
+{
+	struct sockaddr_storage___local ss;
+	struct prefix_key key = {};
+	__u32 *class;
+
+	if (bpf_core_read(&ss, sizeof(ss), &xprt->xpt_remote))
+		return 0;
+
+	key.family = ss.ss_family;
+	switch (ss.ss_family) {
+	case AF_INET:
+		/* struct sockaddr_in: port at 2, address at 4 */
+		__builtin_memcpy(key.addr, &ss.__data[2], 4);
+		key.prefixlen = 8 + 32;
+		break;
+	case AF_INET6:
+		/* struct sockaddr_in6: port at 2, flowinfo at 4, address at 8 */
+		__builtin_memcpy(key.addr, &ss.__data[6], 16);
+		key.prefixlen = 8 + 128;
+		break;
+	default:
+		return 0;
+	}
+
+	class = bpf_map_lookup_elem(&prefixes, &key);
+	return class ? *class : 0;
+}
+
+SEC(".struct_ops.link")
+struct svc_classifier___local prefix = {
+	.name		= "prefix",
+	.classify	= (void *)prefix_classify,
+};
-- 
2.53.0

