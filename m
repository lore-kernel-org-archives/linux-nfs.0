Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47800 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933202AbcBZQBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Feb 2016 11:01:44 -0500
Date: Fri, 26 Feb 2016 11:01:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix a memory leak when meeting unsupported
 state_protect_how4
Message-ID: <20160226160141.GB7760@fieldses.org>
References: <56D062FA.7090605@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56D062FA.7090605@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 26, 2016 at 10:36:42PM +0800, Kinglong Mee wrote:
> Remember free allocated client when meeting unsupported state protect how.

Thanks for catching that!

Impact looks minimal for now as it's a leak in a case no current client
exercises, as far as I know.

Queueing up for 4.5.

--b.

> 
> Fixes: 50c7b948adbd ("nfsd: minor consolidation of mach_cred handling code")
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c484a2b..9d20c6a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2408,7 +2408,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  	default:				/* checked by xdr code */
>  		WARN_ON_ONCE(1);
>  	case SP4_SSV:
> -		return nfserr_encr_alg_unsupp;
> +		status = nfserr_encr_alg_unsupp;
> +		goto out_nolock;
>  	}
>  
>  	/* Cases below refer to rfc 5661 section 18.35.4: */
> -- 
> 2.5.0
