Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46078 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751749AbcKOTyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 14:54:38 -0500
Subject: Re: [Libtirpc-devel] [PATCH rpcbind v2] Move default state-dir to a
 subdirectory of /tmp
To: NeilBrown <neilb@suse.com>
References: <877f8almcf.fsf@notabene.neil.brown.name>
 <20161111210034.GM21655@vapier.lan> <87polzj7sx.fsf@notabene.neil.brown.name>
 <87vavqilre.fsf@notabene.neil.brown.name>
Cc: Mike Frysinger <vapier@gentoo.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <ed1f4f4c-fda6-6909-baab-5fbde2a5bc6c@RedHat.com>
Date: Tue, 15 Nov 2016 14:54:37 -0500
MIME-Version: 1.0
In-Reply-To: <87vavqilre.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/14/2016 02:05 AM, NeilBrown wrote:
> rpcbind can save state in a file to allow restart without forgetting
> about running services.
>
> The default location is currently "/tmp" which is
> not ideal for system files.  It is particularly unpleasant
> to put simple files there rather than creating a directory
> to contain them.
>
> On a modern Linux system it is preferable to use /run, and there it is
> even more consistent with practice to use a subdirectory.
>
> This directory needs to be create one each boot, and while there are
> tools (e.g. systemd-tmpfiles) which can do that it is cleaner to keep
> rpcbind self-contained and have it create the directory.
>
> So change the default location to /tmp/rpcbind, and create that
> directory.  If a different user-id is used, we need to create
> and chown the directory before dropping privileges.  We do this
> with care so avoid chowning the wrong thing by mistake.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>
> hi,
>  I realized that I hadn't allowed for the fact that rpcbind changes
>  it's uid, and we need to mkdir and chown before that.
>  I've also reverted the move to /run, but moved to /tmp/rpcbind
>  instead.  A subdirectory is a good idea, even in /tmp.
I'm beginning to think put these files into a directory call /tmp/rpcbind
is not a good idea...  Because if something in /tmp is called rpcbind (like a
debugging binary ;-) ) the mkdirs will silently fail which is not good.

Here is what I would like to do.

Move the directory into /run then create the /run/rpcbind when it
does not exist... I think that should play nicely in both the
systemd worlds and non-systemd worlds

Thoughts?

steved.
>
> NeilBrown
>
>
>  configure.ac    |  4 ++--
>  src/rpcbind.c   |  5 +++++
>  src/rpcbind.h   |  1 +
>  src/warmstart.c | 25 +++++++++++++++++++++----
>  4 files changed, 29 insertions(+), 6 deletions(-)
>
> diff --git a/configure.ac b/configure.ac
> index f84921eb27fb..df931c720f93 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -22,8 +22,8 @@ AC_ARG_ENABLE([warmstarts],
>  AM_CONDITIONAL(WARMSTART, test x$enable_warmstarts = xyes)
>  
>  AC_ARG_WITH([statedir],
> -  AS_HELP_STRING([--with-statedir=ARG], [use ARG as state dir @<:@default=/tmp@:>@])
> -  ,, [with_statedir=/tmp])
> +  AS_HELP_STRING([--with-statedir=ARG], [use ARG as state dir @<:@default=/tmp/rpcbind@:>@])
> +  ,, [with_statedir=/tmp/rpcbind])
>  AC_SUBST([statedir], [$with_statedir])
>  
>  AC_ARG_WITH([rpcuser],
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 87ccdc27e4c9..8db8dfc17c27 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -263,6 +263,11 @@ main(int argc, char *argv[])
>  			syslog(LOG_ERR, "cannot get uid of '%s': %m", id);
>  			exit(1);
>  		}
> +#ifdef WARMSTART
> +		if (warmstart) {
> +			mkdir_warmstart(p->pw_uid);
> +		}
> +#endif
>                  if (setgid(p->pw_gid) == -1) {
>                          syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", id, p->pw_gid);
>                          exit(1);
> diff --git a/src/rpcbind.h b/src/rpcbind.h
> index 74f9591ae720..5b1a9bb8651a 100644
> --- a/src/rpcbind.h
> +++ b/src/rpcbind.h
> @@ -129,6 +129,7 @@ int is_localroot(struct netbuf *);
>  extern void pmap_service(struct svc_req *, SVCXPRT *);
>  #endif
>  
> +void mkdir_warmstart(int uid);
>  void write_warmstart(void);
>  void read_warmstart(void);
>  
> diff --git a/src/warmstart.c b/src/warmstart.c
> index 122a058b7954..3a6bcb5e34e1 100644
> --- a/src/warmstart.c
> +++ b/src/warmstart.c
> @@ -45,19 +45,23 @@
>  #include <syslog.h>
>  #include <unistd.h>
>  #include <errno.h>
> +#include <fcntl.h>
>  
>  #include "rpcbind.h"
>  
> -#ifndef RPCBIND_STATEDIR
> -#define RPCBIND_STATEDIR "/tmp"
> -#endif
> -
>  /* These files keep the pmap_list and rpcb_list in XDR format */
>  #define	RPCBFILE	RPCBIND_STATEDIR "/rpcbind.xdr"
>  #ifdef PORTMAP
>  #define	PMAPFILE	RPCBIND_STATEDIR "/portmap.xdr"
>  #endif
>  
> +#ifndef O_DIRECTORY
> +#define O_DIRECTORY 0
> +#endif
> +#ifndef O_NOFOLLOW
> +#define O_NOFOLLOW 0
> +#endif
> +
>  static bool_t write_struct(char *, xdrproc_t, void *);
>  static bool_t read_struct(char *, xdrproc_t, void *);
>  
> @@ -139,8 +143,21 @@ error:
>  }
>  
>  void
> +mkdir_warmstart(int uid)
> +{
> +	if (mkdir(RPCBIND_STATEDIR, 0770) == 0) {
> +		int fd = open(RPCBIND_STATEDIR, O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
> +		if (fd >= 0) {
> +			fchown(fd, uid, -1);
> +			close(fd);
> +		}
> +	}
> +}
> +
> +void
>  write_warmstart()
>  {
> +	(void) mkdir(RPCBIND_STATEDIR, 0770);
>  	(void) write_struct(RPCBFILE, (xdrproc_t)xdr_rpcblist_ptr, &list_rbl);
>  #ifdef PORTMAP
>  	(void) write_struct(PMAPFILE, (xdrproc_t)xdr_pmaplist_ptr, &list_pml);

