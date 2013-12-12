Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44693 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469Ab3LLQcG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 11:32:06 -0500
Date: Thu, 12 Dec 2013 11:32:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: using nfsd4_encode_noop for encoding
 destroy_session/free_stateid
Message-ID: <20131212163205.GH11521@fieldses.org>
References: <52A5A3B7.2000303@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52A5A3B7.2000303@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 09, 2013 at 07:04:23PM +0800, Kinglong Mee wrote:
> Get rid of the extra code, using nfsd4_encode_noop for encoding destroy_session and free_stateid.
> And, delete unused argument (fr_status) int nfsd4_free_stateid.

Thanks, applying.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 26 ++------------------------
>  fs/nfsd/xdr4.h    |  1 -
>  2 files changed, 2 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 91afb1c..b0b886e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3463,28 +3463,6 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
>  }
>  
>  static __be32
> -nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, __be32 nfserr,
> -			     struct nfsd4_destroy_session *destroy_session)
> -{
> -	return nfserr;
> -}
> -
> -static __be32
> -nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
> -			  struct nfsd4_free_stateid *free_stateid)
> -{
> -	__be32 *p;
> -
> -	if (nfserr)
> -		return nfserr;
> -
> -	RESERVE_SPACE(4);
> -	*p++ = nfserr;
> -	ADJUST_ARGS();
> -	return nfserr;
> -}
> -
> -static __be32
>  nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		      struct nfsd4_sequence *seq)
>  {
> @@ -3582,8 +3560,8 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>  	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_bind_conn_to_session,
>  	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
>  	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
> -	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
> -	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_free_stateid,
> +	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index b3ed644..916a407 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -374,7 +374,6 @@ struct nfsd4_test_stateid {
>  
>  struct nfsd4_free_stateid {
>  	stateid_t	fr_stateid;         /* request */
> -	__be32		fr_status;          /* response */
>  };
>  
>  /* also used for NVERIFY */
> -- 
> 1.8.4.2
