Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58174 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726270AbeJDHhF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 03:37:05 -0400
Date: Wed, 3 Oct 2018 20:46:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix fall-through annotations
Message-ID: <20181004004619.GL17517@fieldses.org>
References: <20181002100848.GA31166@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181002100848.GA31166@embeddedor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Tue, Oct 02, 2018 at 12:08:48PM +0200, Gustavo A. R. Silva wrote:
> Replace "fallthru" with a proper "fall through" annotation.
> 
> Also, add an annotation were it is expected to fall through.
> 
> These fixes are part of the ongoing efforts to enabling
> -Wimplicit-fallthrough
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>  fs/nfsd/vfs.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index d74583f..2751976 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1407,6 +1407,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  					*created = 1;
>  				break;
>  			}
> +			/* fall through */
>  		case NFS4_CREATE_EXCLUSIVE4_1:
>  			if (   d_inode(dchild)->i_mtime.tv_sec == v_mtime
>  			    && d_inode(dchild)->i_atime.tv_sec == v_atime
> @@ -1415,7 +1416,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  					*created = 1;
>  				goto set_attr;
>  			}
> -			 /* fallthru */
> +			/* fall through */
>  		case NFS3_CREATE_GUARDED:
>  			err = nfserr_exist;
>  		}
> -- 
> 2.7.4
