Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754315Ab0JKNcK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 09:32:10 -0400
Message-ID: <4CB311D6.2000503@RedHat.com>
Date: Mon, 11 Oct 2010 09:32:06 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/15] mount.nfs: Eliminate compiler warnings
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000441.6667.68536.stgit@ellison.1015granger.net>
In-Reply-To: <20101011000441.6667.68536.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/10/2010 08:04 PM, Chuck Lever wrote:
> Clean up.
> 
> fstab.c: In function ‘lock_mtab’:
> fstab.c:385: warning: declaration of ‘errsv’ shadows a previous local
> fstab.c:367: warning: shadowed declaration is here
> fstab.c:407: warning: declaration of ‘errsv’ shadows a previous local
> fstab.c:367: warning: shadowed declaration is here
> fstab.c:417: warning: declaration of ‘tries’ shadows a previous local
> fstab.c:325: warning: shadowed declaration is here
> fstab.c:422: warning: declaration of ‘errsv’ shadows a previous local
> fstab.c:367: warning: shadowed declaration is here
Could you please post the gcc flags you using to generate 
theses warnings... These warnings are not being generated with
the default gcc flags we are currently using... 

tia,

steved.

> These are probably harmless.  Reusing a variable name, however, is a
> little confusing to follow when reading the code.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/fstab.c |   29 ++++++++++++++++-------------
>  1 files changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/utils/mount/fstab.c b/utils/mount/fstab.c
> index 051fa38..a742e64 100644
> --- a/utils/mount/fstab.c
> +++ b/utils/mount/fstab.c
> @@ -364,19 +364,22 @@ lock_mtab (void) {
>  	/* Repeat until it was us who made the link */
>  	while (!we_created_lockfile) {
>  		struct flock flock;
> -		int errsv, j;
> +		int j;
>  
>  		j = link(linktargetfile, MOUNTED_LOCK);
> -		errsv = errno;
>  
> -		if (j == 0)
> -			we_created_lockfile = 1;
> +		{
> +			int errsv = errno;
>  
> -		if (j < 0 && errsv != EEXIST) {
> -			(void) unlink(linktargetfile);
> -			die (EX_FILEIO, _("can't link lock file %s: %s "
> -			     "(use -n flag to override)"),
> -			     MOUNTED_LOCK, strerror (errsv));
> +			if (j == 0)
> +				we_created_lockfile = 1;
> +
> +			if (j < 0 && errsv != EEXIST) {
> +				(void) unlink(linktargetfile);
> +				die (EX_FILEIO, _("can't link lock file %s: %s "
> +				     "(use -n flag to override)"),
> +				     MOUNTED_LOCK, strerror (errsv));
> +			}
>  		}
>  
>  		lockfile_fd = open (MOUNTED_LOCK, O_WRONLY);
> @@ -414,7 +417,7 @@ lock_mtab (void) {
>  			}
>  			(void) unlink(linktargetfile);
>  		} else {
> -			static int tries = 0;
> +			static int retries = 0;
>  
>  			/* Someone else made the link. Wait. */
>  			alarm(LOCK_TIMEOUT);
> @@ -428,10 +431,10 @@ lock_mtab (void) {
>  			alarm(0);
>  			/* Limit the number of iterations - maybe there
>  			   still is some old /etc/mtab~ */
> -			++tries;
> -			if (tries % 200 == 0)
> +			++retries;
> +			if (retries % 200 == 0)
>  			   usleep(30);
> -			if (tries > 100000) {
> +			if (retries > 100000) {
>  				(void) unlink(linktargetfile);
>  				close(lockfile_fd);
>  				die (EX_FILEIO, _("Cannot create link %s\n"
> 
