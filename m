Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbbGaMSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jul 2015 08:18:22 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 538CEB72B2
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 12:18:22 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-48-157.rdu2.redhat.com [10.10.48.157])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t6VCILQj003544
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 08:18:21 -0400
Message-ID: <55BB678C.3050803@RedHat.com>
Date: Fri, 31 Jul 2015 08:18:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.gssd: Only clear the retval if it has not been set
References: <1438290916-12071-1-git-send-email-steved@redhat.com>
In-Reply-To: <1438290916-12071-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/30/2015 05:15 PM, Steve Dickson wrote:
> In gssd_search_krb5_keytab() an error code can be
> cleared by blindly setting retval to zero.
> 
> Reported-by: Jianhong Yin <jiyin@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  utils/gssd/krb5_util.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index f1ebc0d..ecf17a2 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -772,7 +772,9 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
>  			    "keytab '%s'\n", k5err, kt_name);
>  	}
>  
> -	retval = 0;
> +	/* Only clear the retval if has not been set */
> +	if (retval < 0)
> +		retval = 0;
>    out:
>  	free(k5err);
>  	return retval;
> 
