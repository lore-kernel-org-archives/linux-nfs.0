Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35408 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbcAFRbg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2016 12:31:36 -0500
Received: by mail-ob0-f169.google.com with SMTP id xn1so31162036obc.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jan 2016 09:31:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452099090-31729-2-git-send-email-tigran.mkrtchyan@desy.de>
References: <1452099090-31729-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1452099090-31729-2-git-send-email-tigran.mkrtchyan@desy.de>
Date: Wed, 6 Jan 2016 12:31:36 -0500
Message-ID: <CAHQdGtRpXLgAJ2xWUiCaz6XeWoWhN-TXY2Yc6dDFoPSe47Ok4w@mail.gmail.com>
Subject: Re: [PATCH] nfs: set RPC_TASK_TIMEOUT on rpc task to separate TIMEOUT
 from IO errors
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 6, 2016 at 11:51 AM, Tigran Mkrtchyan
<tigran.mkrtchyan@desy.de> wrote:
> to help debug nfs problems
>
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  fs/nfs/read.c  | 2 +-
>  fs/nfs/write.c | 3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 0a5e33f..0fae3f3 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -191,7 +191,7 @@ static void nfs_initiate_read(struct nfs_pgio_header *hdr,
>         struct inode *inode = hdr->inode;
>         int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
>
> -       task_setup_data->flags |= swap_flags;
> +       task_setup_data->flags |= swap_flags | RPC_TASK_TIMEOUT;
>         rpc_ops->read_setup(hdr, msg);
>  }
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 7b93164..05c9963 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1296,6 +1296,7 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
>         int priority = flush_task_priority(how);
>
>         task_setup_data->priority = priority;
> +       task_setup_data->flags |= RPC_TASK_TIMEOUT;
>         rpc_ops->write_setup(hdr, msg);
>
>         nfs4_state_protect_write(NFS_SERVER(hdr->inode)->nfs_client,
> @@ -1578,7 +1579,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
>                 .callback_ops = call_ops,
>                 .callback_data = data,
>                 .workqueue = nfsiod_workqueue,
> -               .flags = RPC_TASK_ASYNC | flags,
> +               .flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT | flags,
>                 .priority = priority,
>         };
>         /* Set up the initial task struct.  */
> --
> 2.5.0
>

This can cause read() write() and fsync() to fail with an ETIMEDOUT
error, which is not allowed by POSIX.

Cheers,
  Trond
