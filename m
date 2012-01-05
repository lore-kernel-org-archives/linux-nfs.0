Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758290Ab2AEVnJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 16:43:09 -0500
Message-ID: <4F06196A.60900@RedHat.com>
Date: Thu, 05 Jan 2012 16:43:06 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Meyering <jim@meyering.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: avoid double-free upon write failure
References: <87lipqumid.fsf@rho.meyering.net>
In-Reply-To: <87lipqumid.fsf@rho.meyering.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/02/2012 10:55 AM, Jim Meyering wrote:
> 
> * utils/gssd/context_lucid.c (prepare_krb5_rfc1964_buffer): Free just-
> calloc'd enc_key.data from one place, unconditionally, after calling
> write_lucid_keyblock, rather than from three places.  Before, upon
> failed write, we would free it, then goto out_err, where we would
> free it again, if it happened to be non-NULL.
> Coverity spotted the possible double free.
Committed....

steved.

> ---
>  utils/gssd/context_lucid.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
> index 3e695ab..64146d7 100644
> --- a/utils/gssd/context_lucid.c
> +++ b/utils/gssd/context_lucid.c
> @@ -80,6 +80,7 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
>  	uint32_t i;
>  	char *skd, *dkd;
>  	gss_buffer_desc fakeoid;
> +	int err;
> 
>  	/*
>  	 * The new Kerberos interface to get the gss context
> @@ -138,11 +139,10 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
>  	dkd = (char *) enc_key.data;
>  	for (i = 0; i < enc_key.length; i++)
>  		dkd[i] = skd[i] ^ 0xf0;
> -	if (write_lucid_keyblock(&p, end, &enc_key)) {
> -		free(enc_key.data);
> -		goto out_err;
> -	}
> +	err = write_lucid_keyblock(&p, end, &enc_key);
>  	free(enc_key.data);
> +	if (err)
> +		goto out_err;
> 
>  	if (write_lucid_keyblock(&p, end, &lctx->rfc1964_kd.ctx_key))
>  		goto out_err;
> @@ -153,7 +153,6 @@ out_err:
>  	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
>  	if (buf->value) free(buf->value);
>  	buf->length = 0;
> -	if (enc_key.data) free(enc_key.data);
>  	return -1;
>  }
> 
> --
> 1.7.8.1.391.g2c2ad
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
