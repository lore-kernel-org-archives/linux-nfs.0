Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35473 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512AbbHYPBt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:01:49 -0400
Received: by obbwr7 with SMTP id wr7so144368771obb.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:01:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440513995-22942-1-git-send-email-xerofoify@gmail.com>
References: <1440513995-22942-1-git-send-email-xerofoify@gmail.com>
Date: Tue, 25 Aug 2015 11:01:48 -0400
Message-ID: <CAHQdGtQ6-e0-P36-omFmCQ+rHmV4rCfLLkAh3KNojBPhcEOTLg@mail.gmail.com>
Subject: Re: [PATCH] nfs:Fix variable assignment for return value to caller in
 the function _nfs4_proc_delegreturn
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2015 at 10:46 AM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This fixes incorrect variable assignment in the function
> _nfs4_proc_delegreturn for when calling either one of the
> functions nfs_post_op_update_inode_force_wcc or the function
> nfs_refresh_inode due to the variable status which the
> function _nfs_proc_delegreturn uses for failure to instead
> properly assign to the variable status used for this function's
> return statement to properly signal to the caller when a failure
> occurs when calling here of these functions internally.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  fs/nfs/nfs4proc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3acb1eb..3a94a6e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5353,9 +5353,9 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
>                 goto out;
>         status = data->rpc_status;
>         if (status == 0)
> -               nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
> +               status = nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
>         else
> -               nfs_refresh_inode(inode, &data->fattr);
> +               status = nfs_refresh_inode(inode, &data->fattr);
>  out:
>         rpc_put_task(task);
>         return status;
> --
> 2.1.4
>

NACK. The success or failure of those 2 operations is completely
immaterial to the success or failure of delegreturn, which is why we
don't test their return values.
