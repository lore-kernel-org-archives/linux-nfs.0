Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50909 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdALRmN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 12:42:13 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] NFS: Detect unreachable NFS/RDMA servers more reliably
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1484242710.4686.1.camel@primarydata.com>
Date: Thu, 12 Jan 2017 12:42:06 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A08E9DCC-B3A3-4ABF-9704-167AB18081DE@oracle.com>
References: <20161216164108.7060.93683.stgit@manet.1015granger.net> <1484242710.4686.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 12, 2017, at 12:38 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2016-12-16 at 11:48 -0500, Chuck Lever wrote:
>> Current NFS clients rely on connection loss to determine when to
>> retransmit. In particular, for protocols like NFSv4, clients no
>> longer rely on RPC timeouts to drive retransmission: NFSv4 servers
>> are required to terminate a connection when they need  a client to
>> retransmit pending RPCs.
>> 
>> When a server is no longer reachable, either because it has crashed
>> or because the network path has broken, the server cannot actively
>> terminate a connection. Thus NFS clients depend on transport-level
>> keepalive to determine when a connection must be replaced and
>> pending RPCs retransmitted.
>> 
>> However, RDMA RC connections do not have a native keepalive
>> mechanism. If an NFS/RDMA server crashes after a client has sent
>> RPCs successfully (an RC ACK has been received for all OTW RDMA
>> requests), there is no way for the client to know the connection is
>> moribund.
>> 
>> In addition, new RDMA requests are subject to the RPC-over-RDMA
>> credit limit. If the client has consumed all granted credits with
>> NFS traffic, it is not allowed to send another RDMA request until
>> the server replies. Thus it has no way to send a true keepalive when
>> the workload has already consumed all credits with pending RPCs.
>> 
>> To address this, we reserve one RPC-over-RDMA credit that may be
>> used only for an NFS NULL. A periodic RPC ping is done on transports
>> whenever there are outstanding RPCs.
>> 
>> The purpose of this ping is to drive traffic regularly on each
>> connection to force the transport layer to disconnect it if it is no
>> longer viable. Some RDMA operations are fully offloaded to the HCA,
>> and can be successful even if the remote host has crashed. Thus an
>> operation that requires that the server is responsive is used for
>> the ping.
>> 
>> This implementation re-uses existing generic RPC infrastructure to
>> form each NULL Call. An rpc_clnt context must be available to start
>> an RPC. Thus a generic keepalive mechanism is introduced so that
>> both an rpc_clnt and an rpc_xprt is available to perform the ping.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Before sending this for internal testing, I'd like to hear comments
>> on this approach. It's a little more churn than I had hoped for.
>> 
>> 
>>  fs/nfs/nfs4client.c             |    1 
>>  include/linux/sunrpc/clnt.h     |    2 +
>>  include/linux/sunrpc/sched.h    |    3 +
>>  include/linux/sunrpc/xprt.h     |    1 
>>  net/sunrpc/clnt.c               |  101
>> +++++++++++++++++++++++++++++++++++++++
>>  net/sunrpc/sched.c              |   19 +++++++
>>  net/sunrpc/xprt.c               |    5 ++
>>  net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +-
>>  net/sunrpc/xprtrdma/transport.c |   13 +++++
>>  9 files changed, 148 insertions(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index 074ac71..c5f5ce8 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -378,6 +378,7 @@ struct nfs_client *nfs4_init_client(struct
>> nfs_client *clp,
>>  		error = nfs_create_rpc_client(clp, cl_init,
>> RPC_AUTH_UNIX);
>>  	if (error < 0)
>>  		goto error;
>> +	rpc_schedule_keepalive(clp->cl_rpcclient);
> 
> Why do we want to enable this for non-RDMA transports? Shouldn't this
> functionality be hidden in the RDMA client code, in the same way that
> the TCP keepalive is hidden in the socket code.

Sending a NULL request by re-using the normal RPC infrastructure
requires a struct rpc_clnt. Thus it has to be driven by an upper
layer context.

I'm open to suggestions.


--
Chuck Lever



