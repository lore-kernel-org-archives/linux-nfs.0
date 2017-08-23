Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932443AbdHWULY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Aug 2017 16:11:24 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSv4: Don't add a new lock on an interrupted wait for
 LOCK
Date: Wed, 23 Aug 2017 16:11:22 -0400
Message-ID: <D7F32DDE-7DE7-46F6-87AA-F6FF68397BE3@redhat.com>
In-Reply-To: <cda7d9d6f145289d2855eb733a8d795938e67453.1501673116.git.bcodding@redhat.com>
References: <1501618320.4702.14.camel@redhat.com>
 <cda7d9d6f145289d2855eb733a8d795938e67453.1501673116.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping on this one as well -- it was buried in a thread:

Ben

On 2 Aug 2017, at 7:27, Benjamin Coddington wrote:

> If the wait for a LOCK operation is interrupted, and then the file is
> closed, the locks cleanup code will assume that no new locks will be 
> added
> to the inode after it has completed.  We already have a mechanism to 
> detect
> if there was signal, so let's use that to avoid recreating the local 
> lock
> once the RPC completes.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index dbfa18900e25..5256f429c268 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6100,7 +6100,7 @@ static void nfs4_lock_done(struct rpc_task 
> *task, void *calldata)
>  	case 0:
>  		renew_lease(NFS_SERVER(d_inode(data->ctx->dentry)),
>  				data->timestamp);
> -		if (data->arg.new_lock) {
> +		if (data->arg.new_lock && !data->cancelled) {
>  			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
>  			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0) {
>  				rpc_restart_call_prepare(task);
> -- 
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
