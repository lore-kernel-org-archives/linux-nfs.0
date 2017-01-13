Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48727 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751551AbdAMKr2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 05:47:28 -0500
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: arnd@arndb.de
Cc: mmarek@suse.com, linux-kbuild@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org,
        adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org,
        linux-cris-kernel@axis.com, uclinux-h8-devel@lists.sourceforge.jp,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-m68k@vger.kernel.org, linux-metag@vger.kernel.org,
        linux-mips@linux-mips.org, linux-am33-list@redhat.com,
        nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org,
        linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org,
        linux-arch@vger.kernel.org, dri-devel@lists.freedesktop.org,
        netdev@vger.kernel.org, linux-media@vger.kernel.org,
        linux-mmc@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org, linux-spi@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-rdma@vger.kernel.org,
        fcoe-devel@open-fcoe.org, alsa-devel@alsa-project.org,
        linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        airlied@linux.ie, davem@davemloft.net, linux@armlinux.org.uk,
        bp@alien8.de, slash.tmp@free.fr, daniel.vetter@ffwll.ch,
        rmk+kernel@armlinux.org.uk, msalter@redhat.com, jengelh@inai.de,
        hch@infradead.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v3 8/8] uapi: export all arch specifics directories
Date: Fri, 13 Jan 2017 11:46:46 +0100
Message-Id: <1484304406-10820-9-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
References: <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch removes the need of subdir-y. Now all files/directories under
arch/<arch>/include/uapi/ are exported.

The only change for userland is the layout of the command 'make
headers_install_all': directories asm-<arch> are replaced by arch-<arch>/.
Those new directories contains all files/directories of the specified arch.

Note that only cris and tile have more directories than only asm:
 - arch-v[10|32] for cris;
 - arch for tile.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/kbuild/makefiles.txt | 15 +--------------
 Makefile                           |  4 ++--
 arch/cris/include/uapi/asm/Kbuild  |  3 ---
 arch/tile/include/uapi/asm/Kbuild  |  2 --
 scripts/Makefile.headersinst       |  3 +--
 5 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 51c072049e45..87a3d7d86776 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -48,7 +48,6 @@ This document describes the Linux kernel Makefiles.
 		--- 7.2 genhdr-y
 		--- 7.3 generic-y
 		--- 7.4 generated-y
-		--- 7.5 subdir-y
 
 	=== 8 Kbuild Variables
 	=== 9 Makefile language
@@ -1264,7 +1263,7 @@ The pre-processing does:
 - drop all sections that are kernel internal (guarded by ifdef __KERNEL__)
 
 All headers under include/uapi/, include/generated/uapi/,
-arch/<arch>/include/uapi/asm/ and arch/<arch>/include/generated/uapi/asm/
+arch/<arch>/include/uapi/ and arch/<arch>/include/generated/uapi/
 are exported.
 
 A Kbuild file may be defined under arch/<arch>/include/uapi/asm/ and
@@ -1331,18 +1330,6 @@ See subsequent chapter for the syntax of the Kbuild file.
 			#arch/x86/include/asm/Kbuild
 			generated-y += syscalls_32.h
 
-	--- 7.5 subdir-y
-
-	subdir-y may be used to specify a subdirectory to be exported.
-
-		Example:
-			#arch/cris/include/uapi/asm/Kbuild
-			subdir-y += ../arch-v10/arch/
-			subdir-y += ../arch-v32/arch/
-
-	The convention is to list one subdir per line and
-	preferably in alphabetic order.
-
 === 8 Kbuild Variables
 
 The top Makefile exports the following variables:
diff --git a/Makefile b/Makefile
index 5f1a84735ff6..a35098157b69 100644
--- a/Makefile
+++ b/Makefile
@@ -1126,7 +1126,7 @@ firmware_install:
 export INSTALL_HDR_PATH = $(objtree)/usr
 
 # If we do an all arch process set dst to asm-$(hdr-arch)
-hdr-dst = $(if $(KBUILD_HEADERS), dst=include/asm-$(hdr-arch), dst=include/asm)
+hdr-dst = $(if $(KBUILD_HEADERS), dst=include/arch-$(hdr-arch), dst=include)
 
 PHONY += archheaders
 archheaders:
@@ -1147,7 +1147,7 @@ headers_install: __headers
 	$(if $(wildcard $(srctree)/arch/$(hdr-arch)/include/uapi/asm/Kbuild),, \
 	  $(error Headers not exportable for the $(SRCARCH) architecture))
 	$(Q)$(MAKE) $(hdr-inst)=include/uapi
-	$(Q)$(MAKE) $(hdr-inst)=arch/$(hdr-arch)/include/uapi/asm $(hdr-dst)
+	$(Q)$(MAKE) $(hdr-inst)=arch/$(hdr-arch)/include/uapi $(hdr-dst)
 
 PHONY += headers_check_all
 headers_check_all: headers_install_all
diff --git a/arch/cris/include/uapi/asm/Kbuild b/arch/cris/include/uapi/asm/Kbuild
index d0c5471856e0..b15bf6bc0e94 100644
--- a/arch/cris/include/uapi/asm/Kbuild
+++ b/arch/cris/include/uapi/asm/Kbuild
@@ -1,5 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-subdir-y += ../arch-v10/arch/
-subdir-y += ../arch-v32/arch/
diff --git a/arch/tile/include/uapi/asm/Kbuild b/arch/tile/include/uapi/asm/Kbuild
index e0a50111e07f..0c74c3c5ebfa 100644
--- a/arch/tile/include/uapi/asm/Kbuild
+++ b/arch/tile/include/uapi/asm/Kbuild
@@ -2,5 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += ucontext.h
-
-subdir-y += ../arch
diff --git a/scripts/Makefile.headersinst b/scripts/Makefile.headersinst
index 16ac3e71050e..cafaca2d9a23 100644
--- a/scripts/Makefile.headersinst
+++ b/scripts/Makefile.headersinst
@@ -2,7 +2,7 @@
 # Installing headers
 #
 # All headers under include/uapi, include/generated/uapi,
-# arch/<arch>/include/uapi/asm and arch/<arch>/include/generated/uapi/asm are
+# arch/<arch>/include/uapi and arch/<arch>/include/generated/uapi are
 # exported.
 # They are preprocessed to remove __KERNEL__ section of the file.
 #
@@ -28,7 +28,6 @@ include scripts/Kbuild.include
 installdir    := $(INSTALL_HDR_PATH)/$(subst uapi/,,$(_dst))
 
 subdirs       := $(patsubst $(srctree)/$(obj)/%/.,%,$(wildcard $(srctree)/$(obj)/*/.))
-subdirs       += $(subdir-y)
 header-files  := $(notdir $(wildcard $(srctree)/$(obj)/*.h))
 header-files  += $(notdir $(wildcard $(srctree)/$(obj)/*.agh))
 genhdr-files  := $(notdir $(wildcard $(srctree)/$(gen)/*.h))
-- 
2.8.1

