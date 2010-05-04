From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [RFC 2/3] nfsd4: hold a reference on nfs4_client when it is
	used by a session
Date: Tue, 4 May 2010 13:45:41 -0400
Message-ID: <20100504174541.GA27457@fieldses.org>
References: <4BDEF641.4020507@panasas.com> <1272904308-27113-1-git-send-email-bhalevy@panasas.com> <20100503223620.GE11904@fieldses.org> <20100504011200.GA15763@fieldses.org> <4BDFC8AC.5060400@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab0EDRpn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 13:45:43 -0400
In-Reply-To: <4BDFC8AC.5060400@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 04, 2010 at 10:11:40AM +0300, Benny Halevy wrote:
> On May. 04, 2010, 4:12 +0300, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > On Mon, May 03, 2010 at 06:36:20PM -0400,  J. Bruce Fields wrote:
> >> On Mon, May 03, 2010 at 07:31:48PM +0300, Benny Halevy wrote:
> >>> Although expire_client unhashes the session form the session table
> >>> so no new compounds can find it, there's no refcount to keep the
> >>> nfs4_client structure around while it's in use and referenced
> >>> in the compound state via the session structure.
> >> The code in my for-2.6.35 branch already has the cl_count removed (and
> >> doesn't use it for callbacks any more, instead destroying callbacks
> >> before the client is destroyed).
> >>
> >> So we need to add a new usage count.
> > 
> > (Which you do in the next patch, OK!)
> 
> Right :)
> 
> This patch fixes another race in which a client can be expired using
> expire_client(), not from the laundromat path,

Ouch, OK, I'd forgotten that case.

--b.

> while it's being referenced
> by the session since we look up the session while holding just the sessionid
> lock and not the state lock.  Therefore we must take a refcount on the
> client while inside the sessionid lock.
> 
> Looks like the new usage count in your for-2.6.35 world (that I _think_
> could just be a kref now) is needed for delegations as well, right?
> 
> Benny
> 
> > 
> > --b.
> > 
> >> I'd prefer to call it something
> >> different, since it's being used for something different (cl_users?)
> >> since it's being used for something different, and I'd rather avoid
> >> confusion with the previous one.
> >>
> >> --b.
> >>
> >>
> >>
> >>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >>> ---
> >>>  fs/nfsd/nfs4callback.c |    2 +-
> >>>  fs/nfsd/nfs4state.c    |    4 +++-
> >>>  fs/nfsd/nfs4xdr.c      |    1 +
> >>>  fs/nfsd/state.h        |    6 ++++++
> >>>  4 files changed, 11 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> >>> index 7e32bd3..fef1dbe 100644
> >>> --- a/fs/nfsd/nfs4callback.c
> >>> +++ b/fs/nfsd/nfs4callback.c
> >>> @@ -571,7 +571,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
> >>>  	}
> >>>  
> >>>  	/* the task holds a reference to the nfs4_client struct */
> >>> -	atomic_inc(&clp->cl_count);
> >>> +	get_nfs4_client(clp);
> >>>  
> >>>  	do_probe_callback(clp);
> >>>  }
> >>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >>> index 6dbcaf1..50b75af 100644
> >>> --- a/fs/nfsd/nfs4state.c
> >>> +++ b/fs/nfsd/nfs4state.c
> >>> @@ -1458,8 +1458,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >>>  
> >>>  out:
> >>>  	/* Hold a session reference until done processing the compound. */
> >>> -	if (cstate->session)
> >>> +	if (cstate->session) {
> >>>  		nfsd4_get_session(cstate->session);
> >>> +		get_nfs4_client(cstate->session->se_client);
> >>> +	}
> >>>  	spin_unlock(&sessionid_lock);
> >>>  	/* Renew the clientid on success and on replay */
> >>>  	if (cstate->session) {
> >>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >>> index 19ff5a3..aed733c 100644
> >>> --- a/fs/nfsd/nfs4xdr.c
> >>> +++ b/fs/nfsd/nfs4xdr.c
> >>> @@ -3313,6 +3313,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
> >>>  			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> >>>  			cs->slot->sl_inuse = false;
> >>>  		}
> >>> +		put_nfs4_client(cs->session->se_client);
> >>>  		nfsd4_put_session(cs->session);
> >>>  	}
> >>>  	return 1;
> >>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> >>> index fefeae2..e3c002e 100644
> >>> --- a/fs/nfsd/state.h
> >>> +++ b/fs/nfsd/state.h
> >>> @@ -231,6 +231,12 @@ struct nfs4_client {
> >>>  						/* wait here for slots */
> >>>  };
> >>>  
> >>> +static inline void
> >>> +get_nfs4_client(struct nfs4_client *clp)
> >>> +{
> >>> +	atomic_inc(&clp->cl_count);
> >>> +}
> >>> +
> >>>  /* struct nfs4_client_reset
> >>>   * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl
> >>>   * upon lease reset, or from upcall to state_daemon (to read in state
> >>> -- 
> >>> 1.6.3.3
> >>>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
