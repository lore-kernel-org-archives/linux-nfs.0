Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23425 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbbLAOgv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2015 09:36:51 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v2 6/7] xprtrdma: Add class for RDMA backwards direction transport
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <565DA2CA.5090507@talpey.com>
Date: Tue, 1 Dec 2015 09:36:47 -0500
Cc: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <170ADDEE-DBC2-4481-BD98-8DB0ADF94877@oracle.com>
References: <20151130222141.13029.98664.stgit@klimt.1015granger.net> <20151130222513.13029.52447.stgit@klimt.1015granger.net> <565DA2CA.5090507@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 1, 2015, at 8:38 AM, Tom Talpey <tom@talpey.com> wrote:
> 
> On 11/30/2015 5:25 PM, Chuck Lever wrote:
>> To support the server-side of an NFSv4.1 backchannel on RDMA
>> connections, add a transport class that enables backward
>> direction messages on an existing forward channel connection.
>> 
> 
>> +static void *
>> +xprt_rdma_bc_allocate(struct rpc_task *task, size_t size)
>> +{
>> +	struct rpc_rqst *rqst = task->tk_rqstp;
>> +	struct svc_rdma_op_ctxt *ctxt;
>> +	struct svcxprt_rdma *rdma;
>> +	struct svc_xprt *sxprt;
>> +	struct page *page;
>> +
>> +	if (size > PAGE_SIZE) {
>> +		WARN_ONCE(1, "failed to handle buffer allocation (size %zu)\n",
>> +			  size);
> 
> You may want to add more context to that rather cryptic string, at
> least the function name.
> 
> Also, it's not exactly "failed to handle", it's an invalid size. Why
> would this ever happen? Why even log it?
> 
> 
> 
>> +static int
>> +rpcrdma_bc_send_request(struct svcxprt_rdma *rdma, struct rpc_rqst *rqst)
>> +{
> ...
>> +
>> +drop_connection:
>> +	dprintk("Failed to send backchannel call\n");
> 
> Ditto on the prefix / function context.
> 
> And also...
> 
>> +	dprintk("%s: sending request with xid: %08x\n",
>> +		__func__, be32_to_cpu(rqst->rq_xid));
> ...
>> +	dprintk("RPC:       %s: xprt %p\n", __func__, xprt);
> 
> The format strings for many of the dprintk's are somewhat inconsistent.
> Some start with "RPC", some with the function name, and some (in other
> patches of this series) with "svcrdma". Confusing, and perhaps hard to
> pick out of the log.

They do follow a convention: “RPC:      “ is used on the client
side when there is no rpc_task::tk_pid available. “svcrdma” is
used on the server everywhere.

The dprintk changes here were a bit cursory, so I will go back and
review them more carefully.

--
Chuck Lever




