Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab3JUR3m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:29:42 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9LHTgmd001455
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 13:29:42 -0400
Message-ID: <526564AE.3010507@RedHat.com>
Date: Mon, 21 Oct 2013 13:30:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: ssorce@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/2] gssd: have process_krb5_upcall fork before handling
 upcall
References: <1381350116-10464-1-git-send-email-jlayton@redhat.com> <1381350116-10464-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1381350116-10464-2-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/10/13 16:21, Jeff Layton wrote:
> Most krb5 installations use credcache locations that contain %{uid},
> which expands to the real UID of the current process. In order for
> GSSAPI to find those properly, we need to be able to switch the real UID
> of the process to the designated one. That however, opens the door to
> allowing gssd to be killed or reniced during the window where we've
> switched credentials.
> 
> To combat this, change gssd to fork before trying to handle each upcall.
> The child will do the work to establish the context and the parent task
> will just wait for it to exit. It's still possible for the child to be
> killed or reniced, but that would only affect a single upcall instead of
> the entire daemon. Also, If the process is killed prematurely, then log
> an error to tip off the admin that there was a problem.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.

> ---
>  utils/gssd/gssd_proc.c | 24 +++++++++++++++++++++++-
>  1 file changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index e58c341..99537d9 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -67,6 +67,8 @@
>  #include <errno.h>
>  #include <gssapi/gssapi.h>
>  #include <netdb.h>
> +#include <sys/types.h>
> +#include <sys/wait.h>
>  
>  #include "gssd.h"
>  #include "err_util.h"
> @@ -982,6 +984,26 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
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
> +		if (WIFSIGNALED(err))
> +			printerr(0, "WARNING: forked child was killed with signal %d\n",
> +					WTERMSIG(err));
> +		return;
> +	}
>  
>  	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
>  
> @@ -1121,7 +1143,7 @@ out:
>  		AUTH_DESTROY(auth);
>  	if (rpc_clnt)
>  		clnt_destroy(rpc_clnt);
> -	return;
> +	exit(0);
>  
>  out_return_error:
>  	do_error_downcall(fd, uid, downcall_err);
> 
