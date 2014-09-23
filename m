Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:62427 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470AbaIWPhe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 11:37:34 -0400
Message-ID: <542193BB.9050106@Netapp.com>
Date: Tue, 23 Sep 2014 11:37:31 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: <andros@netapp.com>, <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1: Fix an NFSv4.1 state renewal regression
References: <1411485490-21967-1-git-send-email-andros@netapp.com>
In-Reply-To: <1411485490-21967-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/23/2014 11:18 AM, andros@netapp.com wrote:
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
> In the above example, without this change, there are no OP_SEQUENCE state
> renewal calls during the sleep, and the clientid is recovered due to lease
> expiration on the ulock (or close if delegations are enabled).
>
> Note that this does not occur with NFSv4 which also sends a renew lease
> heartbeat if the NFS4_RENEW_DELEGATION_CB is set, and so survives the
Survives the ...?

Anna
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
>  	struct rpc_task *task;
>  	int ret = 0;
>  
> -	if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
> -		return 0;
>  	task = _nfs41_proc_sequence(clp, cred, false);
>  	if (IS_ERR(task))
>  		ret = PTR_ERR(task);

