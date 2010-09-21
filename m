Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59746 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab0IUTVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 15:21:42 -0400
Date: Tue, 21 Sep 2010 15:20:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
Message-ID: <20100921192005.GC4385@fieldses.org>
References: <20100918171546.GA9859@fieldses.org>
 <1284831680.2787.1.camel@heimdal.trondhjem.org>
 <20100919184549.GD32071@fieldses.org>
 <20100920130106.GB4580@fieldses.org>
 <20100920131025.GC4580@fieldses.org>
 <1285091815.30222.19.camel@heimdal.trondhjem.org>
 <20100921111657.330e7838@corrin.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100921111657.330e7838@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Added linux-nfs to cc:

On Tue, Sep 21, 2010 at 11:16:57AM -0700, Jeff Layton wrote:
> On Tue, 21 Sep 2010 13:56:55 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Mon, 2010-09-20 at 09:10 -0400, J. Bruce Fields wrote:
> > > On Mon, Sep 20, 2010 at 09:01:06AM -0400, J. Bruce Fields wrote:
> > > > On Sun, Sep 19, 2010 at 02:45:49PM -0400, J. Bruce Fields wrote:
> > > > > On Sat, Sep 18, 2010 at 01:41:20PM -0400, Trond Myklebust wrote:
> > > > > > Argh, yes... It is that very last commit from Chuck's new patch series
> > > > > > that conflicts with Jeff Layton's unlink fixes. I've now reverted that
> > > > > > commit...
> > > > > 
> > > > > Great, thanks.--b.
> > > > 
> > > > Unfortunately, now I'm getting some sort of crash.  I'll try to get
> > > > console and get more of the logs, but it looks like a bad pointer in
> > > > nfs4_xdr_enc_rename, with worker_thread, etc. at the other end of the
> > > > stack, so I assume it's in rpciod.
> > > 
> > > general protection fault: 0000 [#1] PREEMPT 
> > > last sysfs file: /sys/devices/virtio-pci/virtio2/net/eth0/broadcast
> > > CPU 0 
> > > Modules linked in: [last unloaded: scsi_wait_scan]
> > > 
> > > Pid: 2089, comm: kworker/0:2 Not tainted 2.6.36-rc4-00191-g5baeab4 #262 /Bochs
> > > RIP: 0010:[<ffffffff8124335a>]  [<ffffffff8124335a>] nfs4_xdr_enc_rename+0x2a/0x150
> > > RSP: 0018:ffff88001d723c50  EFLAGS: 00010206
> > > RAX: ffff88001e0fa07c RBX: ffff88001e9fb618 RCX: 5a5a5a5a5a5a5a5a
> >                                                    ^^^^^^^^^^^^^^^^
> > Looks like a use-after-free issue.
> > 
> > > RDX: 0000000000000000 RSI: ffff88001e0fa07c RDI: ffff88001e898320
> > > RBP: ffff88001d723cd0 R08: ffff88001e60e908 R09: 0000000000000000
> > > R10: 0000000000000002 R11: 0000000000000001 R12: ffff88001e0fa07c
> > > R13: ffff88001e60e908 R14: ffff88001e898320 R15: ffff88001dcf2668
> > > FS:  0000000000000000(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > CR2: 00007fb75a46c360 CR3: 000000001e532000 CR4: 00000000000006f0
> > > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > Process kworker/0:2 (pid: 2089, threadinfo ffff88001d722000, task ffff88001ddfe050)
> > > Stack:
> > >  ffff88001ddfe050 ffffffff8103faf3 ffff88001ea1d000 ffff88001ea1d658
> > > <0> ffff88001d723c90 ffffffff8106a4dd ffffffff818fce45 ffffffff8190ec98
> > > <0> ffff88001e0fa024 ffff88001dcf2668 ffff88001e0fa028 ffff88001e9fb618
> > > Call Trace:
> > >  [<ffffffff8103faf3>] ? local_bh_enable_ip+0x83/0x110
> > >  [<ffffffff8106a4dd>] ? trace_hardirqs_on_caller+0x14d/0x190
> > >  [<ffffffff818fce45>] ? xprt_prepare_transmit+0x75/0xb0
> > >  [<ffffffff8190ec98>] ? xdr_encode_opaque_fixed+0x48/0x90
> > >  [<ffffffff81243330>] ? nfs4_xdr_enc_rename+0x0/0x150
> > >  [<ffffffff81903f94>] rpcauth_wrap_req+0x84/0xb0
> > >  [<ffffffff818fa637>] call_transmit+0x1a7/0x2c0
> > >  [<ffffffff81903112>] __rpc_execute+0xa2/0x230
> > >  [<ffffffff81903305>] rpc_async_schedule+0x15/0x20
> > >  [<ffffffff81054bf2>] process_one_work+0x192/0x520
> > >  [<ffffffff81054b85>] ? process_one_work+0x125/0x520
> > >  [<ffffffff819032f0>] ? rpc_async_schedule+0x0/0x20
> > >  [<ffffffff81055270>] worker_thread+0x140/0x390
> > >  [<ffffffff81055130>] ? worker_thread+0x0/0x390
> > >  [<ffffffff81059376>] kthread+0x96/0xa0
> > >  [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
> > >  [<ffffffff8196d89c>] ? kprobe_flush_task+0xbc/0xe0
> > >  [<ffffffff8196857e>] ? restore_args+0x0/0x30
> > >  [<ffffffff810592e0>] ? kthread+0x0/0xa0
> > >  [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
> > > Code: 00 55 48 89 e5 41 57 41 56 41 55 41 54 53 48 83 ec 58 0f 1f 44 00 00 48 8b 4a 28 49 89 d5 31 d2 49 89 fe 48 89 f0 48 85 c9 74 10 <48> 8b 91 30 03 00 00 48 8b 92 20 03 00 00 8b 12 48 8d 5d b0 4c 
> > > RIP  [<ffffffff8124335a>] nfs4_xdr_enc_rename+0x2a/0x150
> > >  RSP <ffff88001d723c50>
> > > 
> > > --b.
> > 
> > I can see one double free in the nfs_async_rename() error case: the code
> > calls nfs_async_rename_release() after it has already been called by
> > rpc_run_task().
> > I don't know if that is sufficient to explain the above trace, though.
> > 
> > Cheers
> >   Trond
> > 
> > --------------------------------------------------------------------------------------------------------
> > NFS: Fix a use-after-free case in nfs_async_rename()
> > 
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > The call to nfs_async_rename_release() after rpc_run_task() is incorrect.
> > The rpc_run_task() is always guaranteed to call the ->rpc_release() method.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  fs/nfs/unlink.c |    9 ++-------
> >  1 files changed, 2 insertions(+), 7 deletions(-)
> > 
> > 
> > diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> > index 698b3e6..47530aa 100644
> > --- a/fs/nfs/unlink.c
> > +++ b/fs/nfs/unlink.c
> > @@ -426,7 +426,6 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
> >  		.rpc_client = NFS_CLIENT(old_dir),
> >  		.flags = RPC_TASK_ASYNC,
> >  	};
> > -	struct rpc_task *task;
> >  
> >  	data = kmalloc(sizeof(*data), GFP_KERNEL);
> >  	if (data == NULL)
> > @@ -435,7 +434,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
> >  
> >  	data->cred = rpc_lookup_cred();
> >  	if (IS_ERR(data->cred)) {
> > -		task = (struct rpc_task *)data->cred;
> > +		struct rpc_task *task = ERR_CAST(data->cred);
> >  		kfree(data);
> >  		return task;
> >  	}
> > @@ -468,11 +467,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
> >  
> >  	NFS_PROTO(data->old_dir)->rename_setup(&msg, old_dir);
> >  
> > -	task = rpc_run_task(&task_setup_data);
> > -	if (IS_ERR(task))
> > -		nfs_async_rename_release(data);
> > -
> > -	return task;
> > +	return rpc_run_task(&task_setup_data);
> >  }
> >  
> >  /**
> > 
> 
> Thanks Trond. Sorry I missed that. Good catch.
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> 
> That said, I agree -- that doesn't seem sufficient to explain the
> problem. Bruce, is this reproducible?

All I need to do is mount nfs4.1 and run cthon -s.  The last output I
see from the test is:

check for proper open/unlink operation
nfsjunk files before unlink:
  

That's on a kernel without Trond's fix above.

--b.
