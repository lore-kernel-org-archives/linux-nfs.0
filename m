Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34017 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbbIZN71 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Sep 2015 09:59:27 -0400
Received: by qkfq186 with SMTP id q186so52468107qkf.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Sep 2015 06:59:26 -0700 (PDT)
Date: Sat, 26 Sep 2015 09:59:23 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] gssd: Improve scalability by not waiting for child
 processes
Message-ID: <20150926095923.578d4205@tlielax.poochiereds.net>
In-Reply-To: <5606A3C9.2040705@RedHat.com>
References: <1443043250-25703-1-git-send-email-steved@redhat.com>
	<20150925065317.6f5339cd@tlielax.poochiereds.net>
	<5606A3C9.2040705@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 26 Sep 2015 09:55:21 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 09/25/2015 06:53 AM, Jeff Layton wrote:
> > On Wed, 23 Sep 2015 17:20:50 -0400
> > Steve Dickson <steved@redhat.com> wrote:
> > 
> >> Instead of waiting on every fork, which would
> >> become a bottle neck during a mount storm, simply
> >> set a SIGCHLD signal handler to do the wait on
> >> the child process
> >>
> >> Signed-off-by: Steve Dickson <steved@redhat.com>
> >> ---
> >>  utils/gssd/gssd.c      | 18 ++++++++++++++++++
> >>  utils/gssd/gssd_proc.c | 11 ++---------
> >>  2 files changed, 20 insertions(+), 9 deletions(-)
> >>
> >> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> >> index e480349..8b778cb 100644
> >> --- a/utils/gssd/gssd.c
> >> +++ b/utils/gssd/gssd.c
> >> @@ -44,11 +44,13 @@
> >>  #define _GNU_SOURCE
> >>  #endif
> >>  
> >> +#include <sys/types.h>
> >>  #include <sys/param.h>
> >>  #include <sys/socket.h>
> >>  #include <sys/time.h>
> >>  #include <sys/resource.h>
> >>  #include <sys/inotify.h>
> >> +#include <sys/wait.h>
> >>  #include <rpc/rpc.h>
> >>  #include <netinet/in.h>
> >>  #include <arpa/inet.h>
> >> @@ -736,6 +738,21 @@ sig_die(int signal)
> >>  	printerr(1, "exiting on signal %d\n", signal);
> >>  	exit(0);
> >>  }
> >> +static void
> >> +sig_child(int signal)
> >> +{
> >> +	int err;
> >> +	pid_t pid;
> >> +
> >> +	/* Parent: just wait on child to exit and return */
> >> +	do {
> >> +		pid = wait(&err);
> >> +	} while(pid == -1 && errno != -ECHILD);
> >> +
> >> +	if (WIFSIGNALED(err))
> >> +		printerr(0, "WARNING: forked child was killed"
> >> +			 "with signal %d\n", WTERMSIG(err));
> >> +}
> >>  
> >>  static void
> >>  usage(char *progname)
> >> @@ -902,6 +919,7 @@ main(int argc, char *argv[])
> >>  
> >>  	signal(SIGINT, sig_die);
> >>  	signal(SIGTERM, sig_die);
> >> +	signal(SIGCHLD, sig_child);
> >>  	signal_set(&sighup_ev, SIGHUP, gssd_scan_cb, NULL);
> >>  	signal_add(&sighup_ev, NULL);
> >>  	event_set(&inotify_ev, inotify_fd, EV_READ | EV_PERSIST, gssd_inotify_cb, NULL);
> >> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> >> index 11168b2..8f5ca03 100644
> >> --- a/utils/gssd/gssd_proc.c
> >> +++ b/utils/gssd/gssd_proc.c
> >> @@ -656,16 +656,9 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
> >>  			/* fork() failed! */
> >>  			printerr(0, "WARNING: unable to fork() to handle"
> >>  				"upcall: %s\n", strerror(errno));
> >> -			return;
> >> +			/* FALLTHROUGH */
> >>  		default:
> >> -			/* Parent: just wait on child to exit and return */
> >> -			do {
> >> -				pid = wait(&err);
> >> -			} while(pid == -1 && errno != -ECHILD);
> >> -
> >> -			if (WIFSIGNALED(err))
> >> -				printerr(0, "WARNING: forked child was killed"
> >> -					 "with signal %d\n", WTERMSIG(err));
> >> +			/* Parent: Return and wait for the SIGCHLD */
> >>  			return;
> >>  		}
> >>  no_fork:
> > 
> > I was thinking that there was some reason that we couldn't do this --
> > that there were data structures that would get wiped if you got another
> > upcall while the first was being processed. The forking should prevent
> > that though, so I think this looks reasonable.
> > 
> > Acked-by: Jeff Layton <jlayton@poochiereds.net>
> > 
> Self Nak... During my testing there was a large number zombie rpc.gssd
> process... I'm not sure why but they are there... 
> 
> steved.

It's probably what I mentioned in the other mail.

If you get several children exiting in quick succession then you may
only have one SIGCHLD pending. What you really want to do there is to
have your SIGCHLD handler reap as many children as it can in a
non-blocking fashion and then return. Even better would be to utilize
the event loop for handling the signal...

-- 
Jeff Layton <jlayton@poochiereds.net>
