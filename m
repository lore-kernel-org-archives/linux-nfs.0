From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: [PATCH] rpc.gssd: Don't supply the KDC with unsupported encryption types
Date: Tue, 11 Nov 2008 13:33:50 -0500
Message-ID: <4d569c330811111033p70264b87r2463e8cb68b985e9@mail.gmail.com>
References: <4919B57C.6050104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:55512 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbYKKSdx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2008 13:33:53 -0500
Received: by rn-out-0910.google.com with SMTP id k40so27862rnd.17
        for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2008 10:33:51 -0800 (PST)
In-Reply-To: <4919B57C.6050104-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

This patch shouldn't be necessary.

When you say "registers with the KDC", I assume that you mean gets a
TGT.  That transaction doesn't need to (and shouldn't) have encryption
types limited.  When we get a service ticket to talk to an NFS server,
we need to limit the encryption types to those supported by the
kernel.  The current code should be doing that.  If you find that
isn't the case, let me know.


K.C.

On Tue, Nov 11, 2008 at 11:40 AM, Steve Dickson <SteveD@redhat.com> wrote:
> Hello,
>
> It seems when rpc.gssd initially registers with the KDC, it sends
> a long list of encryption types that are not supported:
>
>      Encryption Types: aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 des3-cbc-sha1
>                        rc4-hmac des-cbc-crc des-cbc-md5 des-cbc-md4 rsa-sha1-cms
>                        rsa-md5-cms des-ede3-cbc-env rc2-cbc-env rsa-env
>
> Now the theory is mounts will hang if the KDC (like a Solaris KDC) returns an unsupported
> encryption type since the client will not know what to do with it. I'm currently
> trying to test this theory with people that actually have a working Solaris KDC,
> unfortunately I'm not one of those people...
>
> But to me, it just makes sense that rpc.gssd should only talk about encryption types
> it supports. It seems like it would cuts out any and all confusion.The following
> patch does just that.
>
> comments?
>
> steved.
>
>
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Nov 11 11:08:13 EST 2008
>
>        When rpc.gssd registers with the KDC, only talk
>        about the supported encryption types during the
>        initial registration so the KDC will only
>        return supported encryption types.
>
>        Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 77814bc..7f131c9 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -125,6 +125,10 @@
>
>  /* Global list of principals/cache file names for machine credentials */
>  struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
> +static krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
> +                                   ENCTYPE_DES_CBC_MD5,
> +                                   ENCTYPE_DES_CBC_MD4 };
> +static int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
>
>  /*==========================*/
>  /*===  Internal routines ===*/
> @@ -309,10 +313,6 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
>        u_int maj_stat, min_stat;
>        gss_cred_id_t credh;
>        gss_OID_set_desc  desired_mechs;
> -       krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
> -                                   ENCTYPE_DES_CBC_MD5,
> -                                   ENCTYPE_DES_CBC_MD4 };
> -       int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
>
>        /* We only care about getting a krb5 cred */
>        desired_mechs.count = 1;
> @@ -412,6 +412,7 @@ gssd_get_single_krb5_cred(krb5_context context,
>
>        krb5_get_init_creds_opt_init(&options);
>        krb5_get_init_creds_opt_set_address_list(&options, NULL);
> +       krb5_get_init_creds_opt_set_etype_list(&options, enctypes, num_enctypes);
>  #ifdef TEST_SHORT_LIFETIME
>        /* set a short lifetime (for debugging only!) */
>        printerr(0, "WARNING: Using (debug) short machine cred lifetime!\n");
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
