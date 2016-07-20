Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365AbcGTPOS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2016 11:14:18 -0400
Subject: Re: [PATCH 2/2] blkmapd: unlink pid file when error out
To: Kinglong Mee <kinglongmee@gmail.com>
References: <90d4ca22-1ec0-3cba-263f-7a3cdd871b28@gmail.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <832ad768-0211-9100-c9c2-2069068bd6ad@RedHat.com>
Date: Wed, 20 Jul 2016 11:14:17 -0400
MIME-Version: 1.0
In-Reply-To: <90d4ca22-1ec0-3cba-263f-7a3cdd871b28@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/13/2016 10:51 PM, Kinglong Mee wrote:
> Fix some error out without unlink pid file.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... 

steved.

> ---
>  utils/blkmapd/device-discovery.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 50e2746..8eb3fd0 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -486,13 +486,13 @@ int main(int argc, char **argv)
>  	signal(SIGHUP, SIG_IGN);
>  
>  	if (dflag) {
> -		bl_discover_devices();
> -		exit(0);
> +		ret = bl_discover_devices();
> +		goto out;
>  	}
>  
>  	if ((bl_watch_fd = inotify_init()) < 0) {
>  		BL_LOG_ERR("init inotify failed %s\n", strerror(errno));
> -		exit(1);
> +		goto out;
>  	}
>  
>  	/* open pipe file */
> @@ -513,7 +513,7 @@ int main(int argc, char **argv)
>  			BL_LOG_ERR("inquiry process return %d\n", ret);
>  		}
>  	}
> -
> +out:
>  	if (pidfd >= 0) {
>  		close(pidfd);
>  		unlink(PID_FILE);
> 
