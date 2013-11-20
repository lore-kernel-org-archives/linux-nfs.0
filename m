Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103Ab3KTVVQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 16:21:16 -0500
Message-ID: <528D280E.2010901@RedHat.com>
Date: Wed, 20 Nov 2013 16:22:22 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: Fix file descriptor leak of old pipe dirs
References: <1384299500-67986-1-git-send-email-dros@netapp.com>
In-Reply-To: <1384299500-67986-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/11/13 18:38, Weston Andros Adamson wrote:
> gssd doesn't properly clean up internal state for old pipes and never
> closes the (since deleted) clnt_info directory. This leads to eventual
> fd exhaustion.
> 
> To reproduce, run a lot of mount / umounts in a loop and watch the
> output of 'ls /proc/$PID/fdinfo | wc -l' (where PID is the pid of gssd)
> steadily grow until gssd eventually crashes with "Too many open files".
> 
> This regression was introduced by 841e83c1, which was trying to fix a
> similar bug in the skip matching logic of update_old_clients. The problem
> with that patch is that pdir will never match dirname, because dirname is
> "<pname>/clntXXX".
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
Committed (tag: nfs-utils-1-2-10-rc1)

steved.

> ---
>  utils/gssd/gssd.h      | 1 +
>  utils/gssd/gssd_proc.c | 6 +++++-
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 86472a1..e44ea40 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -73,6 +73,7 @@ TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
>  struct clnt_info {
>  	TAILQ_ENTRY(clnt_info)	list;
>  	char			*dirname;
> +	char			*pdir;
>  	int			dir_fd;
>  	char			*servicename;
>  	char			*servername;
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index b48d163..02994f6 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -322,6 +322,7 @@ destroy_client(struct clnt_info *clp)
>  	if (clp->krb5_fd != -1) close(clp->krb5_fd);
>  	if (clp->gssd_fd != -1) close(clp->gssd_fd);
>  	free(clp->dirname);
> +	free(clp->pdir);
>  	free(clp->servicename);
>  	free(clp->servername);
>  	free(clp->protocol);
> @@ -463,6 +464,9 @@ process_clnt_dir(char *dir, char *pdir)
>  	if (!(clp = insert_new_clnt()))
>  		goto fail_destroy_client;
>  
> +	if (!(clp->pdir = strdup(pdir)))
> +		goto fail_destroy_client;
> +
>  	/* An extra for the '/', and an extra for the null */
>  	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1))) {
>  		goto fail_destroy_client;
> @@ -527,7 +531,7 @@ update_old_clients(struct dirent **namelist, int size, char *pdir)
>  		/* only compare entries in the global list that are from the
>  		 * same pipefs parent directory as "pdir"
>  		 */
> -		if (strcmp(clp->dirname, pdir) != 0) continue;
> +		if (strcmp(clp->pdir, pdir) != 0) continue;
>  
>  		stillhere = 0;
>  		for (i=0; i < size; i++) {
> 
