Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382Ab1BPSNJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:13:09 -0500
Date: Wed, 16 Feb 2011 13:13:07 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release to
 nfsiod
Message-ID: <20110216131307.0880ad00@tlielax.poochiereds.net>
In-Reply-To: <1297869677.6596.30.camel@heimdal.trondhjem.org>
References: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
	<1297783898.10103.22.camel@heimdal.trondhjem.org>
	<20110215113053.345e3abc@tlielax.poochiereds.net>
	<1297813624.10103.34.camel@heimdal.trondhjem.org>
	<1297865354.6596.13.camel@heimdal.trondhjem.org>
	<1297866373.6596.18.camel@heimdal.trondhjem.org>
	<20110216095002.1e7944c9@tlielax.poochiereds.net>
	<1297869677.6596.30.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 16 Feb 2011 10:21:17 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-02-16 at 09:50 -0500, Jeff Layton wrote: 
> > Thanks Trond,
> > 
> > This builds, but I can't plug in the module:
> > 
> > [  103.540405] sunrpc: Unknown symbol __wake_up_locked_key (err 0)
> > 
> > ...I think __wake_up_locked_key will need to be exported too. I'll do
> > that and then test this out later today.
> 
> Thanks! I've added an EXPORT_SYMBOL_GPL() for __wake_up_locked_key to
> the patch.
> 

So far this patch looks good. I've been able to reproduce the problem
much more reliably with this patch and running the cthon special tests:

---------------------------[snip]-------------------------
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 40381d2..0e3d75f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1849,6 +1849,7 @@ static void nfs4_free_closedata(void *data)
        struct nfs4_closedata *calldata = data;
        struct nfs4_state_owner *sp = calldata->state->owner;
 
+       msleep(100);
        if (calldata->roc)
                pnfs_roc_release(calldata->state->inode);
        nfs4_put_open_state(calldata->state);
---------------------------[snip]-------------------------

...with your patch on top of that, I've not been able to reproduce the
problem so far after around 20 passes. I'll plan to let the tests run
this evening to make sure, but initial results are good.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
