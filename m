Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:59817 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaCDReB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 12:34:01 -0500
Received: by mail-ig0-f176.google.com with SMTP id uy17so11009264igb.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Mar 2014 09:34:00 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 4/4] NFSv4.1 Fail data server I/O if stateid represents a lost lock
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1393954269-3974-5-git-send-email-andros@netapp.com>
Date: Tue, 4 Mar 2014 12:33:58 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <4D628555-CBD8-4217-B9BE-E1C2D2319618@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com> <1393954269-3974-5-git-send-email-andros@netapp.com>
To: Adamson William Andros <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 4, 2014, at 12:31, <andros@netapp.com> <andros@netapp.com> wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/nfs4filelayout.c | 10 ++++++----
> 1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 12c8132..66da1e4 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -324,8 +324,9 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
> 			&rdata->res.seq_res,
> 			task))
> 		return;
> -	nfs4_set_rw_stateid(&rdata->args.stateid, rdata->args.context,
> -			rdata->args.lock_context, FMODE_READ);
> +	if (nfs4_set_rw_stateid(&rdata->args.stateid, rdata->args.context,
> +			rdata->args.lock_context, FMODE_READ) == -EIO)
> +		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
> }
> 
> static void filelayout_read_call_done(struct rpc_task *task, void *data)
> @@ -435,8 +436,9 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
> 			&wdata->res.seq_res,
> 			task))
> 		return;
> -	nfs4_set_rw_stateid(&wdata->args.stateid, wdata->args.context,
> -			wdata->args.lock_context, FMODE_WRITE);
> +	if (nfs4_set_rw_stateid(&wdata->args.stateid, wdata->args.context,
> +			wdata->args.lock_context, FMODE_WRITE))

Shouldn’t this have an '== -EIO’ test, just like the read case?

> +		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
> }
> 
> static void filelayout_write_call_done(struct rpc_task *task, void *data)
> -- 
> 1.8.3.1
> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

