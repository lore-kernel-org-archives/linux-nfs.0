From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE:
Date: Sun, 27 Jul 2008 18:37:03 -0400
Message-ID: <1217198223.7507.3.camel@localhost>
References: <alpine.LFD.1.10.0807271037190.3486@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759483AbYG0WhX@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.10.0807271037190.3486@nehalem.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-07-27 at 10:40 -0700, Linus Torvalds wrote:
> Trond?
> 
> See 'http://lkml.org/lkml/2008/7/17/154'? It's been 10+ days, it's 
> apparently still there.
> 
> 		Linus

Sure thing...

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/super.c  |    6 +++---
 fs/nfs/unlink.c |    3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

commit 744d18dbfae07482ea461701b0aaec3a75ec9224
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 27 18:03:19 2008 -0400

    NFS: Ensure we call nfs_sb_deactive() after releasing the directory inode
    
    In order to avoid the "Busy inodes after unmount" error message, we need to
    ensure that nfs_async_unlink_release() releases the super block after the
    call to nfs_free_unlinkdata().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 31c9446993f412ecb7875e30bba4bc7f216ae016
Author: Marc Zyngier <maz@misterjones.org>
Date:   Thu Jul 17 13:21:55 2008 +0200

    nfs_remount oops when rebooting + possible fix
    
    Jeff, Trond,
    
    The commit
    
    48b605f83c920d8daa50e43fc2c7f718e04c7bfa (NFS: implement option checking
    when remounting NFS filesystems (resend))
    
    generate an Oops on my platform when rebooting while its root FS on
    an NFS share (NFSv3, TCP) :
    
    Unmounting local filesystems...done.
    Unable to handle kernel NULL pointer dereference at virtual address 00000000
    pgd = c3d00000
    [00000000] *pgd=a3d72031, *pte=00000000, *ppte=00000000
    Internal error: Oops: 17 [#1]
    Modules linked in: cpufreq_powersave cpufreq_ondemand cpufreq_userspace cpufreq_conservative ext3 jbd sd_mod pata_pcmcia libata scsi_mod pcmcia loop firmware_class pxafb cfbcopyarea cfbimgblt cfbfillrect pxa2xx_cs pxa2xx_core pcmcia_core snd_pxa2xx_ac97 snd_ac97_codec ac97_bus snd_pxa2xx_pcm snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd isp116x_hcd soundcore rtc_sa1100 snd_page_alloc pxa25x_udc usbcore rtc_ds1307 rtc_core
    CPU: 0    Not tainted  (2.6.26-03414-g33af79d-dirty #15)
    PC is at nfs_remount+0x40/0x264
    LR is at do_remount_sb+0x158/0x194
    pc : [<c00bbf54>]    lr : [<c0076c40>]    psr: 60000013
    sp : c2dd1e70  ip : c2dd1e98  fp : c2dd1e94
    r10: 00000040  r9 : c3d17000  r8 : c3c3fc40
    r7 : 00000000  r6 : 00000000  r5 : c3d2b200  r4 : 00000000
    r3 : 00000003  r2 : 00000000  r1 : c2dd1e9c  r0 : c3c3fc00
    Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
    Control: 0000397f  Table: a3d00000  DAC: 00000015
    Process mount (pid: 1462, stack limit = 0xc2dd0270)
    Stack: (0xc2dd1e70 to 0xc2dd2000)
    1e60:                                     00000000 c3c3fc00 00000000 00000000
    1e80: c3c3fc40 c3d17000 c2dd1ebc c2dd1e98 c0076c40 c00bbf20 c01c61e4 00000001
    1ea0: c2dd1ebc 00000001 c3c3fc00 c2dd1ef0 c2dd1ee4 c2dd1ec0 c008c6d8 c0076af4
    1ec0: 00000021 00000040 c2dd1ef0 c3d77000 c3eaa000 00000000 c2dd1f6c c2dd1ee8
    1ee0: c008d1bc c008c5f8 00000000 c2dd0000 c3c0c320 c3805b38 c002064c 0001f820
    1f00: 0001f810 00000001 00000001 00000000 c2dd0000 00000000 c2dd1f34 c2dd1f28
    1f20: c005ead8 c005e6f8 c2dd1f44 c2dd1f38 c005eaf8 c005ead0 c2dd1f6c c2dd1f48
    1f40: c008ae3c 00000000 c3d77000 0001f810 c0ed0021 c0020ca8 c2dd0000 00000000
    1f60: c2dd1fa4 c2dd1f70 c008d2d4 c008d0bc 00000000 0001f810 c2dd1f9c c3eaa000
    1f80: c3d17000 00000000 00000000 be8b6aa8 be8b6ad0 00000015 00000000 c2dd1fa8
    1fa0: c0020b00 c008d254 00000000 be8b6aa8 0001f810 0001f820 0001f830 c0ed0021
    1fc0: 00000000 be8b6aa8 be8b6ad0 00000015 00000000 be8b6ad0 0001f810 be8b6aa8
    1fe0: 0001f810 be8b6964 0000aab8 40125124 60000010 0001f810 00000000 00000000
    Backtrace:
    [<c00bbf14>] (nfs_remount+0x0/0x264) from [<c0076c40>] (do_remount_sb+0x158/0x194)
      r9:c3d17000 r8:c3c3fc40 r7:00000000 r6:00000000 r5:c3c3fc00
    r4:00000000
    [<c0076ae8>] (do_remount_sb+0x0/0x194) from [<c008c6d8>] (do_remount+0xec/0x118)
      r6:c2dd1ef0 r5:c3c3fc00 r4:00000001
    [<c008c5ec>] (do_remount+0x0/0x118) from [<c008d1bc>] (do_mount+0x10c/0x198)
    [<c008d0b0>] (do_mount+0x0/0x198) from [<c008d2d4>] (sys_mount+0x8c/0xd4)
    [<c008d248>] (sys_mount+0x0/0xd4) from [<c0020b00>] (ret_fast_syscall+0x0/0x2c)
      r7:00000015 r6:be8b6ad0 r5:be8b6aa8 r4:00000000
    Code: 0a000086 ea000006 e3530003 8a000004 (e5923000)
    ---[ end trace 55e1b689cf8c8a6a ]---
    ------------[ cut here ]------------
    WARNING: at kernel/exit.c:966 do_exit+0x3c/0x628()
    Modules linked in: cpufreq_powersave cpufreq_ondemand cpufreq_userspace cpufreq_conservative ext3 jbd sd_mod pata_pcmcia libata scsi_mod pcmcia loop firmware_class pxafb cfbcopyarea cfbimgblt cfbfillrect pxa2xx_cs pxa2xx_core pcmcia_core snd_pxa2xx_ac97 snd_ac97_codec ac97_bus snd_pxa2xx_pcm snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd isp116x_hcd soundcore rtc_sa1100 snd_page_alloc pxa25x_udc usbcore rtc_ds1307 rtc_core
    [<c0025168>] (dump_stack+0x0/0x14) from [<c0032154>] (warn_on_slowpath+0x4c/0x68)
    [<c0032108>] (warn_on_slowpath+0x0/0x68) from [<c003531c>] (do_exit+0x3c/0x628)
      r6:0000000b r5:c3c3dc80 r4:c2dd0000
    [<c00352e0>] (do_exit+0x0/0x628) from [<c0025004>] (die+0x2b0/0x30c)
    [<c0024d54>] (die+0x0/0x30c) from [<c00270bc>] (__do_kernel_fault+0x6c/0x80)
    [<c0027050>] (__do_kernel_fault+0x0/0x80) from [<c00272e0>] (do_page_fault+0x210/0x230)
      r7:c3fa7118 r6:c3c3dc80 r5:c3d166a8 r4:00010000
    [<c00270d0>] (do_page_fault+0x0/0x230) from [<c00201ec>] (do_DataAbort+0x3c/0xa0)
    [<c00201b0>] (do_DataAbort+0x0/0xa0) from [<c002064c>] (__dabt_svc+0x4c/0x60)
    Exception stack(0xc2dd1e28 to 0xc2dd1e70)
    1e20:                   c3c3fc00 c2dd1e9c 00000000 00000003 00000000 c3d2b200
    1e40: 00000000 00000000 c3c3fc40 c3d17000 00000040 c2dd1e94 c2dd1e98 c2dd1e70
    1e60: c0076c40 c00bbf54 60000013 ffffffff
      r8:c3c3fc40 r7:00000000 r6:00000000 r5:c2dd1e5c r4:ffffffff
    [<c00bbf14>] (nfs_remount+0x0/0x264) from [<c0076c40>] (do_remount_sb+0x158/0x194)
      r9:c3d17000 r8:c3c3fc40 r7:00000000 r6:00000000 r5:c3c3fc00
    r4:00000000
    [<c0076ae8>] (do_remount_sb+0x0/0x194) from [<c008c6d8>] (do_remount+0xec/0x118)
      r6:c2dd1ef0 r5:c3c3fc00 r4:00000001
    [<c008c5ec>] (do_remount+0x0/0x118) from [<c008d1bc>] (do_mount+0x10c/0x198)
    [<c008d0b0>] (do_mount+0x0/0x198) from [<c008d2d4>] (sys_mount+0x8c/0xd4)
    [<c008d248>] (sys_mount+0x0/0xd4) from [<c0020b00>] (ret_fast_syscall+0x0/0x2c)
      r7:00000015 r6:be8b6ad0 r5:be8b6aa8 r4:00000000
    ---[ end trace 55e1b689cf8c8a6a ]---
    /etc/rc6.d/S60umountroot: line 17:  1462 Segmentation fault      mount $MOUNT_FORCE_OPT -n -o remount,ro -t dummytype dummydev / 2> /dev/null
    
    The new super.c:nfs_remount function doesn't check the validity of the
    options/options4 pointers. Unfortunately, this seems to happend.
    The obvious patch seems to check the pointers, and not to do anything if
    the happend to be NULL.
    
    Tested on an XScale PXA255 system, latest git.
    
    Regards,
    
    	M.
    
    Signed-off-by: Marc Zyngier <marc.zyngier@altran.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1b94e36..9abcd2b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1718,9 +1718,9 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	 * ones were explicitly specified. Fall back to legacy behavior and
 	 * just return success.
 	 */
-	if ((nfsvers == 4 && options4->version == 1) ||
-	    (nfsvers <= 3 && options->version >= 1 &&
-	     options->version <= 6))
+	if ((nfsvers == 4 && (!options4 || options4->version == 1)) ||
+	    (nfsvers <= 3 && (!options || (options->version >= 1 &&
+					   options->version <= 6))))
 		return 0;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 3adf8b2..f089e58 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -95,10 +95,11 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 static void nfs_async_unlink_release(void *calldata)
 {
 	struct nfs_unlinkdata	*data = calldata;
+	struct super_block *sb = data->dir->i_sb;
 
 	nfs_dec_sillycount(data->dir);
-	nfs_sb_deactive(NFS_SERVER(data->dir));
 	nfs_free_unlinkdata(data);
+	nfs_sb_deactive(NFS_SB(sb));
 }
 
 static const struct rpc_call_ops nfs_unlink_ops = {


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
