Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754463AbbFSTwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jun 2015 15:52:53 -0400
Date: Fri, 19 Jun 2015 15:52:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH 1/1 net-next] sunrpc: use sg_init_one() in
 krb5_rc4_setup_enc/seq_key()
Message-ID: <20150619195251.GD21903@fieldses.org>
References: <1434484672-5877-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1434484672-5877-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Tue, Jun 16, 2015 at 09:57:52PM +0200, Fabian Frederick wrote:
> Don't opencode sg_init_one()
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/sunrpc/auth_gss/gss_krb5_crypto.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index b5408e8..fee3c15 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -881,9 +881,7 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
>  	if (err)
>  		goto out_err;
>  
> -	sg_init_table(sg, 1);
> -	sg_set_buf(sg, &zeroconstant, 4);
> -
> +	sg_init_one(sg, &zeroconstant, 4);
>  	err = crypto_hash_digest(&desc, sg, 4, Kseq);
>  	if (err)
>  		goto out_err;
> @@ -951,9 +949,7 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
>  	if (err)
>  		goto out_err;
>  
> -	sg_init_table(sg, 1);
> -	sg_set_buf(sg, zeroconstant, 4);
> -
> +	sg_init_one(sg, zeroconstant, 4);
>  	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
>  	if (err)
>  		goto out_err;
> -- 
> 2.4.2
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
