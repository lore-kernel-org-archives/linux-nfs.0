Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755152AbaGITLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jul 2014 15:11:11 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s69JBAZi000551
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 9 Jul 2014 15:11:10 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-58-240.rdu2.redhat.com [10.10.58.240])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s69JB3hO001905
	for <linux-nfs@vger.kernel.org>; Wed, 9 Jul 2014 15:11:08 -0400
Message-ID: <53BD93C5.6020806@RedHat.com>
Date: Wed, 09 Jul 2014 15:11:01 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] gssd: Error out when rpc_pipefs directory is empty
References: <1404830019-4299-1-git-send-email-steved@redhat.com>
In-Reply-To: <1404830019-4299-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/08/2014 10:33 AM, Steve Dickson wrote:
> When there is no kernel modules loaded the rpc_pipefs
> directory is empty, which cause rpc.gssd to silently
> exit.
> 
> This patch adds a check to see if the topdirs_list
> is empty. If so error out without dropping a core.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd_main_loop.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index 9970028..6946ab6 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -173,6 +173,10 @@ topdirs_init_list(void)
>  		if (ret)
>  			goto out_err;
>  	}
> +	if (TAILQ_EMPTY(&topdirs_list)) {
> +		printerr(0, "ERROR: rpc_pipefs directory '%s' is empty!\n", pipefs_dir);
> +		return -1;
> +	}
>  	closedir(pipedir);
>  	return 0;
>  out_err:
> @@ -233,9 +237,10 @@ gssd_run()
>  	sigaddset(&set, DNOTIFY_SIGNAL);
>  	sigprocmask(SIG_UNBLOCK, &set, NULL);
>  
> -	if (topdirs_init_list() != 0)
> -		return;
> -
> +	if (topdirs_init_list() != 0) {
> +		/* Error msg is already printed */
> +		exit(1);
> +	}
>  	init_client_list();
>  
>  	printerr(1, "beginning poll\n");
> 
