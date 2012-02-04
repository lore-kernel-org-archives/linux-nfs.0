Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188Ab2BDMVx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Feb 2012 07:21:53 -0500
Date: Sat, 4 Feb 2012 07:21:45 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 3/5] nfsd: convert nfs4_client->cl_cb_flags to a
 generic flags field
Message-ID: <20120204072145.754b6b3e@tlielax.poochiereds.net>
In-Reply-To: <20120203193533.GA2999@fieldses.org>
References: <1328111052-28389-1-git-send-email-jlayton@redhat.com>
	<1328111052-28389-4-git-send-email-jlayton@redhat.com>
	<20120203193533.GA2999@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 Feb 2012 14:35:33 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Feb 01, 2012 at 10:44:10AM -0500, Jeff Layton wrote:
> > We'll need a way to flag the nfs4_client as already being recorded on
> > stable storage so that we don't continually upcall.
> 
> Looks like the code currently uses cl_firststate for that purpose.
> 
> I'm perfectly open to the argument that using a u32 to store a boolean
> is rather silly, and can't see any problem with doing it this way
> instead, but then let's remove cl_firstate while we're at it.
> 
> --b.
> 

Ahh ok, I missed that that was what that was for. Looks like I probably
have a couple of bugs here with that too. There are some places that
check cl_firststate and since the new code doesn't set it it would be
wrong.

I'll respin this patch to merge that in with this change. Thanks.

> > 
> > The cl_cb_flags field is only using 2 bits right now, so repurpose that
> > to a generic flags field. Rename NFSD4_CLIENT_KILL to
> > NFSD4_CLIENT_CB_KILL to make it evident that it's part of the callback
> > flags. Add a mask that we can use for existing checks that look to see
> > whether any flags are set, so that the new STABLE flag doesn't
> > interfere.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4callback.c |   12 ++++++------
> >  fs/nfsd/state.h        |    8 +++++---
> >  2 files changed, 11 insertions(+), 9 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index 6f3ebb4..730e2cc 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -756,7 +756,7 @@ void nfsd4_probe_callback(struct nfs4_client *clp)
> >  {
> >  	/* XXX: atomicity?  Also, should we be using cl_cb_flags? */
> >  	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
> > -	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
> > +	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
> >  	do_probe_callback(clp);
> >  }
> >  
> > @@ -915,7 +915,7 @@ void nfsd4_destroy_callback_queue(void)
> >  /* must be called under the state lock */
> >  void nfsd4_shutdown_callback(struct nfs4_client *clp)
> >  {
> > -	set_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags);
> > +	set_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags);
> >  	/*
> >  	 * Note this won't actually result in a null callback;
> >  	 * instead, nfsd4_do_callback_rpc() will detect the killed
> > @@ -966,15 +966,15 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
> >  		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
> >  		clp->cl_cb_conn.cb_xprt = NULL;
> >  	}
> > -	if (test_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags))
> > +	if (test_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags))
> >  		return;
> >  	spin_lock(&clp->cl_lock);
> >  	/*
> >  	 * Only serialized callback code is allowed to clear these
> >  	 * flags; main nfsd code can only set them:
> >  	 */
> > -	BUG_ON(!clp->cl_cb_flags);
> > -	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
> > +	BUG_ON(!(clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK));
> > +	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
> >  	memcpy(&conn, &cb->cb_clp->cl_cb_conn, sizeof(struct nfs4_cb_conn));
> >  	c = __nfsd4_find_backchannel(clp);
> >  	if (c) {
> > @@ -1000,7 +1000,7 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
> >  	struct nfs4_client *clp = cb->cb_clp;
> >  	struct rpc_clnt *clnt;
> >  
> > -	if (clp->cl_cb_flags)
> > +	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
> >  		nfsd4_process_cb_update(cb);
> >  
> >  	clnt = clp->cl_cb_client;
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 8f539ee..0f9a0ac 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -250,9 +250,11 @@ struct nfs4_client {
> >  
> >  	/* for v4.0 and v4.1 callbacks: */
> >  	struct nfs4_cb_conn	cl_cb_conn;
> > -#define NFSD4_CLIENT_CB_UPDATE	1
> > -#define NFSD4_CLIENT_KILL	2
> > -	unsigned long		cl_cb_flags;
> > +#define NFSD4_CLIENT_STABLE		(0)	/* client on stable storage */
> > +#define NFSD4_CLIENT_CB_UPDATE		(1)
> > +#define NFSD4_CLIENT_CB_KILL		(2)
> > +#define NFSD4_CLIENT_CB_FLAG_MASK	(0x6)
> > +	unsigned long		cl_flags;
> >  	struct rpc_clnt		*cl_cb_client;
> >  	u32			cl_cb_ident;
> >  #define NFSD4_CB_UP		0
> > -- 
> > 1.7.7.6
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@redhat.com>
