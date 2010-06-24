From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/10] pnfs-submit add layoutget,layoutreturn error handling
 version 2
Date: Thu, 24 Jun 2010 16:14:02 +0300
Message-ID: <4C235A1A.1060508@panasas.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60518 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755262Ab0FXNOG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jun 2010 09:14:06 -0400
In-Reply-To: <1277320878-3726-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 23, 2010, 22:21 +0300, andros@netapp.com wrote:
> Responded to comments, added a 2 cleanup patchses
> 
> Plus some code cleanup
> 0001-SQUASHME-pnfs-submit-remove-unused-filelayout_mount_.patch
> 
> and some bug fixes
> 0002-SQUASHME-pnfs-submit-pnfs_try_to_read-write-commit-u.patch
> 
> NOTE: this patch: 0003-SQUASHME-pnfs-submit-tell-commit-to-use-the-MDS.patch
> was replaced by:
> 0003-SQUASHME-pnfs-submit-clear-page-lseg-on-partial-i-o.patch
> 
> 
> Remove unused (by file layout) encode_layoutreturn io operation
> 0004-SQUASHME-pnfs-submit-remove-encode_layoutreturn.patch
> 0005-SQUASHME-pnfs-submit-add-error-handling-to-layout-re.patch
> 
> 0006-SQUASHME-pnfs-submit-handle-assassinated-layoutcommi.patch
> 
> Note: pnfs4_proc_layoutget is only called by send_layout() which prints
> the status.
> 0007-SQUASHME-pnfs-submit-add-error-handlers-to-layout-ge.patch
> 
> Add back encode_layoutreturn io operation
> 0008-pnfs-post-submit-restore-encode_layoutreturn.patch
> 
> 
> New patches:
> 0009-SQUASHME-pnfs-submit-don-t-re-initialize-i_lock.patch
> 
> This gets rid of a frame stack warning;
> 0010-SQUASHME-pnfs-submit-remove-struct-nfs_server-from-s.patch
> 
> Testing:
> ---------
> 
> CONFIG_NFS_V4_1 set: NFSv4.0 NFSv4.1 pNFS
> Passes Connectathon tests
> 
> Tested layoutget and layoutreturn recovery from NFS4ERR_DEAD_SESSION with the
> pyNFS server and the testclient framework.
> 
> Still todo:
> 
> Recover from NFS4ERR_BAD_STATEID. Currently layoutreturn, layoutget, and
> layoutcommit do not pass nfs_stste to the error handlers.
> 
> Handle NFS4ERR_BAD_LAYOUT.
> 
> CONFIG_NFS_V4_1 not set: NFSv4.o mount passes cthon tests.
> 
> -->Andy

Andy, I've hit
	BUG_ON(lo->refcount <= 0);
in put_layout() with this patchset.
I'm not sure if it introduced it or not, still investigating...

Jun 24 12:07:26 tl2 kernel: pnfs_destroy_inode: WARNING: layout.refcount 1
Jun 24 12:07:26 tl2 kernel: ------------[ cut here ]------------
Jun 24 12:07:26 tl2 kernel: kernel BUG at /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/pnfs.c:341!
Jun 24 12:07:26 tl2 kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
Jun 24 12:07:26 tl2 kernel: last sysfs file: /sys/module/nfs/initstate
Jun 24 12:07:26 tl2 kernel: CPU 1 
Jun 24 12:07:26 tl2 kernel: Modules linked in: nfslayoutdriver nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc osd libosd autofs4 crc32c ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi cpufreq_ondemand acpi_cpufreq freq_table mperf ext3 jbd dm_mirror dm_region_hash dm_log dm_multipath dm_mod kvm_intel kvm snd_hda_codec_realtek i915 drm_kms_helper drm snd_hda_intel snd_hda_codec snd_hwdep i2c_algo_bit snd_seq i2c_i801 i2c_core snd_seq_device snd_pcm r8169 mii snd_timer sr_mod snd soundcore snd_page_alloc button video output rng_core sg cdrom ata_generic ata_piix libata sd_mod scsi_mod ext4 mbcache jbd2 crc16 uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
Jun 24 12:07:26 tl2 kernel:
Jun 24 12:07:26 tl2 kernel: Pid: 1920, comm: rpciod/1 Not tainted 2.6.35-rc3-pnfs+ #54 G31M4 (MS-7527)/MS-7527
Jun 24 12:07:26 tl2 kernel: RIP: 0010:[<ffffffffa05d0ea4>]  [<ffffffffa05d0ea4>] put_layout+0x2f/0xa7 [nfs]
Jun 24 12:07:26 tl2 kernel: RSP: 0018:ffff88007525dd20  EFLAGS: 00010246
Jun 24 12:07:26 tl2 kernel: RAX: 0000000000000000 RBX: ffff8800704b6b78 RCX: 0000000000000066
Jun 24 12:07:26 tl2 kernel: RDX: ffff8800704b69a8 RSI: ffffea0001b931a8 RDI: ffff8800704b6b78
Jun 24 12:07:26 tl2 kernel: RBP: ffff88007525dd30 R08: 0000000000000000 R09: ffff88007356a500
Jun 24 12:07:26 tl2 kernel: R10: ffff88007525dd80 R11: 0000000000000003 R12: ffff8800704b69a8
Jun 24 12:07:26 tl2 kernel: R13: ffff880073854f00 R14: ffff88007356a508 R15: ffff88007356a590
Jun 24 12:07:26 tl2 kernel: FS:  0000000000000000(0000) GS:ffff880001a80000(0000) knlGS:0000000000000000
Jun 24 12:07:26 tl2 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Jun 24 12:07:26 tl2 kernel: CR2: 0000003944279000 CR3: 0000000001698000 CR4: 00000000000406e0
Jun 24 12:07:26 tl2 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jun 24 12:07:26 tl2 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jun 24 12:07:26 tl2 kernel: Process rpciod/1 (pid: 1920, threadinfo ffff88007525c000, task ffff88007d988000)
Jun 24 12:07:26 tl2 kernel: Stack:
Jun 24 12:07:26 tl2 kernel: ffff8800704b6b78 ffff8800704b69a8 ffff88007525dd60 ffffffffa05d203f
Jun 24 12:07:26 tl2 kernel: <0> ffff88007525dd60 ffff880073854f18 ffff880073854f00 ffffffffa05d5880
Jun 24 12:07:26 tl2 kernel: <0> ffff88007525dd80 ffffffffa05bfb5c ffff88007525dd90 ffff88007356a500
Jun 24 12:07:26 tl2 kernel: Call Trace:
Jun 24 12:07:26 tl2 kernel: [<ffffffffa05d203f>] pnfs_layout_release+0x43/0x68 [nfs]
Jun 24 12:07:26 tl2 kernel: [<ffffffffa05bfb5c>] nfs4_pnfs_layoutreturn_release+0x61/0x8b [nfs]
Jun 24 12:07:26 tl2 kernel: [<ffffffffa056207d>] rpc_release_calldata+0x17/0x19 [sunrpc]
Jun 24 12:07:26 tl2 kernel: [<ffffffffa05621bd>] rpc_free_task+0x5e/0x66 [sunrpc]
Jun 24 12:07:26 tl2 kernel: [<ffffffffa056225d>] rpc_put_task+0x98/0x9c [sunrpc]
Jun 24 12:07:26 tl2 kernel: [<ffffffffa0562ea7>] __rpc_execute+0x205/0x212 [sunrpc]
Jun 24 12:07:26 tl2 kernel: [<ffffffffa0562ef0>] rpc_async_schedule+0x15/0x17 [sunrpc]
Jun 24 12:07:26 tl2 kernel: [<ffffffff81052cb7>] worker_thread+0x1aa/0x23b
Jun 24 12:07:26 tl2 kernel: [<ffffffffa0562edb>] ? rpc_async_schedule+0x0/0x17 [sunrpc]
Jun 24 12:07:26 tl2 kernel: [<ffffffff81056ab7>] ? autoremove_wake_function+0x0/0x39
Jun 24 12:07:26 tl2 kernel: [<ffffffff8102f96d>] ? spin_unlock_irqrestore+0xe/0x10
Jun 24 12:07:26 tl2 kernel: [<ffffffff81052b0d>] ? worker_thread+0x0/0x23b
Jun 24 12:07:26 tl2 kernel: [<ffffffff81056645>] kthread+0x7f/0x87
Jun 24 12:07:26 tl2 kernel: [<ffffffff81003a24>] kernel_thread_helper+0x4/0x10
Jun 24 12:07:26 tl2 kernel: [<ffffffff810565c6>] ? kthread+0x0/0x87
Jun 24 12:07:26 tl2 kernel: [<ffffffff81003a20>] ? kernel_thread_helper+0x0/0x10
Jun 24 12:07:26 tl2 kernel: Code: 41 54 53 0f 1f 44 00 00 8b 87 24 01 00 00 48 89 fb 48 8d 97 30 fe ff ff 89 c1 c1 f9 08 38 c1 75 04 0f 0b eb fe 8b 07 85 c0 7f 04 <0f> 0b eb fe ff c8 85 c0 89 07 75 67 48 8b 82 48 03 00 00 f6 05 
Jun 24 12:07:26 tl2 kernel: RIP  [<ffffffffa05d0ea4>] put_layout+0x2f/0xa7 [nfs]
Jun 24 12:07:27 tl2 kernel: RSP <ffff88007525dd20>
Jun 24 12:07:27 tl2 kernel: ---[ end trace 0468384c0ab45a1f ]---
