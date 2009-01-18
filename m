From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 10:13:00 +0100
Message-ID: <20090118091300.GA24849@elte.hu>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org> <20090117221932.GA4956@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jaswinder Singh Rajput <jaswinder@kernel.org>,
	x86 maintainers <x86@kernel.org>, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, linux-media@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-raid@vger.kernel.org, dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090117221932.GA4956@uranus.ravnborg.org>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Sam Ravnborg <sam@ravnborg.org> wrote:

> On Sun, Jan 18, 2009 at 08:37:41AM +1100, David Woodhouse wrote:
> > On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
> > > --- a/include/linux/dvb/audio.h
> > > +++ b/include/linux/dvb/audio.h
> > > @@ -24,9 +24,8 @@
> > >  #ifndef _DVBAUDIO_H_
> > >  #define _DVBAUDIO_H_
> > >  
> > > -#ifdef __KERNEL__
> > >  #include <linux/types.h>
> > > -#else
> > > +#ifndef __KERNEL__
> > >  #include <stdint.h>
> > >  #endif
> > >  
> > 
> > That patch looks wrong, and unnecessary. It was fine before.
> Nope - include/linux/dvb/audio.h failed to include linux/types.h
> despite the fact that is uses __u32 etc.
> 
> But why the _kernel_ should include a userspace header is
> much more questionable.

ok, i dropped this one for the time being.

Sam, Andrew, et al, i've got the commit lineup below, to fix the ~200 new 
CONFIG_HEADERS_CHECK=y warnings we have in current -git, on x86 
allyesconfig.

Note that i have restructured the tree and the commits so that this effort 
can be tracked more easily: each commit has a "headers_check fix" subject 
line prefix. So you can go back later and revisit these things - for 
example whether a header really needs to be exported to user-space, via:

  git log --grep='headers_check fix:' --pretty=format:"%h: %s"

to get an overview and a historic track record. We can follow this 
notation in the future too.

So if there are no objections, i'll send this to Linus tomorrow-ish and 
we'll have the worst of the fallout behind us and can embark on a much 
more fluid (and per maintainer) headers_check related workflow.

	Ingo

------------------------->
The latest core/header-fixes git tree can be pulled from:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core/header-fixes

------------------>
Cyrill Gorcunov (3):
      headers_check fix: x86, prctl.h
      headers_check fix: x86, sigcontext32.h
      headers_check fix: x86, setup.h

Jaswinder Singh Rajput (38):
      headers_check fix: include/linux/*, __[us]{8,16,32,64} types
      headers_check fix: capability.h: extern's make no sense in userspace
      headers_check fix: coda_psdev.h: extern's make no sense in userspace
      headers_check fix: in6.h: extern's make no sense in userspace
      headers_check fix: nubus.h: extern's make no sense in userspace
      headers_check fix: socket.h: extern's make no sense in userspace
      headers_check fix: x86, e820.h
      headers_check fix: x86, kvm.h
      headers_check fix: x86, mce.h
      headers_check fix: x86, mtrr.h
      headers_check fix: x86, ptrace-abi.h
      headers_check fix: x86, sigcontext.h
      headers_check fix: x86, swab.h
      headers_check fix: can/bcm.h
      headers_check fix: dvb/dmx.h
      headers_check fix: dvb/frontend.h
      headers_check fix: dvb/net.h
      headers_check fix: dvb/video.h
      headers_check fix: netfilter/xt_conntrack.h
      headers_check fix: nfsd/export.h
      headers_check fix: nfsd/nfsfh.h
      headers_check fix: nfsd/stats.h
      headers_check fix: nfsd/syscall.h
      headers_check fix: raid/md_p.h
      headers_check fix: spi/spidev.h
      headers_check fix: tc_act/tc_gact.h
      headers_check fix: tc_act/tc_mirred.h
      headers_check fix: tc_act/tc_pedit.h
      headers_check fix: tc_ematch/tc_em_cmp.h
      headers_check fix: tc_ematch/tc_em_meta.h
      headers_check fix: tc_ematch/tc_em_nbyte.h
      headers_check fix: tc_ematch/tc_em_text.h
      headers_check fix: usb/cdc.h
      headers_check fix: usb/gadgetfs.h
      headers_check fix: mtd/inftl-user.h
      headers_check fix: sound/hdsp.h
      headers_check fix: video/sisfb.h
      headers_check fix: video/uvesafb.h


 arch/x86/include/asm/e820.h            |   11 ++++++++---
 arch/x86/include/asm/kvm.h             |    2 +-
 arch/x86/include/asm/mce.h             |    5 +----
 arch/x86/include/asm/mtrr.h            |    1 +
 arch/x86/include/asm/prctl.h           |    4 ----
 arch/x86/include/asm/ptrace-abi.h      |    5 ++++-
 arch/x86/include/asm/setup.h           |    8 +++-----
 arch/x86/include/asm/sigcontext.h      |    2 +-
 arch/x86/include/asm/sigcontext32.h    |    2 ++
 arch/x86/include/asm/swab.h            |   21 +++++++++++++++++++--
 include/linux/aio_abi.h                |    1 +
 include/linux/atalk.h                  |    1 +
 include/linux/atmbr2684.h              |    1 +
 include/linux/auto_fs4.h               |    1 +
 include/linux/bfs_fs.h                 |    2 ++
 include/linux/blktrace_api.h           |    2 ++
 include/linux/can/bcm.h                |    2 ++
 include/linux/capability.h             |    8 ++++----
 include/linux/cdrom.h                  |    1 +
 include/linux/cgroupstats.h            |    1 +
 include/linux/coda_psdev.h             |    2 ++
 include/linux/dlm_plock.h              |    2 ++
 include/linux/dn.h                     |    2 ++
 include/linux/dvb/dmx.h                |    2 +-
 include/linux/dvb/frontend.h           |    3 +--
 include/linux/dvb/net.h                |    3 +--
 include/linux/dvb/video.h              |    7 ++-----
 include/linux/edd.h                    |    2 ++
 include/linux/efs_fs_sb.h              |    1 +
 include/linux/errqueue.h               |    2 ++
 include/linux/genetlink.h              |    1 +
 include/linux/gfs2_ondisk.h            |    2 ++
 include/linux/hiddev.h                 |    2 ++
 include/linux/icmpv6.h                 |    1 +
 include/linux/if_addr.h                |    1 +
 include/linux/if_addrlabel.h           |    2 ++
 include/linux/if_fc.h                  |    1 +
 include/linux/if_hippi.h               |    1 +
 include/linux/if_link.h                |    1 +
 include/linux/if_ppp.h                 |    1 +
 include/linux/if_strip.h               |    2 ++
 include/linux/if_tr.h                  |    1 +
 include/linux/igmp.h                   |    1 +
 include/linux/in6.h                    |    2 +-
 include/linux/inet_diag.h              |    2 ++
 include/linux/ip6_tunnel.h             |    2 ++
 include/linux/ipv6.h                   |    1 +
 include/linux/ipv6_route.h             |    2 ++
 include/linux/ipx.h                    |    1 +
 include/linux/irda.h                   |    2 ++
 include/linux/minix_fs.h               |    1 +
 include/linux/msdos_fs.h               |    1 +
 include/linux/neighbour.h              |    1 +
 include/linux/netfilter/xt_conntrack.h |    1 +
 include/linux/nfs_idmap.h              |    2 ++
 include/linux/nfsd/export.h            |    3 +--
 include/linux/nfsd/nfsfh.h             |    3 +--
 include/linux/nfsd/stats.h             |    2 ++
 include/linux/nfsd/syscall.h           |    3 +--
 include/linux/nubus.h                  |    5 ++++-
 include/linux/phonet.h                 |    2 ++
 include/linux/pkt_cls.h                |    1 +
 include/linux/pkt_sched.h              |    2 ++
 include/linux/ppp_defs.h               |    2 ++
 include/linux/raid/md_p.h              |    2 ++
 include/linux/random.h                 |    1 +
 include/linux/rtnetlink.h              |    1 +
 include/linux/signalfd.h               |    1 +
 include/linux/socket.h                 |   10 +++++-----
 include/linux/spi/spidev.h             |    1 +
 include/linux/synclink.h               |    2 ++
 include/linux/taskstats.h              |    2 ++
 include/linux/tc_act/tc_gact.h         |    1 +
 include/linux/tc_act/tc_mirred.h       |    1 +
 include/linux/tc_act/tc_pedit.h        |    1 +
 include/linux/tc_ematch/tc_em_cmp.h    |    1 +
 include/linux/tc_ematch/tc_em_meta.h   |    1 +
 include/linux/tc_ematch/tc_em_nbyte.h  |    1 +
 include/linux/tc_ematch/tc_em_text.h   |    1 +
 include/linux/usb/cdc.h                |    2 ++
 include/linux/usb/gadgetfs.h           |    2 +-
 include/linux/video_decoder.h          |    2 ++
 include/linux/video_encoder.h          |    2 ++
 include/linux/videodev.h               |    1 +
 include/linux/virtio_blk.h             |    1 +
 include/linux/virtio_console.h         |    2 ++
 include/linux/virtio_net.h             |    2 ++
 include/mtd/inftl-user.h               |    2 ++
 include/sound/hdsp.h                   |    2 ++
 include/video/sisfb.h                  |    2 +-
 include/video/uvesafb.h                |    2 ++
 91 files changed, 164 insertions(+), 50 deletions(-)

diff --git a/arch/x86/include/asm/e820.h b/arch/x86/include/asm/e820.h
index 3d8cedd..c026014 100644
--- a/arch/x86/include/asm/e820.h
+++ b/arch/x86/include/asm/e820.h
@@ -5,8 +5,12 @@
 
 /*
  * Legacy E820 BIOS limits us to 128 (E820MAX) nodes due to the
- * constrained space in the zeropage.  If we have more nodes than
- * that, and if we've booted off EFI firmware, then the EFI tables
+ * constrained space in the zeropage.
+ */
+
+#ifdef __KERNEL__
+/* If we have more nodes than that, and if we have
+ * booted off EFI firmware, then the EFI tables
  * passed us from the EFI firmware can list more nodes.  Size our
  * internal memory map tables to have room for these additional
  * nodes, based on up to three entries per node for which the
@@ -26,7 +30,6 @@
  * to collapse the next two #ifdef lines to a single line:
  *	#if defined(__KERNEL__) && defined(CONFIG_EFI)
  */
-#ifdef __KERNEL__
 #ifdef CONFIG_EFI
 #include <linux/numa.h>
 #define E820_X_MAX (E820MAX + 3 * MAX_NUMNODES)
@@ -49,6 +52,8 @@
 #define E820_RESERVED_KERN        128
 
 #ifndef __ASSEMBLY__
+#include <linux/types.h>
+
 struct e820entry {
 	__u64 addr;	/* start of memory segment */
 	__u64 size;	/* size of memory segment */
diff --git a/arch/x86/include/asm/kvm.h b/arch/x86/include/asm/kvm.h
index b95162a..d2e3bf3 100644
--- a/arch/x86/include/asm/kvm.h
+++ b/arch/x86/include/asm/kvm.h
@@ -6,7 +6,7 @@
  *
  */
 
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/ioctl.h>
 
 /* Architectural interrupt line count. */
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index 1d6e17c..32c6e17 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -3,8 +3,8 @@
 
 #ifdef __x86_64__
 
+#include <linux/types.h>
 #include <asm/ioctls.h>
-#include <asm/types.h>
 
 /*
  * Machine Check support for x86
@@ -115,8 +115,6 @@ extern int mce_notify_user(void);
 
 #endif /* !CONFIG_X86_32 */
 
-
-
 #ifdef CONFIG_X86_MCE
 extern void mcheck_init(struct cpuinfo_x86 *c);
 #else
@@ -126,5 +124,4 @@ extern void stop_mce(void);
 extern void restart_mce(void);
 
 #endif /* __KERNEL__ */
-
 #endif /* _ASM_X86_MCE_H */
diff --git a/arch/x86/include/asm/mtrr.h b/arch/x86/include/asm/mtrr.h
index 14080d2..a51ada8 100644
--- a/arch/x86/include/asm/mtrr.h
+++ b/arch/x86/include/asm/mtrr.h
@@ -23,6 +23,7 @@
 #ifndef _ASM_X86_MTRR_H
 #define _ASM_X86_MTRR_H
 
+#include <linux/types.h>
 #include <linux/ioctl.h>
 #include <linux/errno.h>
 
diff --git a/arch/x86/include/asm/prctl.h b/arch/x86/include/asm/prctl.h
index a889464..3ac5032 100644
--- a/arch/x86/include/asm/prctl.h
+++ b/arch/x86/include/asm/prctl.h
@@ -6,8 +6,4 @@
 #define ARCH_GET_FS 0x1003
 #define ARCH_GET_GS 0x1004
 
-#ifdef CONFIG_X86_64
-extern long sys_arch_prctl(int, unsigned long);
-#endif /* CONFIG_X86_64 */
-
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/include/asm/ptrace-abi.h b/arch/x86/include/asm/ptrace-abi.h
index 25f1bb8..ea32e40 100644
--- a/arch/x86/include/asm/ptrace-abi.h
+++ b/arch/x86/include/asm/ptrace-abi.h
@@ -80,10 +80,12 @@
 
 #define PTRACE_SINGLEBLOCK	33	/* resume execution until next branch */
 
+#ifdef __KERNEL__
+
 #ifdef CONFIG_X86_PTRACE_BTS
 
 #ifndef __ASSEMBLY__
-#include <asm/types.h>
+#include <linux/types.h>
 
 /* configuration/status structure used in PTRACE_BTS_CONFIG and
    PTRACE_BTS_STATUS commands.
@@ -141,5 +143,6 @@ struct ptrace_bts_config {
    Returns number of BTS records drained.
 */
 #endif /* CONFIG_X86_PTRACE_BTS */
+#endif /* __KERNEL__ */
 
 #endif /* _ASM_X86_PTRACE_ABI_H */
diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index ebe858c..29d31c0 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_X86_SETUP_H
 #define _ASM_X86_SETUP_H
 
+#ifdef __KERNEL__
+
 #define COMMAND_LINE_SIZE 2048
 
 #ifndef __ASSEMBLY__
@@ -8,10 +10,8 @@
 /* Interrupt control for vSMPowered x86_64 systems */
 void vsmp_init(void);
 
-
 void setup_bios_corruption_check(void);
 
-
 #ifdef CONFIG_X86_VISWS
 extern void visws_early_detect(void);
 extern int is_visws_box(void);
@@ -43,7 +43,7 @@ struct x86_quirks {
 	void (*mpc_oem_bus_info)(struct mpc_bus *m, char *name);
 	void (*mpc_oem_pci_bus)(struct mpc_bus *m);
 	void (*smp_read_mpc_oem)(struct mpc_oemtable *oemtable,
-                                    unsigned short oemsize);
+				unsigned short oemsize);
 	int (*setup_ioapic_ids)(void);
 	int (*update_genapic)(void);
 };
@@ -56,8 +56,6 @@ extern unsigned long saved_video_mode;
 #endif
 #endif /* __ASSEMBLY__ */
 
-#ifdef __KERNEL__
-
 #ifdef __i386__
 
 #include <linux/pfn.h>
diff --git a/arch/x86/include/asm/sigcontext.h b/arch/x86/include/asm/sigcontext.h
index 0afcb5e..ec66649 100644
--- a/arch/x86/include/asm/sigcontext.h
+++ b/arch/x86/include/asm/sigcontext.h
@@ -2,7 +2,7 @@
 #define _ASM_X86_SIGCONTEXT_H
 
 #include <linux/compiler.h>
-#include <asm/types.h>
+#include <linux/types.h>
 
 #define FP_XSTATE_MAGIC1	0x46505853U
 #define FP_XSTATE_MAGIC2	0x46505845U
diff --git a/arch/x86/include/asm/sigcontext32.h b/arch/x86/include/asm/sigcontext32.h
index 6126188..ad1478c 100644
--- a/arch/x86/include/asm/sigcontext32.h
+++ b/arch/x86/include/asm/sigcontext32.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_X86_SIGCONTEXT32_H
 #define _ASM_X86_SIGCONTEXT32_H
 
+#include <linux/types.h>
+
 /* signal context for 32bit programs. */
 
 #define X86_FXSR_MAGIC		0x0000
diff --git a/arch/x86/include/asm/swab.h b/arch/x86/include/asm/swab.h
index 306d417..613be68 100644
--- a/arch/x86/include/asm/swab.h
+++ b/arch/x86/include/asm/swab.h
@@ -1,12 +1,15 @@
 #ifndef _ASM_X86_SWAB_H
 #define _ASM_X86_SWAB_H
 
-#include <asm/types.h>
+#include <linux/types.h>
+#ifdef __KERNEL__
 #include <linux/compiler.h>
+#endif /* __KERNEL__ */
 
 static inline __attribute_const__ __u32 __arch_swab32(__u32 val)
 {
 #ifdef __i386__
+#ifdef __KERNEL__
 # ifdef CONFIG_X86_BSWAP
 	asm("bswap %0" : "=r" (val) : "0" (val));
 # else
@@ -16,7 +19,13 @@ static inline __attribute_const__ __u32 __arch_swab32(__u32 val)
 	    : "=q" (val)
 	    : "0" (val));
 # endif
-
+#else /* __KERNEL__ */
+	asm("xchgb %b0,%h0\n\t"	/* swap lower bytes	*/
+	    "rorl $16,%0\n\t"	/* swap words		*/
+	    "xchgb %b0,%h0"	/* swap higher bytes	*/
+	    : "=q" (val)
+	    : "0" (val));
+#endif /* __KERNEL__ */
 #else /* __i386__ */
 	asm("bswapl %0"
 	    : "=r" (val)
@@ -37,6 +46,7 @@ static inline __attribute_const__ __u64 __arch_swab64(__u64 val)
 		__u64 u;
 	} v;
 	v.u = val;
+#ifdef __KERNEL__
 # ifdef CONFIG_X86_BSWAP
 	asm("bswapl %0 ; bswapl %1 ; xchgl %0,%1"
 	    : "=r" (v.s.a), "=r" (v.s.b)
@@ -48,6 +58,13 @@ static inline __attribute_const__ __u64 __arch_swab64(__u64 val)
 	    : "=r" (v.s.a), "=r" (v.s.b)
 	    : "0" (v.s.a), "1" (v.s.b));
 # endif
+#else /* __KERNEL__ */
+	v.s.a = __arch_swab32(v.s.a);
+	v.s.b = __arch_swab32(v.s.b);
+	asm("xchgl %0,%1"
+	    : "=r" (v.s.a), "=r" (v.s.b)
+	    : "0" (v.s.a), "1" (v.s.b));
+#endif /* __KERNEL__ */
 	return v.u;
 #else /* __i386__ */
 	asm("bswapq %0"
diff --git a/include/linux/aio_abi.h b/include/linux/aio_abi.h
index 9e01729..2c87316 100644
--- a/include/linux/aio_abi.h
+++ b/include/linux/aio_abi.h
@@ -27,6 +27,7 @@
 #ifndef __LINUX__AIO_ABI_H
 #define __LINUX__AIO_ABI_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 typedef unsigned long	aio_context_t;
diff --git a/include/linux/atalk.h b/include/linux/atalk.h
index e9ebac2..d34c187 100644
--- a/include/linux/atalk.h
+++ b/include/linux/atalk.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_ATALK_H__
 #define __LINUX_ATALK_H__
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*
diff --git a/include/linux/atmbr2684.h b/include/linux/atmbr2684.h
index 52bf72a..fdb2629 100644
--- a/include/linux/atmbr2684.h
+++ b/include/linux/atmbr2684.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_ATMBR2684_H
 #define _LINUX_ATMBR2684_H
 
+#include <linux/types.h>
 #include <linux/atm.h>
 #include <linux/if.h>		/* For IFNAMSIZ */
 
diff --git a/include/linux/auto_fs4.h b/include/linux/auto_fs4.h
index 55fa478..2b60077 100644
--- a/include/linux/auto_fs4.h
+++ b/include/linux/auto_fs4.h
@@ -11,6 +11,7 @@
 #ifndef _LINUX_AUTO_FS4_H
 #define _LINUX_AUTO_FS4_H
 
+#include <linux/types.h>
 /* Include common v3 definitions */
 #include <linux/auto_fs.h>
 
diff --git a/include/linux/bfs_fs.h b/include/linux/bfs_fs.h
index 8ed6dfd..2ca3e8f 100644
--- a/include/linux/bfs_fs.h
+++ b/include/linux/bfs_fs.h
@@ -6,6 +6,8 @@
 #ifndef _LINUX_BFS_FS_H
 #define _LINUX_BFS_FS_H
 
+#include <linux/types.h>
+
 #define BFS_BSIZE_BITS		9
 #define BFS_BSIZE		(1<<BFS_BSIZE_BITS)
 
diff --git a/include/linux/blktrace_api.h b/include/linux/blktrace_api.h
index 1dba349..e9ef923 100644
--- a/include/linux/blktrace_api.h
+++ b/include/linux/blktrace_api.h
@@ -6,6 +6,8 @@
 #include <linux/relay.h>
 #endif
 
+#include <linux/types.h>
+
 /*
  * Trace categories
  */
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
diff --git a/include/linux/capability.h b/include/linux/capability.h
index 02bdb76..1b98725 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -69,10 +69,6 @@ typedef struct __user_cap_data_struct {
 #define VFS_CAP_U32             VFS_CAP_U32_2
 #define VFS_CAP_REVISION	VFS_CAP_REVISION_2
 
-#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
-extern int file_caps_enabled;
-#endif
-
 struct vfs_cap_data {
 	__le32 magic_etc;            /* Little endian */
 	struct {
@@ -96,6 +92,10 @@ struct vfs_cap_data {
 #define _KERNEL_CAPABILITY_VERSION _LINUX_CAPABILITY_VERSION_3
 #define _KERNEL_CAPABILITY_U32S    _LINUX_CAPABILITY_U32S_3
 
+#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
+extern int file_caps_enabled;
+#endif
+
 typedef struct kernel_cap_struct {
 	__u32 cap[_KERNEL_CAPABILITY_U32S];
 } kernel_cap_t;
diff --git a/include/linux/cdrom.h b/include/linux/cdrom.h
index 0b49e08..78e9047 100644
--- a/include/linux/cdrom.h
+++ b/include/linux/cdrom.h
@@ -11,6 +11,7 @@
 #ifndef	_LINUX_CDROM_H
 #define	_LINUX_CDROM_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*******************************************************
diff --git a/include/linux/cgroupstats.h b/include/linux/cgroupstats.h
index 4f53abf..3753c33 100644
--- a/include/linux/cgroupstats.h
+++ b/include/linux/cgroupstats.h
@@ -15,6 +15,7 @@
 #ifndef _LINUX_CGROUPSTATS_H
 #define _LINUX_CGROUPSTATS_H
 
+#include <linux/types.h>
 #include <linux/taskstats.h>
 
 /*
diff --git a/include/linux/coda_psdev.h b/include/linux/coda_psdev.h
index 07ae8f8..c620958 100644
--- a/include/linux/coda_psdev.h
+++ b/include/linux/coda_psdev.h
@@ -87,6 +87,8 @@ struct upc_req {
  * Statistics
  */
 
+#ifdef __KERNEL__
 extern struct venus_comm coda_comms[];
+#endif /* __KERNEL__ */
 
 #endif
diff --git a/include/linux/dlm_plock.h b/include/linux/dlm_plock.h
index 18d5fdb..2dd2124 100644
--- a/include/linux/dlm_plock.h
+++ b/include/linux/dlm_plock.h
@@ -9,6 +9,8 @@
 #ifndef __DLM_PLOCK_DOT_H__
 #define __DLM_PLOCK_DOT_H__
 
+#include <linux/types.h>
+
 #define DLM_PLOCK_MISC_NAME		"dlm_plock"
 
 #define DLM_PLOCK_VERSION_MAJOR	1
diff --git a/include/linux/dn.h b/include/linux/dn.h
index 02bba04..fe99908 100644
--- a/include/linux/dn.h
+++ b/include/linux/dn.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_DN_H
 #define _LINUX_DN_H
 
+#include <linux/types.h>
+
 /*
 
 	DECnet Data Structures and Constants
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
diff --git a/include/linux/edd.h b/include/linux/edd.h
index 5d747c5..4cbd0fe 100644
--- a/include/linux/edd.h
+++ b/include/linux/edd.h
@@ -30,6 +30,8 @@
 #ifndef _LINUX_EDD_H
 #define _LINUX_EDD_H
 
+#include <linux/types.h>
+
 #define EDDNR 0x1e9		/* addr of number of edd_info structs at EDDBUF
 				   in boot_params - treat this as 1 byte  */
 #define EDDBUF	0xd00		/* addr of edd_info structs in boot_params */
diff --git a/include/linux/efs_fs_sb.h b/include/linux/efs_fs_sb.h
index ff1945e..a01be90 100644
--- a/include/linux/efs_fs_sb.h
+++ b/include/linux/efs_fs_sb.h
@@ -9,6 +9,7 @@
 #ifndef __EFS_FS_SB_H__
 #define __EFS_FS_SB_H__
 
+#include <linux/types.h>
 #include <linux/magic.h>
 
 /* EFS superblock magic numbers */
diff --git a/include/linux/errqueue.h b/include/linux/errqueue.h
index 92f8d4f..ceb1454 100644
--- a/include/linux/errqueue.h
+++ b/include/linux/errqueue.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_ERRQUEUE_H
 #define _LINUX_ERRQUEUE_H 1
 
+#include <linux/types.h>
+
 struct sock_extended_err
 {
 	__u32	ee_errno;	
diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 7da02c9..b834ef6 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_GENERIC_NETLINK_H
 #define __LINUX_GENERIC_NETLINK_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 #define GENL_NAMSIZ	16	/* length of family name */
diff --git a/include/linux/gfs2_ondisk.h b/include/linux/gfs2_ondisk.h
index 14d0df0..c56b4bc 100644
--- a/include/linux/gfs2_ondisk.h
+++ b/include/linux/gfs2_ondisk.h
@@ -10,6 +10,8 @@
 #ifndef __GFS2_ONDISK_DOT_H__
 #define __GFS2_ONDISK_DOT_H__
 
+#include <linux/types.h>
+
 #define GFS2_MAGIC		0x01161970
 #define GFS2_BASIC_BLOCK	512
 #define GFS2_BASIC_BLOCK_SHIFT	9
diff --git a/include/linux/hiddev.h b/include/linux/hiddev.h
index c760ae0..bb6f58b 100644
--- a/include/linux/hiddev.h
+++ b/include/linux/hiddev.h
@@ -27,6 +27,8 @@
  * Vojtech Pavlik, Ucitelska 1576, Prague 8, 182 00 Czech Republic
  */
 
+#include <linux/types.h>
+
 /*
  * The event structure itself
  */
diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index a93a8dd..10d701e 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_ICMPV6_H
 #define _LINUX_ICMPV6_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 struct icmp6hdr {
diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index 43f3bed..a60c821 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_IF_ADDR_H
 #define __LINUX_IF_ADDR_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 struct ifaddrmsg
diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabel.h
index 9fe79c9..89571f6 100644
--- a/include/linux/if_addrlabel.h
+++ b/include/linux/if_addrlabel.h
@@ -10,6 +10,8 @@
 #ifndef __LINUX_IF_ADDRLABEL_H
 #define __LINUX_IF_ADDRLABEL_H
 
+#include <linux/types.h>
+
 struct ifaddrlblmsg
 {
 	__u8		ifal_family;		/* Address family */
diff --git a/include/linux/if_fc.h b/include/linux/if_fc.h
index 376a34e..6ed7f1b 100644
--- a/include/linux/if_fc.h
+++ b/include/linux/if_fc.h
@@ -20,6 +20,7 @@
 #ifndef _LINUX_IF_FC_H
 #define _LINUX_IF_FC_H
 
+#include <linux/types.h>
 
 #define FC_ALEN	6		/* Octets in one ethernet addr	 */
 #define FC_HLEN   (sizeof(struct fch_hdr)+sizeof(struct fcllc))
diff --git a/include/linux/if_hippi.h b/include/linux/if_hippi.h
index f0f2351..4a7c994 100644
--- a/include/linux/if_hippi.h
+++ b/include/linux/if_hippi.h
@@ -22,6 +22,7 @@
 #ifndef _LINUX_IF_HIPPI_H
 #define _LINUX_IF_HIPPI_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f9032c8..176c518 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_IF_LINK_H
 #define _LINUX_IF_LINK_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 /* The struct should be in sync with struct net_device_stats */
diff --git a/include/linux/if_ppp.h b/include/linux/if_ppp.h
index c3b1f85..047a01c 100644
--- a/include/linux/if_ppp.h
+++ b/include/linux/if_ppp.h
@@ -34,6 +34,7 @@
 #define _IF_PPP_H_
 
 #include <linux/compiler.h>
+#include <linux/types.h>
 
 /*
  * Packet sizes
diff --git a/include/linux/if_strip.h b/include/linux/if_strip.h
index fb5c5c9..6526a62 100644
--- a/include/linux/if_strip.h
+++ b/include/linux/if_strip.h
@@ -18,6 +18,8 @@
 #ifndef __LINUX_STRIP_H
 #define __LINUX_STRIP_H
 
+#include <linux/types.h>
+
 typedef struct {
     __u8 c[6];
 } MetricomAddress;
diff --git a/include/linux/if_tr.h b/include/linux/if_tr.h
index 5bcec8b..fc23aeb 100644
--- a/include/linux/if_tr.h
+++ b/include/linux/if_tr.h
@@ -19,6 +19,7 @@
 #ifndef _LINUX_IF_TR_H
 #define _LINUX_IF_TR_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>	/* For __be16 */
 
 /* IEEE 802.5 Token-Ring magic constants.  The frame sizes omit the preamble
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f734a0b..92fbd8c 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -16,6 +16,7 @@
 #ifndef _LINUX_IGMP_H
 #define _LINUX_IGMP_H
 
+#include <linux/types.h>
 #include <asm/byteorder.h>
 
 /*
diff --git a/include/linux/in6.h b/include/linux/in6.h
index bc49204..718bf21 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -44,11 +44,11 @@ struct in6_addr
  * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
  * in network byte order, not in host byte order as are the IPv4 equivalents
  */
+#ifdef __KERNEL__
 extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
 extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
-#ifdef __KERNEL__
 extern const struct in6_addr in6addr_linklocal_allnodes;
 #define IN6ADDR_LINKLOCAL_ALLNODES_INIT	\
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 6e8bc54..bc8c490 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -1,6 +1,8 @@
 #ifndef _INET_DIAG_H_
 #define _INET_DIAG_H_ 1
 
+#include <linux/types.h>
+
 /* Just some random number */
 #define TCPDIAG_GETSOCK 18
 #define DCCPDIAG_GETSOCK 19
diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index 1e7cc4a..acb9ad6 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -1,6 +1,8 @@
 #ifndef _IP6_TUNNEL_H
 #define _IP6_TUNNEL_H
 
+#include <linux/types.h>
+
 #define IPV6_TLV_TNL_ENCAP_LIMIT 4
 #define IPV6_DEFAULT_TNL_ENCAP_LIMIT 4
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0b816ca..476d946 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -1,6 +1,7 @@
 #ifndef _IPV6_H
 #define _IPV6_H
 
+#include <linux/types.h>
 #include <linux/in6.h>
 #include <asm/byteorder.h>
 
diff --git a/include/linux/ipv6_route.h b/include/linux/ipv6_route.h
index b323ff5..1e7d8af 100644
--- a/include/linux/ipv6_route.h
+++ b/include/linux/ipv6_route.h
@@ -13,6 +13,8 @@
 #ifndef _LINUX_IPV6_ROUTE_H
 #define _LINUX_IPV6_ROUTE_H
 
+#include <linux/types.h>
+
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* (deprecated and will be removed)
 					   fallback, no routers on link */
diff --git a/include/linux/ipx.h b/include/linux/ipx.h
index eb19b4e..aabb1d2 100644
--- a/include/linux/ipx.h
+++ b/include/linux/ipx.h
@@ -1,5 +1,6 @@
 #ifndef _IPX_H_
 #define _IPX_H_
+#include <linux/types.h>
 #include <linux/sockios.h>
 #include <linux/socket.h>
 #define IPX_NODE_LEN	6
diff --git a/include/linux/irda.h b/include/linux/irda.h
index 28f88ec..00bdad0 100644
--- a/include/linux/irda.h
+++ b/include/linux/irda.h
@@ -25,6 +25,8 @@
 #ifndef KERNEL_IRDA_H
 #define KERNEL_IRDA_H
 
+#include <linux/types.h>
+
 /* Please do *not* add any #include in this file, this file is
  * included as-is in user space.
  * Please fix the calling file to properly included needed files before
diff --git a/include/linux/minix_fs.h b/include/linux/minix_fs.h
index 0e39745..13fe09e 100644
--- a/include/linux/minix_fs.h
+++ b/include/linux/minix_fs.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_MINIX_FS_H
 #define _LINUX_MINIX_FS_H
 
+#include <linux/types.h>
 #include <linux/magic.h>
 
 /*
diff --git a/include/linux/msdos_fs.h b/include/linux/msdos_fs.h
index e0a9b20..ce38f1c 100644
--- a/include/linux/msdos_fs.h
+++ b/include/linux/msdos_fs.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_MSDOS_FS_H
 #define _LINUX_MSDOS_FS_H
 
+#include <linux/types.h>
 #include <linux/magic.h>
 #include <asm/byteorder.h>
 
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index bd3bbf6..8730d5d 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_NEIGHBOUR_H
 #define __LINUX_NEIGHBOUR_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 
 struct ndmsg
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
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 15a9f3b..91a1c24 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -37,6 +37,8 @@
 #ifndef NFS_IDMAP_H
 #define NFS_IDMAP_H
 
+#include <linux/types.h>
+
 /* XXX from bits/utmp.h  */
 #define IDMAP_NAMESZ  128
 
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
diff --git a/include/linux/nubus.h b/include/linux/nubus.h
index c435507..9f54a23 100644
--- a/include/linux/nubus.h
+++ b/include/linux/nubus.h
@@ -12,6 +12,8 @@
 #ifndef LINUX_NUBUS_H
 #define LINUX_NUBUS_H
 
+#include <linux/types.h>
+
 #ifdef __KERNEL__
 #include <asm/nubus.h>
 #endif
@@ -295,6 +297,7 @@ struct nubus_dev {
 	struct nubus_board* board;
 };
 
+#ifdef __KERNEL__
 /* This is all NuBus devices (used to find devices later on) */
 extern struct nubus_dev* nubus_devices;
 /* This is all NuBus cards */
@@ -303,7 +306,7 @@ extern struct nubus_board* nubus_boards;
 /* Generic NuBus interface functions, modelled after the PCI interface */
 void nubus_scan_bus(void);
 extern void nubus_proc_init(void);
-int get_nubus_list(char *buf);
+#endif /* __KERNEL__ */
 int nubus_proc_attach_device(struct nubus_dev *dev);
 int nubus_proc_detach_device(struct nubus_dev *dev);
 /* If we need more precision we can add some more of these */
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 4157faa..ee5e3c9 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -23,6 +23,8 @@
 #ifndef LINUX_PHONET_H
 #define LINUX_PHONET_H
 
+#include <linux/types.h>
+
 /* Automatic protocol selection */
 #define PN_PROTO_TRANSPORT	0
 /* Phonet datagram socket */
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index e6aa848..3c842ed 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_PKT_CLS_H
 #define __LINUX_PKT_CLS_H
 
+#include <linux/types.h>
 #include <linux/pkt_sched.h>
 
 /* I think i could have done better macros ; for now this is stolen from
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e3f133a..b2648e8 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_PKT_SCHED_H
 #define __LINUX_PKT_SCHED_H
 
+#include <linux/types.h>
+
 /* Logical priority bands not depending on specific packet scheduler.
    Every scheduler will map them to real traffic classes, if it has
    no more precise mechanism to classify packets.
diff --git a/include/linux/ppp_defs.h b/include/linux/ppp_defs.h
index 6e8adc7..428017e 100644
--- a/include/linux/ppp_defs.h
+++ b/include/linux/ppp_defs.h
@@ -40,6 +40,8 @@
 #ifndef _PPP_DEFS_H_
 #define _PPP_DEFS_H_
 
+#include <linux/types.h>
+
 /*
  * The basic PPP frame.
  */
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
diff --git a/include/linux/random.h b/include/linux/random.h
index 407ea36..25d02fe 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -7,6 +7,7 @@
 #ifndef _LINUX_RANDOM_H
 #define _LINUX_RANDOM_H
 
+#include <linux/types.h>
 #include <linux/ioctl.h>
 #include <linux/irqnr.h>
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index e88f705..1e5f673 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_RTNETLINK_H
 #define __LINUX_RTNETLINK_H
 
+#include <linux/types.h>
 #include <linux/netlink.h>
 #include <linux/if_link.h>
 #include <linux/if_addr.h>
diff --git a/include/linux/signalfd.h b/include/linux/signalfd.h
index bef0c46..b363b91 100644
--- a/include/linux/signalfd.h
+++ b/include/linux/signalfd.h
@@ -8,6 +8,7 @@
 #ifndef _LINUX_SIGNALFD_H
 #define _LINUX_SIGNALFD_H
 
+#include <linux/types.h>
 /* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 20fc4bb..f5771a2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -24,11 +24,6 @@ struct __kernel_sockaddr_storage {
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 
-#ifdef CONFIG_PROC_FS
-struct seq_file;
-extern void socket_seq_show(struct seq_file *seq);
-#endif
-
 typedef unsigned short	sa_family_t;
 
 /*
@@ -303,6 +298,11 @@ struct ucred {
 #define IPX_TYPE	1
 
 #ifdef __KERNEL__
+#ifdef CONFIG_PROC_FS
+struct seq_file;
+extern void socket_seq_show(struct seq_file *seq);
+#endif
+
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 extern int memcpy_fromiovecend(unsigned char *kdata, struct iovec *iov, 
 				int offset, int len);
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
diff --git a/include/linux/synclink.h b/include/linux/synclink.h
index c844a22..99b8bdb 100644
--- a/include/linux/synclink.h
+++ b/include/linux/synclink.h
@@ -13,6 +13,8 @@
 #define _SYNCLINK_H_
 #define SYNCLINK_H_VERSION 3.6
 
+#include <linux/types.h>
+
 #define BIT0	0x0001
 #define BIT1	0x0002
 #define BIT2	0x0004
diff --git a/include/linux/taskstats.h b/include/linux/taskstats.h
index 18269e9..341dddb 100644
--- a/include/linux/taskstats.h
+++ b/include/linux/taskstats.h
@@ -16,6 +16,8 @@
 #ifndef _LINUX_TASKSTATS_H
 #define _LINUX_TASKSTATS_H
 
+#include <linux/types.h>
+
 /* Format for per-task data returned to userland when
  *	- a task exits
  *	- listener requests stats for a task
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
diff --git a/include/linux/video_decoder.h b/include/linux/video_decoder.h
index 121e26d..e26c0c8 100644
--- a/include/linux/video_decoder.h
+++ b/include/linux/video_decoder.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_VIDEO_DECODER_H
 #define _LINUX_VIDEO_DECODER_H
 
+#include <linux/types.h>
+
 #define HAVE_VIDEO_DECODER 1
 
 struct video_decoder_capability { /* this name is too long */
diff --git a/include/linux/video_encoder.h b/include/linux/video_encoder.h
index 4b0e690..b7b6423 100644
--- a/include/linux/video_encoder.h
+++ b/include/linux/video_encoder.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_VIDEO_ENCODER_H
 #define _LINUX_VIDEO_ENCODER_H
 
+#include <linux/types.h>
+
 struct video_encoder_capability { /* this name is too long */
 	__u32	flags;
 #define	VIDEO_ENCODER_PAL	1	/* can encode PAL signal */
diff --git a/include/linux/videodev.h b/include/linux/videodev.h
index 15a653d..837f392 100644
--- a/include/linux/videodev.h
+++ b/include/linux/videodev.h
@@ -12,6 +12,7 @@
 #ifndef __LINUX_VIDEODEV_H
 #define __LINUX_VIDEODEV_H
 
+#include <linux/types.h>
 #include <linux/ioctl.h>
 #include <linux/videodev2.h>
 
diff --git a/include/linux/virtio_blk.h b/include/linux/virtio_blk.h
index c1aef85..596df80 100644
--- a/include/linux/virtio_blk.h
+++ b/include/linux/virtio_blk.h
@@ -3,6 +3,7 @@
 /* This header is BSD licensed so anyone can use the definitions to implement
  * compatible drivers/servers. */
 #include <linux/virtio_config.h>
+#include <linux/types.h>
 
 /* The ID for virtio_block */
 #define VIRTIO_ID_BLOCK	2
diff --git a/include/linux/virtio_console.h b/include/linux/virtio_console.h
index 7615ffc..061c167 100644
--- a/include/linux/virtio_console.h
+++ b/include/linux/virtio_console.h
@@ -4,6 +4,8 @@
 /* This header, excluding the #ifdef __KERNEL__ part, is BSD licensed so
  * anyone can use the definitions to implement compatible drivers/servers. */
 
+#include <linux/types.h>
+
 /* The ID for virtio console */
 #define VIRTIO_ID_CONSOLE	3
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..cf335fe 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -4,6 +4,8 @@
  * compatible drivers/servers. */
 #include <linux/virtio_config.h>
 
+#include <linux/types.h>
+
 /* The ID for virtio_net */
 #define VIRTIO_ID_NET	1
 
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
