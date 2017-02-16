Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753622AbdBPKXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 05:23:41 -0500
Received: from smtp.corp.redhat.com (int-mx16.intmail.prod.int.phx2.redhat.com [10.5.11.28])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2F9ACC057FA5
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2017 10:23:42 +0000 (UTC)
Subject: Re: [nfs-utils PATCH V2 1/2] Replace non-thread-safe strtok function
 calls in gssd
To: Frank Sorenson <sorenson@redhat.com>, linux-nfs@vger.kernel.org
References: <911ff1ff-ac59-2c10-e165-cd1186b1f940@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <d9c722ac-8d70-5df4-ceb1-3c35213600b6@RedHat.com>
Date: Thu, 16 Feb 2017 05:23:41 -0500
MIME-Version: 1.0
In-Reply-To: <911ff1ff-ac59-2c10-e165-cd1186b1f940@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/2017 06:01 PM, Frank Sorenson wrote:
> Author: Frank Sorenson <sorenson@redhat.com>
> Date:   2017-02-09 16:35:51 -0600
>
>     gssd: replace non-thread-safe strtok with strsep
>     
>     gssd uses the non-thread-safe strtok() function, which
>     can lead to incorrect program behavior.
>     
>     Replace strtok() with the thread-safe strsep().
>     
>     Signed-off-by: Frank Sorenson <sorenson@redhat.com>
Committed....

steved.
>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index d74d372..30c6ace 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -729,10 +729,11 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  	char			*target = NULL;
>  	char			*service = NULL;
>  	char			*enctypes = NULL;
> +	char			*pbuf = info->lbuf;
>  
>  	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
>  
> -	for (p = strtok(info->lbuf, " "); p; p = strtok(NULL, " ")) {
> +	while ((p = strsep(&pbuf, " "))) {
>  		if (!strncmp(p, "mech=", strlen("mech=")))
>  			mech = p + strlen("mech=");
>  		else if (!strncmp(p, "uid=", strlen("uid=")))
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

