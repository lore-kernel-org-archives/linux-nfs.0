Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282Ab3KTVT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 16:19:56 -0500
Message-ID: <528D27B9.2070308@RedHat.com>
Date: Wed, 20 Nov 2013 16:20:57 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Harshula Jayasuriya <harshula@redhat.com>, linux-nfs@vger.kernel.org
CC: Jeff Layton <jlayton@redhat.com>,
        "J.Bruce Fields" <bfields@citi.umich.edu>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH v2] exportfs: modify can_test() to use LONG_MAX when appropriate
References: <1376588800.17754.14.camel@serendib>	 <20130815175258.GS17781@fieldses.org> <1384154434.16759.39.camel@serendib>	 <20131111185356.6e0fd0a9@notabene.brown>	 <1384168843.16759.50.camel@serendib> <1384496133.14391.112.camel@serendib>	 <20131115173845.5ff064cd@notabene.brown>	 <1384511960.14391.115.camel@serendib> <1384731949.14391.120.camel@serendib>
In-Reply-To: <1384731949.14391.120.camel@serendib>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/11/13 18:45, Harshula Jayasuriya wrote:
> This patch is the nfs-utils patch corresponding to the kernel patch
> "sunrpc: prepare NFS for 2038": "The kernel sunrpc code needs to handle
> seconds since epoch greater than 2147483647. This means functions that
> parse time as an int need to handle it as time_t."
> 
> When appropriate exportfs should use LONG_MAX in can_test() instead of
> INT_MAX.
> 
> kernel INT_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> =================================================================
> 
> exportfs: /mnt/export does not support NFS export:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
> ------------------------------------------------------------
> 
> + mount fail:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=2147483768 refcnt=2 flags=4
>  # nfsd 192.168.1.6 -no-domain-
> ------------------------------------------------------------
> 
> kernel LONG_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> ==================================================================
> 
> "exportfs: /mnt/export does not support NFS export":
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
> ------------------------------------------------------------
> 
> + mount success:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=2147485448 refcnt=2 flags=1
>  nfsd 192.168.1.6 *
> ------------------------------------------------------------
> 
> kernel LONG_MAX + exportfs LONG_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> ===================================================================
> 
> exportfs:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=9223372036854775807 refcnt=1 flags=1
>  nfsd 0.0.0.0 -test-client-
> ------------------------------------------------------------
> 
> + mount success:
> ------------------------------------------------------------
>  # cat /proc/net/rpc/auth.unix.ip/content
>  #class IP domain
>  # expiry=2147485448 refcnt=2 flags=1
>  nfsd 192.168.1.6 *
>  # expiry=9223372036854775807 refcnt=1 flags=1
>  nfsd 0.0.0.0 -test-client-
> ------------------------------------------------------------
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Committed (tag: nfs-utils-1-2-10-rc1)

steved.

> ---
>  utils/exportfs/exportfs.c | 27 +++++++++++++++++++++++----
>  1 file changed, 23 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index da5fe21..9f13858 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -27,6 +27,8 @@
>  #include <netdb.h>
>  #include <errno.h>
>  #include <dirent.h>
> +#include <limits.h>
> +#include <time.h>
>  
>  #include "sockaddr.h"
>  #include "misc.h"
> @@ -406,17 +408,34 @@ unexportfs(char *arg, int verbose)
>  
>  static int can_test(void)
>  {
> +	char buf[1024];
>  	int fd;
>  	int n;
> -	char *setup = "nfsd 0.0.0.0 2147483647 -test-client-\n";
> +
>  	fd = open("/proc/net/rpc/auth.unix.ip/channel", O_WRONLY);
> -	if ( fd < 0) return 0;
> -	n = write(fd, setup, strlen(setup));
> +	if (fd < 0)
> +		return 0;
> +
> +	/* We introduce tolerance of 1 day to ensure that we use a
> +	 * LONG_MAX for the expiry timestamp before it is actually
> +	 * needed. To use LONG_MAX, the kernel code must have commit
> +	 * 2f74f972d4cc7d83408ea0c32d424edcb44887bf
> +	 * (sunrpc: prepare NFS for 2038).
> +	 */
> +#define INT_TO_LONG_THRESHOLD_SECS (INT_MAX - (60 * 60 * 24))
> +	if (time(NULL) > INT_TO_LONG_THRESHOLD_SECS)
> +		sprintf(buf, "nfsd 0.0.0.0 %ld -test-client-\n", LONG_MAX);
> +	else
> +		sprintf(buf, "nfsd 0.0.0.0 %d -test-client-\n", INT_MAX);
> +
> +	n = write(fd, buf, strlen(buf));
>  	close(fd);
>  	if (n < 0)
>  		return 0;
> +
>  	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
> -	if ( fd < 0) return 0;
> +	if (fd < 0)
> +		return 0;
>  	close(fd);
>  	return 1;
>  }
> 
