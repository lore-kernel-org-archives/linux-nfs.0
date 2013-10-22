Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab3JVOmD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:42:03 -0400
Subject: Re: [PATCH] gssd: validate cred in gssd_acquire_user_cred
From: Simo Sorce <simo@redhat.com>
To: Weston Andros Adamson <dros@netapp.com>
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1382450675-14636-1-git-send-email-dros@netapp.com>
References: <1382450675-14636-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Oct 2013 10:41:59 -0400
Message-ID: <1382452919.9794.63.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-22 at 10:04 -0400, Weston Andros Adamson wrote:
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
> ---
>  utils/gssd/krb5_util.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index c6e52fd..ec5db83 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1405,6 +1405,13 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
>  
>  	ret = gssd_acquire_krb5_cred(name, gss_cred);
>  
> +	/* force validation of cred to check for expiry */
> +	if (ret == 0) {
> +		if (gss_inquire_cred(min_stat, gss_cred, NULL, NULL,
> +				     NULL, NULL) != GSS_S_COMPLETE)
> +			ret = -1;
> +	}
> +
>  	maj_stat = gss_release_name(&min_stat, &name);
>  	return ret;
>  }

A good start, but given you are inquiring creds, then I think it would
totally make sense to pass in a uint32_t for the 4th argument
(lifetime), and check if there is "enough".

For example, if it returns a lifetime of 1 second should we continue ?
There is a fat chance that it will fail later on.

I think we should at least log it if the credential we are trying to use
turns out to be really close to expiring, no ? It may save some gray
hairs to server administrators trying to find out what is going wrong
(like it happened to you :)

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

