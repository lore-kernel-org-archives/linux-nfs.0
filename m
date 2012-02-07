Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49485 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164Ab2BGPT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 10:19:29 -0500
Date: Tue, 7 Feb 2012 10:19:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 5/5] nfsd: add the infrastructure to handle the cld
 upcall
Message-ID: <20120207151928.GD4868@fieldses.org>
References: <1328111052-28389-1-git-send-email-jlayton@redhat.com>
 <1328111052-28389-6-git-send-email-jlayton@redhat.com>
 <20120203225736.GG2999@fieldses.org>
 <20120204064906.39a9f6f3@tlielax.poochiereds.net>
 <20120207100009.07b30249@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120207100009.07b30249@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 07, 2012 at 10:00:09AM -0500, Jeff Layton wrote:
> On Sat, 4 Feb 2012 06:49:06 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Fri, 3 Feb 2012 17:57:36 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Wed, Feb 01, 2012 at 10:44:12AM -0500, Jeff Layton wrote:
> > > > ...and add a mechanism for switching between the "legacy" tracker and
> > > > the new one. The decision is made by looking to see whether the
> > > > v4recoverydir exists. If it does, then the legacy client tracker is
> > > > used.
> > > > 
> > > > If it's not, then the kernel will create a "cld" pipe in rpc_pipefs.
> > > > That pipe is used to talk to a daemon for handling the upcall.
> > > > 
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > ---
> > > >  fs/nfsd/nfs4recover.c |  364 ++++++++++++++++++++++++++++++++++++++++++++++++-
> > > >  1 files changed, 363 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > > > index 3fbf1f4..592fe3d 100644
> > > > --- a/fs/nfsd/nfs4recover.c
> > > > +++ b/fs/nfsd/nfs4recover.c
> > > > @@ -1,5 +1,6 @@
> > > >  /*
> > > >  *  Copyright (c) 2004 The Regents of the University of Michigan.
> > > > +*  Copyright (c) 2011 Jeff Layton <jlayton@redhat.com>
> > > >  *  All rights reserved.
> > > >  *
> > > >  *  Andy Adamson <andros@citi.umich.edu>
> > > > @@ -36,6 +37,10 @@
> > > >  #include <linux/namei.h>
> > > >  #include <linux/crypto.h>
> > > >  #include <linux/sched.h>
> > > > +#include <linux/fs.h>
> > > > +#include <linux/sunrpc/rpc_pipe_fs.h>
> > > > +#include <linux/sunrpc/clnt.h>
> > > > +#include <linux/nfsd/cld.h>
> > > >  
> > > >  #include "nfsd.h"
> > > >  #include "state.h"
> > > > @@ -472,12 +477,369 @@ static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
> > > >  	.grace_done	= nfsd4_recdir_purge_old,
> > > >  };
> > > >  
> > > > +/* Globals */
> > > > +#define NFSD_PIPE_DIR		"/nfsd"
> > > > +
> > > > +static struct dentry *cld_pipe;
> > > > +
> > > > +/* list of cld_msg's that are currently in use */
> > > > +static DEFINE_SPINLOCK(cld_lock);
> > > > +static LIST_HEAD(cld_list);
> > > > +static unsigned int cld_xid;
> > > > +
> > > > +struct cld_upcall {
> > > > +	struct list_head	cu_list;
> > > > +	struct task_struct	*cu_task;
> > > > +	struct cld_msg	cu_msg;
> > > > +};
> > > > +
> > > > +static int
> > > > +__cld_pipe_upcall(struct cld_msg *cmsg)
> > > > +{
> > > > +	int ret;
> > > > +	struct rpc_pipe_msg msg;
> > > > +	struct inode *inode = cld_pipe->d_inode;
> > > > +
> > > > +	memset(&msg, 0, sizeof(msg));
> > > > +	msg.data = cmsg;
> > > > +	msg.len = sizeof(*cmsg);
> > > > +
> > > > +	/*
> > > > +	 * Set task state before we queue the upcall. That prevents
> > > > +	 * wake_up_process in the downcall from racing with schedule.
> > > > +	 */
> > > > +	set_current_state(TASK_UNINTERRUPTIBLE);
> > > 
> > > Is there a risk of nfsd being left unkillable if the daemon dies or
> > > becomes unresponsive?
> > > 
> > 
> > If the daemon dies, then the pipe will be closed and this will get
> > woken back up with msg.errno set to -EAGAIN. At that point, it'll
> > get requeued and then will eventually time out via the
> > RPC_PIPE_WAIT_FOR_OPEN workqueue job.
> > 
> > If the daemon is unresponsive but holds the pipe open then this will
> > sleep indefinitely. I suppose we could use a schedule_timeout() below
> > with a 30s timeout or so and then dequeue it if it does. I'll note
> > though that none of the other rpc_pipefs upcalls do that.
> > 
> > Hmm...now that I look though, I think I see a bug in the rpc_pipefs
> > code. When an upcall is read off the pipe, it moves to the in_upcall
> > list. If there's never a downcall for it, then I think it'll just
> > linger there forever until the pipe is removed. Even closing the pipe
> > won't unwedge it. It seems like we should return an error for those as
> > well. I'll see about spinning up a patch for that too...
> >
> 
> Ok, I had a bit more time to look over this... 
> 
> My mistake -- that last paragraph is wrong. I neglected to note that
> upcalls that are partially read end up moving to filp->private_data as
> well. If the pipe is closed after reading part of a call then the
> upcall will end up getting an -EAGAIN back.
> 
> I think we can make these calls eventually time out if the daemon goes
> unresponsive. It will take some fairly significant reengineering
> however. We'll need to embed the rpc_pipe_msg inside another struct,
> allocate them from the slab and refcount them, and then (carefully!)
> deal with them if the schedule_timeout() times out.
> 
> The question is -- is that really worth it? None of the other rpc_pipe
> upcalls do that (aside from the gssapi one). My preference would be not
> to bother with it until we find that a hung daemon is a problem. That
> said, if you think it's a necessary precondition to merging this then
> I'll see about making those changes.

OK, leaving it as is sounds like a reasonable tradeoff to me.

--b.
