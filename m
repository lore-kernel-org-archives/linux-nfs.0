Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48733 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751520AbdAMKrY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 05:47:24 -0500
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: arnd@arndb.de
Cc: mmarek@suse.com, linux-kbuild@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org,
        adi-buildroot-devel@lists.sourceforge.net,
        linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com,
        uclinux-h8-devel@lists.sourceforge.jp,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org,
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
Subject: [PATCH v3 3/8] nios2: put setup.h in uapi
Date: Fri, 13 Jan 2017 11:46:41 +0100
Message-Id: <1484304406-10820-4-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
References: <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This header file is exported, but from a userland pov, it's just a wrapper
to asm-generic/setup.h.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/nios2/include/uapi/asm/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/nios2/include/uapi/asm/Kbuild b/arch/nios2/include/uapi/asm/Kbuild
index e0bb972a50d7..69c965304146 100644
--- a/arch/nios2/include/uapi/asm/Kbuild
+++ b/arch/nios2/include/uapi/asm/Kbuild
@@ -2,4 +2,5 @@ include include/uapi/asm-generic/Kbuild.asm
 
 header-y += elf.h
 
+generic-y += setup.h
 generic-y += ucontext.h
-- 
2.8.1

