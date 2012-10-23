Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36819 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757110Ab2JWQq1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 12:46:27 -0400
Date: Tue, 23 Oct 2012 12:46:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nix <nix@esperi.org.uk>
Cc: "Ted Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: Heads-up: 3.6.2 / 3.6.3 NFS server oops: 3.6.2+ regression?
 (also an unrelated ext4 data loss bug)
Message-ID: <20121023164621.GC3040@fieldses.org>
References: <87objupjlr.fsf@spindle.srvr.nix>
 <20121023013343.GB6370@fieldses.org>
 <87mwzdnuww.fsf@spindle.srvr.nix>
 <20121023143019.GA3040@fieldses.org>
 <874nllxi7e.fsf_-_@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874nllxi7e.fsf_-_@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 23, 2012 at 05:32:21PM +0100, Nix wrote:
> On 23 Oct 2012, J. Bruce Fields uttered the following:
> > nfs-utils shouldn't be capable of oopsing the kernel, so from my
> > (selfish) point of view I'd actually rather you stick with whatever you
> > have and try to reproduce the oops.
> 
> Reproduced in 3.6.3, not in 3.6.1, not tried 3.6.2. Capturing it was
> rendered somewhat difficult by an ext4/JBD2 bug which leads to data loss
> in /var on every reboot out of 3.6.1 and on some reboots out of 3.6.3 (I
> have runs of NULs in my logs now, which keep eating the oopses):
> 
> [while in 3.6.1]
> [   88.565698] JBD2: Spotted dirty metadata buffer (dev = dm-5, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
> [   88.799263] JBD2: Spotted dirty metadata buffer (dev = dm-5, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
> [   89.648152] ------------[ cut here ]------------
> [   89.648386] WARNING: at fs/inode.c:280 drop_nlink+0x25/0x42()
> [   89.648614] Hardware name: empty
> [   89.648833] Modules linked in: firewire_ohci firewire_core [last unloaded: microcode]
> [   89.649382] Pid: 1484, comm: dhcpd Not tainted 3.6.1-dirty #1
> [   89.649610] Call Trace:
> [   89.649832]  [<ffffffff810608c0>] warn_slowpath_common+0x83/0x9b
> [   89.650063]  [<ffffffff810608f2>] warn_slowpath_null+0x1a/0x1c
> [   89.650292]  [<ffffffff8112efbf>] drop_nlink+0x25/0x42
> [   89.650533]  [<ffffffff81187112>] ext4_dec_count+0x26/0x28
> [   89.650763]  [<ffffffff8118abb8>] ext4_rename+0x4ec/0x7b4
> [   89.650993]  [<ffffffff81125d81>] ? vfs_rename+0xbe/0x3b7
> [   89.651224]  [<ffffffff81125f3f>] vfs_rename+0x27c/0x3b7
> [   89.651454]  [<ffffffff81127a53>] sys_renameat+0x1b1/0x228
> [   89.651682]  [<ffffffff8114bda1>] ? fsnotify+0x226/0x249
> [   89.651911]  [<ffffffff81239b75>] ? security_inode_permission+0x1e/0x20
> [   89.652145]  [<ffffffff8111a240>] ? vfs_write+0x116/0x142
> [   89.652372]  [<ffffffff81127ae5>] sys_rename+0x1b/0x1e
> [   89.652601]  [<ffffffff814fffa2>] system_call_fastpath+0x16/0x1b
> [...]
> [while having just booted into 3.6.1 after some time in 3.6.3: the FS
>  was clean, and fscked on the previous boot into 3.6.3 after a previous
>  instance of this bug]
> Oct 23 17:18:26 spindle crit: [   67.625319] EXT4-fs error (device dm-5): mb_free_blocks:1300: group 65, block 2143748:freeing already freed block (bit 13828)
> 
> This may well be a 3.6.1-specific bug fixed in 3.6.3, but it's hard to
> tell since most of my reboots are 3.6.1->3.6.3 or vice versa right now.
> 
> 
> Anyway, here's the NFSv4 oops (not a panic: it helps if I remember to
> turn off panic_on_oops when I come home from the holidays).
> 
> It's a lockd problem, and probably happens during delivery of mail over
> NFS (my mailserver load soars when it happens):
> 
> [  813.110354] ------------[ cut here ]------------
> [  813.110585] kernel BUG at fs/lockd/mon.c:150!

So nsm_mon_unmon() is being passed a NULL client.

There are three container patches between 3.6.1 and 3.6.3:

	lockd: per-net NSM client creation and destruction helpers introduced
	lockd: use rpc client's cl_nodename for id encoding
	lockd: create and use per-net NSM RPC clients on MON/UNMON requests

and that last does change nsm_monitor's call to nsm_mon_unmon, so that's
almost certainly it....

Looks like there's some confusion about whether nsm_client_get() returns
NULL or an error?

--b.

> [  813.110878] invalid opcode: 0000 [#1] SMP
> [  813.111173] Modules linked in: firewire_ohci firewire_core [last unloaded: microcode]
> [  813.111727] CPU 1
> [  813.111772] Pid: 1040, comm: lockd Not tainted 3.6.3-dirty #1 empty empty/S7010
> [  813.112388] RIP: 0010:[<ffffffff8120fbbc>]  [<ffffffff8120fbbc>] nsm_mon_unmon+0x64/0x98
> [  813.112840] RSP: 0018:ffff88062163dcf0  EFLAGS: 00010246
> [  813.113069] RAX: ffff88062163dcf8 RBX: 0000000000000000 RCX: 0000000000000000
> [  813.113303] RDX: ffff88062163dd68 RSI: 0000000000000002 RDI: ffff88062163dd40
> [  813.113537] RBP: ffff88062163dd50 R08: 0000000000000000 R09: ffffffff8120c463
> [  813.113771] R10: ffffffff8120c463 R11: 0000000000000001 R12: 0000000000000000
> [  813.114006] R13: ffff88061f067e40 R14: ffff88059c763a00 R15: ffff88062163de28
> [  813.114241] FS:  0000000000000000(0000) GS:ffff88063fc40000(0000) knlGS:0000000000000000
> [  813.114651] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  813.114882] CR2: ffffffffff600400 CR3: 0000000001a0b000 CR4: 00000000000007e0
> [  813.115116] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  813.115350] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  813.115584] Process lockd (pid: 1040, threadinfo ffff88062163c000, task ffff880621611640)
> [  813.115994] Stack:
> [  813.116210]  ffff88062163dd90 ffff8805f4e044b1 00000003000186b5 ffffffff00000010
> [  813.116761]  ffff8805f4e044c1 000000000000008c 0000000000000000 ffff88062163dcf8
> [  813.117310]  ffff88062163dd68 0000000000000000 ffff8806200ce088 ffff8805f4e04400
> [  813.117861] Call Trace:
> [  813.118083]  [<ffffffff8120fee4>] nsm_monitor+0x100/0x157
> [  813.118315]  [<ffffffff81211b4a>] nlm4svc_retrieve_args+0x62/0xd7
> [  813.118547]  [<ffffffff81211f49>] nlm4svc_proc_lock+0x3c/0xb5
> [  813.118779]  [<ffffffff8121167b>] ? nlm4svc_decode_lockargs+0x47/0xb2
> [  813.119016]  [<ffffffff814d89ca>] svc_process+0x3bf/0x6a1
> [  813.119246]  [<ffffffff8120d5f0>] lockd+0x127/0x164
> [  813.119474]  [<ffffffff8120d4c9>] ? set_grace_period+0x8a/0x8a
> [  813.119708]  [<ffffffff8107bcbc>] kthread+0x8b/0x93
> [  813.119938]  [<ffffffff815012f4>] kernel_thread_helper+0x4/0x10
> [  813.120170]  [<ffffffff8107bc31>] ? kthread_worker_fn+0xe1/0xe1
> [  813.120401]  [<ffffffff815012f0>] ? gs_change+0xb/0xb
> [  813.120628] Code: b8 10 00 00 00 48 89 45 c0 48 8d 81 8c 00 00 00 b9 08 00 00 00 48 89 45 c8 89 d8 f3 ab 48 8d 45 a8 48 89 55 e0 48 89 45 d8 75 02 <0f> 0b 89 f6 48 c7 02 00 00 00 00 4c 89 c7 48 6b f6 38 ba 00 04
> [  813.123627] RIP  [<ffffffff8120fbbc>] nsm_mon_unmon+0x64/0x98
> [  813.123894]  RSP <ffff88062163dcf0>
> [  813.124129] ---[ end trace 11eb11a091ffd910 ]---
> 
> Aside: I am running with this patch, to prevent mounting of one
> NFS-mounted directory under another from failing all accesses with a
> spurious -EBUSY, a 3.6 regression -- but I can't see how this could
> cause it. I'm running with this in 3.6.1 as well:
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 8086636..649a112 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -2404,6 +2404,10 @@ out_unalias:
>  	if (likely(!d_mountpoint(alias))) {
>  		__d_move(alias, dentry);
>  		ret = alias;
> +	} else {
> +		printk(KERN_WARNING "VFS: __d_move()ing a d_mountpoint(), uh oh\n");
> +		__d_move(alias, dentry);
> +		ret = alias;
>  	}
>  out_err:
>  	spin_unlock(&inode->i_lock);
> 
