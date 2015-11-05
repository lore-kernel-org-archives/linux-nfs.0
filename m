Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60870 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470AbbKEV6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2015 16:58:32 -0500
Date: Thu, 5 Nov 2015 16:58:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error codes
Message-ID: <20151105215830.GJ9210@fieldses.org>
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1446674837-4980-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 04, 2015 at 05:07:17PM -0500, Andrew Elble wrote:
> When delegations are revoked:
> 
> In the NFSv4 case, NFS4ERR_BAD_STATEID
> In the NFSv4.1 case, NFS4ERR_DELEG_REVOKED

Thanks.  That looks right, but this isn't unique to delegreturn--looks
like it's probably applicable to anything that might take a delegation
stateid--maybe preprocess_stateid_op needs a similar change?

--b.

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
> -- 
> 2.4.6
