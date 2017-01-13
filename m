Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26770 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdAMTIu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 14:08:50 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] NFS: Detect unreachable NFS/RDMA servers more reliably
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1484328444.5628.1.camel@primarydata.com>
Date: Fri, 13 Jan 2017 14:08:39 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B88C991D-855B-4F08-B0B9-D63DF8168DA1@oracle.com>
References: <20161216164108.7060.93683.stgit@manet.1015granger.net> <1484242710.4686.1.camel@primarydata.com> <A08E9DCC-B3A3-4ABF-9704-167AB18081DE@oracle.com> <62E20A87-D0C8-4AEA-89B1-902B48E9EE02@primarydata.com> <83F23535-5ACD-41DA-B8D0-05A34AB4821F@oracle.com> <1484328444.5628.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 13, 2017, at 12:27 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-01-13 at 10:13 -0500, Chuck Lever wrote:
>>> On Jan 12, 2017, at 5:15 PM, Trond Myklebust <trondmy@primarydata.c
>>> om> wrote:
>>> 
>>>> 
>>>> On Jan 12, 2017, at 12:42, Chuck Lever <chuck.lever@oracle.com>
>>>> wrote:
>>>> 
>>>> 
>>>>> On Jan 12, 2017, at 12:38 PM, Trond Myklebust <trondmy@primaryd
>>>>> ata.com> wrote:
>>>>> 
>>>>> On Fri, 2016-12-16 at 11:48 -0500, Chuck Lever wrote:
>>>>>> Current NFS clients rely on connection loss to determine when
>>>>>> to
>>>>>> retransmit. In particular, for protocols like NFSv4, clients
>>>>>> no
>>>>>> longer rely on RPC timeouts to drive retransmission: NFSv4
>>>>>> servers
>>>>>> are required to terminate a connection when they need聽聽a
>>>>>> client to
>>>>>> retransmit pending RPCs.
>>>>>> 
>>>>>> When a server is no longer reachable, either because it has
>>>>>> crashed
>>>>>> or because the network path has broken, the server cannot
>>>>>> actively
>>>>>> terminate a connection. Thus NFS clients depend on transport-
>>>>>> level
>>>>>> keepalive to determine when a connection must be replaced and
>>>>>> pending RPCs retransmitted.
>>>>>> 
>>>>>> However, RDMA RC connections do not have a native keepalive
>>>>>> mechanism. If an NFS/RDMA server crashes after a client has
>>>>>> sent
>>>>>> RPCs successfully (an RC ACK has been received for all OTW
>>>>>> RDMA
>>>>>> requests), there is no way for the client to know the
>>>>>> connection is
>>>>>> moribund.
>>>>>> 
>>>>>> In addition, new RDMA requests are subject to the RPC-over-
>>>>>> RDMA
>>>>>> credit limit. If the client has consumed all granted credits
>>>>>> with
>>>>>> NFS traffic, it is not allowed to send another RDMA request
>>>>>> until
>>>>>> the server replies. Thus it has no way to send a true
>>>>>> keepalive when
>>>>>> the workload has already consumed all credits with pending
>>>>>> RPCs.
>>>>>> 
>>>>>> To address this, we reserve one RPC-over-RDMA credit that may
>>>>>> be
>>>>>> used only for an NFS NULL. A periodic RPC ping is done on
>>>>>> transports
>>>>>> whenever there are outstanding RPCs.
>>>>>> 
>>>>>> The purpose of this ping is to drive traffic regularly on
>>>>>> each
>>>>>> connection to force the transport layer to disconnect it if
>>>>>> it is no
>>>>>> longer viable. Some RDMA operations are fully offloaded to
>>>>>> the HCA,
>>>>>> and can be successful even if the remote host has crashed.
>>>>>> Thus an
>>>>>> operation that requires that the server is responsive is used
>>>>>> for
>>>>>> the ping.
>>>>>> 
>>>>>> This implementation re-uses existing generic RPC
>>>>>> infrastructure to
>>>>>> form each NULL Call. An rpc_clnt context must be available to
>>>>>> start
>>>>>> an RPC. Thus a generic keepalive mechanism is introduced so
>>>>>> that
>>>>>> both an rpc_clnt and an rpc_xprt is available to perform the
>>>>>> ping.
>>>>>> 
>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>> ---
>>>>>> 
>>>>>> Before sending this for internal testing, I'd like to hear
>>>>>> comments
>>>>>> on this approach. It's a little more churn than I had hoped
>>>>>> for.
>>>>>> 
>>>>>> 
>>>>>> fs/nfs/nfs4client.c聽聽聽聽聽聽聽聽聽聽聽聽聽|聽聽聽聽1聽
>>>>>> include/linux/sunrpc/clnt.h聽聽聽聽聽|聽聽聽聽2 +
>>>>>> include/linux/sunrpc/sched.h聽聽聽聽|聽聽聽聽3 +
>>>>>> include/linux/sunrpc/xprt.h聽聽聽聽聽|聽聽聽聽1聽
>>>>>> net/sunrpc/clnt.c聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽|聽聽101
>>>>>> +++++++++++++++++++++++++++++++++++++++
>>>>>> net/sunrpc/sched.c聽聽聽聽聽聽聽聽聽聽聽聽聽聽|聽聽聽19 +++++++
>>>>>> net/sunrpc/xprt.c聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽|聽聽聽聽5 ++
>>>>>> net/sunrpc/xprtrdma/rpc_rdma.c聽聽|聽聽聽聽4 +-
>>>>>> net/sunrpc/xprtrdma/transport.c |聽聽聽13 +++++
>>>>>> 9 files changed, 148 insertions(+), 1 deletion(-)
>>>>>> 
>>>>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>>>>> index 074ac71..c5f5ce8 100644
>>>>>> --- a/fs/nfs/nfs4client.c
>>>>>> +++ b/fs/nfs/nfs4client.c
>>>>>> @@ -378,6 +378,7 @@ struct nfs_client
>>>>>> *nfs4_init_client(struct
>>>>>> nfs_client *clp,
>>>>>> 		error = nfs_create_rpc_client(clp, cl_init,
>>>>>> RPC_AUTH_UNIX);
>>>>>> 	if (error < 0)
>>>>>> 		goto error;
>>>>>> +	rpc_schedule_keepalive(clp->cl_rpcclient);
>>>>> 
>>>>> Why do we want to enable this for non-RDMA transports?
>>>>> Shouldn't this
>>>>> functionality be hidden in the RDMA client code, in the same
>>>>> way that
>>>>> the TCP keepalive is hidden in the socket code.
>>>> 
>>>> Sending a NULL request by re-using the normal RPC infrastructure
>>>> requires a struct rpc_clnt. Thus it has to be driven by an upper
>>>> layer context.
>>>> 
>>>> I'm open to suggestions.
>>>> 
>>> 
>>> Ideally we just want this to operate when there are outstanding RPC
>>> calls waiting for a reply, am I correct?
>>> 
>>> If so, perhaps we might have it triggered by a timer that is armed
>>> in xprt->ops->send_request() and disarmed in xprt->ops-
>>>> release_xprt()? It might then configure itself by looking in the
>>> xprt->recv list to find a hanging rpc_task and steal its rpc_client
>>> info.
>> 
>> Perhaps, but I was hoping to find a solution that did not add more
>> overhead (arming and disarming another timer) to the send_request
>> path.
>> 
>> __mod_timer can do an irqsave spinlock in some cases, for example.
>> 
>> This impacts all I/O on all transports to handle a case that will
>> be very rare.
>> 
>> We could mitigate the timer flapping by arming when xprt_transmit
>> finds the recv list empty before adding, and when xprt_lookup_rqst
>> empties the recv list.
>> 
> 
> Alternatively, how about just putting the trigger in xprt_timer (i.e.
> in the xprt->ops->timer() callback)? That requires no new timers, and
> it solves the problem of which rpc_clnt to use.

I was thinking of wiring something into call_timeout, but xprt_timer
looks like it would perform the same job, and there is already a
per-xprt hook. I'll have a look.

Is it safe to call rpc_run_task while transport_lock is held? If not
I can simply schedule a generic worker thread to construct and send
the NULL.


> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> ��N嫥叉靣笡y氊b瞂千v豝�)藓{.n�+壏{睗�"炟^n噐■��侂h櫒璀�&Ⅷ�瓽珴閔��(殠娸"濟���m��飦赇z罐枈帼f＂穐殘坢

--
Chuck Lever



