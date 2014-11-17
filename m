Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192AbaKQScx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 13:32:53 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAHIWqDm002073
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 13:32:53 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-51-108.rdu2.redhat.com [10.10.51.108])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAHIWqHg009968
	for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 13:32:52 -0500
Message-ID: <546A3F54.8020300@RedHat.com>
Date: Mon, 17 Nov 2014 13:32:52 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] exportfs: Do not fail on empty exports file.
References: <1416231994-5177-1-git-send-email-steved@redhat.com>
In-Reply-To: <1416231994-5177-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/17/2014 08:46 AM, Steve Dickson wrote:
> Commit 076dd80 introduced a regression that causes
> exportfs to fail when there is an empty /etc/exports
> file. A empty /etc/exports file is valid and should
> not cause exportfs to fail.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
A slightly modified version was committed... 

steved.
> ---
>  support/export/export.c    |  6 +++---
>  support/include/exportfs.h |  2 +-
>  utils/exportfs/exportfs.c  | 10 +++++-----
>  3 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/support/export/export.c b/support/export/export.c
> index ce714d4..376ca6d 100644
> --- a/support/export/export.c
> +++ b/support/export/export.c
> @@ -71,7 +71,7 @@ static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
>   *
>   */
>  void
> -export_read(char *fname)
> +export_read(char *fname, int verbose)
>  {
>  	struct exportent	*eep;
>  	nfs_export		*exp;
> @@ -90,8 +90,8 @@ export_read(char *fname)
>  			warn_duplicated_exports(exp, eep);
>  	}
>  	endexportent();
> -	if (volumes == 0)
> -		xlog(L_ERROR, "No file systems exported!");
> +	if (volumes == 0 && verbose)
> +		xlog(L_WARNING, "No file systems exported!");
>  }
>  
>  /**
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 9021fae..3d89f12 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -133,7 +133,7 @@ struct addrinfo *		client_resolve(const struct sockaddr *sap);
>  int 				client_member(const char *client,
>  						const char *name);
>  
> -void				export_read(char *fname);
> +void				export_read(char *fname, int verbose);
>  void				export_reset(nfs_export *);
>  nfs_export *			export_lookup(char *hname, char *path, int caconical);
>  nfs_export *			export_find(const struct addrinfo *ai,
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index bdea12b..92fb9eb 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -47,7 +47,7 @@ static void	error(nfs_export *exp, int err);
>  static void	usage(const char *progname, int n);
>  static void	validate_export(nfs_export *exp);
>  static int	matchhostname(const char *hostname1, const char *hostname2);
> -static void	export_d_read(const char *dname);
> +static void	export_d_read(const char *dname, int verbose);
>  static void grab_lockfile(void);
>  static void release_lockfile(void);
>  
> @@ -182,8 +182,8 @@ main(int argc, char **argv)
>  	atexit(release_lockfile);
>  
>  	if (f_export && ! f_ignore) {
> -		export_read(_PATH_EXPORTS);
> -		export_d_read(_PATH_EXPORTS_D);
> +		export_read(_PATH_EXPORTS, f_verbose);
> +		export_d_read(_PATH_EXPORTS_D, f_verbose);
>  	}
>  	if (f_export) {
>  		if (f_all)
> @@ -686,7 +686,7 @@ out:
>  /* Based on mnt_table_parse_dir() in
>     util-linux-ng/shlibs/mount/src/tab_parse.c */
>  static void
> -export_d_read(const char *dname)
> +export_d_read(const char *dname, int verbose)
>  {
>  	int n = 0, i;
>  	struct dirent **namelist = NULL;
> @@ -729,7 +729,7 @@ export_d_read(const char *dname)
>  			continue;
>  		}
>  
> -		export_read(fname);
> +		export_read(fname, verbose);
>  	}
>  
>  	for (i = 0; i < n; i++)
> 
