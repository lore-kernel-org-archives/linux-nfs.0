Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:42185 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757236AbdAFJot (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2017 04:44:49 -0500
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
Subject: [PATCH v2 7/7] uapi: export all headers under uapi directories
Date: Fri,  6 Jan 2017 10:43:59 +0100
Message-Id: <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Regularly, when a new header is created in include/uapi/, the developer
forgets to add it in the corresponding Kbuild file. This error is usually
detected after the release is out.

In fact, all headers under uapi directories should be exported, thus it's
useless to have an exhaustive list.

After this patch, the following files, which were not exported, are now
exported (with make headers_install_all):
asm-unicore32/shmparam.h
asm-unicore32/ucontext.h
asm-hexagon/shmparam.h
asm-mips/ucontext.h
asm-mips/hwcap.h
asm-mips/reg.h
drm/vgem_drm.h
drm/armada_drm.h
drm/omap_drm.h
drm/etnaviv_drm.h
asm-tile/shmparam.h
asm-blackfin/shmparam.h
asm-blackfin/ucontext.h
asm-powerpc/perf_regs.h
rdma/qedr-abi.h
asm-parisc/kvm_para.h
asm-openrisc/shmparam.h
asm-nios2/kvm_para.h
asm-nios2/ucontext.h
asm-sh/kvm_para.h
asm-sh/ucontext.h
asm-xtensa/kvm_para.h
asm-avr32/kvm_para.h
asm-m32r/kvm_para.h
asm-h8300/shmparam.h
asm-h8300/ucontext.h
asm-metag/kvm_para.h
asm-metag/shmparam.h
asm-metag/ucontext.h
asm-m68k/kvm_para.h
asm-m68k/shmparam.h
linux/bcache.h
linux/kvm.h
linux/kvm_para.h
linux/kfd_ioctl.h
linux/cryptouser.h
linux/kcm.h
linux/kcov.h
linux/seg6_iptunnel.h
linux/stm.h
linux/genwqe
linux/genwqe/.install
linux/genwqe/genwqe_card.h
linux/genwqe/..install.cmd
linux/seg6.h
linux/cifs
linux/cifs/.install
linux/cifs/cifs_mount.h
linux/cifs/..install.cmd
linux/auto_dev-ioctl.h

Thanks to Julien Floret <julien.floret@6wind.com> for the tip to get all
subdirs with a pure makefile command.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/kbuild/makefiles.txt          |  41 ++-
 arch/alpha/include/uapi/asm/Kbuild          |  41 ---
 arch/arc/include/uapi/asm/Kbuild            |   3 -
 arch/arm/include/uapi/asm/Kbuild            |  17 -
 arch/arm64/include/uapi/asm/Kbuild          |  18 --
 arch/avr32/include/uapi/asm/Kbuild          |  20 --
 arch/blackfin/include/uapi/asm/Kbuild       |  17 -
 arch/c6x/include/uapi/asm/Kbuild            |   8 -
 arch/cris/include/uapi/arch-v10/arch/Kbuild |   5 -
 arch/cris/include/uapi/arch-v32/arch/Kbuild |   3 -
 arch/cris/include/uapi/asm/Kbuild           |  43 +--
 arch/frv/include/uapi/asm/Kbuild            |  33 --
 arch/h8300/include/uapi/asm/Kbuild          |  28 --
 arch/hexagon/include/asm/Kbuild             |   3 -
 arch/hexagon/include/uapi/asm/Kbuild        |  13 -
 arch/ia64/include/uapi/asm/Kbuild           |  45 ---
 arch/m32r/include/uapi/asm/Kbuild           |  31 --
 arch/m68k/include/uapi/asm/Kbuild           |  24 --
 arch/metag/include/uapi/asm/Kbuild          |   8 -
 arch/microblaze/include/uapi/asm/Kbuild     |  32 --
 arch/mips/include/uapi/asm/Kbuild           |  37 ---
 arch/mn10300/include/uapi/asm/Kbuild        |  32 --
 arch/nios2/include/uapi/asm/Kbuild          |   4 +-
 arch/openrisc/include/asm/Kbuild            |   3 -
 arch/openrisc/include/uapi/asm/Kbuild       |   8 -
 arch/parisc/include/uapi/asm/Kbuild         |  28 --
 arch/powerpc/include/uapi/asm/Kbuild        |  45 ---
 arch/s390/include/uapi/asm/Kbuild           |  52 ---
 arch/score/include/asm/Kbuild               |   4 -
 arch/score/include/uapi/asm/Kbuild          |  32 --
 arch/sh/include/uapi/asm/Kbuild             |  23 --
 arch/sparc/include/uapi/asm/Kbuild          |  48 ---
 arch/tile/include/asm/Kbuild                |   3 -
 arch/tile/include/uapi/arch/Kbuild          |  17 -
 arch/tile/include/uapi/asm/Kbuild           |  19 +-
 arch/unicore32/include/uapi/asm/Kbuild      |   6 -
 arch/x86/include/uapi/asm/Kbuild            |  59 ----
 arch/xtensa/include/uapi/asm/Kbuild         |  23 --
 include/Kbuild                              |   2 -
 include/asm-generic/Kbuild.asm              |   1 -
 include/scsi/fc/Kbuild                      |   0
 include/uapi/Kbuild                         |  15 -
 include/uapi/asm-generic/Kbuild             |  36 ---
 include/uapi/asm-generic/Kbuild.asm         |  62 ++--
 include/uapi/drm/Kbuild                     |  22 --
 include/uapi/linux/Kbuild                   | 482 ----------------------------
 include/uapi/linux/android/Kbuild           |   2 -
 include/uapi/linux/byteorder/Kbuild         |   3 -
 include/uapi/linux/caif/Kbuild              |   3 -
 include/uapi/linux/can/Kbuild               |   6 -
 include/uapi/linux/dvb/Kbuild               |   9 -
 include/uapi/linux/hdlc/Kbuild              |   2 -
 include/uapi/linux/hsi/Kbuild               |   2 -
 include/uapi/linux/iio/Kbuild               |   3 -
 include/uapi/linux/isdn/Kbuild              |   2 -
 include/uapi/linux/mmc/Kbuild               |   2 -
 include/uapi/linux/netfilter/Kbuild         |  89 -----
 include/uapi/linux/netfilter/ipset/Kbuild   |   5 -
 include/uapi/linux/netfilter_arp/Kbuild     |   3 -
 include/uapi/linux/netfilter_bridge/Kbuild  |  18 --
 include/uapi/linux/netfilter_ipv4/Kbuild    |  10 -
 include/uapi/linux/netfilter_ipv6/Kbuild    |  13 -
 include/uapi/linux/nfsd/Kbuild              |   6 -
 include/uapi/linux/raid/Kbuild              |   3 -
 include/uapi/linux/spi/Kbuild               |   2 -
 include/uapi/linux/sunrpc/Kbuild            |   2 -
 include/uapi/linux/tc_act/Kbuild            |  15 -
 include/uapi/linux/tc_ematch/Kbuild         |   5 -
 include/uapi/linux/usb/Kbuild               |  12 -
 include/uapi/linux/wimax/Kbuild             |   2 -
 include/uapi/misc/Kbuild                    |   2 -
 include/uapi/mtd/Kbuild                     |   6 -
 include/uapi/rdma/Kbuild                    |  18 --
 include/uapi/rdma/hfi/Kbuild                |   2 -
 include/uapi/scsi/Kbuild                    |   6 -
 include/uapi/scsi/fc/Kbuild                 |   5 -
 include/uapi/sound/Kbuild                   |  16 -
 include/uapi/video/Kbuild                   |   4 -
 include/uapi/xen/Kbuild                     |   5 -
 include/video/Kbuild                        |   0
 scripts/Makefile.headersinst                |  39 +--
 81 files changed, 73 insertions(+), 1745 deletions(-)
 delete mode 100644 arch/cris/include/uapi/arch-v10/arch/Kbuild
 delete mode 100644 arch/cris/include/uapi/arch-v32/arch/Kbuild
 delete mode 100644 arch/tile/include/uapi/arch/Kbuild
 delete mode 100644 include/Kbuild
 delete mode 100644 include/asm-generic/Kbuild.asm
 delete mode 100644 include/scsi/fc/Kbuild
 delete mode 100644 include/uapi/Kbuild
 delete mode 100644 include/uapi/asm-generic/Kbuild
 delete mode 100644 include/uapi/drm/Kbuild
 delete mode 100644 include/uapi/linux/Kbuild
 delete mode 100644 include/uapi/linux/android/Kbuild
 delete mode 100644 include/uapi/linux/byteorder/Kbuild
 delete mode 100644 include/uapi/linux/caif/Kbuild
 delete mode 100644 include/uapi/linux/can/Kbuild
 delete mode 100644 include/uapi/linux/dvb/Kbuild
 delete mode 100644 include/uapi/linux/hdlc/Kbuild
 delete mode 100644 include/uapi/linux/hsi/Kbuild
 delete mode 100644 include/uapi/linux/iio/Kbuild
 delete mode 100644 include/uapi/linux/isdn/Kbuild
 delete mode 100644 include/uapi/linux/mmc/Kbuild
 delete mode 100644 include/uapi/linux/netfilter/Kbuild
 delete mode 100644 include/uapi/linux/netfilter/ipset/Kbuild
 delete mode 100644 include/uapi/linux/netfilter_arp/Kbuild
 delete mode 100644 include/uapi/linux/netfilter_bridge/Kbuild
 delete mode 100644 include/uapi/linux/netfilter_ipv4/Kbuild
 delete mode 100644 include/uapi/linux/netfilter_ipv6/Kbuild
 delete mode 100644 include/uapi/linux/nfsd/Kbuild
 delete mode 100644 include/uapi/linux/raid/Kbuild
 delete mode 100644 include/uapi/linux/spi/Kbuild
 delete mode 100644 include/uapi/linux/sunrpc/Kbuild
 delete mode 100644 include/uapi/linux/tc_act/Kbuild
 delete mode 100644 include/uapi/linux/tc_ematch/Kbuild
 delete mode 100644 include/uapi/linux/usb/Kbuild
 delete mode 100644 include/uapi/linux/wimax/Kbuild
 delete mode 100644 include/uapi/misc/Kbuild
 delete mode 100644 include/uapi/mtd/Kbuild
 delete mode 100644 include/uapi/rdma/Kbuild
 delete mode 100644 include/uapi/rdma/hfi/Kbuild
 delete mode 100644 include/uapi/scsi/Kbuild
 delete mode 100644 include/uapi/scsi/fc/Kbuild
 delete mode 100644 include/uapi/sound/Kbuild
 delete mode 100644 include/uapi/video/Kbuild
 delete mode 100644 include/uapi/xen/Kbuild
 delete mode 100644 include/video/Kbuild

diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 37b525d329ae..53e31061ff18 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -44,7 +44,7 @@ This document describes the Linux kernel Makefiles.
 	   --- 6.11 Post-link pass
 
 	=== 7 Kbuild syntax for exported headers
-		--- 7.1 header-y
+		--- 7.1 subdir-y
 		--- 7.2 genhdr-y
 		--- 7.3 generic-y
 		--- 7.4 generated-y
@@ -1235,7 +1235,7 @@ When kbuild executes, the following steps are followed (roughly):
 	that may be shared between individual architectures.
 	The recommended approach how to use a generic header file is
 	to list the file in the Kbuild file.
-	See "7.4 generic-y" for further info on syntax etc.
+	See "7.3 generic-y" for further info on syntax etc.
 
 --- 6.11 Post-link pass
 
@@ -1262,37 +1262,36 @@ The pre-processing does:
 - drop include of compiler.h
 - drop all sections that are kernel internal (guarded by ifdef __KERNEL__)
 
-Each relevant directory contains a file name "Kbuild" which specifies the
-headers to be exported.
+All headers under include/uapi/, include/generated/uapi/,
+arch/<arch>/include/uapi/asm/ and arch/<arch>/include/generated/uapi/asm/
+are exported.
+
+A Kbuild file may be defined under arch/<arch>/include/uapi/asm/ and
+arch/<arch>/include/asm/ to list asm files coming from asm-generic.
 See subsequent chapter for the syntax of the Kbuild file.
 
-	--- 7.1 header-y
+	--- 7.1 subdir-y
 
-	header-y specifies header files to be exported.
+	subdir-y may be used to specify a subdirectory to be exported.
 
 		Example:
-			#include/linux/Kbuild
-			header-y += usb/
-			header-y += aio_abi.h
+			#arch/cris/include/uapi/asm/Kbuild
+			subdir-y += ../arch-v10/arch/
+			subdir-y += ../arch-v32/arch/
 
-	The convention is to list one file per line and
+	The convention is to list one subdir per line and
 	preferably in alphabetic order.
 
-	header-y also specifies which subdirectories to visit.
-	A subdirectory is identified by a trailing '/' which
-	can be seen in the example above for the usb subdirectory.
-
-	Subdirectories are visited before their parent directories.
-
 	--- 7.2 genhdr-y
 
-	genhdr-y specifies generated files to be exported.
-	Generated files are special as they need to be looked
-	up in another directory when doing 'make O=...' builds.
+	genhdr-y specifies asm files to be generated.
 
 		Example:
-			#include/linux/Kbuild
-			genhdr-y += version.h
+			#arch/x86/include/uapi/asm/Kbuild
+			genhdr-y += unistd_32.h
+			genhdr-y += unistd_64.h
+			genhdr-y += unistd_x32.h
+
 
 	--- 7.3 generic-y
 
diff --git a/arch/alpha/include/uapi/asm/Kbuild b/arch/alpha/include/uapi/asm/Kbuild
index d96f2ef5b639..b15bf6bc0e94 100644
--- a/arch/alpha/include/uapi/asm/Kbuild
+++ b/arch/alpha/include/uapi/asm/Kbuild
@@ -1,43 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += a.out.h
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += compiler.h
-header-y += console.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += fpu.h
-header-y += gentrap.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += pal.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += reg.h
-header-y += regdef.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += sysinfo.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/arc/include/uapi/asm/Kbuild b/arch/arc/include/uapi/asm/Kbuild
index f50d02df78d5..b15bf6bc0e94 100644
--- a/arch/arc/include/uapi/asm/Kbuild
+++ b/arch/arc/include/uapi/asm/Kbuild
@@ -1,5 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-header-y += elf.h
-header-y += page.h
-header-y += cachectl.h
diff --git a/arch/arm/include/uapi/asm/Kbuild b/arch/arm/include/uapi/asm/Kbuild
index 46a76cd6acb6..607f702c2d62 100644
--- a/arch/arm/include/uapi/asm/Kbuild
+++ b/arch/arm/include/uapi/asm/Kbuild
@@ -1,23 +1,6 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
 
-header-y += auxvec.h
-header-y += byteorder.h
-header-y += fcntl.h
-header-y += hwcap.h
-header-y += ioctls.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += perf_regs.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += signal.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += unistd.h
 genhdr-y += unistd-common.h
 genhdr-y += unistd-oabi.h
 genhdr-y += unistd-eabi.h
diff --git a/arch/arm64/include/uapi/asm/Kbuild b/arch/arm64/include/uapi/asm/Kbuild
index 825b0fe51c2b..13a97aa2285f 100644
--- a/arch/arm64/include/uapi/asm/Kbuild
+++ b/arch/arm64/include/uapi/asm/Kbuild
@@ -2,21 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += kvm_para.h
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += fcntl.h
-header-y += hwcap.h
-header-y += kvm_para.h
-header-y += perf_regs.h
-header-y += param.h
-header-y += ptrace.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += stat.h
-header-y += statfs.h
-header-y += ucontext.h
-header-y += unistd.h
diff --git a/arch/avr32/include/uapi/asm/Kbuild b/arch/avr32/include/uapi/asm/Kbuild
index 08d8a3d76ea8..610395083364 100644
--- a/arch/avr32/include/uapi/asm/Kbuild
+++ b/arch/avr32/include/uapi/asm/Kbuild
@@ -1,26 +1,6 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
 
-header-y += auxvec.h
-header-y += byteorder.h
-header-y += cachectl.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
 generic-y += bitsperlong.h
 generic-y += errno.h
 generic-y += fcntl.h
diff --git a/arch/blackfin/include/uapi/asm/Kbuild b/arch/blackfin/include/uapi/asm/Kbuild
index 0bd28f77abc3..b15bf6bc0e94 100644
--- a/arch/blackfin/include/uapi/asm/Kbuild
+++ b/arch/blackfin/include/uapi/asm/Kbuild
@@ -1,19 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += bfin_sport.h
-header-y += byteorder.h
-header-y += cachectl.h
-header-y += fcntl.h
-header-y += fixed_code.h
-header-y += ioctls.h
-header-y += kvm_para.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += stat.h
-header-y += swab.h
-header-y += unistd.h
diff --git a/arch/c6x/include/uapi/asm/Kbuild b/arch/c6x/include/uapi/asm/Kbuild
index e9bc2b2b8147..13a97aa2285f 100644
--- a/arch/c6x/include/uapi/asm/Kbuild
+++ b/arch/c6x/include/uapi/asm/Kbuild
@@ -2,11 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += kvm_para.h
-
-header-y += byteorder.h
-header-y += kvm_para.h
-header-y += ptrace.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += swab.h
-header-y += unistd.h
diff --git a/arch/cris/include/uapi/arch-v10/arch/Kbuild b/arch/cris/include/uapi/arch-v10/arch/Kbuild
deleted file mode 100644
index 9048c87a782b..000000000000
--- a/arch/cris/include/uapi/arch-v10/arch/Kbuild
+++ /dev/null
@@ -1,5 +0,0 @@
-# UAPI Header export list
-header-y += sv_addr.agh
-header-y += sv_addr_ag.h
-header-y += svinto.h
-header-y += user.h
diff --git a/arch/cris/include/uapi/arch-v32/arch/Kbuild b/arch/cris/include/uapi/arch-v32/arch/Kbuild
deleted file mode 100644
index 59efffd16b61..000000000000
--- a/arch/cris/include/uapi/arch-v32/arch/Kbuild
+++ /dev/null
@@ -1,3 +0,0 @@
-# UAPI Header export list
-header-y += cryptocop.h
-header-y += user.h
diff --git a/arch/cris/include/uapi/asm/Kbuild b/arch/cris/include/uapi/asm/Kbuild
index d5564a0ae66a..d0c5471856e0 100644
--- a/arch/cris/include/uapi/asm/Kbuild
+++ b/arch/cris/include/uapi/asm/Kbuild
@@ -1,44 +1,5 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
 
-header-y += ../arch-v10/arch/
-header-y += ../arch-v32/arch/
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += elf.h
-header-y += elf_v10.h
-header-y += elf_v32.h
-header-y += errno.h
-header-y += ethernet.h
-header-y += etraxgpio.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += ptrace_v10.h
-header-y += ptrace_v32.h
-header-y += resource.h
-header-y += rs485.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += sync_serial.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
+subdir-y += ../arch-v10/arch/
+subdir-y += ../arch-v32/arch/
diff --git a/arch/frv/include/uapi/asm/Kbuild b/arch/frv/include/uapi/asm/Kbuild
index 42a2b33461c0..b15bf6bc0e94 100644
--- a/arch/frv/include/uapi/asm/Kbuild
+++ b/arch/frv/include/uapi/asm/Kbuild
@@ -1,35 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += registers.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/h8300/include/uapi/asm/Kbuild b/arch/h8300/include/uapi/asm/Kbuild
index fb6101a5d4f1..b15bf6bc0e94 100644
--- a/arch/h8300/include/uapi/asm/Kbuild
+++ b/arch/h8300/include/uapi/asm/Kbuild
@@ -1,30 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += siginfo.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index db8ddabc6bd2..f3b1ceb5c1e4 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -1,6 +1,3 @@
-
-header-y += ucontext.h
-
 generic-y += auxvec.h
 generic-y += barrier.h
 generic-y += bug.h
diff --git a/arch/hexagon/include/uapi/asm/Kbuild b/arch/hexagon/include/uapi/asm/Kbuild
index c31706c38631..b15bf6bc0e94 100644
--- a/arch/hexagon/include/uapi/asm/Kbuild
+++ b/arch/hexagon/include/uapi/asm/Kbuild
@@ -1,15 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += kvm_para.h
-header-y += param.h
-header-y += ptrace.h
-header-y += registers.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += signal.h
-header-y += swab.h
-header-y += unistd.h
-header-y += user.h
diff --git a/arch/ia64/include/uapi/asm/Kbuild b/arch/ia64/include/uapi/asm/Kbuild
index 891002bbb995..13a97aa2285f 100644
--- a/arch/ia64/include/uapi/asm/Kbuild
+++ b/arch/ia64/include/uapi/asm/Kbuild
@@ -2,48 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += kvm_para.h
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += break.h
-header-y += byteorder.h
-header-y += cmpxchg.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += fpu.h
-header-y += gcc_intrin.h
-header-y += ia64regs.h
-header-y += intel_intrin.h
-header-y += intrinsics.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += perfmon.h
-header-y += perfmon_default_smpl.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += ptrace_offsets.h
-header-y += resource.h
-header-y += rse.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += ucontext.h
-header-y += unistd.h
-header-y += ustack.h
diff --git a/arch/m32r/include/uapi/asm/Kbuild b/arch/m32r/include/uapi/asm/Kbuild
index 43937a61d6cf..b15bf6bc0e94 100644
--- a/arch/m32r/include/uapi/asm/Kbuild
+++ b/arch/m32r/include/uapi/asm/Kbuild
@@ -1,33 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/m68k/include/uapi/asm/Kbuild b/arch/m68k/include/uapi/asm/Kbuild
index 6a2d257bdfb2..64368077235a 100644
--- a/arch/m68k/include/uapi/asm/Kbuild
+++ b/arch/m68k/include/uapi/asm/Kbuild
@@ -9,27 +9,3 @@ generic-y += socket.h
 generic-y += sockios.h
 generic-y += termbits.h
 generic-y += termios.h
-
-header-y += a.out.h
-header-y += bootinfo.h
-header-y += bootinfo-amiga.h
-header-y += bootinfo-apollo.h
-header-y += bootinfo-atari.h
-header-y += bootinfo-hp300.h
-header-y += bootinfo-mac.h
-header-y += bootinfo-q40.h
-header-y += bootinfo-vme.h
-header-y += byteorder.h
-header-y += cachectl.h
-header-y += fcntl.h
-header-y += ioctls.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += signal.h
-header-y += stat.h
-header-y += swab.h
-header-y += unistd.h
diff --git a/arch/metag/include/uapi/asm/Kbuild b/arch/metag/include/uapi/asm/Kbuild
index ab78be2b6eb0..b29731ebd7a9 100644
--- a/arch/metag/include/uapi/asm/Kbuild
+++ b/arch/metag/include/uapi/asm/Kbuild
@@ -1,14 +1,6 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
 
-header-y += byteorder.h
-header-y += ech.h
-header-y += ptrace.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += swab.h
-header-y += unistd.h
-
 generic-y += mman.h
 generic-y += resource.h
 generic-y += setup.h
diff --git a/arch/microblaze/include/uapi/asm/Kbuild b/arch/microblaze/include/uapi/asm/Kbuild
index 1aac99f87df1..2178c78c7c1a 100644
--- a/arch/microblaze/include/uapi/asm/Kbuild
+++ b/arch/microblaze/include/uapi/asm/Kbuild
@@ -2,35 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += types.h
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += elf.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += unistd.h
diff --git a/arch/mips/include/uapi/asm/Kbuild b/arch/mips/include/uapi/asm/Kbuild
index f2cf41461146..a0266feba9e6 100644
--- a/arch/mips/include/uapi/asm/Kbuild
+++ b/arch/mips/include/uapi/asm/Kbuild
@@ -2,40 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += ipcbuf.h
-
-header-y += auxvec.h
-header-y += bitfield.h
-header-y += bitsperlong.h
-header-y += break.h
-header-y += byteorder.h
-header-y += cachectl.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += inst.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += sgidefs.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += sysmips.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/mn10300/include/uapi/asm/Kbuild b/arch/mn10300/include/uapi/asm/Kbuild
index 040178cdb3eb..b15bf6bc0e94 100644
--- a/arch/mn10300/include/uapi/asm/Kbuild
+++ b/arch/mn10300/include/uapi/asm/Kbuild
@@ -1,34 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/nios2/include/uapi/asm/Kbuild b/arch/nios2/include/uapi/asm/Kbuild
index e0bb972a50d7..766455d0d291 100644
--- a/arch/nios2/include/uapi/asm/Kbuild
+++ b/arch/nios2/include/uapi/asm/Kbuild
@@ -1,5 +1,3 @@
+# UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += elf.h
-
 generic-y += ucontext.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 2832f031fb11..561915716fd9 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -1,6 +1,3 @@
-
-header-y += ucontext.h
-
 generic-y += atomic.h
 generic-y += auxvec.h
 generic-y += barrier.h
diff --git a/arch/openrisc/include/uapi/asm/Kbuild b/arch/openrisc/include/uapi/asm/Kbuild
index 80761eb82b5f..b15bf6bc0e94 100644
--- a/arch/openrisc/include/uapi/asm/Kbuild
+++ b/arch/openrisc/include/uapi/asm/Kbuild
@@ -1,10 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += byteorder.h
-header-y += elf.h
-header-y += kvm_para.h
-header-y += param.h
-header-y += ptrace.h
-header-y += sigcontext.h
-header-y += unistd.h
diff --git a/arch/parisc/include/uapi/asm/Kbuild b/arch/parisc/include/uapi/asm/Kbuild
index 348356c99514..3971c60a7e7f 100644
--- a/arch/parisc/include/uapi/asm/Kbuild
+++ b/arch/parisc/include/uapi/asm/Kbuild
@@ -2,31 +2,3 @@
 include include/uapi/asm-generic/Kbuild.asm
 
 generic-y += resource.h
-
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += pdc.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/powerpc/include/uapi/asm/Kbuild b/arch/powerpc/include/uapi/asm/Kbuild
index dab3717e3ea0..b15bf6bc0e94 100644
--- a/arch/powerpc/include/uapi/asm/Kbuild
+++ b/arch/powerpc/include/uapi/asm/Kbuild
@@ -1,47 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += bootx.h
-header-y += byteorder.h
-header-y += cputable.h
-header-y += eeh.h
-header-y += elf.h
-header-y += epapr_hcalls.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += nvram.h
-header-y += opal-prd.h
-header-y += param.h
-header-y += perf_event.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ps3fb.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += spu_info.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += tm.h
-header-y += types.h
-header-y += ucontext.h
-header-y += unistd.h
diff --git a/arch/s390/include/uapi/asm/Kbuild b/arch/s390/include/uapi/asm/Kbuild
index bf736e764cb4..b15bf6bc0e94 100644
--- a/arch/s390/include/uapi/asm/Kbuild
+++ b/arch/s390/include/uapi/asm/Kbuild
@@ -1,54 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += chpid.h
-header-y += chsc.h
-header-y += clp.h
-header-y += cmb.h
-header-y += dasd.h
-header-y += debug.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += hypfs.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm.h
-header-y += kvm_para.h
-header-y += kvm_perf.h
-header-y += kvm_virtio.h
-header-y += mman.h
-header-y += monwriter.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += qeth.h
-header-y += resource.h
-header-y += schid.h
-header-y += sclp_ctl.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sie.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += tape390.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += ucontext.h
-header-y += unistd.h
-header-y += virtio-ccw.h
-header-y += vtoc.h
-header-y += zcrypt.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index a05218ff3fe4..128ca7ec0220 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -1,7 +1,3 @@
-
-header-y +=
-
-
 generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += cputime.h
diff --git a/arch/score/include/uapi/asm/Kbuild b/arch/score/include/uapi/asm/Kbuild
index 040178cdb3eb..b15bf6bc0e94 100644
--- a/arch/score/include/uapi/asm/Kbuild
+++ b/arch/score/include/uapi/asm/Kbuild
@@ -1,34 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
diff --git a/arch/sh/include/uapi/asm/Kbuild b/arch/sh/include/uapi/asm/Kbuild
index 60613ae78513..b15bf6bc0e94 100644
--- a/arch/sh/include/uapi/asm/Kbuild
+++ b/arch/sh/include/uapi/asm/Kbuild
@@ -1,25 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += byteorder.h
-header-y += cachectl.h
-header-y += cpu-features.h
-header-y += hw_breakpoint.h
-header-y += ioctls.h
-header-y += posix_types.h
-header-y += posix_types_32.h
-header-y += posix_types_64.h
-header-y += ptrace.h
-header-y += ptrace_32.h
-header-y += ptrace_64.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += signal.h
-header-y += sockios.h
-header-y += stat.h
-header-y += swab.h
-header-y += types.h
-header-y += unistd.h
-header-y += unistd_32.h
-header-y += unistd_64.h
diff --git a/arch/sparc/include/uapi/asm/Kbuild b/arch/sparc/include/uapi/asm/Kbuild
index b5843ee09fb5..b15bf6bc0e94 100644
--- a/arch/sparc/include/uapi/asm/Kbuild
+++ b/arch/sparc/include/uapi/asm/Kbuild
@@ -1,50 +1,2 @@
 # UAPI Header export list
-# User exported sparc header files
-
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += apc.h
-header-y += asi.h
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += display7seg.h
-header-y += envctrl.h
-header-y += errno.h
-header-y += fbio.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += jsflash.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += openpromio.h
-header-y += param.h
-header-y += perfctr.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += psr.h
-header-y += psrcompat.h
-header-y += pstate.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += traps.h
-header-y += uctx.h
-header-y += unistd.h
-header-y += utrap.h
-header-y += watchdog.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 2d1f5638974c..057eaa533877 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -1,6 +1,3 @@
-
-header-y += ../arch/
-
 generic-y += bug.h
 generic-y += bugs.h
 generic-y += clkdev.h
diff --git a/arch/tile/include/uapi/arch/Kbuild b/arch/tile/include/uapi/arch/Kbuild
deleted file mode 100644
index 97dfbecec6b6..000000000000
--- a/arch/tile/include/uapi/arch/Kbuild
+++ /dev/null
@@ -1,17 +0,0 @@
-# UAPI Header export list
-header-y += abi.h
-header-y += chip.h
-header-y += chip_tilegx.h
-header-y += chip_tilepro.h
-header-y += icache.h
-header-y += interrupts.h
-header-y += interrupts_32.h
-header-y += interrupts_64.h
-header-y += opcode.h
-header-y += opcode_tilegx.h
-header-y += opcode_tilepro.h
-header-y += sim.h
-header-y += sim_def.h
-header-y += spr_def.h
-header-y += spr_def_32.h
-header-y += spr_def_64.h
diff --git a/arch/tile/include/uapi/asm/Kbuild b/arch/tile/include/uapi/asm/Kbuild
index c20db8e428bf..e0a50111e07f 100644
--- a/arch/tile/include/uapi/asm/Kbuild
+++ b/arch/tile/include/uapi/asm/Kbuild
@@ -1,21 +1,6 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
 
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += cachectl.h
-header-y += hardwall.h
-header-y += kvm_para.h
-header-y += mman.h
-header-y += ptrace.h
-header-y += setup.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += stat.h
-header-y += swab.h
-header-y += ucontext.h
-header-y += unistd.h
-
 generic-y += ucontext.h
+
+subdir-y += ../arch
diff --git a/arch/unicore32/include/uapi/asm/Kbuild b/arch/unicore32/include/uapi/asm/Kbuild
index 0514d7ad6855..13a97aa2285f 100644
--- a/arch/unicore32/include/uapi/asm/Kbuild
+++ b/arch/unicore32/include/uapi/asm/Kbuild
@@ -1,10 +1,4 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
 
-header-y += byteorder.h
-header-y += kvm_para.h
-header-y += ptrace.h
-header-y += sigcontext.h
-header-y += unistd.h
-
 generic-y += kvm_para.h
diff --git a/arch/x86/include/uapi/asm/Kbuild b/arch/x86/include/uapi/asm/Kbuild
index 3dec769cadf7..83b6e9a0dce4 100644
--- a/arch/x86/include/uapi/asm/Kbuild
+++ b/arch/x86/include/uapi/asm/Kbuild
@@ -4,62 +4,3 @@ include include/uapi/asm-generic/Kbuild.asm
 genhdr-y += unistd_32.h
 genhdr-y += unistd_64.h
 genhdr-y += unistd_x32.h
-header-y += a.out.h
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += boot.h
-header-y += bootparam.h
-header-y += byteorder.h
-header-y += debugreg.h
-header-y += e820.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += hw_breakpoint.h
-header-y += hyperv.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += ist.h
-header-y += kvm.h
-header-y += kvm_para.h
-header-y += kvm_perf.h
-header-y += ldt.h
-header-y += mce.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += msr-index.h
-header-y += msr.h
-header-y += mtrr.h
-header-y += param.h
-header-y += perf_regs.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += posix_types_32.h
-header-y += posix_types_64.h
-header-y += posix_types_x32.h
-header-y += prctl.h
-header-y += processor-flags.h
-header-y += ptrace-abi.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += sigcontext32.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += svm.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += ucontext.h
-header-y += unistd.h
-header-y += vm86.h
-header-y += vmx.h
-header-y += vsyscall.h
diff --git a/arch/xtensa/include/uapi/asm/Kbuild b/arch/xtensa/include/uapi/asm/Kbuild
index 56aad54e7fb7..b15bf6bc0e94 100644
--- a/arch/xtensa/include/uapi/asm/Kbuild
+++ b/arch/xtensa/include/uapi/asm/Kbuild
@@ -1,25 +1,2 @@
 # UAPI Header export list
 include include/uapi/asm-generic/Kbuild.asm
-
-header-y += auxvec.h
-header-y += byteorder.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += swab.h
-header-y += termbits.h
-header-y += types.h
-header-y += unistd.h
diff --git a/include/Kbuild b/include/Kbuild
deleted file mode 100644
index bab1145bc7a7..000000000000
--- a/include/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# Top-level Makefile calls into asm-$(ARCH)
-# List only non-arch directories below
diff --git a/include/asm-generic/Kbuild.asm b/include/asm-generic/Kbuild.asm
deleted file mode 100644
index d2ee86b4c091..000000000000
--- a/include/asm-generic/Kbuild.asm
+++ /dev/null
@@ -1 +0,0 @@
-include include/uapi/asm-generic/Kbuild.asm
diff --git a/include/scsi/fc/Kbuild b/include/scsi/fc/Kbuild
deleted file mode 100644
index e69de29bb2d1..000000000000
diff --git a/include/uapi/Kbuild b/include/uapi/Kbuild
deleted file mode 100644
index 245aa6e05e6a..000000000000
--- a/include/uapi/Kbuild
+++ /dev/null
@@ -1,15 +0,0 @@
-# UAPI Header export list
-# Top-level Makefile calls into asm-$(ARCH)
-# List only non-arch directories below
-
-
-header-y += asm-generic/
-header-y += linux/
-header-y += sound/
-header-y += mtd/
-header-y += rdma/
-header-y += video/
-header-y += drm/
-header-y += xen/
-header-y += scsi/
-header-y += misc/
diff --git a/include/uapi/asm-generic/Kbuild b/include/uapi/asm-generic/Kbuild
deleted file mode 100644
index b73de7bb7a62..000000000000
--- a/include/uapi/asm-generic/Kbuild
+++ /dev/null
@@ -1,36 +0,0 @@
-# UAPI Header export list
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += errno-base.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += int-l64.h
-header-y += int-ll64.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman-common.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += shmparam.h
-header-y += siginfo.h
-header-y += signal-defs.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += ucontext.h
-header-y += unistd.h
diff --git a/include/uapi/asm-generic/Kbuild.asm b/include/uapi/asm-generic/Kbuild.asm
index fcd50b759217..c13805d5a2a0 100644
--- a/include/uapi/asm-generic/Kbuild.asm
+++ b/include/uapi/asm-generic/Kbuild.asm
@@ -8,38 +8,38 @@ opt-header += a.out.h
 #
 # Headers that are mandatory in usr/include/asm/
 #
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += byteorder.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += ptrace.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += sigcontext.h
-header-y += siginfo.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += unistd.h
+generic-y += auxvec.h
+generic-y += bitsperlong.h
+generic-y += byteorder.h
+generic-y += errno.h
+generic-y += fcntl.h
+generic-y += ioctl.h
+generic-y += ioctls.h
+generic-y += ipcbuf.h
+generic-y += mman.h
+generic-y += msgbuf.h
+generic-y += param.h
+generic-y += poll.h
+generic-y += posix_types.h
+generic-y += ptrace.h
+generic-y += resource.h
+generic-y += sembuf.h
+generic-y += setup.h
+generic-y += shmbuf.h
+generic-y += sigcontext.h
+generic-y += siginfo.h
+generic-y += signal.h
+generic-y += socket.h
+generic-y += sockios.h
+generic-y += stat.h
+generic-y += statfs.h
+generic-y += swab.h
+generic-y += termbits.h
+generic-y += termios.h
+generic-y += types.h
+generic-y += unistd.h
 
-header-y += $(foreach hdr,$(opt-header), \
+generic-y += $(foreach hdr,$(opt-header), \
 	      $(if \
 		$(wildcard \
 			$(srctree)/arch/$(SRCARCH)/include/uapi/asm/$(hdr) \
diff --git a/include/uapi/drm/Kbuild b/include/uapi/drm/Kbuild
deleted file mode 100644
index 9355dd8eff3b..000000000000
--- a/include/uapi/drm/Kbuild
+++ /dev/null
@@ -1,22 +0,0 @@
-# UAPI Header export list
-header-y += drm.h
-header-y += drm_fourcc.h
-header-y += drm_mode.h
-header-y += drm_sarea.h
-header-y += amdgpu_drm.h
-header-y += exynos_drm.h
-header-y += i810_drm.h
-header-y += i915_drm.h
-header-y += mga_drm.h
-header-y += nouveau_drm.h
-header-y += qxl_drm.h
-header-y += r128_drm.h
-header-y += radeon_drm.h
-header-y += savage_drm.h
-header-y += sis_drm.h
-header-y += tegra_drm.h
-header-y += via_drm.h
-header-y += vmwgfx_drm.h
-header-y += msm_drm.h
-header-y += vc4_drm.h
-header-y += virtgpu_drm.h
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
deleted file mode 100644
index a8b93e685239..000000000000
--- a/include/uapi/linux/Kbuild
+++ /dev/null
@@ -1,482 +0,0 @@
-# UAPI Header export list
-header-y += android/
-header-y += byteorder/
-header-y += can/
-header-y += caif/
-header-y += dvb/
-header-y += hdlc/
-header-y += hsi/
-header-y += iio/
-header-y += isdn/
-header-y += mmc/
-header-y += nfsd/
-header-y += raid/
-header-y += spi/
-header-y += sunrpc/
-header-y += tc_act/
-header-y += tc_ematch/
-header-y += netfilter/
-header-y += netfilter_arp/
-header-y += netfilter_bridge/
-header-y += netfilter_ipv4/
-header-y += netfilter_ipv6/
-header-y += usb/
-header-y += wimax/
-
-genhdr-y += version.h
-
-ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/a.out.h \
-		  $(srctree)/arch/$(SRCARCH)/include/asm/a.out.h),)
-header-y += a.out.h
-endif
-
-header-y += acct.h
-header-y += adb.h
-header-y += adfs_fs.h
-header-y += affs_hardblocks.h
-header-y += agpgart.h
-header-y += aio_abi.h
-header-y += am437x-vpfe.h
-header-y += apm_bios.h
-header-y += arcfb.h
-header-y += atalk.h
-header-y += atmapi.h
-header-y += atmarp.h
-header-y += atmbr2684.h
-header-y += atmclip.h
-header-y += atmdev.h
-header-y += atm_eni.h
-header-y += atm.h
-header-y += atm_he.h
-header-y += atm_idt77105.h
-header-y += atmioc.h
-header-y += atmlec.h
-header-y += atmmpc.h
-header-y += atm_nicstar.h
-header-y += atmppp.h
-header-y += atmsap.h
-header-y += atmsvc.h
-header-y += atm_tcp.h
-header-y += atm_zatm.h
-header-y += audit.h
-header-y += auto_fs4.h
-header-y += auto_fs.h
-header-y += auxvec.h
-header-y += ax25.h
-header-y += b1lli.h
-header-y += baycom.h
-header-y += bcm933xx_hcs.h
-header-y += bfs_fs.h
-header-y += binfmts.h
-header-y += blkpg.h
-header-y += blktrace_api.h
-header-y += blkzoned.h
-header-y += bpf_common.h
-header-y += bpf_perf_event.h
-header-y += bpf.h
-header-y += bpqether.h
-header-y += bsg.h
-header-y += bt-bmc.h
-header-y += btrfs.h
-header-y += can.h
-header-y += capability.h
-header-y += capi.h
-header-y += cciss_defs.h
-header-y += cciss_ioctl.h
-header-y += cdrom.h
-header-y += cec.h
-header-y += cec-funcs.h
-header-y += cgroupstats.h
-header-y += chio.h
-header-y += cm4000_cs.h
-header-y += cn_proc.h
-header-y += coda.h
-header-y += coda_psdev.h
-header-y += coff.h
-header-y += connector.h
-header-y += const.h
-header-y += cramfs_fs.h
-header-y += cuda.h
-header-y += cyclades.h
-header-y += cycx_cfm.h
-header-y += dcbnl.h
-header-y += dccp.h
-header-y += devlink.h
-header-y += dlmconstants.h
-header-y += dlm_device.h
-header-y += dlm.h
-header-y += dlm_netlink.h
-header-y += dlm_plock.h
-header-y += dm-ioctl.h
-header-y += dm-log-userspace.h
-header-y += dn.h
-header-y += dqblk_xfs.h
-header-y += edd.h
-header-y += efs_fs_sb.h
-header-y += elfcore.h
-header-y += elf-em.h
-header-y += elf-fdpic.h
-header-y += elf.h
-header-y += errno.h
-header-y += errqueue.h
-header-y += ethtool.h
-header-y += eventpoll.h
-header-y += fadvise.h
-header-y += falloc.h
-header-y += fanotify.h
-header-y += fb.h
-header-y += fcntl.h
-header-y += fd.h
-header-y += fdreg.h
-header-y += fib_rules.h
-header-y += fiemap.h
-header-y += filter.h
-header-y += firewire-cdev.h
-header-y += firewire-constants.h
-header-y += flat.h
-header-y += fou.h
-header-y += fs.h
-header-y += fsl_hypervisor.h
-header-y += fuse.h
-header-y += futex.h
-header-y += gameport.h
-header-y += genetlink.h
-header-y += gen_stats.h
-header-y += gfs2_ondisk.h
-header-y += gigaset_dev.h
-header-y += gpio.h
-header-y += gsmmux.h
-header-y += gtp.h
-header-y += hdlcdrv.h
-header-y += hdlc.h
-header-y += hdreg.h
-header-y += hiddev.h
-header-y += hid.h
-header-y += hidraw.h
-header-y += hpet.h
-header-y += hsr_netlink.h
-header-y += hyperv.h
-header-y += hysdn_if.h
-header-y += i2c-dev.h
-header-y += i2c.h
-header-y += i2o-dev.h
-header-y += i8k.h
-header-y += icmp.h
-header-y += icmpv6.h
-header-y += if_addr.h
-header-y += if_addrlabel.h
-header-y += if_alg.h
-header-y += if_arcnet.h
-header-y += if_arp.h
-header-y += if_bonding.h
-header-y += if_bridge.h
-header-y += if_cablemodem.h
-header-y += if_eql.h
-header-y += if_ether.h
-header-y += if_fc.h
-header-y += if_fddi.h
-header-y += if_frad.h
-header-y += if.h
-header-y += if_hippi.h
-header-y += if_infiniband.h
-header-y += if_link.h
-header-y += if_ltalk.h
-header-y += if_macsec.h
-header-y += if_packet.h
-header-y += if_phonet.h
-header-y += if_plip.h
-header-y += if_ppp.h
-header-y += if_pppol2tp.h
-header-y += if_pppox.h
-header-y += if_slip.h
-header-y += if_team.h
-header-y += if_tun.h
-header-y += if_tunnel.h
-header-y += if_vlan.h
-header-y += if_x25.h
-header-y += igmp.h
-header-y += ila.h
-header-y += in6.h
-header-y += inet_diag.h
-header-y += in.h
-header-y += inotify.h
-header-y += input.h
-header-y += input-event-codes.h
-header-y += in_route.h
-header-y += ioctl.h
-header-y += ip6_tunnel.h
-header-y += ipc.h
-header-y += ip.h
-header-y += ipmi.h
-header-y += ipmi_msgdefs.h
-header-y += ipsec.h
-header-y += ipv6.h
-header-y += ipv6_route.h
-header-y += ip_vs.h
-header-y += ipx.h
-header-y += irda.h
-header-y += irqnr.h
-header-y += isdn_divertif.h
-header-y += isdn.h
-header-y += isdnif.h
-header-y += isdn_ppp.h
-header-y += iso_fs.h
-header-y += ivtvfb.h
-header-y += ivtv.h
-header-y += ixjuser.h
-header-y += jffs2.h
-header-y += joystick.h
-header-y += kcmp.h
-header-y += kdev_t.h
-header-y += kd.h
-header-y += kernelcapi.h
-header-y += kernel.h
-header-y += kernel-page-flags.h
-header-y += kexec.h
-header-y += keyboard.h
-header-y += keyctl.h
-
-ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/kvm.h \
-		  $(srctree)/arch/$(SRCARCH)/include/asm/kvm.h),)
-header-y += kvm.h
-endif
-
-
-ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/kvm_para.h \
-		  $(srctree)/arch/$(SRCARCH)/include/asm/kvm_para.h),)
-header-y += kvm_para.h
-endif
-
-header-y += hw_breakpoint.h
-header-y += l2tp.h
-header-y += libc-compat.h
-header-y += lirc.h
-header-y += limits.h
-header-y += llc.h
-header-y += loop.h
-header-y += lp.h
-header-y += lwtunnel.h
-header-y += magic.h
-header-y += major.h
-header-y += map_to_7segment.h
-header-y += matroxfb.h
-header-y += mdio.h
-header-y += media.h
-header-y += media-bus-format.h
-header-y += mei.h
-header-y += membarrier.h
-header-y += memfd.h
-header-y += mempolicy.h
-header-y += meye.h
-header-y += mic_common.h
-header-y += mic_ioctl.h
-header-y += mii.h
-header-y += minix_fs.h
-header-y += mman.h
-header-y += mmtimer.h
-header-y += mpls.h
-header-y += mpls_iptunnel.h
-header-y += mqueue.h
-header-y += mroute6.h
-header-y += mroute.h
-header-y += msdos_fs.h
-header-y += msg.h
-header-y += mtio.h
-header-y += nbd.h
-header-y += ncp_fs.h
-header-y += ncp.h
-header-y += ncp_mount.h
-header-y += ncp_no.h
-header-y += ndctl.h
-header-y += neighbour.h
-header-y += netconf.h
-header-y += netdevice.h
-header-y += net_dropmon.h
-header-y += netfilter_arp.h
-header-y += netfilter_bridge.h
-header-y += netfilter_decnet.h
-header-y += netfilter.h
-header-y += netfilter_ipv4.h
-header-y += netfilter_ipv6.h
-header-y += net.h
-header-y += netlink_diag.h
-header-y += netlink.h
-header-y += netrom.h
-header-y += net_namespace.h
-header-y += net_tstamp.h
-header-y += nfc.h
-header-y += nfs2.h
-header-y += nfs3.h
-header-y += nfs4.h
-header-y += nfs4_mount.h
-header-y += nfsacl.h
-header-y += nfs_fs.h
-header-y += nfs.h
-header-y += nfs_idmap.h
-header-y += nfs_mount.h
-header-y += nl80211.h
-header-y += n_r3964.h
-header-y += nubus.h
-header-y += nvme_ioctl.h
-header-y += nvram.h
-header-y += omap3isp.h
-header-y += omapfb.h
-header-y += oom.h
-header-y += openvswitch.h
-header-y += packet_diag.h
-header-y += param.h
-header-y += parport.h
-header-y += patchkey.h
-header-y += pci.h
-header-y += pci_regs.h
-header-y += perf_event.h
-header-y += personality.h
-header-y += pfkeyv2.h
-header-y += pg.h
-header-y += phantom.h
-header-y += phonet.h
-header-y += pktcdvd.h
-header-y += pkt_cls.h
-header-y += pkt_sched.h
-header-y += pmu.h
-header-y += poll.h
-header-y += posix_acl.h
-header-y += posix_acl_xattr.h
-header-y += posix_types.h
-header-y += ppdev.h
-header-y += ppp-comp.h
-header-y += ppp_defs.h
-header-y += ppp-ioctl.h
-header-y += pps.h
-header-y += prctl.h
-header-y += psci.h
-header-y += ptp_clock.h
-header-y += ptrace.h
-header-y += qnx4_fs.h
-header-y += qnxtypes.h
-header-y += quota.h
-header-y += radeonfb.h
-header-y += random.h
-header-y += raw.h
-header-y += rds.h
-header-y += reboot.h
-header-y += reiserfs_fs.h
-header-y += reiserfs_xattr.h
-header-y += resource.h
-header-y += rfkill.h
-header-y += rio_cm_cdev.h
-header-y += rio_mport_cdev.h
-header-y += romfs_fs.h
-header-y += rose.h
-header-y += route.h
-header-y += rtc.h
-header-y += rtnetlink.h
-header-y += scc.h
-header-y += sched.h
-header-y += scif_ioctl.h
-header-y += screen_info.h
-header-y += sctp.h
-header-y += sdla.h
-header-y += seccomp.h
-header-y += securebits.h
-header-y += selinux_netlink.h
-header-y += sem.h
-header-y += serial_core.h
-header-y += serial.h
-header-y += serial_reg.h
-header-y += serio.h
-header-y += shm.h
-header-y += signalfd.h
-header-y += signal.h
-header-y += smiapp.h
-header-y += snmp.h
-header-y += sock_diag.h
-header-y += socket.h
-header-y += sockios.h
-header-y += sonet.h
-header-y += sonypi.h
-header-y += soundcard.h
-header-y += sound.h
-header-y += stat.h
-header-y += stddef.h
-header-y += string.h
-header-y += suspend_ioctls.h
-header-y += swab.h
-header-y += synclink.h
-header-y += sync_file.h
-header-y += sysctl.h
-header-y += sysinfo.h
-header-y += target_core_user.h
-header-y += taskstats.h
-header-y += tcp.h
-header-y += tcp_metrics.h
-header-y += telephony.h
-header-y += termios.h
-header-y += thermal.h
-header-y += time.h
-header-y += times.h
-header-y += timex.h
-header-y += tiocl.h
-header-y += tipc_config.h
-header-y += tipc_netlink.h
-header-y += tipc.h
-header-y += toshiba.h
-header-y += tty_flags.h
-header-y += tty.h
-header-y += types.h
-header-y += udf_fs_i.h
-header-y += udp.h
-header-y += uhid.h
-header-y += uinput.h
-header-y += uio.h
-header-y += uleds.h
-header-y += ultrasound.h
-header-y += un.h
-header-y += unistd.h
-header-y += unix_diag.h
-header-y += usbdevice_fs.h
-header-y += usbip.h
-header-y += utime.h
-header-y += utsname.h
-header-y += uuid.h
-header-y += uvcvideo.h
-header-y += v4l2-common.h
-header-y += v4l2-controls.h
-header-y += v4l2-dv-timings.h
-header-y += v4l2-mediabus.h
-header-y += v4l2-subdev.h
-header-y += veth.h
-header-y += vfio.h
-header-y += vhost.h
-header-y += videodev2.h
-header-y += virtio_9p.h
-header-y += virtio_balloon.h
-header-y += virtio_blk.h
-header-y += virtio_config.h
-header-y += virtio_console.h
-header-y += virtio_gpu.h
-header-y += virtio_ids.h
-header-y += virtio_input.h
-header-y += virtio_net.h
-header-y += virtio_pci.h
-header-y += virtio_ring.h
-header-y += virtio_rng.h
-header-y += virtio_scsi.h
-header-y += virtio_types.h
-header-y += virtio_vsock.h
-header-y += virtio_crypto.h
-header-y += vm_sockets.h
-header-y += vt.h
-header-y += vtpm_proxy.h
-header-y += wait.h
-header-y += wanrouter.h
-header-y += watchdog.h
-header-y += wimax.h
-header-y += wireless.h
-header-y += x25.h
-header-y += xattr.h
-header-y += xfrm.h
-header-y += xilinx-v4l2-controls.h
-header-y += zorro.h
-header-y += zorro_ids.h
-header-y += userfaultfd.h
diff --git a/include/uapi/linux/android/Kbuild b/include/uapi/linux/android/Kbuild
deleted file mode 100644
index ca011eec252a..000000000000
--- a/include/uapi/linux/android/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += binder.h
diff --git a/include/uapi/linux/byteorder/Kbuild b/include/uapi/linux/byteorder/Kbuild
deleted file mode 100644
index 619225b9ff2e..000000000000
--- a/include/uapi/linux/byteorder/Kbuild
+++ /dev/null
@@ -1,3 +0,0 @@
-# UAPI Header export list
-header-y += big_endian.h
-header-y += little_endian.h
diff --git a/include/uapi/linux/caif/Kbuild b/include/uapi/linux/caif/Kbuild
deleted file mode 100644
index 43396612d3a3..000000000000
--- a/include/uapi/linux/caif/Kbuild
+++ /dev/null
@@ -1,3 +0,0 @@
-# UAPI Header export list
-header-y += caif_socket.h
-header-y += if_caif.h
diff --git a/include/uapi/linux/can/Kbuild b/include/uapi/linux/can/Kbuild
deleted file mode 100644
index 21c91bf25a29..000000000000
--- a/include/uapi/linux/can/Kbuild
+++ /dev/null
@@ -1,6 +0,0 @@
-# UAPI Header export list
-header-y += bcm.h
-header-y += error.h
-header-y += gw.h
-header-y += netlink.h
-header-y += raw.h
diff --git a/include/uapi/linux/dvb/Kbuild b/include/uapi/linux/dvb/Kbuild
deleted file mode 100644
index d40942cfc627..000000000000
--- a/include/uapi/linux/dvb/Kbuild
+++ /dev/null
@@ -1,9 +0,0 @@
-# UAPI Header export list
-header-y += audio.h
-header-y += ca.h
-header-y += dmx.h
-header-y += frontend.h
-header-y += net.h
-header-y += osd.h
-header-y += version.h
-header-y += video.h
diff --git a/include/uapi/linux/hdlc/Kbuild b/include/uapi/linux/hdlc/Kbuild
deleted file mode 100644
index 8c1d2cb75e33..000000000000
--- a/include/uapi/linux/hdlc/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += ioctl.h
diff --git a/include/uapi/linux/hsi/Kbuild b/include/uapi/linux/hsi/Kbuild
deleted file mode 100644
index a16a00544258..000000000000
--- a/include/uapi/linux/hsi/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += hsi_char.h cs-protocol.h
diff --git a/include/uapi/linux/iio/Kbuild b/include/uapi/linux/iio/Kbuild
deleted file mode 100644
index 86f76d84c44f..000000000000
--- a/include/uapi/linux/iio/Kbuild
+++ /dev/null
@@ -1,3 +0,0 @@
-# UAPI Header export list
-header-y += events.h
-header-y += types.h
diff --git a/include/uapi/linux/isdn/Kbuild b/include/uapi/linux/isdn/Kbuild
deleted file mode 100644
index 89e52850bf29..000000000000
--- a/include/uapi/linux/isdn/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += capicmd.h
diff --git a/include/uapi/linux/mmc/Kbuild b/include/uapi/linux/mmc/Kbuild
deleted file mode 100644
index 8c1d2cb75e33..000000000000
--- a/include/uapi/linux/mmc/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += ioctl.h
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
deleted file mode 100644
index 03f194aeadc5..000000000000
--- a/include/uapi/linux/netfilter/Kbuild
+++ /dev/null
@@ -1,89 +0,0 @@
-# UAPI Header export list
-header-y += ipset/
-header-y += nf_conntrack_common.h
-header-y += nf_conntrack_ftp.h
-header-y += nf_conntrack_sctp.h
-header-y += nf_conntrack_tcp.h
-header-y += nf_conntrack_tuple_common.h
-header-y += nf_log.h
-header-y += nf_tables.h
-header-y += nf_tables_compat.h
-header-y += nf_nat.h
-header-y += nfnetlink.h
-header-y += nfnetlink_acct.h
-header-y += nfnetlink_compat.h
-header-y += nfnetlink_conntrack.h
-header-y += nfnetlink_cthelper.h
-header-y += nfnetlink_cttimeout.h
-header-y += nfnetlink_log.h
-header-y += nfnetlink_queue.h
-header-y += x_tables.h
-header-y += xt_AUDIT.h
-header-y += xt_CHECKSUM.h
-header-y += xt_CLASSIFY.h
-header-y += xt_CONNMARK.h
-header-y += xt_CONNSECMARK.h
-header-y += xt_CT.h
-header-y += xt_DSCP.h
-header-y += xt_HMARK.h
-header-y += xt_IDLETIMER.h
-header-y += xt_LED.h
-header-y += xt_LOG.h
-header-y += xt_MARK.h
-header-y += xt_NFLOG.h
-header-y += xt_NFQUEUE.h
-header-y += xt_RATEEST.h
-header-y += xt_SECMARK.h
-header-y += xt_SYNPROXY.h
-header-y += xt_TCPMSS.h
-header-y += xt_TCPOPTSTRIP.h
-header-y += xt_TEE.h
-header-y += xt_TPROXY.h
-header-y += xt_addrtype.h
-header-y += xt_bpf.h
-header-y += xt_cgroup.h
-header-y += xt_cluster.h
-header-y += xt_comment.h
-header-y += xt_connbytes.h
-header-y += xt_connlabel.h
-header-y += xt_connlimit.h
-header-y += xt_connmark.h
-header-y += xt_conntrack.h
-header-y += xt_cpu.h
-header-y += xt_dccp.h
-header-y += xt_devgroup.h
-header-y += xt_dscp.h
-header-y += xt_ecn.h
-header-y += xt_esp.h
-header-y += xt_hashlimit.h
-header-y += xt_helper.h
-header-y += xt_ipcomp.h
-header-y += xt_iprange.h
-header-y += xt_ipvs.h
-header-y += xt_l2tp.h
-header-y += xt_length.h
-header-y += xt_limit.h
-header-y += xt_mac.h
-header-y += xt_mark.h
-header-y += xt_multiport.h
-header-y += xt_nfacct.h
-header-y += xt_osf.h
-header-y += xt_owner.h
-header-y += xt_physdev.h
-header-y += xt_pkttype.h
-header-y += xt_policy.h
-header-y += xt_quota.h
-header-y += xt_rateest.h
-header-y += xt_realm.h
-header-y += xt_recent.h
-header-y += xt_rpfilter.h
-header-y += xt_sctp.h
-header-y += xt_set.h
-header-y += xt_socket.h
-header-y += xt_state.h
-header-y += xt_statistic.h
-header-y += xt_string.h
-header-y += xt_tcpmss.h
-header-y += xt_tcpudp.h
-header-y += xt_time.h
-header-y += xt_u32.h
diff --git a/include/uapi/linux/netfilter/ipset/Kbuild b/include/uapi/linux/netfilter/ipset/Kbuild
deleted file mode 100644
index d2680423d9ab..000000000000
--- a/include/uapi/linux/netfilter/ipset/Kbuild
+++ /dev/null
@@ -1,5 +0,0 @@
-# UAPI Header export list
-header-y += ip_set.h
-header-y += ip_set_bitmap.h
-header-y += ip_set_hash.h
-header-y += ip_set_list.h
diff --git a/include/uapi/linux/netfilter_arp/Kbuild b/include/uapi/linux/netfilter_arp/Kbuild
deleted file mode 100644
index 62d5637cc0ac..000000000000
--- a/include/uapi/linux/netfilter_arp/Kbuild
+++ /dev/null
@@ -1,3 +0,0 @@
-# UAPI Header export list
-header-y += arp_tables.h
-header-y += arpt_mangle.h
diff --git a/include/uapi/linux/netfilter_bridge/Kbuild b/include/uapi/linux/netfilter_bridge/Kbuild
deleted file mode 100644
index 0fbad8ef96de..000000000000
--- a/include/uapi/linux/netfilter_bridge/Kbuild
+++ /dev/null
@@ -1,18 +0,0 @@
-# UAPI Header export list
-header-y += ebt_802_3.h
-header-y += ebt_among.h
-header-y += ebt_arp.h
-header-y += ebt_arpreply.h
-header-y += ebt_ip.h
-header-y += ebt_ip6.h
-header-y += ebt_limit.h
-header-y += ebt_log.h
-header-y += ebt_mark_m.h
-header-y += ebt_mark_t.h
-header-y += ebt_nat.h
-header-y += ebt_nflog.h
-header-y += ebt_pkttype.h
-header-y += ebt_redirect.h
-header-y += ebt_stp.h
-header-y += ebt_vlan.h
-header-y += ebtables.h
diff --git a/include/uapi/linux/netfilter_ipv4/Kbuild b/include/uapi/linux/netfilter_ipv4/Kbuild
deleted file mode 100644
index ecb291df390e..000000000000
--- a/include/uapi/linux/netfilter_ipv4/Kbuild
+++ /dev/null
@@ -1,10 +0,0 @@
-# UAPI Header export list
-header-y += ip_tables.h
-header-y += ipt_CLUSTERIP.h
-header-y += ipt_ECN.h
-header-y += ipt_LOG.h
-header-y += ipt_REJECT.h
-header-y += ipt_TTL.h
-header-y += ipt_ah.h
-header-y += ipt_ecn.h
-header-y += ipt_ttl.h
diff --git a/include/uapi/linux/netfilter_ipv6/Kbuild b/include/uapi/linux/netfilter_ipv6/Kbuild
deleted file mode 100644
index 75a668ca2353..000000000000
--- a/include/uapi/linux/netfilter_ipv6/Kbuild
+++ /dev/null
@@ -1,13 +0,0 @@
-# UAPI Header export list
-header-y += ip6_tables.h
-header-y += ip6t_HL.h
-header-y += ip6t_LOG.h
-header-y += ip6t_NPT.h
-header-y += ip6t_REJECT.h
-header-y += ip6t_ah.h
-header-y += ip6t_frag.h
-header-y += ip6t_hl.h
-header-y += ip6t_ipv6header.h
-header-y += ip6t_mh.h
-header-y += ip6t_opts.h
-header-y += ip6t_rt.h
diff --git a/include/uapi/linux/nfsd/Kbuild b/include/uapi/linux/nfsd/Kbuild
deleted file mode 100644
index c11bc404053c..000000000000
--- a/include/uapi/linux/nfsd/Kbuild
+++ /dev/null
@@ -1,6 +0,0 @@
-# UAPI Header export list
-header-y += cld.h
-header-y += debug.h
-header-y += export.h
-header-y += nfsfh.h
-header-y += stats.h
diff --git a/include/uapi/linux/raid/Kbuild b/include/uapi/linux/raid/Kbuild
deleted file mode 100644
index e2c3d25405d7..000000000000
--- a/include/uapi/linux/raid/Kbuild
+++ /dev/null
@@ -1,3 +0,0 @@
-# UAPI Header export list
-header-y += md_p.h
-header-y += md_u.h
diff --git a/include/uapi/linux/spi/Kbuild b/include/uapi/linux/spi/Kbuild
deleted file mode 100644
index 0cc747eff165..000000000000
--- a/include/uapi/linux/spi/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += spidev.h
diff --git a/include/uapi/linux/sunrpc/Kbuild b/include/uapi/linux/sunrpc/Kbuild
deleted file mode 100644
index 8e02e47c20fb..000000000000
--- a/include/uapi/linux/sunrpc/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += debug.h
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
deleted file mode 100644
index e3db7403296f..000000000000
--- a/include/uapi/linux/tc_act/Kbuild
+++ /dev/null
@@ -1,15 +0,0 @@
-# UAPI Header export list
-header-y += tc_csum.h
-header-y += tc_defact.h
-header-y += tc_gact.h
-header-y += tc_ipt.h
-header-y += tc_mirred.h
-header-y += tc_nat.h
-header-y += tc_pedit.h
-header-y += tc_skbedit.h
-header-y += tc_vlan.h
-header-y += tc_bpf.h
-header-y += tc_connmark.h
-header-y += tc_ife.h
-header-y += tc_tunnel_key.h
-header-y += tc_skbmod.h
diff --git a/include/uapi/linux/tc_ematch/Kbuild b/include/uapi/linux/tc_ematch/Kbuild
deleted file mode 100644
index 53fca3925535..000000000000
--- a/include/uapi/linux/tc_ematch/Kbuild
+++ /dev/null
@@ -1,5 +0,0 @@
-# UAPI Header export list
-header-y += tc_em_cmp.h
-header-y += tc_em_meta.h
-header-y += tc_em_nbyte.h
-header-y += tc_em_text.h
diff --git a/include/uapi/linux/usb/Kbuild b/include/uapi/linux/usb/Kbuild
deleted file mode 100644
index 4cc4d6e7e523..000000000000
--- a/include/uapi/linux/usb/Kbuild
+++ /dev/null
@@ -1,12 +0,0 @@
-# UAPI Header export list
-header-y += audio.h
-header-y += cdc.h
-header-y += cdc-wdm.h
-header-y += ch11.h
-header-y += ch9.h
-header-y += functionfs.h
-header-y += g_printer.h
-header-y += gadgetfs.h
-header-y += midi.h
-header-y += tmc.h
-header-y += video.h
diff --git a/include/uapi/linux/wimax/Kbuild b/include/uapi/linux/wimax/Kbuild
deleted file mode 100644
index 1c97be49971f..000000000000
--- a/include/uapi/linux/wimax/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += i2400m.h
diff --git a/include/uapi/misc/Kbuild b/include/uapi/misc/Kbuild
deleted file mode 100644
index e96cae7d58c9..000000000000
--- a/include/uapi/misc/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# misc Header export list
-header-y += cxl.h
diff --git a/include/uapi/mtd/Kbuild b/include/uapi/mtd/Kbuild
deleted file mode 100644
index 5a691e10cd0e..000000000000
--- a/include/uapi/mtd/Kbuild
+++ /dev/null
@@ -1,6 +0,0 @@
-# UAPI Header export list
-header-y += inftl-user.h
-header-y += mtd-abi.h
-header-y += mtd-user.h
-header-y += nftl-user.h
-header-y += ubi-user.h
diff --git a/include/uapi/rdma/Kbuild b/include/uapi/rdma/Kbuild
deleted file mode 100644
index 82bdf5626859..000000000000
--- a/include/uapi/rdma/Kbuild
+++ /dev/null
@@ -1,18 +0,0 @@
-# UAPI Header export list
-header-y += ib_user_cm.h
-header-y += ib_user_mad.h
-header-y += ib_user_sa.h
-header-y += ib_user_verbs.h
-header-y += rdma_netlink.h
-header-y += rdma_user_cm.h
-header-y += hfi/
-header-y += rdma_user_rxe.h
-header-y += cxgb3-abi.h
-header-y += cxgb4-abi.h
-header-y += mlx4-abi.h
-header-y += mlx5-abi.h
-header-y += mthca-abi.h
-header-y += nes-abi.h
-header-y += ocrdma-abi.h
-header-y += hns-abi.h
-header-y += vmw_pvrdma-abi.h
diff --git a/include/uapi/rdma/hfi/Kbuild b/include/uapi/rdma/hfi/Kbuild
deleted file mode 100644
index ef23c294fc71..000000000000
--- a/include/uapi/rdma/hfi/Kbuild
+++ /dev/null
@@ -1,2 +0,0 @@
-# UAPI Header export list
-header-y += hfi1_user.h
diff --git a/include/uapi/scsi/Kbuild b/include/uapi/scsi/Kbuild
deleted file mode 100644
index d791e0ad509d..000000000000
--- a/include/uapi/scsi/Kbuild
+++ /dev/null
@@ -1,6 +0,0 @@
-# UAPI Header export list
-header-y += fc/
-header-y += scsi_bsg_fc.h
-header-y += scsi_netlink.h
-header-y += scsi_netlink_fc.h
-header-y += cxlflash_ioctl.h
diff --git a/include/uapi/scsi/fc/Kbuild b/include/uapi/scsi/fc/Kbuild
deleted file mode 100644
index 5ead9fac265c..000000000000
--- a/include/uapi/scsi/fc/Kbuild
+++ /dev/null
@@ -1,5 +0,0 @@
-# UAPI Header export list
-header-y += fc_els.h
-header-y += fc_fs.h
-header-y += fc_gs.h
-header-y += fc_ns.h
diff --git a/include/uapi/sound/Kbuild b/include/uapi/sound/Kbuild
deleted file mode 100644
index 9578d8bdbf31..000000000000
--- a/include/uapi/sound/Kbuild
+++ /dev/null
@@ -1,16 +0,0 @@
-# UAPI Header export list
-header-y += asequencer.h
-header-y += asoc.h
-header-y += asound.h
-header-y += asound_fm.h
-header-y += compress_offload.h
-header-y += compress_params.h
-header-y += emu10k1.h
-header-y += firewire.h
-header-y += hdsp.h
-header-y += hdspm.h
-header-y += sb16_csp.h
-header-y += sfnt_info.h
-header-y += tlv.h
-header-y += usb_stream.h
-header-y += snd_sst_tokens.h
diff --git a/include/uapi/video/Kbuild b/include/uapi/video/Kbuild
deleted file mode 100644
index ac7203bb32cc..000000000000
--- a/include/uapi/video/Kbuild
+++ /dev/null
@@ -1,4 +0,0 @@
-# UAPI Header export list
-header-y += edid.h
-header-y += sisfb.h
-header-y += uvesafb.h
diff --git a/include/uapi/xen/Kbuild b/include/uapi/xen/Kbuild
deleted file mode 100644
index 5c459628e8c7..000000000000
--- a/include/uapi/xen/Kbuild
+++ /dev/null
@@ -1,5 +0,0 @@
-# UAPI Header export list
-header-y += evtchn.h
-header-y += gntalloc.h
-header-y += gntdev.h
-header-y += privcmd.h
diff --git a/include/video/Kbuild b/include/video/Kbuild
deleted file mode 100644
index e69de29bb2d1..000000000000
diff --git a/scripts/Makefile.headersinst b/scripts/Makefile.headersinst
index 876b42cfede4..bb93f8466a35 100644
--- a/scripts/Makefile.headersinst
+++ b/scripts/Makefile.headersinst
@@ -1,17 +1,18 @@
 # ==========================================================================
 # Installing headers
 #
-# header-y  - list files to be installed. They are preprocessed
-#             to remove __KERNEL__ section of the file
-# genhdr-y  - Same as header-y but in a generated/ directory
+# All headers under include/uapi, include/generated/uapi,
+# arch/<arch>/include/uapi/asm and /include/generated/uapi/asm are exported.
+# They are preprocessed to remove __KERNEL__ section of the file.
 #
 # ==========================================================================
 
 # generated header directory
 gen := $(if $(gen),$(gen),$(subst include/,include/generated/,$(obj)))
 
+# Kbuild file is optional
 kbuild-file := $(srctree)/$(obj)/Kbuild
-include $(kbuild-file)
+-include $(kbuild-file)
 
 # called may set destination dir (when installing to asm/)
 _dst := $(if $(dst),$(dst),$(obj))
@@ -25,9 +26,12 @@ include scripts/Kbuild.include
 
 installdir    := $(INSTALL_HDR_PATH)/$(subst uapi/,,$(_dst))
 
-header-y      := $(sort $(header-y))
-subdirs       := $(patsubst %/,%,$(filter %/, $(header-y)))
-header-y      := $(filter-out %/, $(header-y))
+subdirs       := $(patsubst $(srctree)/$(obj)/%/.,%,$(wildcard $(srctree)/$(obj)/*/.))
+subdirs       += $(subdir-y)
+header-files  := $(notdir $(wildcard $(srctree)/$(obj)/*.h))
+header-files  += $(notdir $(wildcard $(srctree)/$(obj)/*.agh))
+genhdr-files  := $(notdir $(wildcard $(srctree)/$(gen)/*.h))
+genhdr-files  := $(filter-out $(header-files), $(genhdr-files))
 
 # files used to track state of install/check
 install-file  := $(installdir)/.install
@@ -35,26 +39,17 @@ check-file    := $(installdir)/.check
 
 # generic-y list all files an architecture uses from asm-generic
 # Use this to build a list of headers which require a wrapper
-wrapper-files := $(filter $(header-y), $(generic-y))
+generic-files := $(notdir $(wildcard $(srctree)/include/uapi/asm-generic/*.h))
+wrapper-files := $(filter $(generic-files), $(generic-y))
+wrapper-files := $(filter-out $(header-files), $(wrapper-files))
 
 srcdir        := $(srctree)/$(obj)
 gendir        := $(objtree)/$(gen)
 
 # all headers files for this dir
-header-y      := $(filter-out $(generic-y), $(header-y))
-all-files     := $(header-y) $(genhdr-y) $(wrapper-files)
+all-files     := $(header-files) $(genhdr-files) $(wrapper-files)
 output-files  := $(addprefix $(installdir)/, $(all-files))
 
-# Check that all expected files exist
-$(foreach hdr, $(header-y), \
-  $(if $(wildcard $(srcdir)/$(hdr)),, \
-       $(error Missing UAPI file $(srcdir)/$(hdr)) \
-   ))
-$(foreach hdr, $(genhdr-y), \
-  $(if	$(wildcard $(gendir)/$(hdr)),, \
-       $(error Missing generated UAPI file $(gendir)/$(hdr)) \
-  ))
-
 # Work out what needs to be removed
 oldheaders    := $(patsubst $(installdir)/%,%,$(wildcard $(installdir)/*.h))
 unwanted      := $(filter-out $(all-files),$(oldheaders))
@@ -67,8 +62,8 @@ printdir = $(patsubst $(INSTALL_HDR_PATH)/%/,%,$(dir $@))
 quiet_cmd_install = INSTALL $(printdir) ($(words $(all-files))\
                             file$(if $(word 2, $(all-files)),s))
       cmd_install = \
-        $(CONFIG_SHELL) $< $(installdir) $(srcdir) $(header-y); \
-        $(CONFIG_SHELL) $< $(installdir) $(gendir) $(genhdr-y); \
+        $(CONFIG_SHELL) $< $(installdir) $(srcdir) $(header-files); \
+        $(CONFIG_SHELL) $< $(installdir) $(gendir) $(genhdr-files); \
         for F in $(wrapper-files); do                                   \
                 echo "\#include <asm-generic/$$F>" > $(installdir)/$$F;    \
         done;                                                           \
-- 
2.8.1

