From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 27/51] nfsd41: sequence operation
Date: Mon, 17 Nov 2008 16:10:44 +0200
Message-ID: <49217B64.5010400@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350195-11112-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:13055 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751808AbYKQOKr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:10:47 -0500
In-Reply-To: <1226350195-11112-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:49 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Implement the sequece operation conforming to
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
> 
> Check for stale clientid (as derived from the sessionid).
> Enforce slotid range and exactly-once semantics using
> the slotid and seqid.
> 
> If everything went well renew the client lease and
> mark the slot INPROGRESS.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c       |   88 ++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4xdr.c         |   27 +++++++++++++-
>  include/linux/nfsd/xdr4.h |    8 ++++-
>  3 files changed, 119 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 77b89b6..1a9d121 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1077,12 +1077,98 @@ out:
>  	return status;
>  }
>  
> +static int
> +check_slot_seqid(u32 seqid, struct nfs41_slot *slot)
> +{
> +	dprintk("%s enter. seqid %d slot->sl_seqid %d\n", __func__, seqid,
> +		slot->sl_seqid);
> +	/* Normal */
> +	if (likely(seqid == slot->sl_seqid + 1))
> +		return nfs_ok;
> +	/* Replay */
> +	if (seqid == slot->sl_seqid)
> +		return NFSERR_REPLAY_ME;
> +	/* Wraparound */
> +	if (seqid == 1 && (slot->sl_seqid + 1) == 0)
> +		return nfs_ok;
> +	/* Misordered replay or misordered new request */
> +	return nfserr_seq_misordered;
> +}
> +
>  __be32
>  nfsd4_sequence(struct svc_rqst *r,
>  	       struct nfsd4_compound_state *cstate,
>  	       struct nfsd4_sequence *seq)
>  {
> -	return -1;	/* stub */
> +	struct nfs41_session *elem;
> +	struct nfs41_slot *slot;
> +	struct current_session *c_ses = cstate->current_ses;
> +	int status;
> +
> +	if (STALE_CLIENTID((clientid_t *)seq->sessionid))
> +		return nfserr_badsession;

review 11-13: get rid of that.
the sessionid mustn't be in the hash table.

> +
> +	nfs4_lock_state();
> +	status = nfserr_badsession;
> +	elem = find_in_sessionid_hashtbl(&seq->sessionid);

review 11-13: s/elem/session/

> +	if (!elem)
> +		goto out;
> +
> +	status = nfserr_badslot;
> +	if (seq->slotid >= elem->se_fnumslots)
> +		goto out;
> +
> +	slot = &elem->se_slots[seq->slotid];
> +	dprintk("%s: slotid %d\n", __func__, seq->slotid);
> +
> +	/* Server post op_sequence compound processing had an upcall which
> +	 * resulted in replaying the compound processing including the
> +	 * already processed op_sequence. Set current_session
> +	 * but don't bump slot->sl_seqid which was incremented in successful
> +	 * op_sequence processing prior to upcall.
> +	 */
> +	if (nfs41_get_slot_state(slot) == NFS4_SLOT_INPROGRESS) {
> +		dprintk("%s: NFS4_SLOT_INPROGRESS. set current_session\n",
> +			__func__);
> +		goto set_curr_ses;
> +	}

squash DRC changes in here.

> +
> +	status = check_slot_seqid(seq->seqid, slot);
> +	if (status == NFSERR_REPLAY_ME)
> +		goto replay;
> +	else if (status)
> +		goto out;
> +
> +	/* Success! bump slot seqid and renew clientid */
> +	slot->sl_seqid = seq->seqid;
> +	renew_client(elem->se_client);
> +	dprintk("%s: set NFS4_SLOT_INPROGRESS\n", __func__);
> +	nfs41_set_slot_state(slot, NFS4_SLOT_INPROGRESS);
> +
> +set_curr_ses:
> +	/* Set current_session. hold reference until done processing compound.
> +	 * nfs41_put_session called only if cs_slot is set
> +	 */
> +	memcpy(&c_ses->cs_sid, &seq->sessionid, sizeof(c_ses->cs_sid));
> +	BUG_ON(sizeof(c_ses->cs_sid) != sizeof(seq->sessionid));

get rid of this BUG_ON.

> +	c_ses->cs_slot = slot;
> +	nfs41_get_session(slot->sl_session);
> +
> +	/* FIXME: for now just initialize target_highest_slotid and flags
> +	 * response fields */
> +	seq->target_maxslots = seq->maxslots;
> +	seq->status_flags = 0;
> +
> +	status = nfs_ok;
> +out:
> +	dprintk("%s: return %d\n", __func__, ntohl(status));
> +	nfs4_unlock_state();
> +	return status;
> +replay:
> +	dprintk("%s: REPLAY - AKKKK! no code yet! return BAD SESSION\n",
> +		__func__);
> +	status = nfserr_badsession;
> +	goto out;
>  }
>  #endif /* CONFIG_NFSD_V4_1 */
>  
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index f49ddde..6db74f7 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1238,7 +1238,16 @@ static __be32
>  nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
>  		      struct nfsd4_sequence *seq)
>  {
> -	return nfserr_opnotsupp;	/* stub */
> +	DECODE_HEAD;
> +
> +	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
> +	COPYMEM(seq->sessionid, NFS4_MAX_SESSIONID_LEN);
> +	READ32(seq->seqid);
> +	READ32(seq->slotid);
> +	READ32(seq->maxslots);
> +	READ32(seq->catchthis);
> +
> +	DECODE_TAIL;
>  }
>  #endif /* CONFIG_NFSD_V4_1 */
>  
> @@ -3001,7 +3010,21 @@ static __be32
>  nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
>  		      struct nfsd4_sequence *seq)
>  {
> -	/* stub */
> +	ENCODE_HEAD;
> +
> +	if (nfserr)
> +		goto out;
> +
> +	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 20);
> +	WRITEMEM(seq->sessionid, NFS4_MAX_SESSIONID_LEN);
> +	WRITE32(seq->seqid);
> +	WRITE32(seq->slotid);
> +	WRITE32(seq->maxslots);
> +	WRITE32(seq->target_maxslots);
> +	WRITE32(seq->status_flags);
> +
> +	ADJUST_ARGS();
> +out:
>  	return nfserr;
>  }
>  #endif /* CONFIG_NFSD_V4_1 */
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 8b166d8..d78ba3c 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -386,7 +386,13 @@ struct nfsd4_create_session {
>  };
>  
>  struct nfsd4_sequence {
> -	int	foo;	/* stub */
> +	nfs41_sessionid		sessionid;		/* request/response */
> +	u32			seqid;			/* request/response */
> +	u32			slotid;			/* request/response */
> +	u32			maxslots;		/* request/response */
> +	u32			catchthis;		/* request */
> +	u32			target_maxslots;	/* response */
> +	u32			status_flags;		/* response */

review 11-13: get rid of target_maxslots and status_flags for now.

>  };
>  
>  struct nfsd4_destroy_session {
