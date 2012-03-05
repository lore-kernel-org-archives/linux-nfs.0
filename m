Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756053Ab2CEMnG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 07:43:06 -0500
Date: Mon, 5 Mar 2012 07:42:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 5/6] nfsd: add the infrastructure to handle the cld
 upcall
Message-ID: <20120305074256.6dc36fed@tlielax.poochiereds.net>
In-Reply-To: <4F547DF1.8090003@parallels.com>
References: <1330720950-5872-1-git-send-email-jlayton@redhat.com>
	<1330720950-5872-6-git-send-email-jlayton@redhat.com>
	<4F547DF1.8090003@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 05 Mar 2012 12:48:49 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> This variant is almost what was desired.
> If you would be able to prepare one more version - please look at my comments below.
> 
> 03.03.2012 00:42, Jeff Layton пишет:
> > ...and add a mechanism for switching between the "legacy" tracker and
> > the new one. The decision is made by looking to see whether the
> > v4recoverydir exists. If it does, then the legacy client tracker is
> > used.
> >
> > If it's not, then the kernel will create a "cld" pipe in rpc_pipefs.
> > That pipe is used to talk to a daemon for handling the upcall.
> >
> > Signed-off-by: Jeff Layton<jlayton@redhat.com>
> > ---
> >   fs/nfsd/nfs4recover.c |  411 ++++++++++++++++++++++++++++++++++++++++++++++++-
> >   1 files changed, 410 insertions(+), 1 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index ccd9b97..d928c58 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -1,5 +1,6 @@
> >   /*
> >   *  Copyright (c) 2004 The Regents of the University of Michigan.
> > +*  Copyright (c) 2012 Jeff Layton<jlayton@redhat.com>
> >   *  All rights reserved.
> >   *
> >   *  Andy Adamson<andros@citi.umich.edu>
> > @@ -36,6 +37,11 @@
> >   #include<linux/namei.h>
> >   #include<linux/crypto.h>
> >   #include<linux/sched.h>
> > +#include<linux/fs.h>
> > +#include<net/net_namespace.h>
> > +#include<linux/sunrpc/rpc_pipe_fs.h>
> > +#include<linux/sunrpc/clnt.h>
> > +#include<linux/nfsd/cld.h>
> >
> >   #include "nfsd.h"
> >   #include "state.h"
> > @@ -478,12 +484,415 @@ static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
> >   	.grace_done	= nfsd4_recdir_purge_old,
> >   };
> >
> > +/* Globals */
> > +#define NFSD_PIPE_DIR		"nfsd"
> > +#define NFSD_CLD_PIPE		"cld"
> > +
> > +static struct rpc_pipe *cld_pipe;
> > +
> > +/* list of cld_msg's that are currently in use */
> > +static DEFINE_SPINLOCK(cld_lock);
> > +static LIST_HEAD(cld_list);
> > +static unsigned int cld_xid;
> > +
> > +struct cld_upcall {
> > +	struct list_head	cu_list;
> > +	struct task_struct	*cu_task;
> > +	struct cld_msg	cu_msg;
> > +};
> > +
> > +static int
> > +__cld_pipe_upcall(struct cld_msg *cmsg)
> > +{
> > +	int ret;
> > +	struct rpc_pipe_msg msg;
> > +
> > +	memset(&msg, 0, sizeof(msg));
> > +	msg.data = cmsg;
> > +	msg.len = sizeof(*cmsg);
> > +
> > +	/*
> > +	 * Set task state before we queue the upcall. That prevents
> > +	 * wake_up_process in the downcall from racing with schedule.
> > +	 */
> > +	set_current_state(TASK_UNINTERRUPTIBLE);
> > +	ret = rpc_queue_upcall(cld_pipe,&msg);
> 
> 
> Would be great to replace hard-coded cld_pipe here with a passed one.
> For example, put this cld_pipe on cld_msg structure.
> And initialize this pointer (hard-coded value for now) below in 
> nfsd4_cld_create() and all other places where alloc_cld_upcall() is called.
> 
> BTW, maybe allocate this struct cld_upcall per NFS client somehow? And thus get 
> rid of alloc-free calls?
> 
> 

Ok, I think I must have misunderstood what you meant when you said no
per-net ops required. I'll respin and see if I can get closer to what
you intended.

Since most of the upcalls are infrequent and come from nfsd threads,
the number of calls in flight will always be less than the order of the
number of nfsd threads. That value may be much less than the number of
nfs4_clients, so we're probably best off allocating these dynamically.

Now that I've had some time to look, I think what you're probably going
to want to do eventually is to add a new per-namespace object for nfsd,
similar to struct nfs_net for the nfs client. This container will hold
the pointer to the upcall pipe as well as other objects.

The nfs4_client objects for nfsd will then need to be per-namespace,
and will have a pointer back to "struct nfsd_net" or whatever you end up
calling it. From that they'll be able to get the rpc_pipe pointer.

For now, I'll just hardcode init_net in the appropriate places under the
assumption that eventually you'll be able to get a rpc_pipe pointer
given a pointer to an nfs4_client struct.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
