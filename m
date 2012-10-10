Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38359 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756226Ab2JJTnQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Oct 2012 15:43:16 -0400
Received: from vmwexceht05-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9AJhFqH006872
	for <linux-nfs@vger.kernel.org>; Wed, 10 Oct 2012 12:43:15 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1	do not wake up all tasks on data server
 reset to MDS
Date: Wed, 10 Oct 2012 19:43:13 +0000
Message-ID: <7851A663D3BF5E41B9E166C2C7A421451030CF52@SACEXCMBX02-PRD.hq.netapp.com>
References: <1349817608-4730-1-git-send-email-andros@netapp.com>
 <1349817608-4730-2-git-send-email-andros@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091CE9D7@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9091CE9D7@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 10, 2012, at 2:06 PM, Myklebust, Trond wrote:

> On Tue, 2012-10-09 at 17:20 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> There is no advantage to waking up all rpc tasks on each data server disconnect
>> or invalid layout error.
>> 
>> For DS disconnect errors where the data server is reseting all I/O to the MDS,
>> tasks wakened from the fore channel slot table waitq are immediately reset
>> to use the MDS session, and do not request a data server session slot, and
>> so do not call nfs41_session_free_slot, and do not wake up the next task on
>> the data server session fore channel slot table wait queue.
>> 
>> Replace the call to rpc_wake_up which wakes up all tasks with a call to
>> rpc_wake_up_first in the filelayout I/O prepare routines for the case where
>> I/O is redirected to the MDS.
>> 
>> Share code with nfs4_check_drain_fc_complete.
> 
> This will still have false positive wakeups, though, since there is no
> connection to number of slots that are available.

I can't see that number of slots available is an issue. The Deviceid is bad due to a DS connection error.

case 1) DS Role:  All of the tasks are to be redirected to a (working) MDS session on another nfs_client. None of the disconnected DS session slots will be used, no reason to wait for a slot that will not be used.

case 2) MDS DS Role, and MDS is the DS's MDS:  No chance of recovery, as there is no working MDS to redirect to. Wait for a slot, don't wait for a slot, no difference.

case 3) MDS DS Role, and MDS is not the DS's MDS: Here is where this patch fails, and come to think of it, rpc_wake_up is the way to go. The disconnected session slot_table_waitq can contain both MDS and DS traffic. The MDS traffic is hard mounted and will fail (disconnected). So, having the DS tasks which can be redirected to a (working) MDS session wait behind failed hard mounted MDS tasks will not work as the hard mounted MDS tasks will retry forever starving the DS tasks, and we could end up with a bunch of DS tasks still on the disconnected session wait queue with all MDS tasks taking the slots.

My patch which calls rpc_wake_up_first in filelayout_read/write_prepare can also result in DS tasks being starved behind MDS hard mounted tasks as failed DS tasks give up their slot via the session code, and so MDS tasks could use all the slots and DS recovery will fail. 

This is why the rpc_wake_up call in filelayout_async_handle_error for the DS disconnect case is correct. It separates the DS from the MDS traffic guaranteeing all DS tasks will be redirected. The "churn" makes no difference in case 1 as all tasks will be redirected or in case 2 as no tasks will succeed.

So I vote for keeping the rpc_wake_up in the DS disconnect case.

-->Andy

> 
> How about rather just letting the session code drive the wakeups? I'm
> thinking something like the following patch:
> 
> 8<--------------------------------------------------------------
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index a525fde..df2474b 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -248,6 +248,7 @@ extern int nfs4_setup_sequence(const struct nfs_server *server,
> extern int nfs41_setup_sequence(struct nfs4_session *session,
> 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
> 		struct rpc_task *task);
> +extern void nfs41_sequence_free_slot(struct nfs4_sequence_res *res);
> extern void nfs4_destroy_session(struct nfs4_session *session);
> extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
> extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 52d8472..80aa19a 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -291,19 +291,20 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
> {
> 	struct nfs_read_data *rdata = data;
> 
> +	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
> +				&rdata->args.seq_args, &rdata->res.seq_res,
> +				task))
> +		return;
> +
> 	if (filelayout_reset_to_mds(rdata->header->lseg)) {
> 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
> 		filelayout_reset_read(rdata);
> +		nfs41_sequence_free_slot(&rdata->res.seq_res);
> 		rpc_exit(task, 0);
> 		return;
> 	}
> 	rdata->read_done_cb = filelayout_read_done_cb;
> 
> -	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
> -				&rdata->args.seq_args, &rdata->res.seq_res,
> -				task))
> -		return;
> -
> 	rpc_call_start(task);
> }
> 
> @@ -393,17 +394,18 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
> {
> 	struct nfs_write_data *wdata = data;
> 
> +	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
> +				&wdata->args.seq_args, &wdata->res.seq_res,
> +				task))
> +		return;
> +
> 	if (filelayout_reset_to_mds(wdata->header->lseg)) {
> 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
> 		filelayout_reset_write(wdata);
> +		nfs41_sequence_free_slot(&rdata->res.seq_res);
> 		rpc_exit(task, 0);
> 		return;
> 	}
> -	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
> -				&wdata->args.seq_args, &wdata->res.seq_res,
> -				task))
> -		return;
> -
> 	rpc_call_start(task);
> }
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 68b21d8..d186be2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -468,7 +468,7 @@ void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
> 	complete(&ses->bc_slot_table.complete);
> }
> 
> -static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
> +void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
> {
> 	struct nfs4_slot_table *tbl;
> 
> @@ -486,6 +486,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
> 	spin_unlock(&tbl->slot_tbl_lock);
> 	res->sr_slot = NULL;
> }
> +EXPORT_SYMBOL_GPL(nfs41_sequence_free_slot);
> 
> static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
> {
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

