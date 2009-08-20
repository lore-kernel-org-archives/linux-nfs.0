From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: mount.nfs: access denied by server
Date: Thu, 20 Aug 2009 15:19:00 +0800
Message-ID: <20090820071900.GA15657@localhost>
References: <20090820071315.GA14765@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23307 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861AbZHTHVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 03:21:13 -0400
In-Reply-To: <20090820071315.GA14765@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2009 at 03:13:15PM +0800, Wu Fengguang wrote:
> Hi,
> 
> After upgrading NFS client kernel to latest linux-next, NFS mount
> failed:
> 
>         # mount -t nfs pxe:/cc /cc
>         mount.nfs: access denied by server while mounting pxe:/cc
> 
>         # uname -a
>         Linux hp 2.6.31-rc6-next-20090818 #61 SMP Thu Aug 20 14:46:10 CST 2009 x86_64 GNU/Linux 
> 
> However server log says OK:
> 
>         Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated mount request from 192.168.11.6:973 for /cc (/cc)
>         Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated unmount request from 192.168.11.6:974 for /cc (/cc)
> 
> However-2: nfsroot can be mounted at boot time. Server kernel has always been 2.6.30.

Another bug:

[   29.096228] general protection fault: 0000 [#1] SMP
[   29.099602] last sysfs file: /sys/devices/virtual/net/sit0/flags
[   29.099602] CPU 1
[   29.099602] Modules linked in: drm iwlagn iwlcore snd_hda_codec_intelhdmi snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_seq snd_timer snd_seq_device snd soundcore snd_page_alloc
[   29.099602] Pid: 3104, comm: mount.nfs Not tainted 2.6.31-rc6-next-20090818 #61
[   29.099602] RIP: 0010:[<ffffffff812d5aa6>]  [<ffffffff812d5aa6>] __list_add+0x26/0xa0
[   29.099602] RSP: 0018:ffff88001a827d18  EFLAGS: 00010246
[   29.099602] RAX: ff880018fb288048 RBX: ffff880018fb2880 RCX: ffffffff81e0a6a0
[   29.099602] RDX: ffff880018fb2880 RSI: ff880018fb288048 RDI: ffff8800189df548
[   29.099602] RBP: ffff88001a827d38 R08: ffff880018fb29b8 R09: 0000000000000000
[   29.099602] R10: 0000000000000000 R11: 0000000000000000 R12: ff880018fb288048
[   29.099602] R13: ffff8800189df548 R14: ffff880018fb28f0 R15: ffff880018fb28f0
[   29.099602] FS:  0000000000000000(0000) GS:ffff880003a00000(0000) knlGS:0000000000000000
[   29.099602] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   29.099602] CR2: 00007fd2a085ab40 CR3: 0000000001001000 CR4: 00000000000006e0
[   29.099602] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   29.099602] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   29.099602] Process mount.nfs (pid: 3104, threadinfo ffff88001a826000, task ffff88001b568f00)
[   29.099602] Stack:
[   29.099602]  ffffffff81204ce8 ffff880018fb29a0 ffff880018fb28f0 ffff8800189df500
[   29.099602] <0> ffff88001a827d68 ffffffff81204d0a 0000000300000000 ffff88001888e200
[   29.099602] <0> ffff880018fb28f0 ffff880018fa1000 ffff88001a827d88 ffffffff81202a51
[   29.099602] Call Trace:
[   29.099602]  [<ffffffff81204ce8>] ? nfs_release+0x48/0x90
[   29.099602]  [<ffffffff81204d0a>] nfs_release+0x6a/0x90
[   29.099602]  [<ffffffff81202a51>] nfs_file_release+0x61/0x90
[   29.099602]  [<ffffffff8112ca1e>] __fput+0x11e/0x280
[   29.099602]  [<ffffffff8112cba5>] fput+0x25/0x30
[   29.099602]  [<ffffffff81183df8>] removed_exe_file_vma+0x38/0x50
[   29.099602]  [<ffffffff81104d10>] remove_vma+0x90/0xa0
[   29.099602]  [<ffffffff81104e18>] exit_mmap+0xf8/0x180
[   29.099602]  [<ffffffff8104d887>] mmput+0x67/0xd0
[   29.099602]  [<ffffffff81052ead>] exit_mm+0x11d/0x160
[   29.099602]  [<ffffffff81054c08>] do_exit+0x138/0x840
[   29.099602]  [<ffffffff8100c06a>] ? sysret_check+0x2e/0x69
[   29.099602]  [<ffffffff8105535c>] do_group_exit+0x4c/0xc0
[   29.099602]  [<ffffffff810553e7>] sys_exit_group+0x17/0x20
[   29.099602]  [<ffffffff8100c032>] system_call_fastpath+0x16/0x1b
[   29.099602] Code: 00 00 00 00 00 55 48 89 e5 48 83 ec 20 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 49 89 f4 48 8b 42 08 49 89 fd 48 89 d3 48 39 f0 75 27 <49> 8b 04 24 48 39 d8 75 43 4c 89 6b 08 49 89 5d 00 4d 89 65 08
[   29.359600] RIP  [<ffffffff812d5aa6>] __list_add+0x26/0xa0
[   29.359600]  RSP <ffff88001a827d18>
[   29.369139] ---[ end trace 8c118d638a30b42e ]---
[   29.373847] Fixing recursive fault but reboot is needed!

Thanks,
Fengguang

