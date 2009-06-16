From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/44] nfsd41: change check_slot_seqid parameters
Date: Tue, 16 Jun 2009 13:39:51 -0400
Message-ID: <20090616173951.GA3045@fieldses.org>
References: <1245115160-6898-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:47140 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbZFPRjs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 13:39:48 -0400
In-Reply-To: <1245115160-6898-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:19:20AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> For separation of session slot and clientid slot processing.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

This was actually already upstream, just not in my for-2.6.31, because I
based my for-2.6.31 branch off of 2.6.30-rc3, and submitted this to
2.6.30 after -rc3.  So my choices included:

	- Rebase for-2.6.31 onto a later -rc: but things will go
	  smoother if I stop rebasing and rewriting my for-xxx branches,
	  and I've stopped doing that this time around.
	- Apply an identical patch to for-2.6.31 at the same time I
	  submit it upstream: then after I submit for-2.6.31, the
	  history would end up with two commits each for the same patch.
	  I don't think that's a serious problem, but it seems ugly.
	- Merge upstream back into my for-2.6.31 after submitting
	  patches: Linus has complained before about people doing this
	  too much, but I'm assuming doing it in a case like this where
	  there's a clear reason is OK.

I think option 3 was the right one; so I've done that now and merged
2.6.30 back into for-2.6.31....

Better might have been to merge a for-2.6.30 branch into for-2.6.31.

--b.

> ---
>  fs/nfsd/nfs4state.c |   24 +++++++++++++-----------
>  1 files changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d5caf2a..c22ec9b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1313,26 +1313,26 @@ error:
>  }
>  
>  static int
> -check_slot_seqid(u32 seqid, struct nfsd4_slot *slot)
> +check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
>  {
> -	dprintk("%s enter. seqid %d slot->sl_seqid %d\n", __func__, seqid,
> -		slot->sl_seqid);
> +	dprintk("%s enter. seqid %d slot_seqid %d\n", __func__, seqid,
> +		slot_seqid);
>  
>  	/* The slot is in use, and no response has been sent. */
> -	if (slot->sl_inuse) {
> -		if (seqid == slot->sl_seqid)
> +	if (slot_inuse) {
> +		if (seqid == slot_seqid)
>  			return nfserr_jukebox;
>  		else
>  			return nfserr_seq_misordered;
>  	}
>  	/* Normal */
> -	if (likely(seqid == slot->sl_seqid + 1))
> +	if (likely(seqid == slot_seqid + 1))
>  		return nfs_ok;
>  	/* Replay */
> -	if (seqid == slot->sl_seqid)
> +	if (seqid == slot_seqid)
>  		return nfserr_replay_cache;
>  	/* Wraparound */
> -	if (seqid == 1 && (slot->sl_seqid + 1) == 0)
> +	if (seqid == 1 && (slot_seqid + 1) == 0)
>  		return nfs_ok;
>  	/* Misordered replay or misordered new request */
>  	return nfserr_seq_misordered;
> @@ -1355,7 +1355,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  
>  	if (conf) {
>  		slot = &conf->cl_slot;
> -		status = check_slot_seqid(cr_ses->seqid, slot);
> +		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
> +					  slot->sl_inuse);
>  		if (status == nfserr_replay_cache) {
>  			dprintk("Got a create_session replay! seqid= %d\n",
>  				slot->sl_seqid);
> @@ -1380,7 +1381,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		}
>  
>  		slot = &unconf->cl_slot;
> -		status = check_slot_seqid(cr_ses->seqid, slot);
> +		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
> +					  slot->sl_inuse);
>  		if (status) {
>  			/* an unconfirmed replay returns misordered */
>  			status = nfserr_seq_misordered;
> @@ -1481,7 +1483,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	slot = &session->se_slots[seq->slotid];
>  	dprintk("%s: slotid %d\n", __func__, seq->slotid);
>  
> -	status = check_slot_seqid(seq->seqid, slot);
> +	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
>  	if (status == nfserr_replay_cache) {
>  		cstate->slot = slot;
>  		cstate->session = session;
> -- 
> 1.6.3
> 
