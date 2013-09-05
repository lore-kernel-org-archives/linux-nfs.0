Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab3IEQCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 12:02:46 -0400
Message-ID: <5228AB2B.1000608@RedHat.com>
Date: Thu, 05 Sep 2013 12:02:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH - nfs-utils] gssd: suppress error message if rpc_pipefs
 dir disappears.
References: <20130902145750.357c303a@notabene.brown>
In-Reply-To: <20130902145750.357c303a@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/13 00:57, NeilBrown wrote:
> It is possible for a race to cause a name to appear when an rpc_pipefs
> dir is scanned but to no longer be present when we try to open it.
> 
> So if the error is ENOENT, don't complain.
> 
> This is similar to
> 
> commit 5ac9bcfd820f09af4d3f87f1f7346d896f70bc9a
> Author: David Jeffery <djeffery@redhat.com>
> Date:   Wed Jan 16 15:21:55 2013 -0500
> 
>     rpc.idmapd: Ignore open failures in dirscancb()
> 
> which addressed a similar issue in idmapd.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed! 

steved.

> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index b7e2bbb..2d3dbec 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -467,8 +467,9 @@ process_clnt_dir(char *dir, char *pdir)
>  	}
>  	sprintf(clp->dirname, "%s/%s", pdir, dir);
>  	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
> -		printerr(0, "ERROR: can't open %s: %s\n",
> -			 clp->dirname, strerror(errno));
> +		if (errno != ENOENT)
> +			printerr(0, "ERROR: can't open %s: %s\n",
> +				 clp->dirname, strerror(errno));
>  		goto fail_destroy_client;
>  	}
>  	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
> 
