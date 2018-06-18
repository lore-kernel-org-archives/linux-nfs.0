Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33946 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936284AbeFRTwQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Jun 2018 15:52:16 -0400
Date: Mon, 18 Jun 2018 15:52:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: v4.18-rc1 client deadlock
Message-ID: <20180618195216.GA24185@fieldses.org>
References: <20180618183931.GH6355@fieldses.org>
 <CAFX2Jfn27dgiOtKjKf0xCJ__AspzKE3=tjqoc4A5RY_2QLPuAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFX2Jfn27dgiOtKjKf0xCJ__AspzKE3=tjqoc4A5RY_2QLPuAw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 18, 2018 at 03:46:16PM -0400, Anna Schumaker wrote:
> If this is generic/013, then this might be the same issue I was hitting
> last week.  I sent out a patch titled: "NFS: Fix an rcu deadlock in
> nfs_delegation_find_inode()" that should fix it.
> 
> I hope this helps!

I saw it hang in connectathon tests, not xfstests.

That said, Trond's linux-next (which includes your patch) seems to be
getting through all the same tests without a hang.

(Still the same lock debugging warning, though, is it know whether
that's a real bug or a false positive?)

--b.

> Anna
> 
> On Mon, Jun 18, 2018 at 2:40 PM J. Bruce Fields <bfields@fieldses.org>
> wrote:
> 
> > Connectathon tests are hanging for me on v4.18-rc1.  Is this a known
> > issue?
> >
> > --b.
> >
> > [  128.335964] mount.nfs (5196) used greatest stack depth: 11208 bytes left
> > [  135.170104] ------------[ cut here ]------------
> > [  135.171318] DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct
> > *)(1UL << 0)))
> > [  135.171334] WARNING: CPU: 2 PID: 54 at kernel/locking/rwsem.c:217
> > up_read_non_owner+0x58/0x60
> > [  135.176504] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs lockd grace
> > auth_rpcgss sunrpc
> > [  135.179149] CPU: 2 PID: 54 Comm: kworker/2:1 Not tainted
> > 4.18.0-rc1-13725-g5b7b15aee641 #1778
> > [  135.180826] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> > 1.11.0-2.fc28 04/01/2014
> > [  135.182101] Workqueue: nfsiod rpc_async_release [sunrpc]
> > [  135.182725] RIP: 0010:up_read_non_owner+0x58/0x60
> > [  135.183338] Code: bc 00 5b c3 e8 b9 34 66 00 85 c0 74 df 8b 05 bf 15 c1
> > 02 85 c0 75 d5 48 c7 c6 18 7d 51 82 48 c7 c7 fb 71 50 82 e8 0c 94 fa ff
> > <0f> 0b eb be 0f 1f 40 00 0f 1f 44 00 00 53 48 8b 74 24 08 48 89 fb
> > [  135.186349] RSP: 0018:ffffc900001cbe18 EFLAGS: 00010286
> > [  135.187033] RAX: 0000000000000000 RBX: ffff880069a748d8 RCX:
> > 0000000000000001
> > [  135.187982] RDX: 0000000080000001 RSI: ffffffff825602b6 RDI:
> > 00000000ffffffff
> > [  135.188896] RBP: ffff88006a1d0e00 R08: 0000000000000000 R09:
> > 0000000000000001
> > [  135.189806] R10: 0000000000000000 R11: 0000000000000000 R12:
> > ffff88006450c000
> > [  135.190731] R13: ffff88007d371c00 R14: 0000000000000000 R15:
> > ffff88007fd20480
> > [  135.191643] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000)
> > knlGS:0000000000000000
> > [  135.192803] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  135.193511] CR2: 00007f87b0883cb4 CR3: 0000000002858003 CR4:
> > 00000000001606e0
> > [  135.194558] Call Trace:
> > [  135.194792]  nfs_async_unlink_release+0x2d/0x80 [nfs]
> > [  135.195405]  rpc_free_task+0x2d/0x60 [sunrpc]
> > [  135.195868]  process_one_work+0x212/0x640
> > [  135.196288]  worker_thread+0x3c/0x390
> > [  135.196681]  ? process_one_work+0x640/0x640
> > [  135.197161]  kthread+0x11d/0x140
> > [  135.197463]  ? kthread_flush_work_fn+0x10/0x10
> > [  135.197978]  ret_from_fork+0x3a/0x50
> > [  135.198366] irq event stamp: 78327
> > [  135.198676] hardirqs last  enabled at (78327): [<ffffffff81cb9419>]
> > _raw_spin_unlock_irq+0x29/0x50
> > [  135.199791] hardirqs last disabled at (78326): [<ffffffff81cb927f>]
> > _raw_spin_lock_irq+0xf/0x40
> > [  135.200929] softirqs last  enabled at (69438): [<ffffffff81103226>]
> > srcu_invoke_callbacks+0xd6/0x190
> > [  135.202182] softirqs last disabled at (69434): [<ffffffff81103226>]
> > srcu_invoke_callbacks+0xd6/0x190
> > [  135.203471] ---[ end trace 7b0fac2ca4af7443 ]---
> > [  569.422994] nfs: server test1.fieldses.org not responding, still trying
> > [  604.238967] INFO: task bigfile:9141 blocked for more than 120 seconds.
> > [  604.242603]       Tainted: G        W
> >  4.18.0-rc1-13725-g5b7b15aee641 #1778
> > [  604.245664] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> > this message.
> > [  604.247738] bigfile         D12696  9141   9106 0x00000000
> > [  604.249033] Call Trace:
> > [  604.249405]  ? __schedule+0x317/0xbb0
> > [  604.250153]  schedule+0x32/0x90
> > [  604.250767]  io_schedule+0x12/0x40
> > [  604.251425]  wait_on_page_bit+0x110/0x150
> > [  604.251883]  ? add_to_page_cache_lru+0xe0/0xe0
> > [  604.252418]  __filemap_fdatawait_range+0xbc/0x120
> > [  604.252967]  filemap_write_and_wait_range+0x3e/0x70
> > [  604.253536]  nfs_file_fsync+0x6a/0x3e0 [nfs]
> > [  604.254002]  do_fsync+0x38/0x70
> > [  604.254274]  __x64_sys_fsync+0x10/0x20
> > [  604.254631]  do_syscall_64+0x50/0x180
> > [  604.255073]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > [  604.255660] RIP: 0033:0x7fd696044b14
> > [  604.256008] Code: Bad RIP value.
> > [  604.256313] RSP: 002b:00007ffc894e5898 EFLAGS: 00000246 ORIG_RAX:
> > 000000000000004a
> > [  604.257255] RAX: ffffffffffffffda RBX: 0000000000000000 RCX:
> > 00007fd696044b14
> > [  604.258133] RDX: 0000000000002000 RSI: 0000000000605280 RDI:
> > 0000000000000003
> > [  604.259074] RBP: 00007ffc894e5cf0 R08: 0000000000000003 R09:
> > 0000000000000000
> > [  604.259977] R10: 0000000000000000 R11: 0000000000000246 R12:
> > 0000000000400f90
> > [  604.260878] R13: 00007ffc894e5e10 R14: 0000000000000000 R15:
> > 0000000000000000
> > [  604.261760] INFO: lockdep is turned off.
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
