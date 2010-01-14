From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd41: Create the recovery entry for the NFSv4.1
	client
Date: Thu, 14 Jan 2010 12:26:13 -0500
Message-ID: <20100114172613.GD27670@fieldses.org>
References: <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41561 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257Ab0ANRZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 12:25:07 -0500
In-Reply-To: <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 11, 2009 at 07:10:48PM -0800, Ricardo Labiaga wrote:
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Thanks, looks right--applied.

--b.

> ---
>  fs/nfsd/nfs4state.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2153f9b..32aa837 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2487,8 +2487,10 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	}
>  	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
>  
> -	if (nfsd4_has_session(&resp->cstate))
> +	if (nfsd4_has_session(&resp->cstate)) {
>  		open->op_stateowner->so_confirmed = 1;
> +		nfsd4_create_clid_dir(open->op_stateowner->so_client);
> +	}
>  
>  	/*
>  	* Attempt to hand out a delegation. No error return, because the
> -- 
> 1.5.4.3
> 
