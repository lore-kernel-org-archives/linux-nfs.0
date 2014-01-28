Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:44704 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755537AbaA1X2I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jan 2014 18:28:08 -0500
Received: by mail-ie0-f173.google.com with SMTP id e14so1336696iej.18
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jan 2014 15:28:07 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/1] NFSv4.1 free slot before resending I/O to MDS
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1390950074-7245-2-git-send-email-andros@netapp.com>
Date: Tue, 28 Jan 2014 18:28:06 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <3E87C7B9-82D2-493F-B4CE-BC163A3EB4CA@primarydata.com>
References: <1390950074-7245-1-git-send-email-andros@netapp.com> <1390950074-7245-2-git-send-email-andros@netapp.com>
To: Adamson William Andros <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On Jan 28, 2014, at 18:01, <andros@netapp.com> <andros@netapp.com> wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> Free an allocated slot from nfs41_wake_and_assign_slot prior to rpc_exit.
> Prevents a state_manager hang when draining a data server session.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/nfs4filelayout.c | 6 ++++++
> fs/nfs/nfs4session.c    | 1 +
> 2 files changed, 7 insertions(+)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 03fd8be..9611999 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -314,6 +314,9 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
> 	if (filelayout_reset_to_mds(rdata->header->lseg)) {
> 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
> 		filelayout_reset_read(rdata);
> +		if (rdata->res.seq_res.sr_slot != NULL)
> +			nfs4_free_slot(&rdata->ds_clp->cl_session->fc_slot_table,
> +					rdata->res.seq_res.sr_slot);
> 		rpc_exit(task, 0);
> 		return;
> 	}
> @@ -425,6 +428,9 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
> 	if (filelayout_reset_to_mds(wdata->header->lseg)) {
> 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
> 		filelayout_reset_write(wdata);
> +		if (wdata->res.seq_res.sr_slot != NULL)
> +			nfs4_free_slot(&wdata->ds_clp->cl_session->fc_slot_table,
> +					wdata->res.seq_res.sr_slot);
> 		rpc_exit(task, 0);
> 		return;
> 	}
> diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
> index cf883c7..5226846 100644
> --- a/fs/nfs/nfs4session.c
> +++ b/fs/nfs/nfs4session.c
> @@ -98,6 +98,7 @@ void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
> 	dprintk("%s: slotid %u highest_used_slotid %u\n", __func__,
> 		slotid, tbl->highest_used_slotid);
> }
> +EXPORT_SYMBOL_GPL(nfs4_free_slot);
> 
> static struct nfs4_slot *nfs4_new_slot(struct nfs4_slot_table  *tbl,
> 		u32 slotid, u32 seq_init, gfp_t gfp_mask)

OK, this fix makes a lot more sense to me.

However, since rpc_exit() will trigger a call to the rpc_call_ops->rpc_call_done(), then perhaps a better alternative would be to have filelayout_read_call_done() and filelayout_write_call_done() call nfs41_sequence_done() if the test for NFS_IOHDR_REDO succeeds? Otherwise, it looks as if we still have the potential for a leak.

--
Trond Myklebust
Linux NFS client maintainer

