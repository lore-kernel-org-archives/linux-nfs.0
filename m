Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f181.google.com ([209.85.128.181]:34253 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120AbaCELkF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 06:40:05 -0500
Received: by mail-ve0-f181.google.com with SMTP id oy12so888926veb.40
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 03:40:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393959943-9919-4-git-send-email-trond.myklebust@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
	<1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
	<1393959943-9919-2-git-send-email-trond.myklebust@primarydata.com>
	<1393959943-9919-3-git-send-email-trond.myklebust@primarydata.com>
	<1393959943-9919-4-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 5 Mar 2014 06:40:03 -0500
Message-ID: <CAHVgHyUN9nS_2MLMgdY+RtS9MBg-1BKA9_LHC66n8CyfRhpjnQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFSv4: Fail the truncate() if the lock/open
 stateid is invalid
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 4, 2014 at 2:05 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If the open stateid could not be recovered, or the file locks were lost,
> then we should fail the truncate() operation altogether.
>
> Reported-by: Andy Adamson <andros@netapp.com>
> Link: http://lkml.kernel.org/r/1393954269-3974-1-git-send-email-andros@netapp.com
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 44e088dc357c..daf41182ecfb 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2398,13 +2398,16 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>
>         if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
>                 /* Use that stateid */
> -       } else if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
> +       } else if (truncate && state != NULL) {
>                 struct nfs_lockowner lockowner = {
>                         .l_owner = current->files,
>                         .l_pid = current->tgid,
>                 };
> -               nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
> -                               &lockowner);
> +               if (!nfs4_valid_open_stateid(state))
> +                       return -EBADF;
> +               if (nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
> +                               &lockowner) < 0)

AFICS this means -EIO = lost lock. Why fail the setattr? the file
handle is not bad.  Why not send a ZERO_STATEID?  At any rate, -EBADF
looks wrong to me.

-->Andy

> +                       return -EBADF;
>         } else
>                 nfs4_stateid_copy(&arg.stateid, &zero_stateid);
>
> --
> 1.8.5.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
