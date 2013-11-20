Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222Ab3KTVWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 16:22:31 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAKLMVxL013894
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 20 Nov 2013 16:22:31 -0500
Message-ID: <528D285A.2010907@RedHat.com>
Date: Wed, 20 Nov 2013 16:23:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: don't let spurious signals interrupt the wait after
 forking
References: <1384526265-4494-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384526265-4494-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 15/11/13 09:37, Jeff Layton wrote:
> Because gssd uses dnotify under the hood, it's easily possible that the
> parent process can catch a signal while processing an upcall. If that
> happens, then we'll currently exit the wait for the child task to exit,
> and it'll end up as a zombie.
> 
> Fix this by ensuring that we only wait for the child to actually exit.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed (tag: nfs-utils-1-2-10-rc1)

steved.
> ---
>  utils/gssd/gssd_proc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index b48d163..447aec1 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -1040,7 +1040,10 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  		return;
>  	default:
>  		/* Parent: just wait on child to exit and return */
> -		wait(&err);
> +		do {
> +			pid = wait(&err);
> +		} while(pid == -1 && errno != -ECHILD);
> +
>  		if (WIFSIGNALED(err))
>  			printerr(0, "WARNING: forked child was killed with signal %d\n",
>  					WTERMSIG(err));
> 
