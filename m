Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37820 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752931AbeCEVxv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Mar 2018 16:53:51 -0500
Date: Mon, 5 Mar 2018 16:53:50 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Removed -Werror=unused-result warnings.
Message-ID: <20180305215350.GC29226@fieldses.org>
References: <20180305155420.104418-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180305155420.104418-1-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 05, 2018 at 10:54:20AM -0500, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/nfs/nfs_mntent.c         | 3 ++-
>  utils/blkmapd/device-discovery.c | 6 ++++--
>  utils/mount/network.c            | 8 ++++++--
>  utils/nfsd/nfssvc.c              | 5 +++--
>  utils/statd/statd.c              | 3 ++-
>  5 files changed, 17 insertions(+), 8 deletions(-)
> 
> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
> index a2118a2..c60988a 100644
> --- a/support/nfs/nfs_mntent.c
> +++ b/support/nfs/nfs_mntent.c
> @@ -150,7 +150,8 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>  		res = fflush(mfp->mntent_fp);
>  		if (res < 0)
>  			/* Avoid leaving a corrupt mtab file */
> -			ftruncate(fileno(mfp->mntent_fp), length);
> +			if (ftruncate(fileno(mfp->mntent_fp), length))
> +				{/* ignore return value */};

Might be worth a log warning?

--b.

>  	}
>  	return (res < 0) ? 1 : 0;
>  }
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index b71c949..1afc80f 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -504,9 +504,11 @@ int main(int argc, char **argv)
>  			close(pidfd);
>  			exit(1);
>  		}
> -		ftruncate(pidfd, 0);
> +		if (ftruncate(pidfd, 0) < 0)
> +			BL_LOG_WARNING("ftruncate on %s failed: m\n", PID_FILE);
>  		sprintf(pidbuf, "%d\n", getpid());
> -		write(pidfd, pidbuf, strlen(pidbuf));
> +		if (write(pidfd, pidbuf, strlen(pidbuf)) != (ssize_t)strlen(pidbuf))
> +			BL_LOG_WARNING("write on %s failed: m\n", PID_FILE);
>  	}
>  
>  	signal(SIGINT, sig_die);
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 8d6e4c6..9a2c878 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -811,8 +811,12 @@ int start_statd(void)
>  			switch (pid) {
>  			case 0: /* child */
>  				setgroups(0, NULL);
> -				setgid(0);
> -				setuid(0);
> +				if (setgid(0) < 0)
> +					nfs_error(_("%s: setgid(0) failed: %s"),
> +						progname, strerror(errno));
> +				if (setuid(0) < 0)
> +					nfs_error(_("%s: setuid(0) failed: %s"),
> +						progname, strerror(errno));
>  				execle(START_STATD, START_STATD, NULL, envp);
>  				exit(1);
>  			case -1: /* error */
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index fc36792..7923f5d 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -68,7 +68,7 @@ nfssvc_mount_nfsdfs(char *progname)
>  	 * mount nfsdfs when nfsd.ko is plugged in. So, ignore the return
>  	 * code from it and just check for the "threads" file afterward.
>  	 */
> -	system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
> +	err = system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
>  
>  	err = stat(NFSD_THREAD_FILE, &statbuf);
>  	if (err == 0)
> @@ -325,7 +325,8 @@ nfssvc_set_time(const char *type, const int seconds)
>  		/* set same value for lockd */
>  		fd = open("/proc/sys/fs/nfs/nlm_grace_period", O_WRONLY);
>  		if (fd >= 0) {
> -			write(fd, nbuf, strlen(nbuf));
> +			if (write(fd, nbuf, strlen(nbuf)) != (ssize_t)strlen(nbuf))
> +				xlog(L_ERROR, "Unable to write nlm_grace_period : %m");
>  			close(fd);
>  		}
>  	}
> diff --git a/utils/statd/statd.c b/utils/statd/statd.c
> index 197d853..563a272 100644
> --- a/utils/statd/statd.c
> +++ b/utils/statd/statd.c
> @@ -225,7 +225,8 @@ static void set_nlm_port(char *type, int port)
>  	fd = open(pathbuf, O_WRONLY);
>  	if (fd < 0 && errno == ENOENT) {
>  		/* probably module not loaded */
> -		system("modprobe lockd");
> +		if (system("modprobe lockd"))
> +			{/* ignore return value */};
>  		fd = open(pathbuf, O_WRONLY);
>  	}
>  	if (fd >= 0) {
> -- 
> 2.14.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
