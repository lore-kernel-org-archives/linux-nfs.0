Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386Ab1CEWqM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Mar 2011 17:46:12 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p25MkCux022782
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 5 Mar 2011 17:46:12 -0500
Message-ID: <4D72BD33.70208@RedHat.com>
Date: Sat, 05 Mar 2011 17:46:11 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Masatake YAMATO <yamato@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Read /etc/exports.d/*.export as extra export files
References: <20110217.215900.388120588347145930.yamato@redhat.com>
In-Reply-To: <20110217.215900.388120588347145930.yamato@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

On 02/17/2011 07:59 AM, Masatake YAMATO wrote:
> This patch adding a capability to read /etc/exports.d/*.export as 
> extra export files to exportfs.
> 
> If one wants to add or remove an export entry in a script, currently
> one may have to use sed or something tool for adding or removing the
> line for the entry in /etc/exports file. 
> 
> With the patch, adding and removing an entry from a script is much easier.
> cat<<EOF... or mv can be used for adding. rm can be used for removing.
> 
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> ---
>  support/include/nfslib.h  |    6 ++++
>  utils/exportfs/exportfs.c |   59 ++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 64 insertions(+), 1 deletions(-)
> 
> diff --git a/support/include/nfslib.h b/support/include/nfslib.h
> index 53ece0e..864aae2 100644
> --- a/support/include/nfslib.h
> +++ b/support/include/nfslib.h
> @@ -25,6 +25,12 @@
>  #ifndef _PATH_EXPORTS
>  #define _PATH_EXPORTS		"/etc/exports"
>  #endif
> +#ifndef _PATH_EXPORTS_D
> +#define _PATH_EXPORTS_D         "/etc/exports.d"
> +#endif
> +#ifndef _EXT_EXPORT
> +#define _EXT_EXPORT             ".export"
Question: Why do we care about the format of the file that lives in
the _PATH_EXPORTS_D directory? The reason I asked is I created a file
called 'root.exports' which silently failed export those exports.

Now, I realize you added the ".export" explanation to the man page 
but is there a particular reason why file in that directory have 
to end with ".export"? Out of "easy of use" sake, should any 
and all files that exist in that directory be expected to 
be exports files?

steved.


> +#endif
>  #ifndef _PATH_IDMAPDCONF
>  #define _PATH_IDMAPDCONF	"/etc/idmapd.conf"
>  #endif
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index b78957f..26d0504 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -25,6 +25,7 @@
>  #include <fcntl.h>
>  #include <netdb.h>
>  #include <errno.h>
> +#include <dirent.h>
>  
>  #include "sockaddr.h"
>  #include "misc.h"
> @@ -41,6 +42,7 @@ static void	error(nfs_export *exp, int err);
>  static void	usage(const char *progname);
>  static void	validate_export(nfs_export *exp);
>  static int	matchhostname(const char *hostname1, const char *hostname2);
> +static void	export_d_read(const char *dname);
>  
>  int
>  main(int argc, char **argv)
> @@ -127,8 +129,10 @@ main(int argc, char **argv)
>  			return 0;
>  		}
>  	}
> -	if (f_export && ! f_ignore)
> +	if (f_export && ! f_ignore) {
>  		export_read(_PATH_EXPORTS);
> +		export_d_read(_PATH_EXPORTS_D);
> +	}
>  	if (f_export) {
>  		if (f_all)
>  			export_all(f_verbose);
> @@ -485,6 +489,59 @@ out:
>  	return result;
>  }
>  
> +/* Based on mnt_table_parse_dir() in
> +   util-linux-ng/shlibs/mount/src/tab_parse.c */
> +static void
> +export_d_read(const char *dname)
> +{
> +	int n = 0, i;
> +	struct dirent **namelist = NULL;
> +
> +
> +	n = scandir(dname, &namelist, NULL, versionsort);
> +	if (n < 0)
> +		xlog(L_NOTICE, "scandir %s: %s\n", dname, strerror(errno));
> +	else if (n == 0)
> +		return;
> +
> +	for (i = 0; i < n; i++) {
> +		struct dirent *d = namelist[i];
> +		size_t namesz;
> +		char fname[PATH_MAX + 1];
> +		int fname_len;
> +
> +
> +		if (d->d_type != DT_UNKNOWN 
> +		    && d->d_type != DT_REG
> +		    && d->d_type != DT_LNK)
> +			continue;
> +		if (*d->d_name == '.')
> +			continue;
> +
> +#define _EXT_EXPORT_SIZ   (sizeof(_EXT_EXPORT) - 1)
> +		namesz = strlen(d->d_name);
> +		if (!namesz 
> +		    || namesz < _EXT_EXPORT_SIZ + 1
> +		    || strcmp(d->d_name + (namesz - _EXT_EXPORT_SIZ),
> +			      _EXT_EXPORT))
> +			continue;
> +
> +		fname_len = snprintf(fname, PATH_MAX +1, "%s/%s", dname, d->d_name);
> +		if (fname_len > PATH_MAX) {
> +			xlog(L_WARNING, "Too long file name: %s in %s\n", d->d_name, dname);
> +			continue;
> +		}
> +
> +		export_read(fname);
> +	}
> +		
> +	for (i = 0; i < n; i++)
> +		free(namelist[i]);
> +	free(namelist);
> +
> +	return;
> +}
> +
>  static char
>  dumpopt(char c, char *fmt, ...)
>  {
