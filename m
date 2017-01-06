Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:42186 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933971AbdAFJox (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2017 04:44:53 -0500
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
        airlied@linux.ie, davem@davemloft.net,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 6/7] Makefile.headersinst: remove destination-y option
Date: Fri,  6 Jan 2017 10:43:58 +0100
Message-Id: <1483695839-18660-7-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This option was added in commit c7bb349e7c25 ("kbuild: introduce destination-y
for exported headers") but never used in-tree.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/kbuild/makefiles.txt | 23 ++++-------------------
 scripts/Makefile.headersinst       |  2 +-
 2 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 9b9c4797fc55..37b525d329ae 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -46,9 +46,8 @@ This document describes the Linux kernel Makefiles.
 	=== 7 Kbuild syntax for exported headers
 		--- 7.1 header-y
 		--- 7.2 genhdr-y
-		--- 7.3 destination-y
-		--- 7.4 generic-y
-		--- 7.5 generated-y
+		--- 7.3 generic-y
+		--- 7.4 generated-y
 
 	=== 8 Kbuild Variables
 	=== 9 Makefile language
@@ -1295,21 +1294,7 @@ See subsequent chapter for the syntax of the Kbuild file.
 			#include/linux/Kbuild
 			genhdr-y += version.h
 
-	--- 7.3 destination-y
-
-	When an architecture has a set of exported headers that needs to be
-	exported to a different directory destination-y is used.
-	destination-y specifies the destination directory for all exported
-	headers in the file where it is present.
-
-		Example:
-			#arch/xtensa/platforms/s6105/include/platform/Kbuild
-			destination-y := include/linux
-
-	In the example above all exported headers in the Kbuild file
-	will be located in the directory "include/linux" when exported.
-
-	--- 7.4 generic-y
+	--- 7.3 generic-y
 
 	If an architecture uses a verbatim copy of a header from
 	include/asm-generic then this is listed in the file
@@ -1336,7 +1321,7 @@ See subsequent chapter for the syntax of the Kbuild file.
 		Example: termios.h
 			#include <asm-generic/termios.h>
 
-	--- 7.5 generated-y
+	--- 7.4 generated-y
 
 	If an architecture generates other header files alongside generic-y
 	wrappers, and not included in genhdr-y, then generated-y specifies
diff --git a/scripts/Makefile.headersinst b/scripts/Makefile.headersinst
index 3e20d03432d2..876b42cfede4 100644
--- a/scripts/Makefile.headersinst
+++ b/scripts/Makefile.headersinst
@@ -14,7 +14,7 @@ kbuild-file := $(srctree)/$(obj)/Kbuild
 include $(kbuild-file)
 
 # called may set destination dir (when installing to asm/)
-_dst := $(if $(destination-y),$(destination-y),$(if $(dst),$(dst),$(obj)))
+_dst := $(if $(dst),$(dst),$(obj))
 
 old-kbuild-file := $(srctree)/$(subst uapi/,,$(obj))/Kbuild
 ifneq ($(wildcard $(old-kbuild-file)),)
-- 
2.8.1

