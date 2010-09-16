From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #4)
Date: Thu, 16 Sep 2010 09:40:56 -0400
Message-ID: <20100916094056.1e8a5d50@barsoom.rdu.redhat.com>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
	<4C921580.2050903@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab0IPNlH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 09:41:07 -0400
In-Reply-To: <4C921580.2050903-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 16 Sep 2010 09:02:56 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> Hey Jeff,
> 
> Here is the patch with the L_WARNING change and the 
> s/else if/if change I just mentioned... 
> 
> steved.
> 
> Author: Jeff Layton <jlayton@redhat.com>
> Date:   Thu Sep 16 08:58:02 2010 -0400
>     
> There's a bit of a chicken and egg problem when nfsd is run the first
> time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
> is plugged in via a modprobe.conf "install" directive.
> 
> If someone runs rpc.nfsd without plugging in nfsd.ko first,
> /proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
> nfsctl interface. After that, nfsd will be plugged in and subsequent
> rpc.nfsd invocations will use that instead.
> 
> This is a problem as some nfsd command-line options are ignored when the
> legacy interface is used. It'll also be a problem for people who want
> IPv6 enabled servers. The upshot is that we really don't want to use the
> legacy interface unless there is no other option.
> 
> To avoid this situation, have rpc.nfsd check to see if the "threads"
> file is already present. If it's not, then make an attempt to mount
> /proc/fs/nfsd.  This is a "best-effort" sort of thing, however so we
> just ignore the return code from the mount attempt and fall back to
> using nfsctl() if it fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 1cda1e5..658b8fa 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -246,6 +246,9 @@ main(int argc, char **argv)
>  		exit(1);
>  	}
>  
> +	/* make sure nfsdfs is mounted if it's available */
> +	nfssvc_mount_nfsdfs(progname);
> +
>  	/* can only change number of threads if nfsd is already up */
>  	if (nfssvc_inuse()) {
>  		socket_up = 1;
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 34c67ca..7693626 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -15,9 +15,11 @@
>  #include <netdb.h>
>  #include <netinet/in.h>
>  #include <arpa/inet.h>
> +#include <sys/stat.h>
>  #include <unistd.h>
>  #include <fcntl.h>
>  #include <errno.h>
> +#include <stdlib.h>
>  
>  #include "nfslib.h"
>  #include "xlog.h"
> @@ -31,9 +33,13 @@
>   */
>  #undef IPV6_SUPPORTED
>  
> -#define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
> -#define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
> -#define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
> +#ifndef NFSD_FS_DIR
> +#define NFSD_FS_DIR	  "/proc/fs/nfsd"
> +#endif
> +
> +#define NFSD_PORTS_FILE   NFSD_FS_DIR "/portlist"
> +#define NFSD_VERS_FILE    NFSD_FS_DIR "/versions"
> +#define NFSD_THREAD_FILE  NFSD_FS_DIR "/threads"
>  
>  /*
>   * declaring a common static scratch buffer here keeps us from having to
> @@ -44,6 +50,46 @@
>  char buf[128];
>  
>  /*
> + * Using the "new" interfaces for nfsd requires that /proc/fs/nfsd is
> + * actually mounted. Make an attempt to mount it here if it doesn't appear
> + * to be. If the mount attempt fails, no big deal -- fall back to using nfsctl
> + * instead.
> + */
> +void
> +nfssvc_mount_nfsdfs(char *progname)
> +{
> +	int err;
> +	struct stat statbuf;
> +
> +	err = stat(NFSD_THREAD_FILE, &statbuf);
> +	if (err == 0)
> +		return;
> +
> +	if (errno != ENOENT) {
> +		xlog(L_ERROR, "Unable to stat %s: errno %d (%m)",
> +				NFSD_THREAD_FILE, errno);
> +		return;
> +	}
> +
> +	/*
> +	 * this call can return an error if modprobe is set up to automatically
> +	 * mount nfsdfs when nfsd.ko is plugged in. So, ignore the return
> +	 * code from it and just check for the "threads" file afterward.
> +	 */
> +	system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
> +
> +	err = stat(NFSD_THREAD_FILE, &statbuf);
> +	if (err == 0)
> +		return;
> +
> +	xlog(L_WARNING, "Unable to access " NFSD_FS_DIR " errno %d (%m)." 
> +		"\nPlease try, as root, 'mount -t nfsd nfsd " NFSD_FS_DIR 
> +		"' and then restart %s to correct the problem", errno, progname);
> +
> +	return;
> +}
> +
> +/*
>   * Are there already sockets configured? If not, then it is safe to try to
>   * open some and pass them through.
>   *
> diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
> index 0c69bd6..1a01cec 100644
> --- a/utils/nfsd/nfssvc.h
> +++ b/utils/nfsd/nfssvc.h
> @@ -20,6 +20,7 @@
>   *
>   */
>  
> +void	nfssvc_mount_nfsdfs(char *progname);
>  int	nfssvc_inuse(void);
>  int	nfssvc_set_sockets(const int family, const unsigned int protobits,
>  			   const char *host, const char *port);
> 

Looks good to me.
-- 
Jeff Layton <jlayton@redhat.com>
