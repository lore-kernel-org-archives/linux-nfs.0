Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36225 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbcF0VMt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jun 2016 17:12:49 -0400
Received: by mail-it0-f65.google.com with SMTP id h190so11458ith.3
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jun 2016 14:12:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1466896768-23657-1-git-send-email-trond.myklebust@primarydata.com>
References: <1466896768-23657-1-git-send-email-trond.myklebust@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 27 Jun 2016 17:12:48 -0400
Message-ID: <CAN-5tyF2UU096gnD_qGCiLyfF1KaVu+w4yuMLXpDWiBwFcHvhw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix another OPEN_DOWNGRADE bug
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 25, 2016 at 7:19 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Olga Kornievskaia reports that the following test fails to trigger
> an OPEN_DOWNGRADE on the wire, and only triggers the final CLOSE.
>
>         fd0 = open(foo, RDRW)   -- should be open on the wire for "both"
>         fd1 = open(foo, RDONLY)  -- should be open on the wire for "read"
>         close(fd0) -- should trigger an open_downgrade
>         read(fd1)
>         close(fd1)
>
> The issue is that we're missing a check for whether or not the current
> state transitioned from an O_RDWR state as opposed to having transitioned
> from a combination of O_RDONLY and O_WRONLY.
>
> Reported-by: Olga Kornievskaia <aglo@umich.edu>
> Fixes: cd9288ffaea4 ("NFSv4: Fix another bug in the close/open_downgrade code")
> Cc: stable@vger.kernel.org # 2.6.33+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 406dd3eb68e2..ff416d0e24bc 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2882,12 +2882,11 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>                         call_close |= is_wronly;
>                 else if (is_wronly)
>                         calldata->arg.fmode |= FMODE_WRITE;
> +               if (calldata->arg.fmode != (FMODE_READ|FMODE_WRITE))
> +                       call_close |= is_rdwr;
>         } else if (is_rdwr)
>                 calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;
>
> -       if (calldata->arg.fmode == 0)
> -               call_close |= is_rdwr;
> -
>         if (!nfs4_valid_open_stateid(state))
>                 call_close = 0;
>         spin_unlock(&state->owner->so_lock);
> --
> 2.7.4
>

Thanks Trond. With this patch, in my test I see OPEN_DOWNGRADE sent.
