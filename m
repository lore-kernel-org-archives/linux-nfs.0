From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mountd: use separate lockfiles
Date: Thu, 19 Mar 2009 14:01:21 -0400
Message-ID: <1237485682.7534.39.camel@heimdal.trondhjem.org>
References: <20090319172841.GF26378@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46062 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012AbZCSSBb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2009 14:01:31 -0400
In-Reply-To: <20090319172841.GF26378@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-03-19 at 12:28 -0500, Ben Myers wrote:
> Hi Steve,
> 
> I've been having some trouble with locking in mountd under load.  Where
> num_threads > 1 rmtab often gets munged.  Here's an attempt to sort that
> out.  Tested w/ nfs-utils-1.1.3 and 1.0.7.
> 
> Thanks,
> 	Ben
> 
> commit c17d382bcf24d74bfc70088492e5e79f347ee319
> Author: Ben Myers <bpm@sgi.com>
> Date:   Thu Mar 19 09:46:08 2009 -0500
> 
>     Mountd should use separate lockfiles
>     
>     Mountd keeps file descriptors used for locks separate from those used for io
>     and seems to assume that the lock will only be released on close of the file
>     descriptor that was used with fcntl.  Actually the lock is released when any
>     file descriptor for that file is closed.  When setexportent() is called after
>     xflock() he closes and reopens the io file descriptor and defeats the lock.
>     
>     This patch fixes that by using a separate file for locking, cleaning them up
>     when finished.
>     
>     Signed-off-by: Ben Myers <bpm@sgi.com>
> 
> diff --git a/support/export/rmtab.c b/support/export/rmtab.c
> index e11a22a..b49e1aa 100644
> --- a/support/export/rmtab.c
> +++ b/support/export/rmtab.c
> @@ -57,7 +57,7 @@ rmtab_read(void)
>  		   file. */
>  		int	lockid;
>  		FILE	*fp;
> -		if ((lockid = xflock(_PATH_RMTAB, "w")) < 0)
> +		if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
>  			return -1;
>  		rewindrmtabent();
>  		if (!(fp = fsetrmtabent(_PATH_RMTABTMP, "w"))) {
> diff --git a/support/export/xtab.c b/support/export/xtab.c
> index 510765a..3b1dcce 100644
> --- a/support/export/xtab.c
> +++ b/support/export/xtab.c
> @@ -23,7 +23,7 @@
>  static void cond_rename(char *newfile, char *oldfile);
>  
>  static int
> -xtab_read(char *xtab, int is_export)
> +xtab_read(char *xtab, char *lockfn, int is_export)
>  {
>      /* is_export == 0  => reading /proc/fs/nfs/exports - we know these things are exported to kernel
>       * is_export == 1  => reading /var/lib/nfs/etab - these things are allowed to be exported
> @@ -33,7 +33,7 @@ xtab_read(char *xtab, int is_export)
>  	nfs_export		*exp;
>  	int			lockid;
>  
> -	if ((lockid = xflock(xtab, "r")) < 0)
> +	if ((lockid = xflock(lockfn, "r")) < 0)
>  		return 0;
>  	setexportent(xtab, "r");
>  	while ((xp = getexportent(is_export==0, 0)) != NULL) {
> @@ -66,18 +66,20 @@ xtab_mount_read(void)
>  	int fd;
>  	if ((fd=open(_PATH_PROC_EXPORTS, O_RDONLY))>=0) {
>  		close(fd);
> -		return xtab_read(_PATH_PROC_EXPORTS, 0);
> +		return xtab_read(_PATH_PROC_EXPORTS,
> +				 _PATH_PROC_EXPORTS, 0);
>  	} else if ((fd=open(_PATH_PROC_EXPORTS_ALT, O_RDONLY) >= 0)) {
>  		close(fd);
> -		return xtab_read(_PATH_PROC_EXPORTS_ALT, 0);
> +		return xtab_read(_PATH_PROC_EXPORTS_ALT,
> +				 _PATH_PROC_EXPORTS_ALT, 0);
>  	} else
> -		return xtab_read(_PATH_XTAB, 2);
> +		return xtab_read(_PATH_XTAB, _PATH_XTABLCK, 2);
>  }
>  
>  int
>  xtab_export_read(void)
>  {
> -	return xtab_read(_PATH_ETAB, 1);
> +	return xtab_read(_PATH_ETAB, _PATH_ETABLCK, 1);
>  }
>  
>  /*
> @@ -87,13 +89,13 @@ xtab_export_read(void)
>   * fix the auth_reload logic as well...
>   */
>  static int
> -xtab_write(char *xtab, char *xtabtmp, int is_export)
> +xtab_write(char *xtab, char *xtabtmp, char *lockfn, int is_export)
>  {
>  	struct exportent	xe;
>  	nfs_export		*exp;
>  	int			lockid, i;
>  
> -	if ((lockid = xflock(xtab, "w")) < 0) {
> +	if ((lockid = xflock(lockfn, "w")) < 0) {
>  		xlog(L_ERROR, "can't lock %s for writing", xtab);
>  		return 0;
>  	}
> @@ -124,13 +126,13 @@ xtab_write(char *xtab, char *xtabtmp, int is_export)
>  int
>  xtab_export_write()
>  {
> -	return xtab_write(_PATH_ETAB, _PATH_ETABTMP, 1);
> +	return xtab_write(_PATH_ETAB, _PATH_ETABTMP, _PATH_ETABLCK, 1);
>  }
>  
>  int
>  xtab_mount_write()
>  {
> -	return xtab_write(_PATH_XTAB, _PATH_XTABTMP, 0);
> +	return xtab_write(_PATH_XTAB, _PATH_XTABTMP, _PATH_XTABLCK, 0);
>  }
>  
>  void
> @@ -139,7 +141,7 @@ xtab_append(nfs_export *exp)
>  	struct exportent xe;
>  	int		lockid;
>  
> -	if ((lockid = xflock(_PATH_XTAB, "w")) < 0)
> +	if ((lockid = xflock(_PATH_XTABLCK, "w")) < 0)
>  		return;
>  	setexportent(_PATH_XTAB, "a");
>  	xe = exp->m_export;
> diff --git a/support/include/nfslib.h b/support/include/nfslib.h
> index a51d79d..9d0d39d 100644
> --- a/support/include/nfslib.h
> +++ b/support/include/nfslib.h
> @@ -34,18 +34,27 @@
>  #ifndef _PATH_XTABTMP
>  #define _PATH_XTABTMP		NFS_STATEDIR "/xtab.tmp"
>  #endif
> +#ifndef _PATH_XTABLCK
> +#define _PATH_XTABLCK		NFS_STATEDIR "/.xtab.lock"
> +#endif
>  #ifndef _PATH_ETAB
>  #define _PATH_ETAB		NFS_STATEDIR "/etab"
>  #endif
>  #ifndef _PATH_ETABTMP
>  #define _PATH_ETABTMP		NFS_STATEDIR "/etab.tmp"
>  #endif
> +#ifndef _PATH_ETABLCK
> +#define _PATH_ETABLCK		NFS_STATEDIR "/.etab.lock"
> +#endif
>  #ifndef _PATH_RMTAB
>  #define _PATH_RMTAB		NFS_STATEDIR "/rmtab"
>  #endif
>  #ifndef _PATH_RMTABTMP
>  #define _PATH_RMTABTMP		_PATH_RMTAB ".tmp"
>  #endif
> +#ifndef _PATH_RMTABLCK
> +#define _PATH_RMTABLCK		NFS_STATEDIR "/.rmtab.lock"
> +#endif
>  #ifndef _PATH_PROC_EXPORTS
>  #define	_PATH_PROC_EXPORTS	"/proc/fs/nfs/exports"
>  #define	_PATH_PROC_EXPORTS_ALT	"/proc/fs/nfsd/exports"
> diff --git a/support/nfs/xio.c b/support/nfs/xio.c
> index f21f5f0..76fb9a1 100644
> --- a/support/nfs/xio.c
> +++ b/support/nfs/xio.c
> @@ -17,6 +17,7 @@
>  #include <ctype.h>
>  #include <signal.h>
>  #include <unistd.h>
> +#include <errno.h>
>  #include "xmalloc.h"
>  #include "xlog.h"
>  #include "xio.h"
> @@ -58,12 +59,17 @@ xflock(char *fname, char *type)
>  	struct flock	fl = { readonly? F_RDLCK : F_WRLCK, SEEK_SET, 0, 0, 0 };
>  	int		fd;
>  
> -	if (readonly)
> -		fd = open(fname, O_RDONLY);
> -	else
> -		fd = open(fname, (O_RDWR|O_CREAT), mode);
> +again:
> +	fd = open(fname, readonly ? O_RDONLY : (O_RDWR|O_CREAT), 0600);
> +	if (fd < 0 && readonly && errno == ENOENT) {
> +		/* create a new lockfile */
> +		fd = open(fname, O_RDONLY|O_CREAT, 0600);

I don't see how you expect to get EEXIST with a non-exclusive create.

Why do you need a second call to open() in the first place? How is this
better than just doing

	if (readonly)
		fd = open(fname, O_RDONLY|O_CREAT, 0600);
	else
		fd = open(fname, O_RDWR|O_CREAT, 0600);

...or, since these are now all private lockfiles, and so we shouldn't
need to care much about read-only vs read-write

	fd = open(fname, O_RDWR|O_CREAT, 0600);

> +		if (fd < 0 && errno == EEXIST) 
> +			goto again;	/* raced with another creator */
> +	}
>  	if (fd < 0) {
> -		xlog(L_WARNING, "could not open %s for locking", fname);
> +		xlog(L_WARNING, "could not open %s for locking: %s",
> +				fname, strerror(errno));
>  		return -1;
>  	}
>  
> @@ -74,7 +80,8 @@ xflock(char *fname, char *type)
>  	alarm(10);
>  	if (fcntl(fd, F_SETLKW, &fl) < 0) {
>  		alarm(0);
> -		xlog(L_WARNING, "failed to lock %s", fname);
> +		xlog(L_WARNING, "failed to lock %s: %s",
> +				fname, strerror(errno));
>  		close(fd);
>  		fd = 0;
>  	} else {
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 8084359..25d292b 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -88,6 +88,14 @@ unregister_services (void)
>  		pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
>  }
>  
> +static void
> +cleanup_lockfiles (void)
> +{
> +	unlink(_PATH_XTABLCK);
> +	unlink(_PATH_ETABLCK);
> +	unlink(_PATH_RMTABLCK);
> +}
> +
>  /* Wait for all worker child processes to exit and reap them */
>  static void
>  wait_for_workers (void)
> @@ -154,6 +162,7 @@ fork_workers(void)
>  	/* in parent */
>  	wait_for_workers();
>  	unregister_services();
> +	cleanup_lockfiles();
>  	xlog(L_NOTICE, "mountd: no more workers, exiting\n");
>  	exit(0);
>  }
> @@ -170,6 +179,7 @@ killer (int sig)
>  		kill(0, SIGTERM);
>  		wait_for_workers();
>  	}
> +	cleanup_lockfiles();
>  	xlog (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
>  }
>  
> diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
> index 5787ed6..c371f8d 100644
> --- a/utils/mountd/rmtab.c
> +++ b/utils/mountd/rmtab.c
> @@ -58,7 +58,7 @@ mountlist_add(char *host, const char *path)
>  	int		lockid;
>  	long		pos;
>  
> -	if ((lockid = xflock(_PATH_RMTAB, "a")) < 0)
> +	if ((lockid = xflock(_PATH_RMTABLCK, "a")) < 0)
>  		return;
>  	setrmtabent("r+");
>  	while ((rep = getrmtabent(1, &pos)) != NULL) {
> @@ -98,7 +98,7 @@ mountlist_del(char *hname, const char *path)
>  	int		lockid;
>  	int		match;
>  
> -	if ((lockid = xflock(_PATH_RMTAB, "w")) < 0)
> +	if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
>  		return;
>  	if (!setrmtabent("r")) {
>  		xfunlock(lockid);
> @@ -139,7 +139,7 @@ mountlist_del_all(struct sockaddr_in *sin)
>  	FILE		*fp;
>  	int		lockid;
>  
> -	if ((lockid = xflock(_PATH_RMTAB, "w")) < 0)
> +	if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
>  		return;
>  	if (!(hp = gethostbyaddr((char *)&addr, sizeof(addr), AF_INET))) {
>  		xlog(L_ERROR, "can't get hostname of %s", inet_ntoa(addr));
> @@ -188,7 +188,7 @@ mountlist_list(void)
>  	struct in_addr		addr;
>  	struct hostent		*he;
>  
> -	if ((lockid = xflock(_PATH_RMTAB, "r")) < 0)
> +	if ((lockid = xflock(_PATH_RMTABLCK, "r")) < 0)
>  		return NULL;
>  	if (stat(_PATH_RMTAB, &stb) < 0) {
>  		xlog(L_ERROR, "can't stat %s", _PATH_RMTAB);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

