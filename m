From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 01:47:21 +0530
Message-ID: <1232223441.3966.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
To: Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:37154 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754465AbZAQUSg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Jan 2009 15:18:36 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes since commit 03b3e5ab1d1ac93bd45a6d3b38ab81785cda0d41:
  Ingo Molnar (1):
        Merge branch 'out-of-tree'

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tip.git master

Jaswinder Singh Rajput (26):
      can/bcm.h: fix make headers_check
      dvb/audio.h: fix make headers_check
      dvb/dmx.h: fix make headers_check
      dvb/frontend.h: fix make headers_check
      dvb/net.h: fix make headers_check
      dvb/video.h: fix make headers_check
      netfilter/xt_conntrack.h: fix make headers_check
      nfsd/export.h: fix make headers_check
      nfsd/nfsfh.h: fix make headers_check
      nfsd/stats.h: fix make headers_check
      nfsd/syscall.h: fix make headers_check
      raid/md_p.h: fix make headers_check
      spi/spidev.h: fix make headers_check
      tc_act/tc_gact.h: fix make headers_check
      tc_act/tc_mirred.h: fix make headers_check
      tc_act/tc_pedit.h: fix make headers_check
      tc_ematch/tc_em_cmp.h: fix make headers_check
      tc_ematch/tc_em_meta.h: fix make headers_check
      tc_ematch/tc_em_nbyte.h: fix make headers_check
      tc_ematch/tc_em_text.h: fix make headers_check
      usb/cdc.h: fix make headers_check
      usb/gadgetfs.h: fix make headers_check
      mtd/inftl-user.h: fix make headers_check
      sound/hdsp.h: fix make headers_check
      video/sisfb.h: fix make headers_check
      video/uvesafb.h: fix make headers_check

 include/linux/can/bcm.h                |    2 ++
 include/linux/dvb/audio.h              |    3 +--
 include/linux/dvb/dmx.h                |    2 +-
 include/linux/dvb/frontend.h           |    3 +--
 include/linux/dvb/net.h                |    3 +--
 include/linux/dvb/video.h              |    7 ++-----
 include/linux/netfilter/xt_conntrack.h |    1 +
 include/linux/nfsd/export.h            |    3 +--
 include/linux/nfsd/nfsfh.h             |    3 +--
 include/linux/nfsd/stats.h             |    2 ++
 include/linux/nfsd/syscall.h           |    3 +--
 include/linux/raid/md_p.h              |    2 ++
 include/linux/spi/spidev.h             |    1 +
 include/linux/tc_act/tc_gact.h         |    1 +
 include/linux/tc_act/tc_mirred.h       |    1 +
 include/linux/tc_act/tc_pedit.h        |    1 +
 include/linux/tc_ematch/tc_em_cmp.h    |    1 +
 include/linux/tc_ematch/tc_em_meta.h   |    1 +
 include/linux/tc_ematch/tc_em_nbyte.h  |    1 +
 include/linux/tc_ematch/tc_em_text.h   |    1 +
 include/linux/usb/cdc.h                |    2 ++
 include/linux/usb/gadgetfs.h           |    2 +-
 include/mtd/inftl-user.h               |    2 ++
 include/sound/hdsp.h                   |    2 ++
 include/video/sisfb.h                  |    2 +-
 include/video/uvesafb.h                |    2 ++
 26 files changed, 34 insertions(+), 20 deletions(-)

diff --git a/include/linux/can/bcm.h b/include/linux/can/bcm.h
index 7f29327..1432b27 100644
--- a/include/linux/can/bcm.h
+++ b/include/linux/can/bcm.h
@@ -14,6 +14,8 @@
 #ifndef CAN_BCM_H
 #define CAN_BCM_H
 
+#include <linux/types.h>
+
 /**
  * struct bcm_msg_head - head of messages to/from the broadcast manager
  * @opcode:    opcode, see enum below.
diff --git a/include/linux/dvb/audio.h b/include/linux/dvb/audio.h
index 89412e1..758a48c 100644
--- a/include/linux/dvb/audio.h
+++ b/include/linux/dvb/audio.h
@@ -24,9 +24,8 @@
 #ifndef _DVBAUDIO_H_
 #define _DVBAUDIO_H_
 
-#ifdef __KERNEL__
 #include <linux/types.h>
-#else
+#ifndef __KERNEL__
 #include <stdint.h>
 #endif
 
diff --git a/include/linux/dvb/dmx.h b/include/linux/dvb/dmx.h
index 402fb7a..fef9437 100644
--- a/include/linux/dvb/dmx.h
+++ b/include/linux/dvb/dmx.h
@@ -24,7 +24,7 @@
 #ifndef _DVBDMX_H_
 #define _DVBDMX_H_
 
-#include <asm/types.h>
+#include <linux/types.h>
 #ifdef __KERNEL__
 #include <linux/time.h>
 #else
diff --git a/include/linux/dvb/frontend.h b/include/linux/dvb/frontend.h
index 55026b1..51c8d2d 100644
--- a/include/linux/dvb/frontend.h
+++ b/include/linux/dvb/frontend.h
@@ -26,8 +26,7 @@
 #ifndef _DVBFRONTEND_H_
 #define _DVBFRONTEND_H_
 
-#include <asm/types.h>
-
+#include <linux/types.h>
 
 typedef enum fe_type {
 	FE_QPSK,
diff --git a/include/linux/dvb/net.h b/include/linux/dvb/net.h
index 5be474b..f451e7e 100644
--- a/include/linux/dvb/net.h
+++ b/include/linux/dvb/net.h
@@ -24,8 +24,7 @@
 #ifndef _DVBNET_H_
 #define _DVBNET_H_
 
-#include <asm/types.h>
-
+#include <linux/types.h>
 
 struct dvb_net_if {
 	__u16 pid;
diff --git a/include/linux/dvb/video.h b/include/linux/dvb/video.h
index 50839fe..bd49c3e 100644
--- a/include/linux/dvb/video.h
+++ b/include/linux/dvb/video.h
@@ -24,17 +24,14 @@
 #ifndef _DVBVIDEO_H_
 #define _DVBVIDEO_H_
 
-#include <linux/compiler.h>
-
-#ifdef __KERNEL__
 #include <linux/types.h>
+#ifdef __KERNEL__
+#include <linux/compiler.h>
 #else
-#include <asm/types.h>
 #include <stdint.h>
 #include <time.h>
 #endif
 
-
 typedef enum {
 	VIDEO_FORMAT_4_3,     /* Select 4:3 format */
 	VIDEO_FORMAT_16_9,    /* Select 16:9 format. */
diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilter/xt_conntrack.h
index f3fd83e..8f53452 100644
--- a/include/linux/netfilter/xt_conntrack.h
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -5,6 +5,7 @@
 #ifndef _XT_CONNTRACK_H
 #define _XT_CONNTRACK_H
 
+#include <linux/types.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 
 #define XT_CONNTRACK_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 5431512..bcd0201 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -10,9 +10,8 @@
 #ifndef NFSD_EXPORT_H
 #define NFSD_EXPORT_H
 
-#include <asm/types.h>
-#ifdef __KERNEL__
 # include <linux/types.h>
+#ifdef __KERNEL__
 # include <linux/in.h>
 #endif
 
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index b2e0938..fa317f6 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -14,9 +14,8 @@
 #ifndef _LINUX_NFSD_FH_H
 #define _LINUX_NFSD_FH_H
 
-#include <asm/types.h>
-#ifdef __KERNEL__
 # include <linux/types.h>
+#ifdef __KERNEL__
 # include <linux/string.h>
 # include <linux/fs.h>
 #endif
diff --git a/include/linux/nfsd/stats.h b/include/linux/nfsd/stats.h
index 7678cfb..0b53cfe 100644
--- a/include/linux/nfsd/stats.h
+++ b/include/linux/nfsd/stats.h
@@ -29,9 +29,11 @@ struct nfsd_stats {
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
 					 * in the cache (10percentiles). [10] = not found */
+#ifdef __KERNEL__
 #ifdef CONFIG_NFSD_V4
 	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
 #endif
+#endif /* __KERNEL__ */
 
 };
 
diff --git a/include/linux/nfsd/syscall.h b/include/linux/nfsd/syscall.h
index 4e43976..7a3b565 100644
--- a/include/linux/nfsd/syscall.h
+++ b/include/linux/nfsd/syscall.h
@@ -9,9 +9,8 @@
 #ifndef NFSD_SYSCALL_H
 #define NFSD_SYSCALL_H
 
-#include <asm/types.h>
-#ifdef __KERNEL__
 # include <linux/types.h>
+#ifdef __KERNEL__
 # include <linux/in.h>
 #endif 
 #include <linux/posix_types.h>
diff --git a/include/linux/raid/md_p.h b/include/linux/raid/md_p.h
index 9491026..6ba830f 100644
--- a/include/linux/raid/md_p.h
+++ b/include/linux/raid/md_p.h
@@ -15,6 +15,8 @@
 #ifndef _MD_P_H
 #define _MD_P_H
 
+#include <linux/types.h>
+
 /*
  * RAID superblock.
  *
diff --git a/include/linux/spi/spidev.h b/include/linux/spi/spidev.h
index c93ef9d..95251cc 100644
--- a/include/linux/spi/spidev.h
+++ b/include/linux/spi/spidev.h
@@ -22,6 +22,7 @@
 #ifndef SPIDEV_H
 #define SPIDEV_H
 
+#include <linux/types.h>
 
 /* User space versions of kernel symbols for SPI clocking modes,
  * matching <linux/spi/spi.h>
diff --git a/include/linux/tc_act/tc_gact.h b/include/linux/tc_act/tc_gact.h
index 23a03eb..e895c0a 100644
--- a/include/linux/tc_act/tc_gact.h
+++ b/include/linux/tc_act/tc_gact.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_GACT_H
 #define __LINUX_TC_GACT_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 #define TCA_ACT_GACT 5
diff --git a/include/linux/tc_act/tc_mirred.h b/include/linux/tc_act/tc_mirred.h
index 71d6340..0a99ab6 100644
--- a/include/linux/tc_act/tc_mirred.h
+++ b/include/linux/tc_act/tc_mirred.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_MIR_H
 #define __LINUX_TC_MIR_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 #define TCA_ACT_MIRRED 8
diff --git a/include/linux/tc_act/tc_pedit.h b/include/linux/tc_act/tc_pedit.h
index 83e56e3..54ce906 100644
--- a/include/linux/tc_act/tc_pedit.h
+++ b/include/linux/tc_act/tc_pedit.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_PED_H
 #define __LINUX_TC_PED_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 #define TCA_ACT_PEDIT 7
diff --git a/include/linux/tc_ematch/tc_em_cmp.h b/include/linux/tc_ematch/tc_em_cmp.h
index c7f4d43..38e7f7b 100644
--- a/include/linux/tc_ematch/tc_em_cmp.h
+++ b/include/linux/tc_ematch/tc_em_cmp.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_EM_CMP_H
 #define __LINUX_TC_EM_CMP_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 struct tcf_em_cmp
diff --git a/include/linux/tc_ematch/tc_em_meta.h b/include/linux/tc_ematch/tc_em_meta.h
index c50d2ba..dcfb733 100644
--- a/include/linux/tc_ematch/tc_em_meta.h
+++ b/include/linux/tc_ematch/tc_em_meta.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_EM_META_H
 #define __LINUX_TC_EM_META_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 enum
diff --git a/include/linux/tc_ematch/tc_em_nbyte.h b/include/linux/tc_ematch/tc_em_nbyte.h
index f19d1f5..9ed8c2e 100644
--- a/include/linux/tc_ematch/tc_em_nbyte.h
+++ b/include/linux/tc_ematch/tc_em_nbyte.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_EM_NBYTE_H
 #define __LINUX_TC_EM_NBYTE_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 struct tcf_em_nbyte
diff --git a/include/linux/tc_ematch/tc_em_text.h b/include/linux/tc_ematch/tc_em_text.h
index 7cd43e9..d12a73a 100644
--- a/include/linux/tc_ematch/tc_em_text.h
+++ b/include/linux/tc_ematch/tc_em_text.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_TC_EM_TEXT_H
 #define __LINUX_TC_EM_TEXT_H
 
+#include <linux/types.h>
 #include <linux/pkt_cls.h>
 
 #define TC_EM_TEXT_ALGOSIZ	16
diff --git a/include/linux/usb/cdc.h b/include/linux/usb/cdc.h
index 18a7293..3c86ed2 100644
--- a/include/linux/usb/cdc.h
+++ b/include/linux/usb/cdc.h
@@ -9,6 +9,8 @@
 #ifndef __LINUX_USB_CDC_H
 #define __LINUX_USB_CDC_H
 
+#include <linux/types.h>
+
 #define USB_CDC_SUBCLASS_ACM			0x02
 #define USB_CDC_SUBCLASS_ETHERNET		0x06
 #define USB_CDC_SUBCLASS_WHCM			0x08
diff --git a/include/linux/usb/gadgetfs.h b/include/linux/usb/gadgetfs.h
index ea45f26..612102e 100644
--- a/include/linux/usb/gadgetfs.h
+++ b/include/linux/usb/gadgetfs.h
@@ -18,7 +18,7 @@
 #ifndef __LINUX_USB_GADGETFS_H
 #define __LINUX_USB_GADGETFS_H
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <asm/ioctl.h>
 
 #include <linux/usb/ch9.h>
diff --git a/include/mtd/inftl-user.h b/include/mtd/inftl-user.h
index e17eda3..d409d48 100644
--- a/include/mtd/inftl-user.h
+++ b/include/mtd/inftl-user.h
@@ -6,6 +6,8 @@
 #ifndef __MTD_INFTL_USER_H__
 #define __MTD_INFTL_USER_H__
 
+#include <linux/types.h>
+
 #define	OSAK_VERSION	0x5120
 #define	PERCENTUSED	98
 
diff --git a/include/sound/hdsp.h b/include/sound/hdsp.h
index dec6b1d..d98a78d 100644
--- a/include/sound/hdsp.h
+++ b/include/sound/hdsp.h
@@ -19,6 +19,8 @@
  *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#include <linux/types.h>
+
 #define HDSP_MATRIX_MIXER_SIZE 2048
 
 enum HDSP_IO_Type {
diff --git a/include/video/sisfb.h b/include/video/sisfb.h
index e402eb5..fdd74f1 100644
--- a/include/video/sisfb.h
+++ b/include/video/sisfb.h
@@ -21,8 +21,8 @@
 #ifndef _LINUX_SISFB_H_
 #define _LINUX_SISFB_H_
 
+#include <linux/types.h>
 #include <asm/ioctl.h>
-#include <asm/types.h>
 
 /**********************************************/
 /*                   PUBLIC                   */
diff --git a/include/video/uvesafb.h b/include/video/uvesafb.h
index 95bcef1..0993a22 100644
--- a/include/video/uvesafb.h
+++ b/include/video/uvesafb.h
@@ -1,6 +1,8 @@
 #ifndef _UVESAFB_H
 #define _UVESAFB_H
 
+#include <linux/types.h>
+
 struct v86_regs {
 	__u32 ebx;
 	__u32 ecx;


