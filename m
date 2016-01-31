Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34620 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564AbcAaKkx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 05:40:53 -0500
Received: by mail-pa0-f65.google.com with SMTP id yy13so5813702pab.1
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 02:40:53 -0800 (PST)
Subject: Re: [PATCH 4/5] NFSv4.x: Fix wraparound issues when validing the
 callback sequence id
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-4-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-5-git-send-email-trond.myklebust@primarydata.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <56ADE4A4.9060604@gmail.com>
Date: Sun, 31 Jan 2016 18:40:36 +0800
MIME-Version: 1.0
In-Reply-To: <1453730956-5325-5-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 1/25/2016 22:09, Trond Myklebust wrote:
> We need to make sure that we don't allow args->csa_sequenceid == 0.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/callback_proc.c | 43 +++++++++++++++++--------------------------
>  1 file changed, 17 insertions(+), 26 deletions(-)
... snip ...
> @@ -486,6 +476,13 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  		goto out_unlock;
>  	}
>  
> +	status = validate_seqid(tbl, slot, args);
> +	if (status)
> +		goto out_unlock;

For NFS4ERR_RETRY_UNCACHED_REP error, nfs should initialize
cb_sequenceres information, but goto out_unlock will skip it.

thanks,
Kinglong Mee

> +
> +	cps->slotid = args->csa_slotid;
> +	tbl->highest_used_slotid = args->csa_slotid;
> +
>  	memcpy(&res->csr_sessionid, &args->csa_sessionid,
>  	       sizeof(res->csr_sessionid));
>  	res->csr_sequenceid = args->csa_sequenceid;
> @@ -493,12 +490,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  	res->csr_highestslotid = tbl->server_highest_slotid;
>  	res->csr_target_highestslotid = tbl->target_highest_slotid;
>  
> -	status = validate_seqid(tbl, args);
> -	if (status)
> -		goto out_unlock;
> -
> -	cps->slotid = args->csa_slotid;
> -
>  	/* The ca_maxresponsesize_cached is 0 with no DRC */
>  	if (args->csa_cachethis != 0)
>  		return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);
> @@ -518,7 +509,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  	 * If CB_SEQUENCE returns an error, then the state of the slot
>  	 * (sequence ID, cached reply) MUST NOT change.
>  	 */
> -	slot->seq_nr++;
> +	slot->seq_nr = args->csa_sequenceid;
>  out_unlock:
>  	spin_unlock(&tbl->slot_tbl_lock);
>  
> 
