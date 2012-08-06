Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756474Ab2HFOXM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Aug 2012 10:23:12 -0400
Message-ID: <501FD347.1000100@RedHat.com>
Date: Mon, 06 Aug 2012 10:23:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] rpc.gssd: handle error to open toplevel directory
References: <20120731205931.GA32161@fieldses.org> <1343768449-32205-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1343768449-32205-3-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 05:00 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Reverse the sense of the test here, and also add debugging and cleanup
> in the error case.
> 
> (Though the lack of cleanup isn't currently a problem in practice since
> we'll eventually exit in this case.)
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed...

steved.

> ---
>  utils/gssd/gssd_main_loop.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index 6914687..142c8c5 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -121,11 +121,13 @@ topdirs_add_entry(struct dirent *dent)
>  	}
>  	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
>  	tdi->fd = open(tdi->dirname, O_RDONLY);
> -	if (tdi->fd != -1) {
> -		fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
> -		fcntl(tdi->fd, F_NOTIFY,
> -		      DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
> +	if (tdi->fd == -1) {
> +		printerr(0, "ERROR: failed to open %s\n", tdi->dirname);
> +		free(tdi);
> +		return -1;
>  	}
> +	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
> +	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
>  
>  	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
>  	return 0;
