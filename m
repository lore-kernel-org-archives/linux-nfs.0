Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab1EMVgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2011 17:36:10 -0400
Date: Fri, 13 May 2011 17:36:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: added FREE_STATEID operation
Message-ID: <20110513213608.GB14771@fieldses.org>
References: <1304708255-20464-1-git-send-email-bjschuma@netapp.com>
 <1304708255-20464-2-git-send-email-bjschuma@netapp.com>
 <20110510003624.GB3600@fieldses.org>
 <4DCA9FFD.5070707@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DCA9FFD.5070707@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 11, 2011 at 10:41:01AM -0400, Bryan Schumaker wrote:
> On 05/09/2011 08:36 PM, J. Bruce Fields wrote:
> > On Fri, May 06, 2011 at 02:57:34PM -0400, bjschuma@netapp.com wrote:
> >> +		release_open_stateid(stp);
> > 
> > OK, but it might not be a lock stateid.  (I assume free_stateid can be
> > called on *any* kind of stateid?)
> 
> I thought release_open_stateid() freed all stateids, not just the lock stateid...

Lock stateid's are released by release_lock_stateid(), delegation
stateid's (actually embedded in a struct nfs4_delegation) by
unhash_delegation().

--b.

> 
> > 
> > --b.
> > 
> >> +	return nfs_ok;
> >> +}
> >> +
> >>  static inline int
> >>  setlkflg (int type)
> >>  {
> >> @@ -3619,6 +3653,28 @@ find_stateid(stateid_t *stid, int flags)
> >>  	return NULL;
> >>  }
> >>  
> >> +static struct nfs4_stateid *
> >> +search_for_stateid(stateid_t *stid)
> >> +{
> >> +	struct nfs4_stateid *local;
> >> +	u32 st_id = stid->si_stateownerid;
> >> +	u32 f_id  = stid->si_fileid;
> >> +	unsigned int hashval = stateid_hashval(st_id, f_id);
> >> +
> >> +	list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
> >> +		if ((local->st_stateid.si_stateownerid == st_id) &&
> >> +		    (local->st_stateid.si_fileid == f_id))
> >> +			return local;
> >> +	}
> >> +
> >> +	list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
> >> +		if ((local->st_stateid.si_stateownerid == st_id) &&
> >> +		    (local->st_stateid.si_fileid == f_id))
> >> +			return local;
> >> +	}
> >> +	return NULL;
> >> +}
> >> +
> >>  static struct nfs4_delegation *
> >>  find_delegation_stateid(struct inode *ino, stateid_t *stid)
> >>  {
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index 195a91d..5da6874 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -1246,6 +1246,19 @@ nfsd4_decode_destroy_session(struct nfsd4_compoundargs *argp,
> >>  }
> >>  
> >>  static __be32
> >> +nfsd4_decode_free_stateid(struct nfsd4_compoundargs *argp,
> >> +			  struct nfsd4_free_stateid *free_stateid)
> >> +{
> >> +	DECODE_HEAD;
> >> +
> >> +	READ_BUF(sizeof(stateid_t));
> >> +	READ32(free_stateid->fr_stateid.si_generation);
> >> +	COPYMEM(&free_stateid->fr_stateid.si_opaque, sizeof(stateid_opaque_t));
> >> +
> >> +	DECODE_TAIL;
> >> +}
> >> +
> >> +static __be32
> >>  nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
> >>  		      struct nfsd4_sequence *seq)
> >>  {
> >> @@ -1370,7 +1383,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
> >>  	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
> >>  	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
> >>  	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
> >> -	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >> +	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_free_stateid,
> >>  	[OP_GET_DIR_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >>  	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >>  	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >> @@ -3115,6 +3128,21 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
> >>  	return nfserr;
> >>  }
> >>  
> >> +static __be32
> >> +nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, int nfserr,
> >> +			  struct nfsd4_free_stateid *free_stateid)
> >> +{
> >> +	__be32 *p;
> >> +
> >> +	if (nfserr)
> >> +		return nfserr;
> >> +
> >> +	RESERVE_SPACE(4);
> >> +	WRITE32(nfserr);
> >> +	ADJUST_ARGS();
> >> +	return nfserr;
> >> +}
> >> +
> >>  __be32
> >>  nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
> >>  		      struct nfsd4_sequence *seq)
> >> @@ -3196,7 +3224,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
> >>  	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
> >>  	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
> >>  	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
> >> -	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
> >> +	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_free_stateid,
> >>  	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
> >>  	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
> >>  	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
> >> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> >> index 366401e..ed1784d 100644
> >> --- a/fs/nfsd/xdr4.h
> >> +++ b/fs/nfsd/xdr4.h
> >> @@ -342,6 +342,11 @@ struct nfsd4_setclientid_confirm {
> >>  	nfs4_verifier	sc_confirm;
> >>  };
> >>  
> >> +struct nfsd4_free_stateid {
> >> +	stateid_t	fr_stateid;         /* request */
> >> +	__be32		fr_status;          /* response */
> >> +};
> >> +
> >>  /* also used for NVERIFY */
> >>  struct nfsd4_verify {
> >>  	u32		ve_bmval[3];        /* request */
> >> @@ -432,6 +437,7 @@ struct nfsd4_op {
> >>  		struct nfsd4_destroy_session	destroy_session;
> >>  		struct nfsd4_sequence		sequence;
> >>  		struct nfsd4_reclaim_complete	reclaim_complete;
> >> +		struct nfsd4_free_stateid	free_stateid;
> >>  	} u;
> >>  	struct nfs4_replay *			replay;
> >>  };
> >> @@ -564,6 +570,8 @@ extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
> >>  		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
> >>  extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
> >>  			  struct nfsd4_compound_state *, clientid_t *clid);
> >> +extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
> >> +		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
> >>  #endif
> >>  
> >>  /*
> >> -- 
> >> 1.7.5.1
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
