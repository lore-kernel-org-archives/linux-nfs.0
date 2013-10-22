Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752289Ab3JVIhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 04:37:32 -0400
Message-ID: <52663973.8000005@RedHat.com>
Date: Tue, 22 Oct 2013 04:38:11 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Tony Asleson <tasleson@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com> <20131022092519.4f4683a8@notabene.brown>
In-Reply-To: <20131022092519.4f4683a8@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 18:25, NeilBrown wrote:
> From 2f63d6c3c38e673216a3351aff47d32059056638 Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Mon, 21 Oct 2013 17:40:55 +1100
> Subject: [PATCH] exportfs: exit with error code if there was any error.
> 
> exportfs currently exits with a non-zero error for some errors,
> but not for others.
> 
> It does this by having various support routines set the global
> variable "export_errno".
> 
> Change this to have 'xlog' set export_errno if an ERROR is
> reported.  That way all errors will be caught.
> 
> Note that the exit error code is changed from 22 (EINVAL)
> to the more traditional '1'.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.

> 
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 1fbf754..97b2327 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -179,7 +179,4 @@ struct export_features {
>  struct export_features *get_export_features(void);
>  void fix_pseudoflavor_flags(struct exportent *ep);
>  
> -/* Record export error.  */
> -extern int export_errno;
> -
>  #endif /* EXPORTFS_H */
> diff --git a/support/include/xlog.h b/support/include/xlog.h
> index fd1a3f4..fd34ec2 100644
> --- a/support/include/xlog.h
> +++ b/support/include/xlog.h
> @@ -35,6 +35,7 @@ struct xlog_debugfac {
>  	int		df_fac;
>  };
>  
> +extern int export_errno;
>  void			xlog_open(char *progname);
>  void			xlog_stderr(int on);
>  void			xlog_syslog(int on);
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index d3160d3..d18667f 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -47,8 +47,6 @@ struct flav_info flav_map[] = {
>  
>  const int flav_map_size = sizeof(flav_map)/sizeof(flav_map[0]);
>  
> -int export_errno;
> -
>  static char	*efname = NULL;
>  static XFILE	*efp = NULL;
>  static int	first;
> @@ -133,7 +131,6 @@ getexportent(int fromkernel, int fromexports)
>  	}
>  	if (ok < 0) {
>  		xlog(L_ERROR, "expected client(options...)");
> -		export_errno = EINVAL;
>  		return NULL;
>  	}
>  	first = 0;
> @@ -153,7 +150,6 @@ getexportent(int fromkernel, int fromexports)
>  		ok = getexport(exp, sizeof(exp));
>  		if (ok < 0) {
>  			xlog(L_ERROR, "expected client(options...)");
> -			export_errno = EINVAL;
>  			return NULL;
>  		}
>  	}
> @@ -173,7 +169,6 @@ getexportent(int fromkernel, int fromexports)
>  		*opt++ = '\0';
>  		if (!(sp = strchr(opt, ')')) || sp[1] != '\0') {
>  			syntaxerr("bad option list");
> -			export_errno = EINVAL;
>  			return NULL;
>  		}
>  		*sp = '\0';
> @@ -590,7 +585,6 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
>  				     flname, flline, opt);	
>  bad_option:
>  				free(opt);
> -				export_errno = EINVAL;
>  				return -1;
>  			}
>  		} else if (strncmp(opt, "anongid=", 8) == 0) {
> diff --git a/support/nfs/xlog.c b/support/nfs/xlog.c
> index 6820346..9f9e63e 100644
> --- a/support/nfs/xlog.c
> +++ b/support/nfs/xlog.c
> @@ -38,6 +38,8 @@ static int  logmask = 0;		/* What will be logged		*/
>  static char log_name[256];		/* name of this program		*/
>  static int  log_pid = -1;		/* PID of this program		*/
>  
> +int export_errno = 0;
> +
>  static void	xlog_toggle(int sig);
>  static struct xlog_debugfac	debugnames[] = {
>  	{ "general",	D_GENERAL, },
> @@ -189,6 +191,8 @@ void
>  xlog(int kind, const char* fmt, ...)
>  {
>  	va_list args;
> +	if (kind & (L_ERROR|D_GENERAL))
> +		export_errno = 1;
>  
>  	va_start(args, fmt);
>  	xlog_backend(kind, fmt, args);
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 4331697..c2cb2fc 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -103,8 +103,6 @@ main(int argc, char **argv)
>  	xlog_stderr(1);
>  	xlog_syslog(0);
>  
> -	export_errno = 0;
> -
>  	while ((c = getopt(argc, argv, "afhio:ruv")) != EOF) {
>  		switch(c) {
>  		case 'a':
