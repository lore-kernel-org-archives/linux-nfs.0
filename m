Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57796 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbaCaVLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Mar 2014 17:11:34 -0400
Date: Mon, 31 Mar 2014 17:11:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: fix memory leak in nfsd4_encode_fattr()
Message-ID: <20140331211134.GD20024@fieldses.org>
References: <1394427127-9985-1-git-send-email-zheng.z.yan@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1394427127-9985-1-git-send-email-zheng.z.yan@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 12:52:07PM +0800, Yan, Zheng wrote:
> fh_put() does not free the temporary file handle.

Applying, sorry for the delay.--b.

> 
> Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
> ---
>  fs/nfsd/nfs4xdr.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 63f2395..8de4c9d 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2499,8 +2499,10 @@ out:
>  		security_release_secctx(context, contextlen);
>  #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
>  	kfree(acl);
> -	if (tempfh)
> +	if (tempfh) {
>  		fh_put(tempfh);
> +		kfree(tempfh);
> +	}
>  	return status;
>  out_nfserr:
>  	status = nfserrno(err);
> -- 
> 1.8.5.3
> 
