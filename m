Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33655 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761228Ab3DCTUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 15:20:07 -0400
Date: Wed, 3 Apr 2013 15:20:05 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: fanchaoting <fanchaoting@cn.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: PATCH]nfsd: don't run get_file if nfs4_preprocess_stateid_op
 return error
Message-ID: <20130403192005.GG6044@fieldses.org>
References: <5159868A.8080105@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5159868A.8080105@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying, and adding a cc: for stable.--b.

On Mon, Apr 01, 2013 at 09:07:22PM +0800, fanchaoting wrote:
> we should return error status directly when 
> nfs4_preprocess_stateid_op return error. 
> 
> Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4proc.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index ae73175..8288b08 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -931,14 +931,14 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	nfs4_lock_state();
>  	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
>  					cstate, stateid, WR_STATE, &filp);
> -	if (filp)
> -		get_file(filp);
> -	nfs4_unlock_state();
> -
>  	if (status) {
> +		nfs4_unlock_state();
>  		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
>  		return status;
>  	}
> +	if (filp)
> +		get_file(filp);
> +	nfs4_unlock_state();
>  
>  	cnt = write->wr_buflen;
>  	write->wr_how_written = write->wr_stable_how;
> -- 
> 1.7.1
> 
> 
