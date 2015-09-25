Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35346 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbbIYLNm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 07:13:42 -0400
Received: by qgt47 with SMTP id 47so66064376qgt.2
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 04:13:42 -0700 (PDT)
Date: Fri, 25 Sep 2015 07:13:39 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [PATCH] gssd: Improve scalability by not waiting for child
 processes
Message-ID: <20150925071339.75e2d7db@tlielax.poochiereds.net>
In-Reply-To: <1443043250-25703-1-git-send-email-steved@redhat.com>
References: <1443043250-25703-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 23 Sep 2015 17:20:50 -0400
Steve Dickson <steved@redhat.com> wrote:

> Instead of waiting on every fork, which would
> become a bottle neck during a mount storm, simply
> set a SIGCHLD signal handler to do the wait on
> the child process
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/gssd.c      | 18 ++++++++++++++++++
>  utils/gssd/gssd_proc.c | 11 ++---------
>  2 files changed, 20 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index e480349..8b778cb 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -44,11 +44,13 @@
>  #define _GNU_SOURCE
>  #endif
>  
> +#include <sys/types.h>
>  #include <sys/param.h>
>  #include <sys/socket.h>
>  #include <sys/time.h>
>  #include <sys/resource.h>
>  #include <sys/inotify.h>
> +#include <sys/wait.h>
>  #include <rpc/rpc.h>
>  #include <netinet/in.h>
>  #include <arpa/inet.h>
> @@ -736,6 +738,21 @@ sig_die(int signal)
>  	printerr(1, "exiting on signal %d\n", signal);
>  	exit(0);
>  }
> +static void
> +sig_child(int signal)
> +{
> +	int err;
> +	pid_t pid;
> +
> +	/* Parent: just wait on child to exit and return */
> +	do {
> +		pid = wait(&err);
> +	} while(pid == -1 && errno != -ECHILD);
> +
> +	if (WIFSIGNALED(err))
> +		printerr(0, "WARNING: forked child was killed"
> +			 "with signal %d\n", WTERMSIG(err));
> +}
>  

That said, there is a problem here. You're going to get a SIGCHLD for
each child that exits and multiples could exit at nearly the same time,
so some of the SIGCHLDs can get "lost". This probably needs to keep
reaping children (in a non-blocking way) until there aren't any more
that have exited.

Also, given that gssd is based around libevent, you may be better off
adding a libevent signal event handler instead of doing it with a "raw"
signal handler. That way you won't block upcalls that are in the middle
of running just to reap child processes.

>  static void
>  usage(char *progname)
> @@ -902,6 +919,7 @@ main(int argc, char *argv[])
>  
>  	signal(SIGINT, sig_die);
>  	signal(SIGTERM, sig_die);
> +	signal(SIGCHLD, sig_child);
>  	signal_set(&sighup_ev, SIGHUP, gssd_scan_cb, NULL);
>  	signal_add(&sighup_ev, NULL);
>  	event_set(&inotify_ev, inotify_fd, EV_READ | EV_PERSIST, gssd_inotify_cb, NULL);
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 11168b2..8f5ca03 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -656,16 +656,9 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  			/* fork() failed! */
>  			printerr(0, "WARNING: unable to fork() to handle"
>  				"upcall: %s\n", strerror(errno));
> -			return;
> +			/* FALLTHROUGH */
>  		default:
> -			/* Parent: just wait on child to exit and return */
> -			do {
> -				pid = wait(&err);
> -			} while(pid == -1 && errno != -ECHILD);
> -
> -			if (WIFSIGNALED(err))
> -				printerr(0, "WARNING: forked child was killed"
> -					 "with signal %d\n", WTERMSIG(err));
> +			/* Parent: Return and wait for the SIGCHLD */
>  			return;
>  		}
>  no_fork:


-- 
Jeff Layton <jlayton@poochiereds.net>
