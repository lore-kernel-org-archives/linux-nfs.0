Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756637Ab2CLTRh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 15:17:37 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2CJHaTX021417
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2012 15:17:37 -0400
Message-ID: <4F5E4BCF.5050908@RedHat.com>
Date: Mon, 12 Mar 2012 15:17:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/1] exportfs: Stop racing exportfs on clusters
References: <1331573020-28628-1-git-send-email-steved@redhat.com>
In-Reply-To: <1331573020-28628-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/12/2012 01:23 PM, Steve Dickson wrote:
> This problem can occur when multiple cluster services fail over
> at the same time, causing missing high-available exports.
> Having a lot of nfs-exports will trigger this issue easier.
> 
> https://bugzilla.linux-nfs.org/show_bug.cgi?id=224
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  support/include/exportfs.h |    4 ++++
>  utils/exportfs/exportfs.c  |   41 +++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 45 insertions(+), 0 deletions(-)
> 
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 01e87dd..99916e5 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -32,6 +32,10 @@ enum {
>  	FSLOC_STUB
>  };
>  
> +#ifndef EXP_LOCKFILE
> +#define EXP_LOCKFILE "/var/lib/nfs/export-lock"
> +#endif
> +
>  typedef struct mclient {
>  	struct mclient *	m_next;
>  	char *			m_hostname;
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 7432a65..7326802 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -16,6 +16,7 @@
>  #include <sys/stat.h>
>  #include <sys/vfs.h>
>  #include <sys/stat.h>
> +#include <sys/file.h>
>  #include <unistd.h>
>  #include <stdbool.h>
>  #include <stdlib.h>
> @@ -44,6 +45,39 @@ static void	validate_export(nfs_export *exp);
>  static int	matchhostname(const char *hostname1, const char *hostname2);
>  static void	export_d_read(const char *dname);
>  
> +static const char *lockfile = EXP_LOCKFILE;
> +static int _lockfd = -1;
> +
> +/*
> + * If we aren't careful, changes made by exportfs can be lost
> + * when multiple exports process run at once:
> + *
> + *	exportfs process 1	exportfs process 2
> + *	------------------------------------------
> + *	reads etab version A	reads etab version A
> + *	adds new export B	adds new export C
> + *	writes A+B		writes A+C
> + *
> + * The locking in support/export/xtab.c will prevent mountd from
> + * seeing a partially written version of etab, and will prevent 
> + * the two writers above from writing simultaneously and
> + * corrupting etab, but to prevent problems like the above we
> + * need these additional lockfile() routines.
> + */
> +void 
> +grab_lockfile()
> +{
> +	_lockfd = open(lockfile, O_CREAT|O_RDWR, 0666);
> +	if (_lockfd != -1) 
> +		lockf(_lockfd, F_LOCK, 0);
> +}
> +void 
> +release_lockfile()
> +{
> +	if (_lockfd != -1)
> +		lockf(_lockfd, F_ULOCK, 0);
> +}
> +
>  int
>  main(int argc, char **argv)
>  {
> @@ -129,6 +163,13 @@ main(int argc, char **argv)
>  			return 0;
>  		}
>  	}
> +
> +	/*
> +	 * Serialize things as best we can
> +	 */
> +	grab_lockfile();
> +	atexit(release_lockfile);
> +
>  	if (f_export && ! f_ignore) {
>  		export_read(_PATH_EXPORTS);
>  		export_d_read(_PATH_EXPORTS_D);
