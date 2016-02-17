Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21960 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160998AbcBQPUE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 10:20:04 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH] xprtrdma: rpcrdma_bc_receive_call() should init rq_private_buf.len
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56C48EC9.2080304@Netapp.com>
Date: Wed, 17 Feb 2016 10:19:59 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FDCF275D-FCBE-4A5B-A6F7-1FCF6618C2B7@oracle.com>
References: <20160215152040.22738.95129.stgit@manet.1015granger.net> <56C48EC9.2080304@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 17, 2016, at 10:16 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> Hi Chuck,
> 
> On 02/15/2016 10:23 AM, Chuck Lever wrote:
>> Some NFSv4.1 OPEN requests were hanging waiting for the NFS server
>> to finish recalling delegations. Turns out that each NFSv4.1 CB
>> request on RDMA gets a GARBAGE_ARGS reply from the Linux client.
>> 
>> Commit 756b9b37cfb2e3dc added a line in bc_svc_process that
>> overwrites the incoming rq_rcv_buf's length with the value in
>> rq_private_buf.len. But rpcrdma_bc_receive_call() does not invoke
>> xprt_complete_bc_request(), thus rq_private_buf.len is not
>> initialized. svc_process_common() is invoked with a zero-length
>> RPC message, and fails.
>> 
>> Fixes: 756b9b37cfb2e3dc ('SUNRPC: Fix callback channel')
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Hi Anna-
>> 
>> Commit 756b9b37cfb2e3dc in v4.5-rc1 introduced a behavior
>> regression for NFSv4.1-over-RDMA. Would it be possible to merge
>> this bug fix into 4.5-rc ?
>> 
>> 
>> net/sunrpc/xprtrdma/backchannel.c |    2 ++
>> 1 file changed, 2 insertions(+)
>> 
>> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
>> index cc1251d..2dcd764 100644
>> --- a/net/sunrpc/xprtrdma/backchannel.c
>> +++ b/net/sunrpc/xprtrdma/backchannel.c
>> @@ -341,6 +341,8 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
>> 	rqst->rq_reply_bytes_recvd = 0;
>> 	rqst->rq_bytes_sent = 0;
>> 	rqst->rq_xid = headerp->rm_xid;
>> +
> 
> nit: Any reason for the extra newline?

Yes: xprt_complete_bc_request sets the private buffer length
and sets RPC_BC_PA_IN_USE. So I want to group these two
lines in their own paragraph just to "document" that they
belong together and are not related to the lines above
them.


>> +	rqst->rq_private_buf.len = size;
> 
> This patch looks okay to me, and I'll make sure it's included in the next rc pull request Trond sends.

Thanks!


> Thanks,
> Anna
> 
>> 	set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
>> 
>> 	buf = &rqst->rq_rcv_buf;

--
Chuck Lever




