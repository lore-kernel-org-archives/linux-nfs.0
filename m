Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34884 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbdGaOrg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jul 2017 10:47:36 -0400
Received: by mail-io0-f194.google.com with SMTP id f1so19231498ioj.2
        for <linux-nfs@vger.kernel.org>; Mon, 31 Jul 2017 07:47:35 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [Libtirpc-devel] [PATCH] Replace bcopy() calls with equivalent memmove() calls
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <d64c84f4-6253-5a31-0bff-771ebff2fa28@gentoo.org>
Date: Mon, 31 Jul 2017 10:47:33 -0400
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8B18C258-8434-42B0-80D9-89773DAD748F@gmail.com>
References: <d64c84f4-6253-5a31-0bff-771ebff2fa28@gentoo.org>
To: Joshua Kinard <kumba@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 31, 2017, at 12:26 AM, Joshua Kinard <kumba@gentoo.org> wrote:
> 
> As annotated in the bcopy(3) man page, bcopy() was marked as LEGACY in
> POSIX.1-2001 and removed in POSIX.1-2008, and should be replaced with
> either memcpy() or memmove() calls to copy bytes from one memory region to
> another.  The attached patch replaces all bcopy() calls in libtirpc with
> equivalent memmove() calls.

As far as I can tell these are all deprecated code paths.
memmove(3) should be safe in all cases, but there's no way
to test the change.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: Joshua Kinard <kumba@gentoo.org>
> ---
> 
> src/auth_time.c    |    2 +-
> src/crypt_client.c |    8 ++++----
> src/svc_auth_des.c |    2 +-
> 3 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/src/auth_time.c b/src/auth_time.c
> index 210d251..5426902 100644
> --- a/src/auth_time.c
> +++ b/src/auth_time.c
> @@ -104,7 +104,7 @@ static int uaddr_to_sockaddr(uaddr, sin)
> 	p_bytes[1] = (unsigned char)a[5] & 0x000000FF;
> 
> 	sin->sin_family = AF_INET; /* always */
> -	bcopy((char *)&p_bytes, (char *)&sin->sin_port, 2);
> +	memmove((char *)&sin->sin_port, (char *)&p_bytes, 2);
> 
> 	return (0);
> }
> diff --git a/src/crypt_client.c b/src/crypt_client.c
> index f393926..b8c5767 100644
> --- a/src/crypt_client.c
> +++ b/src/crypt_client.c
> @@ -75,8 +75,8 @@ _des_crypt_call(buf, len, dparms)
> 	des_crypt_1_arg.desbuf.desbuf_val = buf;
> 	des_crypt_1_arg.des_dir = dparms->des_dir;
> 	des_crypt_1_arg.des_mode = dparms->des_mode;
> -	bcopy(dparms->des_ivec, des_crypt_1_arg.des_ivec, 8);
> -	bcopy(dparms->des_key, des_crypt_1_arg.des_key, 8);
> +	memmove(des_crypt_1_arg.des_ivec, dparms->des_ivec, 8);
> +	memmove(des_crypt_1_arg.des_key, dparms->des_key, 8);
> 
> 	result_1 = des_crypt_1(&des_crypt_1_arg, clnt);
> 	if (result_1 == (desresp *) NULL) {
> @@ -88,8 +88,8 @@ _des_crypt_call(buf, len, dparms)
> 
> 	if (result_1->stat == DESERR_NONE ||
> 	    result_1->stat == DESERR_NOHWDEVICE) {
> -		bcopy(result_1->desbuf.desbuf_val, buf, len);
> -		bcopy(result_1->des_ivec, dparms->des_ivec, 8);
> +		memmove(buf, result_1->desbuf.desbuf_val, len);
> +		memmove(dparms->des_ivec, result_1->des_ivec, 8);
> 	}
> 
> 	clnt_freeres(clnt, (xdrproc_t)xdr_desresp, result_1);
> diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
> index 64a7682..5813c5a 100644
> --- a/src/svc_auth_des.c
> +++ b/src/svc_auth_des.c
> @@ -145,7 +145,7 @@ _svcauth_des(rqst, msg)
> 			return (AUTH_BADCRED);
> 		}
> 		cred->adc_fullname.name = area->area_netname;
> -		bcopy((char *)ixdr, cred->adc_fullname.name, 
> +		memmove(cred->adc_fullname.name, (char *)ixdr,
> 			(u_int)namelen);
> 		cred->adc_fullname.name[namelen] = 0;
> 		ixdr += (RNDUP(namelen) / BYTES_PER_XDR_UNIT);
> 

--
Chuck Lever
chucklever@gmail.com



