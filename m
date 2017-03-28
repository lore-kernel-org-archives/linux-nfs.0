Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35363 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753916AbdC1NmQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Mar 2017 09:42:16 -0400
Received: by mail-it0-f66.google.com with SMTP id y18so3384600itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Mar 2017 06:42:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170315204240.44221-1-kolga@netapp.com>
References: <20170315204240.44221-1-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 28 Mar 2017 09:41:50 -0400
Message-ID: <CAN-5tyG5s1B25WShf5HJ0DkYLpM7oQ1OiZO+zvg892yZ=68NoQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] PNFS fix fallback to MDS if got error on commit to DS
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 15, 2017 at 4:42 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Upon receiving an error on commit to the DS, the code doesn't fallback
> to MDS and instead retried to the same DS again.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/filelayout/filelayout.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index e1d9bea..948cb70 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -382,6 +382,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
>         switch (err) {
>         case -NFS4ERR_RESET_TO_MDS:
>                 pnfs_generic_prepare_to_resend_writes(data);
> +               pnfs_set_lo_fail(data->lseg);
>                 return -EAGAIN;
>         case -EAGAIN:
>                 rpc_restart_call_prepare(task);
> --
> 1.8.3.1
>

Anna, Trond,

Any comments?
