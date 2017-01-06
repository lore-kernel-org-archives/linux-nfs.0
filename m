Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:42111 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762468AbdAFJof (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2017 04:44:35 -0500
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
Subject: [PATCH v2 3/7] nios2: put setup.h in uapi
Date: Fri,  6 Jan 2017 10:43:55 +0100
Message-Id: <1483695839-18660-4-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This header file is exported, thus move it to uapi.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/nios2/include/asm/setup.h      | 2 +-
 arch/nios2/include/uapi/asm/setup.h | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)
 create mode 100644 arch/nios2/include/uapi/asm/setup.h

diff --git a/arch/nios2/include/asm/setup.h b/arch/nios2/include/asm/setup.h
index dcbf8cf1a344..d49e9e91bf55 100644
--- a/arch/nios2/include/asm/setup.h
+++ b/arch/nios2/include/asm/setup.h
@@ -19,7 +19,7 @@
 #ifndef _ASM_NIOS2_SETUP_H
 #define _ASM_NIOS2_SETUP_H
 
-#include <asm-generic/setup.h>
+#include <uapi/asm/setup.h>
 
 #ifndef __ASSEMBLY__
 #ifdef __KERNEL__
diff --git a/arch/nios2/include/uapi/asm/setup.h b/arch/nios2/include/uapi/asm/setup.h
new file mode 100644
index 000000000000..8d8285997ba8
--- /dev/null
+++ b/arch/nios2/include/uapi/asm/setup.h
@@ -0,0 +1,6 @@
+#ifndef _UAPI_ASM_NIOS2_SETUP_H
+#define _UAPI_ASM_NIOS2_SETUP_H
+
+#include <asm-generic/setup.h>
+
+#endif /* _UAPI_ASM_NIOS2_SETUP_H */
-- 
2.8.1

