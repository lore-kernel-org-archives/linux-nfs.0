Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60177 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253AbbGJVKy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 17:10:54 -0400
Date: Fri, 10 Jul 2015 17:10:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        william@gandi.net
Subject: Re: [RFC PATCH 0/4] locks/nfs: fix use-after-free problem in unlock
 codepath
Message-ID: <20150710211054.GB7665@fieldses.org>
References: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 04:33:30PM -0400, Jeff Layton wrote:
> William Dauchy reported some instability after trying to apply
> db2efec0caba to the v3.14 stable series kernels. The problem was that
> that patch had us taking an extra reference to the filp in the NFSv4
> unlock code. If we're unlocking locks on task exit though, then we may
> be taking a reference after the last reference had already been put.
> 
> This fixes the problem in a different way. Most of the locking code is
> not terribly concerned with the actual filp, but rather with the inode.
> So we can fix this by adding helpers {flock|posix}_inode_lock_wait
> helpers and using those from the NFSv4 code. We _know_ that we hold a
> reference to the inode by virtue of the NFS open context, so this should
> be safe.
> 
> I intend to do some more testing of this set over the weekend, but wanted
> to get this out there so we can go ahead and get the patch reverted and
> get some early feedback.
> 
> Jeff Layton (4):
>   Revert "nfs: take extra reference to fl->fl_file when running a LOCKU
>     operation"
>   locks: have flock_lock_file take an inode pointer instead of a filp
>   locks: new helpers - flock_lock_inode_wait and posix_lock_inode_wait
>   nfs4: have do_vfs_lock take an inode pointer
> 
>  fs/locks.c         | 60 ++++++++++++++++++++++++++++++++++++++----------------
>  fs/nfs/nfs4proc.c  | 18 ++++++++--------
>  include/linux/fs.h | 14 +++++++++++++
>  3 files changed, 65 insertions(+), 27 deletions(-)

By the way, I noticed just yesterday that my testing of recent upstream
was failing--processes getting stuck in some lock tests, with log
warnings as appended below.  After applying these four patches it looks
like that's no longer happening.

I can run some more tests over the weekend if that'd help confirm.

Definitely in favor of expediting these fixes if possible as it was
blocking my testing and looks easy to reproduce.  But I haven't reviewed
them yet.

--b.

[  158.972038] ------------[ cut here ]------------
[  158.972346] WARNING: CPU: 0 PID: 0 at kernel/rcu/tree.c:2694
rcu_process_callbacks+0x6d1/0x980()
[  158.972893] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs nfsd
auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
[  158.974257] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.2.0-rc1-00004-gfbb2913 #222
[  158.974714] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140709_153950- 04/01/2014
[  158.975307]  ffffffff81f0a3de ffff88007f803e28 ffffffff81ac1cf7
0000000000000102
[  158.976022]  0000000000000000 ffff88007f803e68 ffffffff81078ec6
0000000100000000
[  158.976022]  ffff88007f8160c0 0000000000000002 0000000000000000
0000000000000246
[  158.976022] Call Trace:
[  158.976022]  <IRQ>  [<ffffffff81ac1cf7>] dump_stack+0x4f/0x7b
[  158.976022]  [<ffffffff81078ec6>] warn_slowpath_common+0x86/0xc0
[  158.976022]  [<ffffffff81078fba>] warn_slowpath_null+0x1a/0x20
[  158.976022]  [<ffffffff810e1691>] rcu_process_callbacks+0x6d1/0x980
[  158.976022]  [<ffffffff810e127d>] ? rcu_process_callbacks+0x2bd/0x980
[  158.976022]  [<ffffffff810b6466>] ? run_rebalance_domains+0x156/0x3d0
[  158.976022]  [<ffffffff810b6315>] ? run_rebalance_domains+0x5/0x3d0
[  158.976022]  [<ffffffff8107d834>] __do_softirq+0xd4/0x5f0
[  158.976022]  [<ffffffff8107de9c>] irq_exit+0x5c/0x60
[  158.976022]  [<ffffffff81acdee6>] smp_apic_timer_interrupt+0x46/0x60
[  158.976022]  [<ffffffff81acc2ad>] apic_timer_interrupt+0x6d/0x80
[  158.976022]  <EOI>  [<ffffffff8100dd55>] ? default_idle+0x25/0x210
[  158.976022]  [<ffffffff8100dd53>] ? default_idle+0x23/0x210
[  158.976022]  [<ffffffff8100e4ef>] arch_cpu_idle+0xf/0x20
[  158.976022]  [<ffffffff810bd37a>] default_idle_call+0x2a/0x40
[  158.976022]  [<ffffffff810bd607>] cpu_startup_entry+0x217/0x450
[  158.976022]  [<ffffffff81abc074>] rest_init+0x134/0x140
[  158.976022]  [<ffffffff82354ebe>] start_kernel+0x43c/0x449
[  158.976022]  [<ffffffff82354495>] x86_64_start_reservations+0x2a/0x2c
[  158.976022]  [<ffffffff8235457d>] x86_64_start_kernel+0xe6/0xea
[  158.976022] ---[ end trace 9d29787e24defe89 ]---
[  245.953371] general protection fault: 0000 [#1] PREEMPT SMP
DEBUG_PAGEALLOC 
[  245.954280] Modules linked in: nfsv3 rpcsec_gss_krb5 nfsv4 nfs nfsd
auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
[  245.955795] CPU: 1 PID: 6604 Comm: plock_tests Tainted: G        W
4.2.0-rc1-00004-gfbb2913 #222
[  245.956098] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140709_153950- 04/01/2014
[  245.956098] task: ffff8800502ec0c0 ti: ffff8800576cc000 task.ti:
ffff8800576cc000
[  245.956098] RIP: 0010:[<ffffffff811ae3c1>]  [<ffffffff811ae3c1>]
filp_close+0x31/0x80
[  245.956098] RSP: 0018:ffff8800576cfbf8  EFLAGS: 00010206
[  245.956098] RAX: 5d5f415e415d415c RBX: ffff8800727dee40 RCX:
ffff880063c00dd0
[  245.956098] RDX: 0000000080000000 RSI: ffff880063c00cc0 RDI:
ffff8800727dee40
[  245.956098] RBP: ffff8800576cfc18 R08: 0000000000000000 R09:
0000000000000001
[  245.956098] R10: 0000000000000000 R11: 0000000000000000 R12:
0000000000000000
[  245.956098] R13: ffff880063c00cc0 R14: ffff880063c00d18 R15:
0000000000000007
[  245.956098] FS:  00007f3a4655d700(0000) GS:ffff88007f900000(0000)
knlGS:0000000000000000
[  245.956098] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  245.956098] CR2: 00007f3a4655cff8 CR3: 0000000049c7b000 CR4:
00000000000406e0
[  245.956098] Stack:
[  245.956098]  00000000576cfc18 00000000000001ff 0000000000000000
ffff880063c00cc0
[  245.956098]  ffff8800576cfc68 ffffffff811d001a ffff880063c00cc0
00000001502eccb0
[  245.956098]  0000000000000008 ffff8800502ec0c0 ffff880063c00cc0
ffff8800502eccb0
[  245.956098] Call Trace:
[  245.956098]  [<ffffffff811d001a>] put_files_struct+0x7a/0xf0
[  245.956098]  [<ffffffff811d013b>] exit_files+0x4b/0x60
[  245.956098]  [<ffffffff8107acc7>] do_exit+0x3a7/0xc90
[  245.956098]  [<ffffffff81acaaa0>] ? _raw_spin_unlock_irq+0x30/0x60
[  245.956098]  [<ffffffff8107c96e>] do_group_exit+0x4e/0xc0
[  245.956098]  [<ffffffff810891b8>] get_signal+0x238/0x9b0
[  245.956098]  [<ffffffff81003278>] do_signal+0x28/0x690
[  245.956098]  [<ffffffff81205082>] ? fcntl_setlk+0x72/0x430
[  245.956098]  [<ffffffff81acb5e0>] ? int_very_careful+0x5/0x3f
[  245.956098]  [<ffffffff810c7942>] ?
trace_hardirqs_on_caller+0x122/0x1b0
[  245.956098]  [<ffffffff81003925>] do_notify_resume+0x45/0x60
[  245.956098]  [<ffffffff81acb62c>] int_signal+0x12/0x17
[  245.956098] Code: 48 89 e5 41 55 41 54 53 48 89 fb 48 83 ec 08 48 8b
47 68 48 85 c0 74 4a 48 8b 47 28 45 31 e4 49 89 f5 48 8b 40 68 48 85 c0
74 05 <ff> d0 41 89 c4 f6 43 75 40 75 16 4c 89 ee 48 89 df e8 f9 8e 04 
[  245.956098] RIP  [<ffffffff811ae3c1>] filp_close+0x31/0x80
[  245.956098]  RSP <ffff8800576cfbf8>
[  245.980303] ---[ end trace 9d29787e24defe8a ]---
[  245.981531] Fixing recursive fault but reboot is needed!
[  246.957011] general protection fault: 0000 [#2] PREEMPT SMP
DEBUG_PAGEALLOC 
[  246.957933] Modules linked in: nfsv3 rpcsec_gss_krb5 nfsv4 nfs nfsd
auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
[  246.959467] CPU: 1 PID: 6602 Comm: plock_tests Tainted: G      D W
4.2.0-rc1-00004-gfbb2913 #222
[  246.960075] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140709_153950- 04/01/2014
[  246.960075] task: ffff88004cf54380 ti: ffff88004cc40000 task.ti:
ffff88004cc40000
[  246.960075] RIP: 0010:[<ffffffff811ae3c1>]  [<ffffffff811ae3c1>]
filp_close+0x31/0x80
[  246.960075] RSP: 0018:ffff88004cc43bf8  EFLAGS: 00010206
[  246.960075] RAX: 5d5f415e415d415c RBX: ffff8800727dee40 RCX:
ffff88006c373dd0
[  246.960075] RDX: 0000000080000000 RSI: ffff88006c373cc0 RDI:
ffff8800727dee40
[  246.960075] RBP: ffff88004cc43c18 R08: 0000000000000001 R09:
0000000000000001
[  246.960075] R10: 0000000000000000 R11: 0000000000000000 R12:
0000000000000000
[  246.960075] R13: ffff88006c373cc0 R14: ffff88006c373d18 R15:
0000000000000007
[  246.960075] FS:  00007f3a46d4a700(0000) GS:ffff88007f900000(0000)
knlGS:0000000000000000
[  246.960075] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  246.960075] CR2: 00007fa219b62010 CR3: 000000000220b000 CR4:
00000000000406e0
[  246.960075] Stack:
[  246.960075]  000000004cc43c18 0000000000000001 0000000000000000
ffff88006c373cc0
[  246.960075]  ffff88004cc43c68 ffffffff811d001a ffff88006c373cc0
000000014cf54f70
[  246.960075]  0000000000000008 ffff88004cf54380 ffff88006c373cc0
ffff88004cf54f70
[  246.960075] Call Trace:
[  246.960075]  [<ffffffff811d001a>] put_files_struct+0x7a/0xf0
[  246.960075]  [<ffffffff811d013b>] exit_files+0x4b/0x60
[  246.960075]  [<ffffffff8107acc7>] do_exit+0x3a7/0xc90
[  246.960075]  [<ffffffff810c79dd>] ? trace_hardirqs_on+0xd/0x10
[  246.960075]  [<ffffffff8107c96e>] do_group_exit+0x4e/0xc0
[  246.960075]  [<ffffffff810891b8>] get_signal+0x238/0x9b0
[  246.960075]  [<ffffffff81003278>] do_signal+0x28/0x690
[  246.960075]  [<ffffffff811afbc7>] ? __vfs_read+0xa7/0xd0
[  246.960075]  [<ffffffff811b034a>] ? vfs_read+0x8a/0x110
[  246.960075]  [<ffffffff81003925>] do_notify_resume+0x45/0x60
[  246.960075]  [<ffffffff81acb62c>] int_signal+0x12/0x17
[  246.960075] Code: 48 89 e5 41 55 41 54 53 48 89 fb 48 83 ec 08 48 8b
47 68 48 85 c0 74 4a 48 8b 47 28 45 31 e4 49 89 f5 48 8b 40 68 48 85 c0
74 05 <ff> d0 41 89 c4 f6 43 75 40 75 16 4c 89 ee 48 89 df e8 f9 8e 04 
[  246.960075] RIP  [<ffffffff811ae3c1>] filp_close+0x31/0x80
[  246.960075]  RSP <ffff88004cc43bf8>
[  246.978654] ---[ end trace 9d29787e24defe8b ]---
[  246.979247] Fixing recursive fault but reboot is needed!

