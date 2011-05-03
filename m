Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62376 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754976Ab1ECUTC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 16:19:02 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p43KJ15j014572
	for <linux-nfs@vger.kernel.org>; Tue, 3 May 2011 13:19:02 -0700 (PDT)
Subject: Re: [PATCH 1/1] NFSv41: Resend on NFS4ERR_RETRY_UNCACHED_REP
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1304387669-2969-1-git-send-email-andros@netapp.com>
References: <1304387669-2969-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 May 2011 16:19:00 -0400
Message-ID: <1304453940.20025.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-02 at 21:54 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Free the slot and resend the RPC with new session <slot#,seq#>.
> 
> For nfs4_async_handle_error, return -EAGAIN and set the task->tk_status to 0
> to restart the async rpc in the rpc_restart_call_prepare state which resets
> the slot.
> 
> For nfs4_handle_exception, retrying a call that uses nfs4_call_sync will
> reset the slot via nfs41_call_sync_prepare.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b8e1ac6..01d70dd 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -300,6 +300,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>  			ret = nfs4_delay(server->client, &exception->timeout);
>  			if (ret != 0)
>  				break;
> +		case -NFS4ERR_RETRY_UNCACHED_REP:
>  		case -NFS4ERR_OLD_STATEID:
>  			exception->retry = 1;
>  			break;
> @@ -3677,6 +3678,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>  			rpc_delay(task, NFS4_POLL_RETRY_MAX);
>  			task->tk_status = 0;
>  			return -EAGAIN;
> +		case -NFS4ERR_RETRY_UNCACHED_REP:
>  		case -NFS4ERR_OLD_STATEID:
>  			task->tk_status = 0;
>  			return -EAGAIN;

Looks good... Do we need handlers for this in things like
'reclaim_complete_done()' and 'nfs41_sequence_handle_errors()'?

I'm assuming that all the stateful operations such as open/close/... set
the cache reply flag and so don't need it?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

