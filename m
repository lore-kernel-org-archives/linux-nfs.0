Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:41737 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbaGIKcD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 06:32:03 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so6384752qcq.20
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jul 2014 03:32:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 9 Jul 2014 06:32:00 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] gssd: Error out when rpc_pipefs directory is empty
Message-ID: <20140709063200.6add2dce@tlielax.poochiereds.net>
In-Reply-To: <1404830019-4299-1-git-send-email-steved@redhat.com>
References: <1404830019-4299-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue,  8 Jul 2014 10:33:39 -0400
Steve Dickson <steved@redhat.com> wrote:

> When there is no kernel modules loaded the rpc_pipefs
> directory is empty, which cause rpc.gssd to silently
> exit.
> 
> This patch adds a check to see if the topdirs_list
> is empty. If so error out without dropping a core.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
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

Does it drop a core now? It looks sort of like it would just exit(1)
silently.

In any case, this patch is certainly better than crashing, but gssd
looks sort of like it's doing the wrong thing here. Should it not just
wait idly for directories to show up instead of exiting if none are
present?

Also, because topdir_init_list is run only once, it looks like gssd
doesn't properly handle the case where there may be some directories in
rpc_pipefs when gssd starts, but then others show up later. Any that
show up after gssd is started are just ignored currently, right? That
seems like a subtle source of bugs if you just happen to start gssd a
little early.

-- 
Jeff Layton <jlayton@primarydata.com>
