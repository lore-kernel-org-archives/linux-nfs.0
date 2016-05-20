Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36548 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbcETPbT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2016 11:31:19 -0400
Received: by mail-yw0-f195.google.com with SMTP id u62so15222340ywe.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2016 08:31:18 -0700 (PDT)
Message-ID: <1463758273.14305.1.camel@poochiereds.net>
Subject: Re: [PATCH] sunrpc: fix stripping of padded MIC tokens
From: Jeff Layton <jlayton@poochiereds.net>
To: =?UTF-8?Q?Tom=C3=A1=C5=A1?= Trnka <ttrnka@mail.muni.cz>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 20 May 2016 11:31:13 -0400
In-Reply-To: <38521704.8vjDAt0XQs@mintaka.ncbr.muni.cz>
References: <38521704.8vjDAt0XQs@mintaka.ncbr.muni.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-05-20 at 16:41 +0200, Tomáš Trnka wrote:
> The length of the GSS MIC token need not be a multiple of four bytes.
> It is then padded by XDR to a multiple of 4 B, but unwrap_integ_data()
> would previously only trim mic.len + 4 B. The remaining up to three
> bytes would then trigger a check in nfs4svc_decode_compoundargs(),
> leading to a "garbage args" error and mount failure:
> 
> nfs4svc_decode_compoundargs: compound not properly padded!
> nfsd: failed to decode arguments!
> 
> This would prevent older clients using the pre-RFC 4121 MIC format
> (37-byte MIC including a 9-byte OID) from mounting exports from v3.9+
> servers using krb5i.
> 
> The trimming was introduced by commit 4c190e2f913f ("sunrpc: trim off
> trailing checksum before returning decrypted or integrity authenticated
> buffer").
> 
> Signed-off-by: Tomáš Trnka <ttrnka@mail.muni.cz>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c 
> b/net/sunrpc/auth_gss/svcauth_gss.c
> index 1095be9..4605dc7 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -857,8 +857,8 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf 
> *buf, u32 seq, struct g
>  		goto out;
>  	if (svc_getnl(&buf->head[0]) != seq)
>  		goto out;
> -	/* trim off the mic at the end before returning */
> -	xdr_buf_trim(buf, mic.len + 4);
> +	/* trim off the mic and padding at the end before returning */
> +	xdr_buf_trim(buf, round_up_to_quad(mic.len) + 4);
>  	stat = 0;
>  out:
>  	kfree(mic.data);

Looks reasonable:

Acked-by: Jeff Layton <jlayton@poochiereds.net>
