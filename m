Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755722AbaAVQXy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jan 2014 11:23:54 -0500
Message-ID: <52DFF102.40406@RedHat.com>
Date: Wed, 22 Jan 2014 11:25:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, nmorey@kalray.eu, rh-bugzilla@ensc.de,
        m.a.young@durham.ac.uk
Subject: Re: [PATCH] gssd: set $HOME to prevent recursion when home dirs are
 on kerberized NFS mount
References: <1390402755-10845-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1390402755-10845-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/01/14 09:59, Jeff Layton wrote:
> Some krb5 routines will attempt to access files in the user's home
> directory. This is problematic for gssd when the user's homedir is
> on a kerberized NFS mount as it will end up deadlocked.
> 
> Fix this by setting $HOME unconditionally to "/".
> 
> Fixes this Fedora bug:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=1052902
> 
> Reported-by: Enrico Scholz <rh-bugzilla@ensc.de>
> Reported-by: nmorey <nmorey@kalray.eu>
> Tested-by: Michael Young <m.a.young@durham.ac.uk>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index fdad153..611ef1a 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -46,6 +46,7 @@
>  
>  #include <unistd.h>
>  #include <err.h>
> +#include <errno.h>
>  #include <stdio.h>
>  #include <stdlib.h>
>  #include <string.h>
> @@ -161,6 +162,18 @@ main(int argc, char *argv[])
>  		}
>  	}
>  
> +	/*
> +	 * Some krb5 routines try to scrape info out of files in the user's
> +	 * home directory. This can easily deadlock when that homedir is on a
> +	 * kerberized NFS mount. By setting $HOME unconditionally to "/", we
> +	 * prevent this behavior in routines that use $HOME in preference to
> +	 * the results of getpw*.
> +	 */
> +	if (setenv("HOME", "/", 1)) {
> +		printerr(1, "Unable to set $HOME: %s\n", strerror(errno));
> +		exit(1);
> +	}
> +
>  	i = 0;
>  	ccachesearch[i++] = strtok(ccachedir, ":");
>  	do {
> 
