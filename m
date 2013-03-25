Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40887 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986Ab3CYJi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2013 05:38:58 -0400
Date: Mon, 25 Mar 2013 17:27:40 +0800
From: root <ycnian@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsv4.1 client refuses to suspend
Message-ID: <20130325092740.GA12898@mail.example.com>
References: <1363921041-5042-1-git-send-email-ycnian@gmail.com>
 <20130322074003.616911b6@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
In-Reply-To: <20130322074003.616911b6@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 22, 2013 at 07:40:03AM -0400, Jeff Layton wrote:
> On Fri, 22 Mar 2013 10:57:21 +0800
> ycnian@gmail.com wrote:
> 
> > nfsv4.1 client suspending fails with such info
> > 
> > Freezing of tasks failed after 20.00 seconds (1 tasks refusing to freeze, wq_busy=0):
> > nfsv4.1-svc     S ffff88007889f2e0     0  3191      2 0x00000080   
> >  ffff88007b2f3e28 0000000000000046 ffff88007b2f2010 00000000000127c0
> >  ffff880079b08000 00000000000127c0 ffff88007b2f3fd8 00000000000127c0
> >  ffff88007b2f3fd8 00000000000127c0 ffffffff81a14410 ffff880079b08000
> > Call Trace:
> >  [<ffffffff81441396>] schedule+0x64/0x66
> >  [<ffffffffa06a6892>] nfs41_callback_svc+0x100/0x129 [nfsv4]
> >  [<ffffffff8104fdb8>] ? wake_up_bit+0x2a/0x2a
> >  [<ffffffffa06a6792>] ? nfs_callback_up+0x548/0x548 [nfsv4]
> >  [<ffffffff8104f7e0>] kthread+0xb5/0xbd
> >  [<ffffffff8104f72b>] ? kthread_freezable_should_stop+0x65/0x65
> >  [<ffffffff8144912c>] ret_from_fork+0x7c/0xb0
> >  [<ffffffff8104f72b>] ? kthread_freezable_should_stop+0x65/0x65
> > 
> > I read such threads
> > [1] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
> > [2] LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
> > and then modify nfs41_callback_svc(). It works on my machine. I don't know
> > the details of freezing, so I'm not sure if the modification is reasonable.
> > This is not a formal patch. Thanks.
> > 
> > Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> > ---
> >  fs/nfs/callback.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index 5088b57..8addb7b 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -138,7 +138,7 @@ nfs41_callback_svc(void *vrqstp)
> >  				error);
> >  		} else {
> >  			spin_unlock_bh(&serv->sv_cb_lock);
> > -			schedule();
> > +			freezable_schedule();
> >  		}
> >  		finish_wait(&serv->sv_cb_waitq, &wq);
> >  	}
> 
> I think it'd be better to have that thread call try_to_freeze()
> directly instead of doing this. There are some problems with
> freezable_schedule() that still need to be resolved and I suspect that
> it will eventually go away entirely.
> 
> It's may be sufficient to simply call try_to_freeze() at the top of
> the loop, but that would need to be tested.

Thanks, I tried it as follow
echo 'mem' > /sys/power/state
and it works ok. No further tests.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
