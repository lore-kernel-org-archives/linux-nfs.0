From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 18/22] More arcfour-hmac support
Date: Mon, 15 Mar 2010 12:41:33 -0400
Message-ID: <1268671293.2993.110.camel@localhost.localdomain>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
	 <1268655627-18712-19-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48806 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964834Ab0COQlk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 12:41:40 -0400
In-Reply-To: <1268655627-18712-19-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> For the arcfour-hmac support, the make_seq_num and get_seq_num
> functions need access to the kerberos context structure.
> This will be used in a later patch.
> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  include/linux/sunrpc/gss_krb5.h       |    6 ++++--
>  net/sunrpc/auth_gss/gss_krb5_seal.c   |    5 ++---
>  net/sunrpc/auth_gss/gss_krb5_seqnum.c |    6 ++++--
>  net/sunrpc/auth_gss/gss_krb5_unseal.c |    3 ++-
>  net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +++---
>  5 files changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
> index 9753485..de87e20 100644
> --- a/include/linux/sunrpc/gss_krb5.h
> +++ b/include/linux/sunrpc/gss_krb5.h
> @@ -275,12 +275,14 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *inbuf,
>  		    int offset);
>  
>  s32
> -krb5_make_seq_num(struct crypto_blkcipher *key,
> +krb5_make_seq_num(struct krb5_ctx *kctx,
> +		struct crypto_blkcipher *key,
>  		int direction,
>  		u32 seqnum, unsigned char *cksum, unsigned char *buf);
>  
>  s32
> -krb5_get_seq_num(struct crypto_blkcipher *key,
> +krb5_get_seq_num(struct krb5_ctx *kctx,
> +	       struct crypto_blkcipher *key,
>  	       unsigned char *cksum,
>  	       unsigned char *buf, int *direction, u32 *seqnum);
>  

It looks as if we are always passing in both ctx and ctx->seq. Is there
any reason why we should keep both parameters?



