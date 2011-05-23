From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] Remove risk of nfs_addmntent corrupting mtab
Date: Mon, 23 May 2011 08:26:02 -0400
Message-ID: <4DDA525A.802@RedHat.com>
References: <20110517045125.29020.14596.stgit@notabene.brown> <20110517045217.29020.16140.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505Ab1EWM0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2011 08:26:06 -0400
In-Reply-To: <20110517045217.29020.16140.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/17/2011 12:52 AM, Neil Brown wrote:
> nfs_addmntent is used to append directly to /etc/mtab.
> If the write partially fail, e.g. due to RLIMIT_FSIZE,
> truncate back to original size and return an error.
> 
> See also https://bugzilla.redhat.com/show_bug.cgi?id=697975
>  (CVE-2011-1749) CVE-2011-1749 nfs-utils: mount.nfs fails to anticipate RLIMIT_FSIZE
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  support/nfs/nfs_mntent.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
> index a5216fc..a2118a2 100644
> --- a/support/nfs/nfs_mntent.c
> +++ b/support/nfs/nfs_mntent.c
> @@ -12,6 +12,7 @@
>  #include <string.h>		/* for index */
>  #include <ctype.h>		/* for isdigit */
>  #include <sys/stat.h>		/* for umask */
> +#include <unistd.h>		/* for ftruncate */
>  
>  #include "nfs_mntent.h"
>  #include "nls.h"
> @@ -127,9 +128,11 @@ int
>  nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>  	char *m1, *m2, *m3, *m4;
>  	int res;
> +	off_t length;
>  
>  	if (fseek (mfp->mntent_fp, 0, SEEK_END))
>  		return 1;			/* failure */
> +	length = ftell(mfp->mntent_fp);
>  
>  	m1 = mangle(mnt->mnt_fsname);
>  	m2 = mangle(mnt->mnt_dir);
> @@ -143,6 +146,12 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>  	free(m2);
>  	free(m3);
>  	free(m4);
> +	if (res >= 0) {
> +		res = fflush(mfp->mntent_fp);
> +		if (res < 0)
> +			/* Avoid leaving a corrupt mtab file */
> +			ftruncate(fileno(mfp->mntent_fp), length);
> +	}
>  	return (res < 0) ? 1 : 0;
>  }
>  
> 
> 
Committed...

steved.
