Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040Ab1BQNk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Feb 2011 08:40:56 -0500
Date: Thu, 17 Feb 2011 08:40:52 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release to
 nfsiod
Message-ID: <20110217084052.34a6686b@barsoom.rdu.redhat.com>
In-Reply-To: <20110216131307.0880ad00@tlielax.poochiereds.net>
References: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
	<1297783898.10103.22.camel@heimdal.trondhjem.org>
	<20110215113053.345e3abc@tlielax.poochiereds.net>
	<1297813624.10103.34.camel@heimdal.trondhjem.org>
	<1297865354.6596.13.camel@heimdal.trondhjem.org>
	<1297866373.6596.18.camel@heimdal.trondhjem.org>
	<20110216095002.1e7944c9@tlielax.poochiereds.net>
	<1297869677.6596.30.camel@heimdal.trondhjem.org>
	<20110216131307.0880ad00@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 16 Feb 2011 13:13:07 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 16 Feb 2011 10:21:17 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Wed, 2011-02-16 at 09:50 -0500, Jeff Layton wrote: 
> > > Thanks Trond,
> > > 
> > > This builds, but I can't plug in the module:
> > > 
> > > [  103.540405] sunrpc: Unknown symbol __wake_up_locked_key (err 0)
> > > 
> > > ...I think __wake_up_locked_key will need to be exported too. I'll do
> > > that and then test this out later today.
> > 
> > Thanks! I've added an EXPORT_SYMBOL_GPL() for __wake_up_locked_key to
> > the patch.
> > 
> 
> So far this patch looks good. I've been able to reproduce the problem
> much more reliably with this patch and running the cthon special tests:
> 
> ---------------------------[snip]-------------------------
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 40381d2..0e3d75f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1849,6 +1849,7 @@ static void nfs4_free_closedata(void *data)
>         struct nfs4_closedata *calldata = data;
>         struct nfs4_state_owner *sp = calldata->state->owner;
>  
> +       msleep(100);
>         if (calldata->roc)
>                 pnfs_roc_release(calldata->state->inode);
>         nfs4_put_open_state(calldata->state);
> ---------------------------[snip]-------------------------
> 
> ...with your patch on top of that, I've not been able to reproduce the
> problem so far after around 20 passes. I'll plan to let the tests run
> this evening to make sure, but initial results are good.
> 

Looks like it finally failed on the 39th pass:

second check for lost reply on non-idempotent requests
testing 50 idempotencies in directory "testdir"
rmdir 1: Directory not empty
special tests failed

When I look in the directory (several hours after it failed), the
silly-renamed file is still there:

-rw---x--x. 1 root root   30 Feb 16 15:04 .nfs000000000000002d00000090

...so I'm not sure what exactly is wrong yet, but it looks like the
silly delete just never happened. Maybe there's a dentry refcount leak
of some sort? There are no queued RPC's.

I'll keep looking at it but if you have ideas as to what it could be,
let me know.

-- 
Jeff Layton <jlayton@redhat.com>
