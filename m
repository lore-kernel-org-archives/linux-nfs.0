Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56023 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab3KASkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Nov 2013 14:40:04 -0400
Date: Fri, 1 Nov 2013 14:39:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com
Subject: Re: [PATCH] nfsd4: fix discarded security labels on setattr
Message-ID: <20131101183957.GC17294@fieldses.org>
References: <20131101144903.GA15493@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131101144903.GA15493@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 01, 2013 at 10:49:03AM -0400, J. Bruce Fields wrote:
> Jeff just noticed this.  Argh.

Applying for 3.13.--b.

> 
> --b.
> 
> commit 1012e867f57b3ae5712ea329065a9ab899c7986c
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Nov 1 10:42:15 2013 -0400
> 
>     nfsd4: fix discarded security labels on setattr
>     
>     Security labels in setattr calls are currently ignored because we forget
>     to set label->len.
>     
>     Reported-by: Jeff Layton <jlayton@redhat.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d9454fe..438d818 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -411,6 +411,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		label->data = kzalloc(dummy32 + 1, GFP_KERNEL);
>  		if (!label->data)
>  			return nfserr_jukebox;
> +		label->len = dummy32;
>  		defer_free(argp, kfree, label->data);
>  		memcpy(label->data, buf, dummy32);
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
