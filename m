Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:57599 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbaIWQfy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 12:35:54 -0400
Received: by mail-vc0-f173.google.com with SMTP id le20so5624276vcb.18
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 09:35:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411486536-23401-2-git-send-email-andros@netapp.com>
References: <1411486536-23401-1-git-send-email-andros@netapp.com>
	<1411486536-23401-2-git-send-email-andros@netapp.com>
Date: Tue, 23 Sep 2014 12:35:53 -0400
Message-ID: <CAHQdGtSt+6-Gf6NmSY1tHUzdLvFbM=PSCiFXvAx63tO5usfMew@mail.gmail.com>
Subject: Re: [PATCH Version 2 1/1] NFSv4.1: Fix an NFSv4.1 state renewal regression
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On Tue, Sep 23, 2014 at 11:35 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Commit 2f60ea6b8ced ("NFSv4: The NFSv4.0 client must send RENEW calls if it holds a delegation") set the NFS4_RENEW_TIMEOUT
> flag in nfs4_renew_state, and does not put an nfs41_proc_async_sequence call,
> the NFSv4.1 lease renewal heartbeat call, on the wire to renew the NFSv4.1
> state if the flag was not set.
>
> The NFS4_RENEW_TIMEOUT flag is set when "now" is after the last renewal
> (cl_last_renewal) plus the lease time divided by 3. This is arbitrary and
> sometimes does the following:
>
> In normal operation, the only way a future state renewal call is put on the
> wire is via a call to nfs4_schedule_state_renewal, which schedules a
> nfs4_renew_state workqueue task. nfs4_renew_state determines if the
> NFS4_RENEW_TIMEOUT should be set, and the calls nfs41_proc_async_sequence,
> which only gets sent if the NFS4_RENEW_TIMEOUT flag is set.
> Then the nfs41_proc_async_sequence rpc_release function schedules
> another state remewal via nfs4_schedule_state_renewal.
>
> Without this change we can get into a state where an application stops
> accessing the NFSv4.1 share, state renewal calls stop due to the
> NFS4_RENEW_TIMEOUT flag _not_ being set. Note that the only way to recover
> from this situation is with a clientid re-establishment, once the application
> resumes and the server has timed out the lease and so returns
> NFS4ERR_BAD_SESSION.
>
> An example application:
> open, lock, write a file.
>
> sleep for 6 * lease (could be less)
>
> ulock, close.
>
> In the above example with NFSv4.1 delegations enabled, without this change,
> there are no OP_SEQUENCE state renewal calls during the sleep, and the
> clientid is recovered due to lease expiration on the close.
>
> This issue does not occur with NFSv4.1 delegations disabled, nor with
> NFSv4.0, with or without delegations enabled.
>
> Commit 2f60ea6b8ced ("NFSv4: The NFSv4.0 client must send RENEW calls if it holds a delegation") states:
>
>     RFC3530 states that if the client holds a delegation, then it is obliged
>     to continue to send RENEW calls once every lease period in order to allow
>     the server to return NFS4ERR_CB_PATH_DOWN if the callback path is
>     unreachable.
>
>     This is not required for NFSv4.1, since the server can at any time set
>     the SEQ4_STATUS_CB_PATH_DOWN_SESSION in any SEQUENCE operation.
>
> The problem is, in the above example, there is not SEQUENCE operation sent.
>
> AFAICS the purpose of "NFSv4: The NFSv4.0 client must send RENEW calls if it holds a delegation" is to not send a lease renewal when NFSv4.1 delegations are
> enabled, perhaps we should revert that commit.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 288be08..efe802a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7348,8 +7348,6 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
>         struct rpc_task *task;
>         int ret = 0;
>
> -       if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
> -               return 0;
>         task = _nfs41_proc_sequence(clp, cred, false);
>         if (IS_ERR(task))
>                 ret = PTR_ERR(task);
> --
> 1.8.3.1

The problem here isn't that we're failing to send a SEQUENCE in a
situation where we're not required to do so by the spec. The problem
is that we're failing to rearm renewd when we skip that SEQUENCE call.

Instead of removing them, could you rather please modify the above
lines to return an error, and then have nfs4_renew_state() respond by
calling nfs4_schedule_state_renewal(), instead of just skipping it as
we do today. In fact, AFAICS we want to do the same when the renew
call fails due to ENOMEM (but not when it returns EIO, since that
signals that the nfs_client is in the process of shutting down).

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
