From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sm-notify: always exiting without any notification
Date: Mon, 8 Dec 2008 18:34:44 -0500
Message-ID: <20081208233444.GC24083@fieldses.org>
References: <493A81A2.5050904@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35675 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243AbYLHXeq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 18:34:46 -0500
In-Reply-To: <493A81A2.5050904-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 06, 2008 at 08:44:02AM -0500, Steve Dickson wrote:
> In my recent trials and tribulations on dealing with
> the state file I found this fairly obvious bug:

Yipes.  This code needs all the eyes it can get, I guess.

--b.

> 
> commit 5d8b800b8438222a55c4698c86b558b15717aa21
> Author: Steve Dickson <steved@redhat.com>
> Date:   Sat Dec 6 08:31:29 2008 -0500
> 
>     sm-notify: always exiting without any notification
>     
>     Added curly brackets around the record_pid() check which
>     stops sm-notify from exiting when a pid file does not
>     exist.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index 7a7ae1a..d8e2c01 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -193,10 +193,11 @@ usage:		fprintf(stderr,
>  	openlog("sm-notify", LOG_PID, LOG_DAEMON);
>  
>  	if (strcmp(_SM_BASE_PATH, BASEDIR) == 0) {
> -		if (record_pid() == 0 && force == 0 && opt_update_state == 1)
> +		if (record_pid() == 0 && force == 0 && opt_update_state == 1) {
>  			/* already run, don't try again */
>  			nsm_log(LOG_NOTICE, "Already notifying clients; Exiting!");
>  			exit(0);
> +		}
>  	}
>  
>  	if (opt_srcaddr) {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
