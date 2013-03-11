Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab3CKSyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 14:54:38 -0400
Date: Mon, 11 Mar 2013 14:54:34 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v3 6/7] NFSv4: Add O_DENY* open flags support
Message-ID: <20130311145434.707f5ed1@corrin.poochiereds.net>
In-Reply-To: <1362065133-9490-7-git-send-email-piastry@etersoft.ru>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-7-git-send-email-piastry@etersoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 28 Feb 2013 19:25:32 +0400
Pavel Shilovsky <piastry@etersoft.ru> wrote:

> by passing these flags to NFSv4 open request.
> 
> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> ---
>  fs/nfs/nfs4xdr.c | 24 ++++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 26b1439..58ddc74 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1325,7 +1325,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
>  	encode_string(xdr, name->len, name->name);
>  }
>  
> -static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
> +static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
> +				int open_flags)
>  {
>  	__be32 *p;
>  
> @@ -1343,7 +1344,22 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
>  	default:
>  		*p++ = cpu_to_be32(0);
>  	}
> -	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
> +	if (open_flags & O_DENYMAND) {


As Bruce mentioned, I think a mount option to enable this on a per-fs
basis would be a better approach than this new O_DENYMAND flag. 


> +		switch (open_flags & (O_DENYREAD|O_DENYWRITE)) {
> +		case O_DENYREAD:
> +			*p = cpu_to_be32(NFS4_SHARE_DENY_READ);
> +			break;
> +		case O_DENYWRITE:
> +			*p = cpu_to_be32(NFS4_SHARE_DENY_WRITE);
> +			break;
> +		case O_DENYREAD|O_DENYWRITE:
> +			*p = cpu_to_be32(NFS4_SHARE_DENY_BOTH);
> +			break;
> +		default:
> +			*p = cpu_to_be32(0);
> +		}
> +	} else
> +		*p = cpu_to_be32(0);
>  }
>  
>  static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
> @@ -1354,7 +1370,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
>   * owner 4 = 32
>   */
>  	encode_nfs4_seqid(xdr, arg->seqid);
> -	encode_share_access(xdr, arg->fmode);
> +	encode_share_access(xdr, arg->fmode, arg->open_flags);
>  	p = reserve_space(xdr, 36);
>  	p = xdr_encode_hyper(p, arg->clientid);
>  	*p++ = cpu_to_be32(24);
> @@ -1491,7 +1507,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
>  	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
>  	encode_nfs4_stateid(xdr, arg->stateid);
>  	encode_nfs4_seqid(xdr, arg->seqid);
> -	encode_share_access(xdr, arg->fmode);
> +	encode_share_access(xdr, arg->fmode, 0);
>  }
>  
>  static void


Other than that, this seems reasonable.

Acked-by: Jeff Layton <jlayton@redhat.com>
