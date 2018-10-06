Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f193.google.com ([209.85.166.193]:40324 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727726AbeJFUcX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Oct 2018 16:32:23 -0400
Received: by mail-it1-f193.google.com with SMTP id i191-v6so6468100iti.5
        for <linux-nfs@vger.kernel.org>; Sat, 06 Oct 2018 06:29:04 -0700 (PDT)
MIME-Version: 1.0
References: <20180928200258.68552-1-trond.myklebust@hammerspace.com> <20180928200258.68552-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180928200258.68552-2-trond.myklebust@hammerspace.com>
From: Stan Hu <stanhu@gmail.com>
Date: Sat, 6 Oct 2018 06:28:52 -0700
Message-ID: <CAMBWrQ=Ef7R8_wrK7v89Za0LdFZf-S6sRL7qy8A-d44JZEsQVw@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFS: Fix dentry revalidation on NFSv4 lookup
To: trondmy@gmail.com
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, Trond! I applied this patch on 4.19rc4 and ran my test, and
this seemed to have solved the problem!

On Fri, Sep 28, 2018 at 1:03 PM Trond Myklebust <trondmy@gmail.com> wrote:
>
> We need to ensure that inode and dentry revalidation occurs correctly
> on reopen of a file that is already open. Currently, we can end up
> not revalidating either in the case of NFSv4.0, due to the 'cached open'
> path.
> Let's fix that by ensuring that we only do cached open for the special
> cases of open recovery and delegation return.
>
> Reported-by: Stan Hu <stanhu@gmail.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/nfs4proc.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4da59bd53f98..db84b4adbc49 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1349,12 +1349,20 @@ static bool nfs4_mode_match_open_stateid(struct nfs4_state *state,
>         return false;
>  }
>
> -static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode)
> +static int can_open_cached(struct nfs4_state *state, fmode_t mode,
> +               int open_mode, enum open_claim_type4 claim)
>  {
>         int ret = 0;
>
>         if (open_mode & (O_EXCL|O_TRUNC))
>                 goto out;
> +       switch (claim) {
> +       case NFS4_OPEN_CLAIM_NULL:
> +       case NFS4_OPEN_CLAIM_FH:
> +               goto out;
> +       default:
> +               break;
> +       }
>         switch (mode & (FMODE_READ|FMODE_WRITE)) {
>                 case FMODE_READ:
>                         ret |= test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0
> @@ -1747,7 +1755,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
>
>         for (;;) {
>                 spin_lock(&state->owner->so_lock);
> -               if (can_open_cached(state, fmode, open_mode)) {
> +               if (can_open_cached(state, fmode, open_mode, claim)) {
>                         update_open_stateflags(state, fmode);
>                         spin_unlock(&state->owner->so_lock);
>                         goto out_return_state;
> @@ -2294,7 +2302,8 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
>         if (data->state != NULL) {
>                 struct nfs_delegation *delegation;
>
> -               if (can_open_cached(data->state, data->o_arg.fmode, data->o_arg.open_flags))
> +               if (can_open_cached(data->state, data->o_arg.fmode,
> +                                       data->o_arg.open_flags, claim))
>                         goto out_no_action;
>                 rcu_read_lock();
>                 delegation = rcu_dereference(NFS_I(data->state->inode)->delegation);
> --
> 2.17.1
>
