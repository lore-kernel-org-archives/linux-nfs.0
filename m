Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365AbcGTPN5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2016 11:13:57 -0400
Subject: Re: [PATCH 1/2] blkmapd: Let running correctly when pid file exists
To: Kinglong Mee <kinglongmee@gmail.com>
References: <ae344139-4e98-4c61-ac5c-352f04bc80db@gmail.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <9878b4f2-0e9e-5918-6a1d-b1fb64728d32@RedHat.com>
Date: Wed, 20 Jul 2016 11:13:55 -0400
MIME-Version: 1.0
In-Reply-To: <ae344139-4e98-4c61-ac5c-352f04bc80db@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/13/2016 10:51 PM, Kinglong Mee wrote:
> Blkmapd cannot run until blkmapd.pid is unlinked.
> This patch lets checking exists based on lockf without stat.
> 
> # ps -ajx | grep blkmapd
>  1644  9126  9125  1644 pts/1     9125 S+       0   0:00 grep --color=auto blkmapd
> # ll /var/run/blkmapd
>  -rw-r--r--. 1 root root 5 Jul 14 09:51 /var/run/blkmapd.pid
> # blkmapd
>  Pid file /var/run/blkmapd.pid already existed
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... 

steved.

> ---
>  utils/blkmapd/device-discovery.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 052d582..50e2746 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -436,7 +436,6 @@ static void usage(void)
>  int main(int argc, char **argv)
>  {
>  	int opt, dflag = 0, fg = 0, ret = 1;
> -	struct stat statbuf;
>  	char pidbuf[64];
>  
>  	while ((opt = getopt(argc, argv, "hdf")) != -1) {
> @@ -460,11 +459,6 @@ int main(int argc, char **argv)
>  	if (fg) {
>  		openlog("blkmapd", LOG_PERROR, 0);
>  	} else {
> -		if (!stat(PID_FILE, &statbuf)) {
> -			fprintf(stderr, "Pid file %s already existed\n", PID_FILE);
> -			exit(1);
> -		}
> -
>  		if (daemon(0, 0) != 0) {
>  			fprintf(stderr, "Daemonize failed\n");
>  			exit(1);
> @@ -478,7 +472,7 @@ int main(int argc, char **argv)
>  		}
>  
>  		if (lockf(pidfd, F_TLOCK, 0) < 0) {
> -			BL_LOG_ERR("Lock pid file %s failed\n", PID_FILE);
> +			BL_LOG_ERR("Already running; Exiting!");
>  			close(pidfd);
>  			exit(1);
>  		}
> 
