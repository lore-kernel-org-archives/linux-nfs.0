From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Mon, 14 Sep 2009 17:09:06 -0400
Message-ID: <1252962546.6866.102.camel@heimdal.trondhjem.org>
References: <4AA8C597.8080809@panasas.com>
	 <1252574759-30176-1-git-send-email-bhalevy@panasas.com>
	 <20090914163535.GE30806@fieldses.org> <20090914164951.GA32757@fieldses.org>
	 <4AAE7C19.7070600@panasas.com> <20090914200423.GE1658@fieldses.org>
	 <1252959452.6866.92.camel@heimdal.trondhjem.org>
	 <20090914203910.GF1658@fieldses.org>
	 <1252961253.6866.98.camel@heimdal.trondhjem.org>
	 <20090914205648.GG1658@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41528 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933548AbZINVJK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 17:09:10 -0400
In-Reply-To: <20090914205648.GG1658@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-09-14 at 16:56 -0400, J. Bruce Fields wrote:
> On Mon, Sep 14, 2009 at 04:47:33PM -0400, Trond Myklebust wrote:
> > On Mon, 2009-09-14 at 16:39 -0400, J. Bruce Fields wrote:
> > > On Mon, Sep 14, 2009 at 04:17:32PM -0400, Trond Myklebust wrote:
> > > > On Mon, 2009-09-14 at 16:04 -0400, J. Bruce Fields wrote:
> > > > > On Mon, Sep 14, 2009 at 08:23:37PM +0300, Benny Halevy wrote:
> > > > > > Where exactly is the NULL deref?
> > > > > > 
> > > > > > > 
> > > > > > > Note--that's fixed 7 patches later in fsd41: Refactor create_client(),
> > > > > > > but I don't actually understand how yet.
> > > > > > 
> > > > > > unconf's cl_flavor initialization was moved in the latter patch
> > > > > > from nfsd4_setclientid to create_client so maybe this could
> > > > > > be the culprit (though, assuming it is initialized to 0
> > > > > > it will choosing implicitly authnull_ops in rpcauth_create()
> > > > > > which _should_ work...)
> > > > > 
> > > > > Oog, yes, turns out auth_null doesn't initialize the cred hashtable.  So
> > > > > also reproduceable by mounting with "mount -tnfs4 -osec=null", then
> > > > > touching a file.  So either we should be using some other interface, or
> > > > > rpcauth_lookupcred should be checking au_credcache, or something.
> > > > 
> > > > There shouldn't be a need for an auth_null hashtable. It isn't a
> > > > credential...
> > > 
> > > Got it.  Looking at the code: I guess rpcauth_lookup_credcache is really
> > > meant to be used only by auth types implementing their own cred lookups.
> > > 
> > > Err, maybe I want the following?
> > > 
> > > Or add a "lookup_machine_cred" helper to auth.c.  Or use the
> > > auth_generic stuff?
> > > 
> > > --b.
> > > 
> > > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > > index 77a6d10..b91cc8e 100644
> > > --- a/fs/nfsd/nfs4callback.c
> > > +++ b/fs/nfsd/nfs4callback.c
> > > @@ -450,6 +450,7 @@ static struct rpc_cred *lookup_cb_cred(struct nfs4_cb_conn *cb)
> > >  	struct auth_cred acred = {
> > >  		.machine_cred = 1
> > >  	};
> > > +	struct rpc_auth *auth = cb->cb_client->cl_auth;
> > >  
> > >  	/*
> > >  	 * Note in the gss case this doesn't actually have to wait for a
> > > @@ -457,8 +458,7 @@ static struct rpc_cred *lookup_cb_cred(struct nfs4_cb_conn *cb)
> > >  	 * non-uptodate cred which the rpc state machine will fill in with
> > >  	 * a refresh_upcall later.
> > >  	 */
> > > -	return rpcauth_lookup_credcache(cb->cb_client->cl_auth, &acred,
> > > -							RPCAUTH_LOOKUP_NEW);
> > > +	return auth->lookup_cred(auth, &acred, RPCAUTH_LOOKUP_NEW);
> > >  }
> > >  
> > >  void do_probe_callback(struct nfs4_client *clp)
> > 
> > That looks better. There is no guarantee that auth flavours will
> > implement a credcache...
> > 
> > However, is there any reason why you can't just call
> > rpc_lookup_machine_cred()?
> 
> I don't want to sleep; could we add a flags argument to
> rpc_lookup_machine_cred()?

I suppose we could. Alternatively, why not just call it once and for all
when you start the NFSv4 server? The one cred will work on all
rpc_clients. You just have to remember to bump the reference count
before using it in an RPC call...


