Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48713 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdAMKr1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 05:47:27 -0500
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
        hch@infradead.org
Subject: [PATCH v3 0/8] uapi: export all headers under uapi directories
Date: Fri, 13 Jan 2017 11:46:38 +0100
Message-Id: <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <3131144.4Ej3KFWRbz@wuerfel>
References: <3131144.4Ej3KFWRbz@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is the v3 of this series. The first 5 patches are just cleanup: some
exported headers were still under a non-uapi directory or (x86 case) were
wrongly exported.
The patch 6 was spotted by code review: there is no in-tree user of this
functionality.
Patches 7 and 8 remove the need to list explicitly headers. Now all files
under an uapi directory are exported.

This series has been tested with a 'make headers_install' on x86 and a
'make headers_install_all'. I've checked the result of both commands.

This patch is built against linus tree. If I must rebase it against the kbuild
tree, just tell me ;-)

v2 -> v3:
 - patch #1: remove arch/arm/include/asm/types.h
 - patch #2: remove arch/h8300/include/asm/bitsperlong.h
 - patch #3: remove arch/nios2/include/uapi/asm/setup.h
 - patch #4: don't export msr-index.h
 - patch #5: fix a typo: s/unput-files3-name/input-files3-name
 - patch #6: no change
 - patch #7: fix include/uapi/asm-generic/Kbuild.asm by introducing mandatory-y
 - add patch #8

v1 -> v2:
 - add patch #1 to #6
 - patch #7: remove use of header-y

Comments are welcomed,
Nicolas
