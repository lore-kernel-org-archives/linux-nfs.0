Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48657 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758463Ab3BNSm0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 13:42:26 -0500
Date: Thu, 14 Feb 2013 13:42:22 -0500
To: Ulrich Windl <Ulrich.Windl@rz.uni-regensburg.de>
Cc: linux-ha@lists.linux-ha.org, linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: Antw: Re: [Linux-HA] Problem with exportfs
Message-ID: <20130214184222.GA6732@fieldses.org>
References: <510B7BCE020000A10000ECB5@gwsmtp1.uni-regensburg.de>
 <20130201075338.GA29620@walrus.homenet>
 <511B9D24020000A10000F0FC@gwsmtp1.uni-regensburg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <511B9D24020000A10000F0FC@gwsmtp1.uni-regensburg.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 02:03:16PM +0100, Ulrich Windl wrote:
> Hi!
> 
> I've made a patch to let exportfs propagate the errors it reported to the exit code of the process (see attachments, the compressed tar is there in case the mailer corrupts the patche files):
> 
> The exportfs seems to have been written with a "hot needle", not having error processing in mind. So I have to change the prototypes of several routines. Also one routine returns 1 on success, and 0 of failure, which is against all C conventions. Anyway, I've tested my code a littel bit, and it looks promising:
> 
> # non-root calling exportfs
> ./exportfs; echo $?
> exportfs: could not open /var/lib/nfs/.etab.lock for locking: errno 13 (Permission denied)
> 1
> # Empty export list
> # ./exportfs; echo $?
> 0
> # ./exportfs no-such-host:/tmp; echo $?
> exportfs: Failed to resolve no-such-host
> 1
> # existing host and filesystem
> rksapv04:/tmp # ./exportfs localhost:/tmp; echo $?
> 0
> # non-existing filesystem or directory
> # ./exportfs localhost:/no-such-file; echo $?
> exportfs: Failed to stat /no-such-file: No such file or directory
> exportfs: localhost:/no-such-file: No such file or directory
> 1
> # both incorrect
> # ./exportfs no-host:/no-file; echo $?
> exportfs: Failed to resolve no-host
> exportfs: localhost:/no-such-file: No such file or directory
> 1
> # unfortunately the non-existing filesystem is still exported:
> # ./exportfs ; echo $?
> /tmp            localhost
> /no-such-file   localhost
> 0
> # At least it can be unexported
> # ./exportfs -u localhost:/no-such-file; echo $?
> 0
> 
> So the patch is not perfect, but probably a good staring point. Please send feedback!

Thanks, agreed that this is worth fixing.

I'm used to the kernel convention:

	int try_something(void)
	{
		return -ERRNO;
	}

	ret = try_something();
	if (ret)
		return ret;
	...

so this convention is a bit alien to me, but I suppose it's fine as long
as we aren't losing any error information that the callers could use.

Cc'ing steved as this is an nfs-utils patch.

--b.

> 
> Regards,
> Ulrich
> 
> >>> Ulrich Windl schrieb am 01.02.2013 um 09:47 in Nachricht <510B8119.CA2 : 161 :
> 60728>:
> > >>> Dejan Muhamedagic <dejanmm@fastmail.fm> schrieb am 01.02.2013 um 08:53 in
> > Nachricht <20130201075338.GA29620@walrus.homenet>:
> > > Hi,
> > > 
> > > On Fri, Feb 01, 2013 at 08:24:46AM +0100, Ulrich Windl wrote:
> > > > Hi!
> > > > 
> > > > While trying to develop an improved exportfs RA that can export one 
> > > filesystem to a list of names (instead of just one name), I found an error:
> > > > 
> > > > exportfs is returning exit code 0 even if the filesystem could not be 
> > > exported, like in
> > > > 
> > > > > h02:~ # exportfs h012:/mnt; echo $? # h012 does not exist
> > > > > exportfs: Failed to resolve h012 
> > > > > 0 
> > > > 
> > > > Accordingly the start operation for the exportfs alway reports success, 
> > > even if the operation failed! That's due to
> > > > 
> > > > [...]
> > > > >         ocf_run exportfs -v ${OPTIONS} 
> > > ${OCF_RESKEY_clientspec}:${OCF_RESKEY_directory} || exit $OCF_ERR_GENERIC  
> > >   
> > > > >     
> > > > >         # Restore the rmtab to ensure smooth NFS-over-TCP failover    
> > > > >         restore_rmtab    
> > > > >     
> > > > >         ocf_log info "File system exported"    
> > > > >         return $OCF_SUCCESS    
> > > > [...]
> > > > 
> > > > However the monitor operation does the correct thing, thus reporting an 
> > > error (rc==7).
> > > 
> > > We could insert the monitor operation after the call to exportfs.
> > > Would there be any timing issues? I guess not.
> > > 
> > > Thanks,
> > > 
> > > Dejan
> > 
> > Hi!
> > 
> > I'd fix the root of the problem: exportfs is unreliable!
> > 
> > Regards,
> > Ulrich
> > 
> > 
> > 
> > > 
> > > > This combination leads to the message of ocf-tester:
> > > > * rc=1: Monitoring an active resource should return 0      
> > > > 
> > > > (The tester thinks the resource was started when it was not)
> > > > 
> > > > I had reported this for SLES10 SP2 to support in November, but after a long 
> > > time of waiting and repeating the same facts over and over, support told me 
> > > it's "working as designed"; lvscan and lvcreate would be similar.
> > > > 
> > > > A quick test showed that this is actually not true vor lvcreate:
> > > > # lvcreate -n bar -L40G foobar; echo $?
> > > >   Volume group "foobar" not found
> > > > 5
> > > > # lvcreate -n foo -L1T sys; echo $?
> > > >   Volume group "sys" has insufficient free space (1855 extents): 32768 
> > > required.
> > > > 5
> > > > 
> > > > I got the impression that my support is just unwilling to fix the rather 
> > > trivial problem. My exportfs comes from nfs-kernel-server-1.2.3-18.23.1.
> > > > 
> > > > Getting the exportfs sources, it took me two minutes to find out that 
> > > exportfs uses variable export_errno to define the exit code, and that 
> > > variable is nowhere set. The worker routine exportfs() does return nothing 
> > at 
> > > all. What a design!
> > > > 
> > > > Here's an example from an old HP-UX system that didn't get any updates for 
> > > three years:
> > > > 
> > > > # exportfs nohost:/mnt; echo $?
> > > > exportfs: no entry for nohost:/mnt in /etc/dfs/dfstab
> > > > 1
> > > > 
> > > > Here it works!
> > > > 
> > > > I wonder why some Linux people are so ignorant occasionally...
> > > > 
> > > > Regards,
> > > > Ulrich
> > > > 
> > > > 
> > > > _______________________________________________
> > > > Linux-HA mailing list
> > > > Linux-HA@lists.linux-ha.org  
> > > > http://lists.linux-ha.org/mailman/listinfo/linux-ha  
> > > > See also: http://linux-ha.org/ReportingProblems  
> > > _______________________________________________
> > > Linux-HA mailing list
> > > Linux-HA@lists.linux-ha.org  
> > > http://lists.linux-ha.org/mailman/listinfo/linux-ha  
> > > See also: http://linux-ha.org/ReportingProblems  
> > > 
> > 
> >  
> >  
> > 
> 
> 
>  


> >From 11c4a0d45a06169f2de8bd220509f4569a5c37c2 Mon Sep 17 00:00:00 2001
> From: Ulrich Windl <Ulrich.Windl@RZ.Uni-Regensburg.DE>
> Date: Wed, 13 Feb 2013 11:45:33 +0100
> Subject: [PATCH 1/2] Include <stdio.h> for snprintf()
> 
> Include <stdio.h> to declare snprintf() in utils/nfsdcltrack/sqlite.c.
> ---
>  utils/nfsdcltrack/sqlite.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
> index bac6789..f825873 100644
> --- a/utils/nfsdcltrack/sqlite.c
> +++ b/utils/nfsdcltrack/sqlite.c
> @@ -38,6 +38,7 @@
>  #include "config.h"
>  #endif /* HAVE_CONFIG_H */
>  
> +#include <stdio.h>
>  #include <dirent.h>
>  #include <errno.h>
>  #include <event.h>
> -- 
> 1.7.12.4
> 

> >From eaaa966427e64b247f67a22df3ed87fe6dd61923 Mon Sep 17 00:00:00 2001
> From: Ulrich Windl <Ulrich.Windl@RZ.Uni-Regensburg.DE>
> Date: Wed, 13 Feb 2013 13:24:54 +0100
> Subject: [PATCH 2/2] Let exportfs exit with error on errors
> 
> support/export/xtab.c:
> xtab_read() and xtab_export_read() will return 0 on errors (strange logic,
> but according to existing code).
> 
> support/include/nfslib.h, support/nfs/cacheio.c:
> cache_flush() will return 0 on success.
> 
> utils/exportfs/exportfs.c:
> Changed export_all(), exportfs(), unexportfs(), exports_update(),
> validate_export(), grab_lockfile(), release_lockfile() to return 0 on
> success.  Added verbose_release_lockfile() to keep atexit() happy.
> Changed main() to return 1 on failure of any of: cache_flush(),
> xtab_export_read(), grab_lockfile(), export_all(), exportfs(),
> unexportfs(), exports_update(), xtab_export_write(), xtab_mount_write()
> Changed exports_update_one() to return 0 on success, watching
> export_export() and export_unexport() for errors.
> Changed exports_update() to return 0 on success, watching
> exports_update_one() for errors.
> Changed export_all() to return 0 on success watching validate_export() for
> errors.
> Changed exportfs() to return 0 on success, watching updateexportent() and
> validate_export() for errors.
> Changed validate_export() to return 0 on success, watching test_export()
> for errors.
> ---
>  support/export/xtab.c     |   4 +-
>  support/include/nfslib.h  |   2 +-
>  support/nfs/cacheio.c     |   5 +-
>  utils/exportfs/exportfs.c | 173 ++++++++++++++++++++++++++++++----------------
>  4 files changed, 120 insertions(+), 64 deletions(-)
> 
> diff --git a/support/export/xtab.c b/support/export/xtab.c
> index 2a43193..a87d453 100644
> --- a/support/export/xtab.c
> +++ b/support/export/xtab.c
> @@ -24,6 +24,7 @@
>  int v4root_needed;
>  static void cond_rename(char *newfile, char *oldfile);
>  
> +/* return 0 on failure! */
>  static int
>  xtab_read(char *xtab, char *lockfn, int is_export)
>  {
> @@ -63,7 +64,7 @@ xtab_read(char *xtab, char *lockfn, int is_export)
>  	endexportent();
>  	xfunlock(lockid);
>  
> -	return 0;
> +	return 1;
>  }
>  
>  int
> @@ -93,6 +94,7 @@ xtab_export_read(void)
>   * inode number changes when the xtab_export_write is done. If you change the
>   * routine below such that the files are edited in place, then you'll need to
>   * fix the auth_reload logic as well...
> + * Return 0 on failure!
>   */
>  static int
>  xtab_write(char *xtab, char *xtabtmp, char *lockfn, int is_export)
> diff --git a/support/include/nfslib.h b/support/include/nfslib.h
> index f210a06..ee45f56 100644
> --- a/support/include/nfslib.h
> +++ b/support/include/nfslib.h
> @@ -155,7 +155,7 @@ int qword_eol(FILE *f);
>  int readline(int fd, char **buf, int *lenp);
>  int qword_get(char **bpp, char *dest, int bufsize);
>  int qword_get_int(char **bpp, int *anint);
> -void cache_flush(int force);
> +int cache_flush(int force);
>  int check_new_cache(void);
>  void qword_add(char **bpp, int *lp, char *str);
>  void qword_addhex(char **bpp, int *lp, char *buf, int blen);
> diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
> index e641c45..7ffca97 100644
> --- a/support/nfs/cacheio.c
> +++ b/support/nfs/cacheio.c
> @@ -321,7 +321,7 @@ check_new_cache(void)
>   *  auth.unix.ip nfsd.export nfsd.fh
>   */
>  
> -void
> +int
>  cache_flush(int force)
>  {
>  	struct stat stb;
> @@ -329,6 +329,7 @@ cache_flush(int force)
>  	char stime[20];
>  	char path[200];
>  	time_t now;
> +	int result = 0;
>  	/* Note: the order of these caches is important.
>  	 * They need to be flushed in dependancy order. So
>  	 * a cache that references items in another cache,
> @@ -357,8 +358,10 @@ cache_flush(int force)
>  			if (write(fd, stime, strlen(stime)) != (ssize_t)strlen(stime)) {
>  				xlog_warn("Writing to '%s' failed: errno %d (%s)",
>  				path, errno, strerror(errno));
> +				result = 1;
>  			}
>  			close(fd);
>  		}
>  	}
> +	return result;
>  }
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 9f79541..27ac8c3 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -34,18 +34,19 @@
>  #include "exportfs.h"
>  #include "xlog.h"
>  
> -static void	export_all(int verbose);
> -static void	exportfs(char *arg, char *options, int verbose);
> -static void	unexportfs(char *arg, int verbose);
> -static void	exports_update(int verbose);
> +static int	export_all(int verbose);
> +static int	exportfs(char *arg, char *options, int verbose);
> +static int	unexportfs(char *arg, int verbose);
> +static int	exports_update(int verbose);
>  static void	dump(int verbose);
>  static void	error(nfs_export *exp, int err);
>  static void	usage(const char *progname, int n);
> -static void	validate_export(nfs_export *exp);
> +static int	validate_export(nfs_export *exp);
>  static int	matchhostname(const char *hostname1, const char *hostname2);
>  static void	export_d_read(const char *dname);
> -static void grab_lockfile(void);
> -static void release_lockfile(void);
> +static int	grab_lockfile(void);
> +static int	release_lockfile(void);
> +static void	verbose_release_lockfile(void);
>  
>  static const char *lockfile = EXP_LOCKFILE;
>  static int _lockfd = -1;
> @@ -66,18 +67,28 @@ static int _lockfd = -1;
>   * corrupting etab, but to prevent problems like the above we
>   * need these additional lockfile() routines.
>   */
> -static void 
> +static int
>  grab_lockfile()
>  {
>  	_lockfd = open(lockfile, O_CREAT|O_RDWR, 0666);
> -	if (_lockfd != -1) 
> -		lockf(_lockfd, F_LOCK, 0);
> +	if (_lockfd != -1 && lockf(_lockfd, F_LOCK, 0) == 0)
> +		return 0;
> +	return 1;
>  }
> -static void 
> +
> +static int
>  release_lockfile()
>  {
> -	if (_lockfd != -1)
> -		lockf(_lockfd, F_ULOCK, 0);
> +	if (_lockfd != -1 && lockf(_lockfd, F_ULOCK, 0) == 0)
> +		return 0;
> +	return 1;
> +}
> +
> +static void
> +verbose_release_lockfile()
> +{
> +	if (release_lockfile())
> +		xlog(L_ERROR, "problem releasing lockfile %s: %m", lockfile);
>  }
>  
>  int
> @@ -153,38 +164,44 @@ main(int argc, char **argv)
>  	new_cache = check_new_cache();
>  	if (optind == argc && ! f_all) {
>  		if (force_flush) {
> -			if (new_cache)
> -				cache_flush(1);
> -			else {
> +			if (new_cache) {
> +				if (cache_flush(1))
> +					export_errno = 1;
> +			} else {
>  				xlog(L_ERROR, "-f is available only "
>  					"with new cache controls. "
>  					"Mount /proc/fs/nfsd first");
>  				return 1;
>  			}
> -			return 0;
> +			return export_errno;
>  		} else {
> -			xtab_export_read();
> +			if (xtab_export_read() == 0)
> +				export_errno = 1;
>  			dump(f_verbose);
> -			return 0;
> +			return export_errno;
>  		}
>  	}
>  
>  	/*
>  	 * Serialize things as best we can
>  	 */
> -	grab_lockfile();
> -	atexit(release_lockfile);
> +	if (grab_lockfile())
> +		export_errno = 1;
> +	atexit(verbose_release_lockfile);
>  
>  	if (f_export && ! f_ignore) {
>  		export_read(_PATH_EXPORTS);
>  		export_d_read(_PATH_EXPORTS_D);
>  	}
>  	if (f_export) {
> -		if (f_all)
> -			export_all(f_verbose);
> -		else
> -			for (i = optind; i < argc ; i++)
> -				exportfs(argv[i], options, f_verbose);
> +		if (f_all) {
> +			if (export_all(f_verbose))
> +				export_errno = 1;
> +		} else
> +			for (i = optind; i < argc ; i++) {
> +				if (exportfs(argv[i], options, f_verbose))
> +					export_errno = 1;
> +			}
>  	}
>  	/* If we are unexporting everything, then
>  	 * don't care about what should be exported, as that
> @@ -194,30 +211,41 @@ main(int argc, char **argv)
>  		/* note: xtab_*_read does not update entries if they already exist,
>  		 * so this will not lose new options
>  		 */
> -		if (!f_reexport)
> -			xtab_export_read();
> +		if (!f_reexport) {
> +			if (xtab_export_read() == 0)
> +				export_errno = 1;
> +		}
>  		if (!f_export)
> -			for (i = optind ; i < argc ; i++)
> -				unexportfs(argv[i], f_verbose);
> +			for (i = optind ; i < argc ; i++) {
> +				if (unexportfs(argv[i], f_verbose))
> +					export_errno = 1;
> +			}
>  		if (!new_cache)
>  			rmtab_read();
>  	}
>  	if (!new_cache) {
>  		xtab_mount_read();
> -		exports_update(f_verbose);
> +		if (exports_update(f_verbose))
> +			export_errno = 1;
> +	}
> +	if (!xtab_export_write())
> +		export_errno = 1;
> +	if (new_cache) {
> +		if (cache_flush(force_flush))
> +			export_errno = 1;
>  	}
> -	xtab_export_write();
> -	if (new_cache)
> -		cache_flush(force_flush);
>  	if (!new_cache)
> -		xtab_mount_write();
> +		if (!xtab_mount_write())
> +			export_errno = 1;
>  
>  	return export_errno;
>  }
>  
> -static void
> +static int
>  exports_update_one(nfs_export *exp, int verbose)
>  {
> +	int	result = 0;
> +
>  		/* check mountpoint option */
>  	if (exp->m_mayexport &&
>  	    exp->m_export.e_mountpoint &&
> @@ -227,6 +255,7 @@ exports_update_one(nfs_export *exp, int verbose)
>  		printf("%s not exported as %s not a mountpoint.\n",
>  		       exp->m_export.e_path, exp->m_export.e_mountpoint);
>  		exp->m_mayexport = 0;
> +		result = 1;
>  	}
>  	if (exp->m_mayexport && ((exp->m_exported<1) || exp->m_changed)) {
>  		if (verbose)
> @@ -234,17 +263,22 @@ exports_update_one(nfs_export *exp, int verbose)
>  			       exp->m_exported ?"re":"",
>  			       exp->m_client->m_hostname,
>  			       exp->m_export.e_path);
> -		if (!export_export(exp))
> +		if (!export_export(exp)) {
>  			error(exp, errno);
> +			result = 1;
> +		}
>  	}
>  	if (exp->m_exported && ! exp->m_mayexport) {
>  		if (verbose)
>  			printf("unexporting %s:%s from kernel\n",
>  			       exp->m_client->m_hostname,
>  			       exp->m_export.e_path);
> -		if (!export_unexport(exp))
> +		if (!export_unexport(exp)) {
>  			error(exp, errno);
> +			result = 1;
> +		}
>  	}
> +	return result;
>  }
>  
>  
> @@ -253,28 +287,33 @@ exports_update_one(nfs_export *exp, int verbose)
>   * entries with m_exported but not m_mayexport get unexported
>   * looking at m_client->m_type == MCL_FQDN and m_client->m_type == MCL_GSS only
>   */
> -static void
> +static int
>  exports_update(int verbose)
>  {
>  	nfs_export 	*exp;
> +	int		result = 0;
>  
>  	for (exp = exportlist[MCL_FQDN].p_head; exp; exp=exp->m_next) {
> -		exports_update_one(exp, verbose);
> +		if (exports_update_one(exp, verbose))
> +			result = 1;
>  	}
>  	for (exp = exportlist[MCL_GSS].p_head; exp; exp=exp->m_next) {
> -		exports_update_one(exp, verbose);
> +		if (exports_update_one(exp, verbose))
> +			result = 1;
>  	}
> +	return result;
>  }
>  			
>  /*
> - * export_all finds all entries and
> - *    marks them xtabent and mayexport so that they get exported
> + * export_all finds all entries and marks them xtabent and mayexport so that
> + * they get exported. Return 0 if thewre were no errors.
>   */
> -static void
> +static int
>  export_all(int verbose)
>  {
>  	nfs_export	*exp;
>  	int		i;
> +	int		result = 0;
>  
>  	for (i = 0; i < MCL_MAXTYPES; i++) {
>  		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
> @@ -286,13 +325,15 @@ export_all(int verbose)
>  			exp->m_mayexport = 1;
>  			exp->m_changed = 1;
>  			exp->m_warned = 0;
> -			validate_export(exp);
> +			if (validate_export(exp))
> +				result = 1;
>  		}
>  	}
> +	return result;
>  }
>  
> -
> -static void
> +/* return 0 on success */
> +static int
>  exportfs(char *arg, char *options, int verbose)
>  {
>  	struct exportent *eep;
> @@ -301,13 +342,14 @@ exportfs(char *arg, char *options, int verbose)
>  	char		*path;
>  	char		*hname = arg;
>  	int		htype;
> +	int		result = 0;
>  
>  	if ((path = strchr(arg, ':')) != NULL)
>  		*path++ = '\0';
>  
>  	if (!path || *path != '/') {
>  		xlog(L_ERROR, "Invalid exporting option: %s", arg);
> -		return;
> +		return 1;
>  	}
>  
>  	if ((htype = client_gettype(hname)) == MCL_FQDN) {
> @@ -321,10 +363,14 @@ exportfs(char *arg, char *options, int verbose)
>  
>  	if (!exp) {
>  		if (!(eep = mkexportent(hname, path, options)) ||
> -		    !(exp = export_create(eep, 0)))
> +		    !(exp = export_create(eep, 0))) {
> +			result = 1;
>  			goto out;
> -	} else if (!updateexportent(&exp->m_export, options))
> +		}
> +	} else if (!updateexportent(&exp->m_export, options)) {
> +		result = 1;
>  		goto out;
> +	}
>  
>  	if (verbose)
>  		printf("exporting %s:%s\n", exp->m_client->m_hostname, 
> @@ -333,13 +379,15 @@ exportfs(char *arg, char *options, int verbose)
>  	exp->m_mayexport = 1;
>  	exp->m_changed = 1;
>  	exp->m_warned = 0;
> -	validate_export(exp);
> +	result = validate_export(exp);
>  
>  out:
>  	freeaddrinfo(ai);
> +	return result;
>  }
>  
> -static void
> +/* return 0 on success */
> +static int
>  unexportfs(char *arg, int verbose)
>  {
>  	nfs_export	*exp;
> @@ -347,13 +395,14 @@ unexportfs(char *arg, int verbose)
>  	char		*path;
>  	char		*hname = arg;
>  	int		htype;
> +	int		result = 0;
>  
>  	if ((path = strchr(arg, ':')) != NULL)
>  		*path++ = '\0';
>  
>  	if (!path || *path != '/') {
>  		xlog(L_ERROR, "Invalid unexporting option: %s", arg);
> -		return;
> +		return 1;
>  	}
>  
>  	if ((htype = client_gettype(hname)) == MCL_FQDN) {
> @@ -396,6 +445,7 @@ unexportfs(char *arg, int verbose)
>  	}
>  
>  	freeaddrinfo(ai);
> +	return result;
>  }
>  
>  static int can_test(void)
> @@ -433,10 +483,11 @@ static int test_export(char *path, int with_fsid)
>  	return 1;
>  }
>  
> -static void
> +static int
>  validate_export(nfs_export *exp)
>  {
> -	/* Check that the given export point is potentially exportable.
> +	/* Check that the given export point is potentially exportable,
> +	 * returning 0 on success.
>  	 * We just give warnings here, don't cause anything to fail.
>  	 * If a path doesn't exist, or is not a dir or file, give an warning
>  	 * otherwise trial-export to '-test-client-' and check for failure.
> @@ -448,15 +499,15 @@ validate_export(nfs_export *exp)
>  
>  	if (stat(path, &stb) < 0) {
>  		xlog(L_ERROR, "Failed to stat %s: %m", path);
> -		return;
> +		return 1;
>  	}
>  	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
>  		xlog(L_ERROR, "%s is neither a directory nor a file. "
>  			"Remote access will fail", path);
> -		return;
> +		return 1;
>  	}
>  	if (!can_test())
> -		return;
> +		return 1;
>  
>  	if (!statfs64(path, &stf) &&
>  	    (stf.f_fsid.__val[0] || stf.f_fsid.__val[1]))
> @@ -466,16 +517,16 @@ validate_export(nfs_export *exp)
>  	    fs_has_fsid) {
>  		if ( !test_export(path, 1)) {
>  			xlog(L_ERROR, "%s does not support NFS export", path);
> -			return;
> +			return 1;
>  		}
>  	} else if ( ! test_export(path, 0)) {
>  		if (test_export(path, 1))
>  			xlog(L_ERROR, "%s requires fsid= for NFS export", path);
>  		else
>  			xlog(L_ERROR, "%s does not support NFS export", path);
> -		return;
> -
> +		return 1;
>  	}
> +	return 0;
>  }
>  
>  static _Bool
> -- 
> 1.7.12.4
> 

