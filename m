Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758810Ab2HWRJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Aug 2012 13:09:45 -0400
Message-ID: <50366401.6040409@RedHat.com>
Date: Thu, 23 Aug 2012 13:10:25 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH-Resend 2/2] blkmapd: proper signal handling
References: <1345739792-2385-1-git-send-email-bergwolf@gmail.com> <1345739792-2385-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1345739792-2385-2-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/23/2012 12:36 PM, Peng Tao wrote:
> Signed-off-by: Peng Tao <tao.peng@emc.com>
Committed...

steved.
> ---
>  utils/blkmapd/device-discovery.c |   18 +++++++++++++++++-
>  1 files changed, 17 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 8eddf50..df4627e 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -36,6 +36,7 @@
>  #include <scsi/scsi.h>
>  #include <scsi/scsi_ioctl.h>
>  #include <scsi/sg.h>
> +#include <signal.h>
>  
>  #include <stdlib.h>
>  #include <stdio.h>
> @@ -61,6 +62,7 @@
>  
>  struct bl_disk *visible_disk_list;
>  int    bl_watch_fd, bl_pipe_fd, nfs_pipedir_wfd, rpc_pipedir_wfd;
> +int    pidfd = -1;
>  
>  struct bl_disk_path *bl_get_path(const char *filepath,
>  				 struct bl_disk_path *paths)
> @@ -431,10 +433,20 @@ static int bl_event_helper(void)
>  	return ret;
>  }
>  
> +void sig_die(int signal)
> +{
> +	if (pidfd >= 0) {
> +		close(pidfd);
> +		unlink(PID_FILE);
> +	}
> +	BL_LOG_ERR("exit on signal(%d)\n", signal);
> +	exit(1);
> +}
> +
>  /* Daemon */
>  int main(int argc, char **argv)
>  {
> -	int pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
> +	int opt, dflag = 0, fg = 0, ret = 1;
>  	struct stat statbuf;
>  	char pidbuf[64];
>  
> @@ -479,6 +491,10 @@ int main(int argc, char **argv)
>  		write(pidfd, pidbuf, strlen(pidbuf));
>  	}
>  
> +	signal(SIGINT, sig_die);
> +	signal(SIGTERM, sig_die);
> +	signal(SIGHUP, SIG_IGN);
> +
>  	if (dflag) {
>  		bl_discover_devices();
>  		exit(0);
