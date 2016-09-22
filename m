Return-Path: <jlayton@redhat.com>
Message-ID: <1474561258.9454.8.camel@redhat.com>
Subject: Re: nfsd crash when running xfstests/089
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>, bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benjamin Coddington <bcodding@redhat.com>
Date: Thu, 22 Sep 2016 12:20:58 -0400
In-Reply-To: <20160920163717.GA946@infradead.org>
References: <20160920163717.GA946@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-09-20 at 09:37 -0700, Christoph Hellwig wrote:
> Running a latest Linus tree with nfsv4.2 and the blocklayout driver
> against an XFS file system exported from the local machine I get
> this error when running generic/089 somewhat relatively reproducibly
> (doesn't happen on every run, but more often than not):
> 
> generic/089 133s ...[  387.409504] run fstests generic/089 at 2016-09-20 16:31:44
> [  462.789037] general protection fault: 0000 [#1] SMP
> [  462.790231] Modules linked in:
> [  462.790557] CPU: 2 PID: 3087 Comm: nfsd Tainted: G        W 4.8.0-rc6+ #1939
> [  462.791235] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [  462.792145] task: ffff880137fa1280 task.stack: ffff880137fa4000
> [  462.792163] RIP: 0010:[<ffffffff813fff4a>]  [<ffffffff813fff4a>] release_lock_stateid+0x1a/0x60
> [  462.792163] RSP: 0018:ffff880137fa7cd8  EFLAGS: 00010246
> [  462.792163] RAX: ffff880137d90548 RBX: ffff88013a7c7a88 RCX: ffff880137fa1a48
> [  462.792163] RDX: ffff880137fa1a48 RSI: 0000000000000000 RDI: ffff88013a7c7a88
> [  462.792163] RBP: ffff880137fa7cf0 R08: 0000000000000001 R09: 0000000000000000
> [  462.792163] R10: 0000000000000001 R11: 0000000000000000 R12: 6b6b6b6b6b6b6b6b
> [  462.792163] R13: 0000000000000000 R14: ffff88013ac08000 R15: 0000000000000021
> [  462.792163] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) knlGS:0000000000000000
> [  462.792163] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  462.792163] CR2: 00007fcf2d818000 CR3: 0000000135b0e000 CR4: 00000000000006e0
> [  462.792163] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  462.792163] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [  462.792163] Stack:
> [  462.792163]  ffff88013a7c7a88 ffff88013a7c7b40 0000000000000000 ffff880137fa7d18
> [  462.792163]  ffffffff81405b5a ffff880138ffd000 ffff880136dce000 ffff880138ffd068
> [  462.792163]  ffff880137fa7d70 ffffffff813f13f4 ffff88013ac08220 0000000000000870
> [  462.792163] Call Trace:
> [  462.792163]  [<ffffffff81405b5a>] nfsd4_free_stateid+0x16a/0x170
> [  462.792163]  [<ffffffff813f13f4>] nfsd4_proc_compound+0x344/0x630
> [  462.792163]  [<ffffffff813dc573>] nfsd_dispatch+0xb3/0x1f0
> [  462.792163]  [<ffffffff81dc0898>] svc_process_common+0x428/0x650
> [  462.792163]  [<ffffffff81dc0c15>] svc_process+0x155/0x340
> [  462.792163]  [<ffffffff813dbaf2>] nfsd+0x172/0x270
> [  462.792163]  [<ffffffff813db980>] ? nfsd_destroy+0x180/0x180
> [  462.792163]  [<ffffffff813db980>] ? nfsd_destroy+0x180/0x180
> [  462.792163]  [<ffffffff810fab91>] kthread+0xf1/0x110
> [  462.792163]  [<ffffffff81e01e6f>] ret_from_fork+0x1f/0x40
> [  462.792163]  [<ffffffff810faaa0>] ? kthread_create_on_node+0x200/0x200
> 
> (gdb) l *(release_lock_stateid+0x1a)
> 0xffffffff813fff4a is in release_lock_stateid
> (./include/linux/spinlock.h:302).
> 297		raw_spin_lock_init(&(_lock)->rlock);		\
> 298	} while (0)
> 299	
> 300	static __always_inline void spin_lock(spinlock_t *lock)
> 301	{
> 302		raw_spin_lock(&lock->rlock);
> 303	}
> 304	
> 305	static __always_inline void spin_lock_bh(spinlock_t *lock)
> 306	{
> (gdb) l *(nfsd4_free_stateid+0x16a)
> 0xffffffff81405b5a is in nfsd4_free_stateid (fs/nfsd/nfs4state.c:4923).
> 4918		ret = nfserr_locks_held;
> 4919		if (check_for_locks(stp->st_stid.sc_file,
> 4920				    lockowner(stp->st_stateowner)))
> 4921			goto out;
> 4922	
> 4923		release_lock_stateid(stp);
> 4924		ret = nfs_ok;
> 4925	
> 4926	out:
> 4927		mutex_unlock(&stp->st_mutex);
> (gdb) 
> 

I had a go at reproducing this, but no luck. I'm running generic/089 on
a KVM guest client and with the server running on a different KVM
guest. I'm using vhost-scsi to emulate a disk (thanks to Ben Coddington
for the help setting that up, btw...)

No oopses so far, and I've run the test several times. I am seeing the
test usually error out after several hours though and I'm not yet sure
why, so maybe it's not getting far enough to trigger this?

In any case, I'll poke at it again if I get time. In the meantime, if
you're able to get a vmcore, maybe take a look and see if you can
figure out what's actually bad there? How far does it get in chasing
the pointer to the cl_lock in release_lock_stateid?
-- 
Jeff Layton <jlayton@redhat.com>
