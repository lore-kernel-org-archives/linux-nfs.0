Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932797AbcKOVtf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 16:49:35 -0500
Subject: Re: [PATCH nfs-utils] Remove all use of /var/lib/nfs/xtab
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>
References: <87eg2kma65.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <63756e70-e862-ba83-95e8-6338f16b1870@RedHat.com>
Date: Tue, 15 Nov 2016 16:49:34 -0500
MIME-Version: 1.0
In-Reply-To: <87eg2kma65.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/09/2016 07:49 PM, NeilBrown wrote:
> /var/lib/nfs/xtab is only used to find out what has been exported to
> the kernel.  This is more reliably done by reading
> /proc/fs/nfs{,d}/export and nfs-utils uses that file if is available.
> So xtab is only need if you have an incredibly ancient kernel which
> doesn't have /proc/fs/nfs/export (and so which only supports NFSv2) or if
> /proc is not mounted.
>
> Neither of these are credible contexts to run a modern nfs-utils,
> so stop creating or reading the xtab file.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  Makefile.am                |  3 +--
>  support/export/xtab.c      | 31 ++-----------------------------
>  support/include/exportfs.h |  4 +---
>  support/include/nfslib.h   |  9 ---------
>  utils/exportfs/exportfs.c  |  4 +---
>  utils/mountd/auth.c        |  1 -
>  utils/mountd/mountd.c      | 11 ++---------
>  7 files changed, 7 insertions(+), 56 deletions(-)
Committed....

steved.
>
> diff --git a/Makefile.am b/Makefile.am
> index 4a2edc682de8..e1f39aab5f62 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -23,7 +23,6 @@ ACLOCAL_AMFLAGS = -I aclocal
>  
>  install-data-hook:
>  	if [ ! -d $(DESTDIR)$(statedir) ]; then mkdir -p $(DESTDIR)$(statedir); fi
> -	touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
>  	touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
>  	touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
>  	mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
> @@ -32,7 +31,7 @@ install-data-hook:
>  	-chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statdpath)/state
>  
>  uninstall-hook:
> -	rm $(DESTDIR)$(statedir)/xtab
> +	rm -f $(DESTDIR)$(statedir)/xtab
>  	rm $(DESTDIR)$(statedir)/etab
>  	rm $(DESTDIR)$(statedir)/rmtab
>  	rm $(DESTDIR)$(statdpath)/state
> diff --git a/support/export/xtab.c b/support/export/xtab.c
> index e953071ea901..10d9dbc5db15 100644
> --- a/support/export/xtab.c
> +++ b/support/export/xtab.c
> @@ -1,7 +1,7 @@
>  /*
>   * support/export/xtab.c
>   *
> - * Interface to the xtab file.
> + * Interface to the etab/exports file.
>   *
>   * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
>   */
> @@ -29,7 +29,6 @@ xtab_read(char *xtab, char *lockfn, int is_export)
>  {
>      /* is_export == 0  => reading /proc/fs/nfs/exports - we know these things are exported to kernel
>       * is_export == 1  => reading /var/lib/nfs/etab - these things are allowed to be exported
> -     * is_export == 2  => reading /var/lib/nfs/xtab - these things might be known to kernel
>       */
>  	struct exportent	*xp;
>  	nfs_export		*exp;
> @@ -55,9 +54,6 @@ xtab_read(char *xtab, char *lockfn, int is_export)
>  			if ((xp->e_flags & NFSEXP_FSID) && xp->e_fsid == 0)
>  				v4root_needed = 0;
>  			break;
> -		case 2:
> -			exp->m_exported = -1;/* may be exported */
> -			break;
>  		}
>  	}
>  	endexportent();
> @@ -79,7 +75,7 @@ xtab_mount_read(void)
>  		return xtab_read(_PATH_PROC_EXPORTS_ALT,
>  				 _PATH_PROC_EXPORTS_ALT, 0);
>  	} else
> -		return xtab_read(_PATH_XTAB, _PATH_XTABLCK, 2);
> +		return 0;
>  }
>  
>  int
> @@ -135,29 +131,6 @@ xtab_export_write()
>  	return xtab_write(_PATH_ETAB, _PATH_ETABTMP, _PATH_ETABLCK, 1);
>  }
>  
> -int
> -xtab_mount_write()
> -{
> -	return xtab_write(_PATH_XTAB, _PATH_XTABTMP, _PATH_XTABLCK, 0);
> -}
> -
> -void
> -xtab_append(nfs_export *exp)
> -{
> -	struct exportent xe;
> -	int		lockid;
> -
> -	if ((lockid = xflock(_PATH_XTABLCK, "w")) < 0)
> -		return;
> -	setexportent(_PATH_XTAB, "a");
> -	xe = exp->m_export;
> -	xe.e_hostname = exp->m_client->m_hostname;
> -	putexportent(&xe);
> -	endexportent();
> -	xfunlock(lockid);
> -	exp->m_xtabent = 1;
> -}
> -
>  /*
>   * rename newfile onto oldfile unless
>   * they are identical
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 32d4fe95fd7e..08ef30a2f580 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -96,7 +96,7 @@ typedef struct mexport {
>  	struct mexport *	m_next;
>  	struct mclient *	m_client;
>  	struct exportent	m_export;
> -	int			m_exported;	/* known to knfsd. -1 means not sure */
> +	int			m_exported;	/* known to knfsd. */
>  	int			m_xtabent  : 1,	/* xtab entry exists */
>  				m_mayexport: 1,	/* derived from xtabbed */
>  				m_changed  : 1, /* options (may) have changed */
> @@ -150,9 +150,7 @@ int				export_unexport(nfs_export *);
>  
>  int				xtab_mount_read(void);
>  int				xtab_export_read(void);
> -int				xtab_mount_write(void);
>  int				xtab_export_write(void);
> -void				xtab_append(nfs_export *);
>  
>  int				secinfo_addflavor(struct flav_info *, struct exportent *);
>  
> diff --git a/support/include/nfslib.h b/support/include/nfslib.h
> index ddd71ac94aa5..777f398c1486 100644
> --- a/support/include/nfslib.h
> +++ b/support/include/nfslib.h
> @@ -35,15 +35,6 @@
>  #ifndef _PATH_IDMAPDCONF
>  #define _PATH_IDMAPDCONF	"/etc/idmapd.conf"
>  #endif
> -#ifndef _PATH_XTAB
> -#define _PATH_XTAB		NFS_STATEDIR "/xtab"
> -#endif
> -#ifndef _PATH_XTABTMP
> -#define _PATH_XTABTMP		NFS_STATEDIR "/xtab.tmp"
> -#endif
> -#ifndef _PATH_XTABLCK
> -#define _PATH_XTABLCK		NFS_STATEDIR "/.xtab.lock"
> -#endif
>  #ifndef _PATH_ETAB
>  #define _PATH_ETAB		NFS_STATEDIR "/etab"
>  #endif
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 5136810029d0..98368a5ef1e1 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -219,8 +219,6 @@ main(int argc, char **argv)
>  	xtab_export_write();
>  	if (new_cache)
>  		cache_flush(force_flush);
> -	if (!new_cache)
> -		xtab_mount_write();
>  
>  	return export_errno;
>  }
> @@ -238,7 +236,7 @@ exports_update_one(nfs_export *exp, int verbose)
>  		       exp->m_export.e_path, exp->m_export.e_mountpoint);
>  		exp->m_mayexport = 0;
>  	}
> -	if (exp->m_mayexport && ((exp->m_exported<1) || exp->m_changed)) {
> +	if (exp->m_mayexport && exp->m_changed) {
>  		if (verbose)
>  			printf("%sexporting %s:%s to kernel\n",
>  			       exp->m_exported ?"re":"",
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index 0881d9a6edba..b612d88b6143 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -46,7 +46,6 @@ void
>  auth_init(void)
>  {
>  	auth_reload();
> -	xtab_mount_write();
>  }
>  
>  /*
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 7a51b093f66a..981abd456d91 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -107,7 +107,6 @@ unregister_services (void)
>  static void
>  cleanup_lockfiles (void)
>  {
> -	unlink(_PATH_XTABLCK);
>  	unlink(_PATH_ETABLCK);
>  	unlink(_PATH_RMTABLCK);
>  }
> @@ -289,7 +288,7 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp),
>  	xlog(D_CALL, "Received UMNTALL request from %s",
>  		host_ntop(sap, buf, sizeof(buf)));
>  
> -	/* Reload /etc/xtab if necessary */
> +	/* Reload /etc/exports if necessary */
>  	auth_reload();
>  
>  	mountlist_del_all(nfs_getrpccaller(rqstp->rq_xprt));
> @@ -350,7 +349,7 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
>  	if (*p == '\0')
>  		p = "/";
>  
> -	/* Reload /etc/xtab if necessary */
> +	/* Reload /etc/exports if necessary */
>  	auth_reload();
>  
>  	/* Resolve symlinks */
> @@ -531,12 +530,6 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
>  	} else {
>  		int did_export = 0;
>  	retry:
> -		if (exp->m_exported<1) {
> -			export_export(exp);
> -			did_export = 1;
> -		}
> -		if (!exp->m_xtabent)
> -			xtab_append(exp);
>  
>  		if (v3)
>  			fh = getfh_size((struct sockaddr_in *)sap, p, 64);

