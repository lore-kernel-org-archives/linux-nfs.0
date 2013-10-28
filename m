Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558Ab3J1Mn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 08:43:59 -0400
Message-ID: <526E5C3C.10405@RedHat.com>
Date: Mon, 28 Oct 2013 08:44:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: validate cred in gssd_acquire_user_cred
References: <1382720974-2746-1-git-send-email-dros@netapp.com>
In-Reply-To: <1382720974-2746-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/10/13 13:09, Weston Andros Adamson wrote:
> Call gss_inquire_cred after gssd_acquire_krb5_cred check for expired
> credentials.
> 
> This fixes a recent regression (since 302de786930a2c533068f9d8909a817b40f07c32)
> that causes the user's ticket cache to grow unbounded with expired service
> tickets when the user's credentials expire.
> 
> To reproduce this issue:
> 
>  - mount kerberos nfs export
>  - kinit for a short lifetime (ie "kinit -l 1m")
>  - run a job that opens a file and writes for more than the lifetime
>  - run klist a few times after expiry and see the list grow, ie:
> 
> Ticket cache: DIR::/run/user/1749600001/krb5cc/tktYmpGlX
> Default principal: dros@APIKIA.FAKE
> 
> Valid starting       Expires              Service principal
> 10/21/2013 15:39:38  10/21/2013 15:40:35  krbtgt/APIKIA.FAKE@APIKIA.FAKE
> 10/21/2013 15:39:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:35  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:36  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:37  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:37  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:38  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:38  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:41  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:41  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> Reviewed-by: Simo Sorce <simo@redhat.com>
Committed...

steved.

> 
> ---
> 
> Version 2 of the patch - version 1 had compiler warnings I completely missed!
> I wonder how it worked before... but this now compiles cleanly and I verified
> that it fixes the growing tkt cache problem.
> 
> Thanks,
>   -dros
> 
> 
>  utils/gssd/krb5_util.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index c6e52fd..697d1d2 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1405,6 +1405,13 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
>  
>  	ret = gssd_acquire_krb5_cred(name, gss_cred);
>  
> +	/* force validation of cred to check for expiry */
> +	if (ret == 0) {
> +		if (gss_inquire_cred(&min_stat, *gss_cred, NULL, NULL,
> +				     NULL, NULL) != GSS_S_COMPLETE)
> +			ret = -1;
> +	}
> +
>  	maj_stat = gss_release_name(&min_stat, &name);
>  	return ret;
>  }
> -- 1.8.3.1 (Apple Git-46)
> 
