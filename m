Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbaLCWQN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2014 17:16:13 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB3MGDxk012260
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Dec 2014 17:16:13 -0500
Message-ID: <547F8BAC.7060705@RedHat.com>
Date: Wed, 03 Dec 2014 17:16:12 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Pavel Raiskup <praiskup@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: warn when really nothing is exported
References: <1416589975-11372-1-git-send-email-praiskup@redhat.com>
In-Reply-To: <1416589975-11372-1-git-send-email-praiskup@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/21/2014 12:12 PM, Pavel Raiskup wrote:
> Throw 'No file systems exported!' iff no volume is exported rather
> then if some exports file is empty.  Typically this can happen if
> the default /etc/exports file is empty and admin installed
> configuration into /etc/exports.d directory.
> 
> This is follow-up for e725def62c73b4 commit.
> 
> Signed-off-by: Pavel Raiskup <praiskup@redhat.com>
Committed... 

steved.

> ---
>  support/export/export.c    | 20 +++++++-------------
>  support/include/exportfs.h |  2 +-
>  utils/exportfs/exportfs.c  | 22 +++++++++++++---------
>  3 files changed, 21 insertions(+), 23 deletions(-)
> 
> diff --git a/support/export/export.c b/support/export/export.c
> index 30a5b4a..e1bebce 100644
> --- a/support/export/export.c
> +++ b/support/export/export.c
> @@ -69,36 +69,30 @@ static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
>   * export_read - read entries from /etc/exports
>   * @fname: name of file to read from
>   *
> + * Returns number of read entries.
>   */
> -void
> -export_read(char *fname, int verbose)
> +int
> +export_read(char *fname)
>  {
>  	struct exportent	*eep;
>  	nfs_export		*exp;
>  
>  	int volumes = 0;
> -	int bad_entry = 0;
>  
>  	setexportent(fname, "r");
>  	while ((eep = getexportent(0,1)) != NULL) {
>  		exp = export_lookup(eep->e_hostname, eep->e_path, 0);
>  		if (!exp) {
> -			exp = export_create(eep, 0);
> -			if (exp)
> +			if (export_create(eep, 0))
> +				/* possible complaints already logged */
>  				volumes++;
> -			else 
> -				bad_entry++;
>  		}
>  		else
>  			warn_duplicated_exports(exp, eep);
>  	}
>  	endexportent();
> -	if (volumes == 0) {
> -		if (bad_entry > 0)
> -			xlog(L_ERROR, "No file systems exported!");
> -		else if (verbose)
> -			xlog(L_WARNING, "No file systems exported!");
> -	}
> +
> +	return volumes;
>  }
>  
>  /**
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 3d89f12..3b92f04 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -133,7 +133,7 @@ struct addrinfo *		client_resolve(const struct sockaddr *sap);
>  int 				client_member(const char *client,
>  						const char *name);
>  
> -void				export_read(char *fname, int verbose);
> +int				export_read(char *fname);
>  void				export_reset(nfs_export *);
>  nfs_export *			export_lookup(char *hname, char *path, int caconical);
>  nfs_export *			export_find(const struct addrinfo *ai,
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 92fb9eb..48eac00 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -47,7 +47,7 @@ static void	error(nfs_export *exp, int err);
>  static void	usage(const char *progname, int n);
>  static void	validate_export(nfs_export *exp);
>  static int	matchhostname(const char *hostname1, const char *hostname2);
> -static void	export_d_read(const char *dname, int verbose);
> +static int	export_d_read(const char *dname);
>  static void grab_lockfile(void);
>  static void release_lockfile(void);
>  
> @@ -182,8 +182,11 @@ main(int argc, char **argv)
>  	atexit(release_lockfile);
>  
>  	if (f_export && ! f_ignore) {
> -		export_read(_PATH_EXPORTS, f_verbose);
> -		export_d_read(_PATH_EXPORTS_D, f_verbose);
> +		if (! (export_read(_PATH_EXPORTS) +
> +		       export_d_read(_PATH_EXPORTS_D))) {
> +			if (f_verbose)
> +				xlog(L_WARNING, "No file systems exported!");
> +		}
>  	}
>  	if (f_export) {
>  		if (f_all)
> @@ -685,21 +688,22 @@ out:
>  
>  /* Based on mnt_table_parse_dir() in
>     util-linux-ng/shlibs/mount/src/tab_parse.c */
> -static void
> -export_d_read(const char *dname, int verbose)
> +static int
> +export_d_read(const char *dname)
>  {
>  	int n = 0, i;
>  	struct dirent **namelist = NULL;
> +	int volumes = 0;
>  
>  
>  	n = scandir(dname, &namelist, NULL, versionsort);
>  	if (n < 0) {
>  		if (errno == ENOENT)
>  			/* Silently return */
> -			return;
> +			return volumes;
>  		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
>  	} else if (n == 0)
> -		return;
> +		return volumes;
>  
>  	for (i = 0; i < n; i++) {
>  		struct dirent *d = namelist[i];
> @@ -729,14 +733,14 @@ export_d_read(const char *dname, int verbose)
>  			continue;
>  		}
>  
> -		export_read(fname, verbose);
> +		volumes += export_read(fname);
>  	}
>  
>  	for (i = 0; i < n; i++)
>  		free(namelist[i]);
>  	free(namelist);
>  
> -	return;
> +	return volumes;
>  }
>  
>  static char
> 
