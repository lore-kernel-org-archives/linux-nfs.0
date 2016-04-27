Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbcD0Rdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 13:33:55 -0400
Subject: Re: [PATCH/nfs-utils] mount: run START_STATD fully as root
To: NeilBrown <neilb@suse.com>
References: <87shyey1zw.fsf@notabene.neil.brown.name>
Cc: NFS List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5720F801.5090700@RedHat.com>
Date: Wed, 27 Apr 2016 13:33:53 -0400
MIME-Version: 1.0
In-Reply-To: <87shyey1zw.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/21/2016 07:29 PM, NeilBrown wrote:
> 
> If a "user" mount is the first NFSv3 mount, mount.nfs will be running
> setuid to root (with non-root as the real-uid) when it executes START_STATD.
> 
> start-statd is a shell script and many shells refuse to run setuid,
> dropping privileges immediately.  This results in start-statd running
> as an unprivileged user and so statd fails to start.
> 
> To fix this, call "setuid(0)" to set real uid to zero.  Also call "setgid(0)"
> for consistency.
> 
> The behaviour of a shell can often be affected by the environment,
> such as the "shell functions" that bash includes from the environment.
> To avoid the user being able to pass such environment to the shell,
> explicitly pass an empty environment.  The start-statd script explicitly
> sets the PATH which is all it really needs.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... 

steved.

> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 7240ca7bcdc4..0d12613e86a4 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -795,6 +795,7 @@ int start_statd(void)
>  		if (S_ISREG(stb.st_mode) && (stb.st_mode & S_IXUSR)) {
>  			int cnt = STATD_TIMEOUT * 10;
>  			int status = 0;
> +			char * const envp[1] = { NULL };
>  			const struct timespec ts = {
>  				.tv_sec = 0,
>  				.tv_nsec = 100000000,
> @@ -802,7 +803,9 @@ int start_statd(void)
>  			pid_t pid = fork();
>  			switch (pid) {
>  			case 0: /* child */
> -				execl(START_STATD, START_STATD, NULL);
> +				setgid(0);
> +				setuid(0);
> +				execle(START_STATD, START_STATD, NULL, envp);
>  				exit(1);
>  			case -1: /* error */
>  				nfs_error(_("%s: fork failed: %s"),
> 
