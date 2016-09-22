Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37898 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752747AbcIVQMh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 12:12:37 -0400
Date: Thu, 22 Sep 2016 12:12:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix dprintk in nfsd4_encode_getdeviceinfo
Message-ID: <20160922161236.GG30401@fieldses.org>
References: <1474543142-3534-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1474543142-3534-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 22, 2016 at 07:19:02AM -0400, Jeff Layton wrote:
> nfserr is big-endian, so we should convert it to host-endian before
> printing it.

Thanks, applying.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 0aa0236a1429..7f8232e32dc7 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4062,7 +4062,7 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	u32 starting_len = xdr->buf->len, needed_len;
>  	__be32 *p;
>  
> -	dprintk("%s: err %d\n", __func__, nfserr);
> +	dprintk("%s: err %d\n", __func__, be32_to_cpu(nfserr));
>  	if (nfserr)
>  		goto out;
>  
> -- 
> 2.7.4
