From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Date: Sun, 29 Aug 2010 08:29:49 +1000
Message-ID: <20100829082949.376206ba@notabene>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org,
	chuck.lever@oracle.com, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51730 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444Ab0H1W36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Aug 2010 18:29:58 -0400
In-Reply-To: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 28 Aug 2010 07:35:14 -0400
Jeff Layton <jlayton@redhat.com> wrote:

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
> Full disclosure: I'm not 100% thrilled with this patch. It seems ugly
> and kludgey, but I don't see a better way to handle this problem.
> Suggestions welcome.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/nfsd/nfsd.c   |    3 +++
>  utils/nfsd/nfssvc.c |   21 +++++++++++++++++++++
>  utils/nfsd/nfssvc.h |    1 +
>  3 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 1cda1e5..6bbf697 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -246,6 +246,9 @@ main(int argc, char **argv)
>  		exit(1);
>  	}
>  
> +	/* make sure nfsdfs is mounted if it's available */
> +	nfssvc_mount_nfsdfs();
> +
>  	/* can only change number of threads if nfsd is already up */
>  	if (nfssvc_inuse()) {
>  		socket_up = 1;
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 34c67ca..9ea3a1f 100644
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
> @@ -44,6 +46,25 @@
>  char buf[128];
>  
>  /*
> + * Using the "new" interfaces for nfsd requires that /proc/fs/nfsd is
> + * actually mounted. Make an attempt to mount it here if it doesn't appear
> + * to be. If the mount attempt fails, no big deal -- fall back to using nfsctl
> + * instead.
> + */
> +void
> +nfssvc_mount_nfsdfs(void)
> +{
> +	int err;
> +	struct stat statbuf;
> +
> +	err = stat(NFSD_THREAD_FILE, &statbuf);
> +	if (err == 0 || errno != ENOENT)
> +		return;
> +
> +	system("/bin/mount -t nfsd nfsd /proc/fs/nfsd >/dev/null 2>&1");
> +}
> +
> +/*
>   * Are there already sockets configured? If not, then it is safe to try to
>   * open some and pass them through.
>   *
> diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
> index 0c69bd6..ff81165 100644
> --- a/utils/nfsd/nfssvc.h
> +++ b/utils/nfsd/nfssvc.h
> @@ -20,6 +20,7 @@
>   *
>   */
>  
> +void	nfssvc_mount_nfsdfs(void);
>  int	nfssvc_inuse(void);
>  int	nfssvc_set_sockets(const int family, const unsigned int protobits,
>  			   const char *host, const char *port);

