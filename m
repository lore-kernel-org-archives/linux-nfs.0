Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:34233 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750832AbcILUTr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Sep 2016 16:19:47 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 05/10] nfs: track whether server sets MAY_NOTIFY_LOCK
 flag
To: Jeff Layton <jlayton@redhat.com>, <trond.myklebust@primarydata.com>,
        <Anna.Schumaker@netapp.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
 <1473446870-1831-6-git-send-email-jlayton@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <68634996-8fba-5bcd-27e3-5d6ab5f881ba@Netapp.com>
Date: Mon, 12 Sep 2016 16:19:39 -0400
MIME-Version: 1.0
In-Reply-To: <1473446870-1831-6-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On 09/09/2016 02:47 PM, Jeff Layton wrote:
> If it does, then always have the client sleep for the max time before
> repolling for the lock. If it doesn't then we can skip all of the
> waitqueue handling as well.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/nfs4_fs.h  | 1 +
>  fs/nfs/nfs4proc.c | 2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 9bf64eacba5b..91e4f135a5f2 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -156,6 +156,7 @@ enum {
>  	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
>  	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
>  	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
> +	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */

Looks like the reason I don't have this flag is because it's added as part of the server patches.  I'll coordinate with the nfsd merge to make sure everything is added in the right order!

Thanks,
Anna
>  };
>  
>  struct nfs4_state {
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 90e8ded0ef82..627a9185822f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2537,6 +2537,8 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
>  		goto out;
>  	if (server->caps & NFS_CAP_POSIX_LOCK)
>  		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
> +	if (opendata->o_res.rflags & NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK)
> +		set_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state->flags);
>  
>  	dentry = opendata->dentry;
>  	if (d_really_is_negative(dentry)) {
> 

