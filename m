Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33992 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389656AbeHAREb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 13:04:31 -0400
Date: Wed, 1 Aug 2018 11:18:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: nixiaoming <nixiaoming@huawei.com>
Cc: jlayton@kernel.org, chuck.lever@oracle.com,
        trondmy@hammerspace.com, andros@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
Message-ID: <20180801151820.GA18338@fieldses.org>
References: <20180723015711.27961-1-nixiaoming@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180723015711.27961-1-nixiaoming@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 23, 2018 at 09:57:11AM +0800, nixiaoming wrote:
> READ_BUF(8);
> dummy = be32_to_cpup(p++);
> dummy = be32_to_cpup(p++);
> ...
> READ_BUF(4);
> dummy = be32_to_cpup(p++);
> 
> Assigning value to "dummy" here, but that stored value
> is overwritten before it can be used.
> At the same time READ_BUF() will re-update the pointer p.
> 
> delete invalid assignment statements

Thanks, applying with a minor comment tweak to clarify that we're
intentionally not reading these:

-		/* ssp_window and ssp_num_gss_handles */
+		/* ignore ssp_window and ssp_num_gss_handles: */
 		READ_BUF(8);
 		break;

--b.

> 
> Signed-off-by: nixiaoming <nixiaoming@huawei.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trondmy@hammerspace.com>
> ---
>  fs/nfsd/nfs4xdr.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index a96843c..375ad4b 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1392,8 +1392,6 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>  
>  		/* ssp_window and ssp_num_gss_handles */
>  		READ_BUF(8);
> -		dummy = be32_to_cpup(p++);
> -		dummy = be32_to_cpup(p++);
>  		break;
>  	default:
>  		goto xdr_error;
> -- 
> 2.10.1
