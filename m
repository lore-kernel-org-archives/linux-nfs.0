From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] nfs41: Do not free slot if retried while operation
 was in progress
Date: Fri, 25 Sep 2009 11:01:58 -0400
Message-ID: <1253890918.31072.35.camel@heimdal.trondhjem.org>
References: <1253852945-22020-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbZIYPCd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2009 11:02:33 -0400
In-Reply-To: <1253852945-22020-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-25 at 07:29 +0300, Benny Halevy wrote:
> The client cannot reuse a slot while the server's
> still working on the previous RPC using it.
> 
> The symptom Bruce saw without this patch was occasional
> ESERVERFAULT during Connectathon special tests, 30 MB write/read test.
> 
> Reported-by: J. Bruce Fields <bfields@fieldses.org>
> Tested-by: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index be6544a..70895d6 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -386,6 +386,12 @@ static void nfs41_sequence_done(struct nfs_client *clp,
>  		spin_unlock(&clp->cl_lock);
>  		return;
>  	}
> +
> +	/* Do not free slot if retried while operation was in progress */
> +	if (res->sr_status == -NFS4ERR_DELAY) {
> +		dprintk("%s: Operation in progress\n", __func__);
> +		return;
> +	}
>  out:
>  	/* The session may be reset by one of the error handlers. */
>  	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);

OK... Can somebody please tell me how this is supposed to work? As far
as I can see, most callers of nfs41_sequence_done() are calling
nfs41_sequence_free_slot() themselves.

IOW: Who is responsible for calling nfs41_sequence_free_slot()? Is it
nfs41_sequence_done(), or is it the callers, or is it some combination
of the two (and if so, what determines who calls it)?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
