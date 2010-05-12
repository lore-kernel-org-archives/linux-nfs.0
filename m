From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH v2 8/9] nfsd4: keep a reference count on client while
	in use
Date: Wed, 12 May 2010 08:23:52 -0400
Message-ID: <20100512122352.GA2266@fieldses.org>
References: <4BE9C7A2.8030801@panasas.com> <1273612434-13726-1-git-send-email-bhalevy@panasas.com> <20100512024030.GA27184@fieldses.org> <4BEA2E06.7070902@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53509 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab0ELMXx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 08:23:53 -0400
In-Reply-To: <4BEA2E06.7070902@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 12, 2010 at 07:26:46AM +0300, Benny Halevy wrote:
> On May. 12, 2010, 5:40 +0300, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > Something still doesn't look quite right: a sequence operation
> > increments cl_count from 1 to 2; then, say, an exchangeid in another
> > thread expires the client, dropping cl_count from 2 to 1; then the
> > laundromat runs, sees cl_count 1, and decides it can expire the
> > client.  Meanwhile, the original compound is still running.
> > 
> > Am I missing something?
> 
> Yeah.  exchange_id doesn't touch cl_refcount.  It may call expire_client
> explicitly which will unhash the client but will not destroy it if cl_refcount > 0
> the laundromat won't the client either after that since it's not on the lru list
> any more (and even if it would, it's refcount is still great than zero so it would
> have been ignored)

Right, that was the whole point.  Thanks!

--b.

> 
> Benny
> 
> > 
> > --b.
> > 
> > On Wed, May 12, 2010 at 12:13:54AM +0300, Benny Halevy wrote:
> >> Get a refcount on the client on SEQUENCE,
> >> Release the refcount and renew the client when all respective compounds completed.
> >> Do not expire the client by the laundromat while in use.
> >> If the client was expired via another path, free it when the compounds
> >> complete and the refcount reaches 0.
> >>
> >> Note that unhash_client_locked must call list_del_init on cl_lru as
> >> it may be called twice for the same client (once from nfs4_laundromat
> >> and then from expire_client)
> >>
> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >> ---
> >>  fs/nfsd/nfs4state.c |   27 ++++++++++++++++++++++++---
> >>  fs/nfsd/nfs4xdr.c   |    3 ++-
> >>  fs/nfsd/state.h     |    1 +
> >>  3 files changed, 27 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 378ee86..1a8fb39 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -701,6 +701,22 @@ free_client(struct nfs4_client *clp)
> >>  	kfree(clp);
> >>  }
> >>  
> >> +void
> >> +release_session_client(struct nfsd4_session *session)
> >> +{
> >> +	struct nfs4_client *clp = session->se_client;
> >> +
> >> +	spin_lock(&client_lock);
> >> +	BUG_ON(clp->cl_refcount <= 0);
> >> +	if (--clp->cl_refcount <= 0) {
> >> +		free_client(clp);
> >> +		session->se_client = NULL;
> >> +	} else if (clp->cl_refcount == 1)
> >> +		renew_client_locked(clp);
> >> +	spin_unlock(&client_lock);
> >> +	nfsd4_put_session(session);
> >> +}
> >> +
> >>  /* must be called under the client_lock */
> >>  static inline void
> >>  unhash_client_locked(struct nfs4_client *clp)
> >> @@ -1477,8 +1493,7 @@ out:
> >>  	/* Hold a session reference until done processing the compound. */
> >>  	if (cstate->session) {
> >>  		nfsd4_get_session(cstate->session);
> >> -		/* Renew the clientid on success and on replay */
> >> -		renew_client_locked(session->se_client);
> >> +		session->se_client->cl_refcount++;
> >>  	}
> >>  	spin_unlock(&client_lock);
> >>  	dprintk("%s: return %d\n", __func__, ntohl(status));
> >> @@ -2599,7 +2614,13 @@ nfs4_laundromat(void)
> >>  				clientid_val = t;
> >>  			break;
> >>  		}
> >> -		list_move(&clp->cl_lru, &reaplist);
> >> +		if (clp->cl_refcount > 1) {
> >> +			dprintk("NFSD: client in use (clientid %08x)\n",
> >> +				clp->cl_clientid.cl_id);
> >> +			continue;
> >> +		}
> >> +		unhash_client_locked(clp);
> >> +		list_add(&clp->cl_lru, &reaplist);
> >>  	}
> >>  	spin_unlock(&client_lock);
> >>  	list_for_each_safe(pos, next, &reaplist) {
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index 5c2de47..126d0ca 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -3313,7 +3313,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
> >>  			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> >>  			cs->slot->sl_inuse = false;
> >>  		}
> >> -		nfsd4_put_session(cs->session);
> >> +		/* Renew the clientid on success and on replay */
> >> +		release_session_client(cs->session);
> >>  	}
> >>  	return 1;
> >>  }
> >> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> >> index 37e1dff..f263174 100644
> >> --- a/fs/nfsd/state.h
> >> +++ b/fs/nfsd/state.h
> >> @@ -419,6 +419,7 @@ extern int nfs4_has_reclaimed_state(const char *name, bool use_exchange_id);
> >>  extern void nfsd4_recdir_purge_old(void);
> >>  extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
> >>  extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
> >> +extern void release_session_client(struct nfsd4_session *);
> >>  
> >>  static inline void
> >>  nfs4_put_stateowner(struct nfs4_stateowner *so)
> >> -- 
> >> 1.6.5.1
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
