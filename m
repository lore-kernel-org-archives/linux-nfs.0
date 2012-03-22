Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35722 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030319Ab2CVNXx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 09:23:53 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2MDNViw005557
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 06:23:32 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 05/12] NFSv4.1: mark deviceid invalid on
 filelayout DS connection errors
Date: Thu, 22 Mar 2012 13:23:28 +0000
Message-ID: <7121AA63-B59E-40B4-85DF-96C763929E23@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
 <1332359184-1887-6-git-send-email-andros@netapp.com>
 <1332362355.12332.8.camel@lade.trondhjem.org>
In-Reply-To: <1332362355.12332.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 21, 2012, at 4:39 PM, Myklebust, Trond wrote:

> On Wed, 2012-03-21 at 15:46 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> This prevents the use of any layout for i/o that references the deviceid.
>> I/O is redirected through the MDS.
>> 
>> Redirect the unhandled failed I/O to the MDS without marking either the
>> layout or the deviceid invalid.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/nfs4filelayout.c |   65 ++++++++++++++++++++++++++++++++++------------
>> fs/nfs/nfs4filelayout.h |    6 ++++
>> 2 files changed, 54 insertions(+), 17 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 3802937..1f1be26 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -116,7 +116,7 @@ void filelayout_reset_read(struct rpc_task *task, struct nfs_read_data *data)
>> static int filelayout_async_handle_error(struct rpc_task *task,
>> 					 struct nfs4_state *state,
>> 					 struct nfs_client *clp,
>> -					 int *reset)
>> +					 unsigned long *reset)
>> {
>> 	struct nfs_server *mds_server = NFS_SERVER(state->inode);
>> 	struct nfs_client *mds_client = mds_server->nfs_client;
>> @@ -158,10 +158,23 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>> 		break;
>> 	case -NFS4ERR_RETRY_UNCACHED_REP:
>> 		break;
>> +	/* RPC connection errors */
>> +	case -ECONNREFUSED:
>> +	case -EHOSTDOWN:
>> +	case -EHOSTUNREACH:
>> +	case -ENETUNREACH:
>> +	case -EIO:
>> +	case -ETIMEDOUT:
>> +	case -EPIPE:
>> +		dprintk("%s DS connection error. Retry through MDS %d\n",
>> +			__func__, task->tk_status);
>> +		set_bit(NFS4_RESET_DEVICEID, reset);
>> +		set_bit(NFS4_RESET_TO_MDS, reset);
>> +		break;
>> 	default:
>> -		dprintk("%s DS error. Retry through MDS %d\n", __func__,
>> -			task->tk_status);
>> -		*reset = 1;
>> +		dprintk("%s Unhandled DS error. Retry through MDS %d\n",
>> +			__func__, task->tk_status);
>> +		set_bit(NFS4_RESET_TO_MDS, reset);
>> 		break;
>> 	}
>> out:
>> @@ -179,16 +192,22 @@ wait_on_recovery:
>> static int filelayout_read_done_cb(struct rpc_task *task,
>> 				struct nfs_read_data *data)
>> {
>> -	int reset = 0;
>> +	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
>> +	unsigned long reset = 0;
>> 
>> 	dprintk("%s DS read\n", __func__);
>> 
>> 	if (filelayout_async_handle_error(task, data->args.context->state,
>> 					  data->ds_clp, &reset) == -EAGAIN) {
>> -		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
>> -			__func__, data->ds_clp, data->ds_clp->cl_session);
>> -		if (reset)
>> +
>> +		dprintk("%s reset 0x%lx ds_clp %p session %p\n", __func__,
>> +			reset, data->ds_clp, data->ds_clp->cl_session);
>> +
>> +		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
>> 			filelayout_reset_read(task, data);
>> +			if (test_bit(NFS4_RESET_DEVICEID, &reset))
>> +				filelayout_mark_devid_invalid(devid);
> 
> Is there any reason why we shouldn't just do the
> filelayout_mark_devid_invalid() within filelayout_async_handle_error()
> instead of having the caller do it?

We would have to pass in the lseg argument.

> 
> That should also enable us to get rid of the whole 'reset' argument and
> replace it with a return value != 0 && != -EAGAIN.

We would need to pass in the operation because READ/WRITE/COMMIT call different reset functions.

I chose the 'reset' argument method instead of passing in the operation because I thought it cleaner to keep the per operation logic in the per operation rpc functions instead of having a switch(operation) statement in the async handler for each group of errors.

> 
>> +		}
>> 		rpc_restart_call_prepare(task);
> 
> This can probably also be done inside filelayout_async_handle_error(),
> BTW.

COMMIT does not call rpc_restart_call_prepare on reset  or invalid deviceid errors because we want the release function to fail with a verifier mismatch.

So it's up to you: I could move all the per operation logic into the async handler by passing in the operation and using it to dereferencing the tk_callback to get the lseg and other needed parameters - then moving the code from the done_cb routines into the async handler under a switch(operation) for both the default reset to mds and for the invalid deviced.

-->Andy

> 
>> 		return -EAGAIN;
>> 	}
>> @@ -260,14 +279,20 @@ static void filelayout_read_release(void *data)
>> static int filelayout_write_done_cb(struct rpc_task *task,
>> 				struct nfs_write_data *data)
>> {
>> -	int reset = 0;
>> +	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
>> +	unsigned long reset = 0;
>> 
>> 	if (filelayout_async_handle_error(task, data->args.context->state,
>> 					  data->ds_clp, &reset) == -EAGAIN) {
>> -		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
>> -			__func__, data->ds_clp, data->ds_clp->cl_session);
>> -		if (reset)
>> +
>> +		dprintk("%s reset 0x%lx ds_clp %p session %p\n", __func__,
>> +			reset, data->ds_clp, data->ds_clp->cl_session);
>> +
>> +		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
>> 			filelayout_reset_write(task, data);
>> +			if (test_bit(NFS4_RESET_DEVICEID, &reset))
>> +				filelayout_mark_devid_invalid(devid);
>> +		}
>> 		rpc_restart_call_prepare(task);
>> 		return -EAGAIN;
>> 	}
>> @@ -290,16 +315,22 @@ static void prepare_to_resend_writes(struct nfs_write_data *data)
>> static int filelayout_commit_done_cb(struct rpc_task *task,
>> 				     struct nfs_write_data *data)
>> {
>> -	int reset = 0;
>> +	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
>> +	unsigned long reset = 0;
>> 
>> 	if (filelayout_async_handle_error(task, data->args.context->state,
>> 					  data->ds_clp, &reset) == -EAGAIN) {
>> -		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
>> -			__func__, data->ds_clp, data->ds_clp->cl_session);
>> -		if (reset)
>> +
>> +		dprintk("%s reset 0x%lx ds_clp %p session %p\n", __func__,
>> +			reset, data->ds_clp, data->ds_clp->cl_session);
>> +
>> +		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
>> 			prepare_to_resend_writes(data);
>> -		else
>> +			if (test_bit(NFS4_RESET_DEVICEID, &reset))
>> +				filelayout_mark_devid_invalid(devid);
>> +		} else {
>> 			rpc_restart_call_prepare(task);
>> +		}
>> 		return -EAGAIN;
>> 	}
>> 
>> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
>> index b54b389..08b667a 100644
>> --- a/fs/nfs/nfs4filelayout.h
>> +++ b/fs/nfs/nfs4filelayout.h
>> @@ -41,6 +41,12 @@
>> #define NFS4_PNFS_MAX_STRIPE_CNT 4096
>> #define NFS4_PNFS_MAX_MULTI_CNT  256 /* 256 fit into a u8 stripe_index */
>> 
>> +/* internal use */
>> +enum nfs4_fl_reset_state {
>> +	NFS4_RESET_TO_MDS = 0,
>> +	NFS4_RESET_DEVICEID,
>> +};
>> +
>> enum stripetype4 {
>> 	STRIPE_SPARSE = 1,
>> 	STRIPE_DENSE = 2
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

