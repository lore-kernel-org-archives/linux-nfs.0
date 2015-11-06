Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33864 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031995AbbKFM2S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2015 07:28:18 -0500
Received: by qkcn129 with SMTP id n129so44738364qkc.1
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2015 04:28:17 -0800 (PST)
Date: Fri, 6 Nov 2015 07:28:14 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error
 codes
Message-ID: <20151106072814.7e29d649@tlielax.poochiereds.net>
In-Reply-To: <1446674837-4980-1-git-send-email-aweits@rit.edu>
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed,  4 Nov 2015 17:07:17 -0500
Andrew Elble <aweits@rit.edu> wrote:

> When delegations are revoked:
> 
> In the NFSv4 case, NFS4ERR_BAD_STATEID
> In the NFSv4.1 case, NFS4ERR_DELEG_REVOKED
> 
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 66df2903ab8e..0f0634ca4158 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5147,15 +5147,21 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
>  		return status;
>  
> -	status = nfsd4_lookup_stateid(cstate, stateid, NFS4_DELEG_STID, &s, nn);
> +	status = nfsd4_lookup_stateid(cstate, stateid,
> +				NFS4_DELEG_STID|NFS4_REVOKED_DELEG_STID,
> +				&s, nn);
>  	if (status)
>  		goto out;
>  	dp = delegstateid(s);
>  	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
>  	if (status)
>  		goto put_stateid;
> -
> -	destroy_delegation(dp);
> +	if (dp->dl_stid.sc_type == NFS4_DELEG_STID)
> +		destroy_delegation(dp);
> +	if (dp->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID)
> +		status = nfserr_bad_stateid;
> +		if (cstate->minorversion)
> +			status = nfserr_deleg_revoked;
>  put_stateid:
>  	nfs4_put_stid(&dp->dl_stid);
>  out:

Looks correct to me.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
