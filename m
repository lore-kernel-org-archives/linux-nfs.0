From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 02/31] nfsd41: change check_slot_seqid parameters
Date: Thu, 30 Apr 2009 20:35:14 +0300
Message-ID: <49F9E152.5090809@panasas.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com> <1240938005-23778-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:6631 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933446AbZD3Rfy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 13:35:54 -0400
In-Reply-To: <1240938005-23778-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 28, 2009, 19:59 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> For separation of session slot and clientid slot processing.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |   24 +++++++++++++-----------
>  1 files changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 42ebcb3..43c821f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1310,26 +1310,26 @@ error:
>  }
>  
>  static int
> -check_slot_seqid(u32 seqid, struct nfsd4_slot *slot)
> +check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse )

nit: extra space before closing parentheses.
(I'll remove it when merging into the pnfs tree)

Benny

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
> @@ -1352,7 +1352,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  
>  	if (conf) {
>  		slot = &conf->cl_slot;
> -		status = check_slot_seqid(cr_ses->seqid, slot);
> +		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
> +					  slot->sl_inuse);
>  		if (status == nfserr_replay_cache) {
>  			dprintk("Got a create_session replay! seqid= %d\n",
>  				slot->sl_seqid);
> @@ -1377,7 +1378,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		}
>  
>  		slot = &unconf->cl_slot;
> -		status = check_slot_seqid(cr_ses->seqid, slot);
> +		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
> +					  slot->sl_inuse);
>  		if (status) {
>  			/* an unconfirmed replay returns misordered */
>  			status = nfserr_seq_misordered;
> @@ -1487,7 +1489,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	slot = &session->se_slots[seq->slotid];
>  	dprintk("%s: slotid %d\n", __func__, seq->slotid);
>  
> -	status = check_slot_seqid(seq->seqid, slot);
> +	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
>  	if (status == nfserr_replay_cache) {
>  		cstate->slot = slot;
>  		cstate->session = session;
