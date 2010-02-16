From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] libtirpc: handle large numbers of supplemental groups
 gracefully (try #2)
Date: Tue, 16 Feb 2010 14:22:51 -0500
Message-ID: <4B7AF08B.3090608@oracle.com>
References: <1266347817-11186-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: steved@redhat.com, libtirpc-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59648 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757013Ab0BPTY5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Feb 2010 14:24:57 -0500
In-Reply-To: <1266347817-11186-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/16/2010 02:16 PM, Jeff Layton wrote:
> This is the second attempt at this patch. The main changes are that this
> one doesn't set a floor value for the size of the group list. There are
> also a few minor cleanups and comments added.
>
> If authunix_create_default() is called by a user with more than 16
> supplimental groups, it'll abort(), which causes the program to crash
> and coredump.
>
> Fix it to handle this situation gracefully. Get the number of groups
> that the user has first, and then allocate a big enough buffer to hold
> them. Then, just don't let the lower function use more than the NGRPS
> groups.
>
> Also fix up the error handling in this function so that it just returns
> a NULL pointer on error and logs a message via warnx() instead of
> calling abort().
>
> Reported-by: Peter Engel<peter.engel-y6kNeMnOB+c@public.gmane.org>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> ---
>   src/auth_unix.c |   62 +++++++++++++++++++++++++++++++++++++++++++++++++-----
>   1 files changed, 56 insertions(+), 6 deletions(-)
>
> diff --git a/src/auth_unix.c b/src/auth_unix.c
> index 71ca15d..a295e71 100644
> --- a/src/auth_unix.c
> +++ b/src/auth_unix.c
> @@ -49,6 +49,7 @@
>   #include<stdlib.h>
>   #include<unistd.h>
>   #include<string.h>
> +#include<errno.h>
>
>   #include<rpc/types.h>
>   #include<rpc/xdr.h>
> @@ -175,20 +176,69 @@ AUTH *
>   authunix_create_default()
>   {
>   	int len;
> +	size_t bufsize = 0;
>   	char machname[MAXHOSTNAMELEN + 1];
>   	uid_t uid;
>   	gid_t gid;
> -	gid_t gids[NGRPS];
> +	gid_t *gids = NULL;
> +	AUTH *auth;
> +
> +	if (gethostname(machname, sizeof machname) == -1) {
> +		warnx("%s: gethostname() failed: %s", __func__,
> +			strerror(errno));
> +		return NULL;
> +	}
>
> -	if (gethostname(machname, sizeof machname) == -1)
> -		abort();
>   	machname[sizeof(machname) - 1] = 0;
>   	uid = geteuid();
>   	gid = getegid();
> -	if ((len = getgroups(NGRPS, gids))<  0)
> -		abort();
> +
> +retry:
> +	len = getgroups(0, NULL);
> +	if (len<  0) {
> +		warnx("%s: failed to get number of groups: %s", __func__,
> +			strerror(errno));
> +		return NULL;
> +	}
> +
> +	if (len == 0)
> +		goto no_groups;
> +
> +	bufsize = len * sizeof(gid_t);
> +	gids = mem_alloc(bufsize);
> +	if (gids == NULL) {
> +		warnx("%s: memory allocation failed: %s", __func__,
> +			strerror(ENOMEM));
> +		return NULL;
> +	}
> +
> +	len = getgroups(len, gids);
> +	if (len<  0) {
> +		mem_free(gids, bufsize);
> +		/*
> +		 * glibc equivalent routines mention that it's possible for
> +		 * the number of groups to change between two getgroups calls.
> +		 * If that happens, retry the whole thing again.
> +		 */
> +		if (len == -EINVAL) {
> +			gids = NULL;
> +			bufsize = 0;
> +			goto retry;
> +		}
> +		warnx("%s: failed to get group list: %s", __func__,
> +			strerror(errno));
> +		return NULL;
> +	}
> +
> +	/* AUTH_UNIX has a hard limit of NGRPS supplemental groups */
> +	if (len>  NGRPS)
> +		len = NGRPS;
> +
> +no_groups:
>   	/* XXX: interface problem; those should all have been unsigned */
> -	return (authunix_create(machname, uid, gid, len, gids));
> +	auth = authunix_create(machname, uid, gid, len, gids);
> +	mem_free(gids, bufsize);
> +	return auth;
>   }
>
>   /*


-- 
chuck[dot]lever[at]oracle[dot]com
