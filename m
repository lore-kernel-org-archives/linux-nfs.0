Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536Ab3JCSyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Oct 2013 14:54:24 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r93IsOuq017835
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Oct 2013 14:54:24 -0400
Date: Thu, 3 Oct 2013 14:56:01 -0400
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] gssd: have process_krb5_upcall fork before handling
 upcall
Message-ID: <20131003145601.6ceb8d2d@corrin.poochiereds.net>
In-Reply-To: <1380825731-3314-2-git-send-email-jlayton@redhat.com>
References: <1380825731-3314-1-git-send-email-jlayton@redhat.com>
	<1380825731-3314-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  3 Oct 2013 14:42:10 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> In order to handle KEYRING: caches, we need to be able to switch the
> real UID of the process to the designated one, but that opens the door
> to allowing gssd to be killed or reniced during the window where we've
> switched credentials.
> 
> Change gssd to fork before trying to handle each upcall. The child will
> do the work to establish the context and the parent task will just wait
> for it to exit. It's still possible for the child to be killed or
> reniced, but that would only affect a single upcall instead of the
> entire daemon.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/gssd/gssd_main_loop.c |  3 ++-
>  utils/gssd/gssd_proc.c      | 19 ++++++++++++++++++-
>  2 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index ccf7fe5..7b0f568 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -40,7 +40,8 @@
>  #include <sys/socket.h>
>  #include <sys/poll.h>
>  #include <netinet/in.h>
> -
> +#include <sys/types.h>
> +#include <sys/wait.h>

My apologies -- unneeded delta here that gets fixed up in the 2nd
patch. The final result is fine, but this breaks bisectability. I'll
fix and send a v2 set. Sorry for the noise...

>  #include <stdio.h>
>  #include <stdlib.h>
>  #include <string.h>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index e58c341..1a58809 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -982,6 +982,23 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	int			err, downcall_err = -EACCES;
>  	gss_cred_id_t		gss_cred;
>  	OM_uint32		maj_stat, min_stat, lifetime_rec;
> +	pid_t			pid;
> +
> +	pid = fork();
> +	switch(pid) {
> +	case 0:
> +		/* Child: fall through to rest of function */
> +		break;
> +	case -1:
> +		/* fork() failed! */
> +		printerr(0, "WARNING: unable to fork() to handle upcall: %s\n",
> +				strerror(errno));
> +		return;
> +	default:
> +		/* Parent: just wait on child to exit and return */
> +		wait(&err);
> +		return;
> +	}
>  
>  	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
>  
> @@ -1121,7 +1138,7 @@ out:
>  		AUTH_DESTROY(auth);
>  	if (rpc_clnt)
>  		clnt_destroy(rpc_clnt);
> -	return;
> +	exit(0);
>  
>  out_return_error:
>  	do_error_downcall(fd, uid, downcall_err);


-- 
Jeff Layton <jlayton@redhat.com>
