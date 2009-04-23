From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/29] nfsd41: encode create_session result into cache
Date: Thu, 23 Apr 2009 19:32:38 -0400
Message-ID: <20090423233237.GL1906@fieldses.org>
References: <1240504988-9572-1-git-send-email-andros@netapp.com> <1240504988-9572-2-git-send-email-andros@netapp.com> <1240504988-9572-3-git-send-email-andros@netapp.com> <20090423232105.GI1906@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37492 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694AbZDWXci (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:38 -0400
In-Reply-To: <20090423232105.GI1906@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 07:21:05PM -0400, bfields wrote:
> On Thu, Apr 23, 2009 at 12:42:41PM -0400, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > CREATE_SESSION can be preceeded by a SEQUENCE operation and the
> > create session single slot cache must be maintained. Encode the results of
> > a create session call into the cache at the end of processing.
> > 
> > The create session result will also be encoded into the RPC response, and if
> > it is preceeded by a SEQUENCE operation, will also be encoded into the
> > session slot table cache.
> > 
> > Errors that do not change the create session cache:
> > A create session NFS4ERR_STALE_CLIENTID error means that a client record
> > (and associated create session slot) could not be found and therefore can't
> > be changed.  NFSERR_SEQ_MISORDERED errors do not change the slot cache.
> > 
> > All other errors get cached.
> 
> Thanks, this all sounds sensible.  (One simple thing I think I was
> confused about: the create_session sequencing is done at a layer above
> sessions; so in the case of a create_session preceded by a sequence, if
> we discover at the point of processing the sequence that this is a
> replay, we use the sequence replay cache and never even get to any
> create_session processing.  OK!)
> 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfsd/nfs4state.c       |    6 +++++-
> >  fs/nfsd/nfs4xdr.c         |   19 +++++++++++++++++++
> >  include/linux/nfsd/xdr4.h |    2 ++
> >  3 files changed, 26 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 27ad37f..279b47e 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1377,7 +1377,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >  		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> >  		    (ip_addr != unconf->cl_addr)) {
> 
> Could we apply the patch removing these ip_addr checks before any of
> these patches?  Also I seem to recall expressing some other doubts about
> the correctness of exchange_id and create_session--I'd like to see those
> addressed first, as this builds on those.
> 
> >  			status = nfserr_clid_inuse;
> > -			goto out;
> > +			goto out_cache;
> >  		}
> >  
> >  		slot = &unconf->cl_slot;
> > @@ -1424,6 +1424,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >  	cstate->slot = slot;
> >  	/* Ensure a page is used for the cache */
> >  	slot->sl_cache_entry.ce_cachethis = 1;
> 
> Is this still needed?

Oh, I see, that's gone in a later patch.  I think that's OK.

--b.

> 
> --b.
> 
> > +out_cache:
> > +	/* cache solo and embedded create sessions under the state lock */
> > +	nfsd4_cache_create_session(cr_ses, slot, status);
> > +
> >  out:
> >  	nfs4_unlock_state();
> >  	dprintk("%s returns %d\n", __func__, ntohl(status));
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index b2f8d74..6b34fac 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -3046,6 +3046,25 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
> >  	return 0;
> >  }
> >  
> > +/*
> > + * Encode the create_session result into the create session single DRC
> > + * slot cache. Do this for solo or embedded create session operations.
> > + */
> > +void
> > +nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
> > +			   struct nfsd4_slot *slot, int nfserr)
> > +{
> > +	struct nfsd4_cache_entry *entry = &slot->sl_cache_entry;
> > +	__be32 *p = (__be32 *)entry->ce_datav.iov_base;
> > +	struct nfsd4_compoundres tmp = {
> > +		.p = p,
> > +		.end = p + XDR_QUADLEN(CS_MAX_ENC_SZ),
> > +	}, *resp = &tmp;
> > +
> > +	entry->ce_status = nfsd4_encode_create_session(resp, nfserr, cr_ses);
> > +	entry->ce_datav.iov_len = (char *)resp->p - (char *)p;
> > +}
> > +
> >  static __be32
> >  nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
> >  			     struct nfsd4_destroy_session *destroy_session)
> > diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> > index afd4464..cc50ca0 100644
> > --- a/include/linux/nfsd/xdr4.h
> > +++ b/include/linux/nfsd/xdr4.h
> > @@ -517,6 +517,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
> >  extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
> >  extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
> >  		struct nfsd4_sequence *seq);
> > +extern void nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
> > +		struct nfsd4_slot *slot, int nfserr);
> >  extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
> >  		struct nfsd4_compound_state *,
> >  struct nfsd4_exchange_id *);
> > -- 
> > 1.5.4.3
> > 
