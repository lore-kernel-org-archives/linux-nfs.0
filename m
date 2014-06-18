Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210AbaFRPmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2014 11:42:05 -0400
Date: Wed, 18 Jun 2014 11:42:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix return of nfs4_acl_write_who
Message-ID: <20140618154204.GF17790@fieldses.org>
References: <1403000048-31245-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403000048-31245-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2014 at 06:14:08AM -0400, Jeff Layton wrote:
> AFAICT, the only way to hit this error is to pass this function a bogus
> "who" value. In that case, we probably don't want to return -1 as that
> could get sent back to the client. Turn this into nfserr_serverfault,
> which is a more appropriate error for a server bug like this.

I don't really care since there shouldn't be any way to hit this, but
OK, applying for 3.17.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4acl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index d714156a19fd..b0cf00d3ee7d 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -935,5 +935,5 @@ __be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
>  		return 0;
>  	}
>  	WARN_ON_ONCE(1);
> -	return -1;
> +	return nfserr_serverfault;
>  }
> -- 
> 1.9.3
> 
