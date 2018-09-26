Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727205AbeIZWzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Sep 2018 18:55:47 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D0866315009E
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2018 16:41:59 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Fix version setting by config for vers4
To: Justin Mitchell <jumitche@redhat.com>, linux-nfs@vger.kernel.org
References: <1537476294.8924.12.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6cb11ada-cbb6-35f3-1011-3729624bceab@RedHat.com>
Date: Wed, 26 Sep 2018 12:41:58 -0400
MIME-Version: 1.0
In-Reply-To: <1537476294.8924.12.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 9/20/18 4:44 PM, Justin Mitchell wrote:
> The code path for setting major versions via nfs.conf was not
> the same as setting it by cli option, resulting in vers4=n not
> working unless vers4.0=n was also set
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> ---
>  utils/nfsd/nfsd.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
Committed.... 

steved.

> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 6b57e2b..b256bd9 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -83,6 +83,9 @@ main(int argc, char **argv)
>  
>  	conf_init_file(NFS_CONFFILE); 
>  	xlog_from_conffile("nfsd");
> +
> +	nfssvc_get_minormask(&minormask);
> +
>  	count = conf_get_num("nfsd", "threads", count);
>  	grace = conf_get_num("nfsd", "grace-time", grace);
>  	lease = conf_get_num("nfsd", "lease-time", lease);
> @@ -101,13 +104,19 @@ main(int argc, char **argv)
>  	for (i = 2; i <= 4; i++) {
>  		char tag[20];
>  		sprintf(tag, "vers%d", i);
> -		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
> +		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i))) {
>  			NFSCTL_VERSET(versbits, i);
> -		else
> +			if (i == 4)
> +				minorvers = minorversset = minormask;
> +		} else {
>  			NFSCTL_VERUNSET(versbits, i);
> +			if (i == 4) {
> +				minorvers = 0;
> +				minorversset = minormask;
> +			}
> +		}
>  	}
>  
> -	nfssvc_get_minormask(&minormask);
>  	/* We assume the kernel will default all minor versions to 'on',
>  	 * and allow the config file to disable some.
>  	 */
> 
