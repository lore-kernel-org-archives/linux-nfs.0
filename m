Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35914 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387574AbeHBPZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Aug 2018 11:25:59 -0400
Date: Thu, 2 Aug 2018 09:34:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: use true and false for boolean values
Message-ID: <20180802133445.GB30706@fieldses.org>
References: <20180802004405.GA23995@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180802004405.GA23995@embeddedor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, applied for for-4.19, thanks.--b.

On Wed, Aug 01, 2018 at 07:44:05PM -0500, Gustavo A. R. Silva wrote:
> Return statements in functions returning bool should use true or false
> instead of an integer value.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>  fs/nfsd/nfsfh.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index a008e76..b319080 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -451,7 +451,7 @@ static bool fsid_type_ok_for_exp(u8 fsid_type, struct svc_export *exp)
>  	switch (fsid_type) {
>  	case FSID_DEV:
>  		if (!old_valid_dev(exp_sb(exp)->s_dev))
> -			return 0;
> +			return false;
>  		/* FALL THROUGH */
>  	case FSID_MAJOR_MINOR:
>  	case FSID_ENCODE_DEV:
> @@ -461,13 +461,13 @@ static bool fsid_type_ok_for_exp(u8 fsid_type, struct svc_export *exp)
>  	case FSID_UUID8:
>  	case FSID_UUID16:
>  		if (!is_root_export(exp))
> -			return 0;
> +			return false;
>  		/* fall through */
>  	case FSID_UUID4_INUM:
>  	case FSID_UUID16_INUM:
>  		return exp->ex_uuid != NULL;
>  	}
> -	return 1;
> +	return true;
>  }
>  
>  
> -- 
> 2.7.4
