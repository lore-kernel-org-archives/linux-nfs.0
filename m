Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:25459 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751007AbdALWPN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 17:15:13 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] NFS: Detect unreachable NFS/RDMA servers more reliably
Date: Thu, 12 Jan 2017 22:15:05 +0000
Message-ID: <62E20A87-D0C8-4AEA-89B1-902B48E9EE02@primarydata.com>
References: <20161216164108.7060.93683.stgit@manet.1015granger.net>
 <1484242710.4686.1.camel@primarydata.com>
 <A08E9DCC-B3A3-4ABF-9704-167AB18081DE@oracle.com>
In-Reply-To: <A08E9DCC-B3A3-4ABF-9704-167AB18081DE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 12, 2017, at 12:42, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
>=20
>> On Jan 12, 2017, at 12:38 PM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>>=20
>> On Fri, 2016-12-16 at 11:48 -0500, Chuck Lever wrote:
>>> Current NFS clients rely on connection loss to determine when to
>>> retransmit. In particular, for protocols like NFSv4, clients no
>>> longer rely on RPC timeouts to drive retransmission: NFSv4 servers
>>> are required to terminate a connection when they need  a client to
>>> retransmit pending RPCs.
>>>=20
>>> When a server is no longer reachable, either because it has crashed
>>> or because the network path has broken, the server cannot actively
>>> terminate a connection. Thus NFS clients depend on transport-level
>>> keepalive to determine when a connection must be replaced and
>>> pending RPCs retransmitted.
>>>=20
>>> However, RDMA RC connections do not have a native keepalive
>>> mechanism. If an NFS/RDMA server crashes after a client has sent
>>> RPCs successfully (an RC ACK has been received for all OTW RDMA
>>> requests), there is no way for the client to know the connection is
>>> moribund.
>>>=20
>>> In addition, new RDMA requests are subject to the RPC-over-RDMA
>>> credit limit. If the client has consumed all granted credits with
>>> NFS traffic, it is not allowed to send another RDMA request until
>>> the server replies. Thus it has no way to send a true keepalive when
>>> the workload has already consumed all credits with pending RPCs.
>>>=20
>>> To address this, we reserve one RPC-over-RDMA credit that may be
>>> used only for an NFS NULL. A periodic RPC ping is done on transports
>>> whenever there are outstanding RPCs.
>>>=20
>>> The purpose of this ping is to drive traffic regularly on each
>>> connection to force the transport layer to disconnect it if it is no
>>> longer viable. Some RDMA operations are fully offloaded to the HCA,
>>> and can be successful even if the remote host has crashed. Thus an
>>> operation that requires that the server is responsive is used for
>>> the ping.
>>>=20
>>> This implementation re-uses existing generic RPC infrastructure to
>>> form each NULL Call. An rpc_clnt context must be available to start
>>> an RPC. Thus a generic keepalive mechanism is introduced so that
>>> both an rpc_clnt and an rpc_xprt is available to perform the ping.
>>>=20
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>=20
>>> Before sending this for internal testing, I'd like to hear comments
>>> on this approach. It's a little more churn than I had hoped for.
>>>=20
>>>=20
>>> fs/nfs/nfs4client.c             |    1=20
>>> include/linux/sunrpc/clnt.h     |    2 +
>>> include/linux/sunrpc/sched.h    |    3 +
>>> include/linux/sunrpc/xprt.h     |    1=20
>>> net/sunrpc/clnt.c               |  101
>>> +++++++++++++++++++++++++++++++++++++++
>>> net/sunrpc/sched.c              |   19 +++++++
>>> net/sunrpc/xprt.c               |    5 ++
>>> net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +-
>>> net/sunrpc/xprtrdma/transport.c |   13 +++++
>>> 9 files changed, 148 insertions(+), 1 deletion(-)
>>>=20
>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>> index 074ac71..c5f5ce8 100644
>>> --- a/fs/nfs/nfs4client.c
>>> +++ b/fs/nfs/nfs4client.c
>>> @@ -378,6 +378,7 @@ struct nfs_client *nfs4_init_client(struct
>>> nfs_client *clp,
>>> =09=09error =3D nfs_create_rpc_client(clp, cl_init,
>>> RPC_AUTH_UNIX);
>>> =09if (error < 0)
>>> =09=09goto error;
>>> +=09rpc_schedule_keepalive(clp->cl_rpcclient);
>>=20
>> Why do we want to enable this for non-RDMA transports? Shouldn't this
>> functionality be hidden in the RDMA client code, in the same way that
>> the TCP keepalive is hidden in the socket code.
>=20
> Sending a NULL request by re-using the normal RPC infrastructure
> requires a struct rpc_clnt. Thus it has to be driven by an upper
> layer context.
>=20
> I'm open to suggestions.
>=20

Ideally we just want this to operate when there are outstanding RPC calls w=
aiting for a reply, am I correct?

If so, perhaps we might have it triggersd by a timer that is armed in xprt-=
>ops->send_request() and disarmed in xprt->ops->release_xprt()? It might th=
en configure itself by looking in the xprt->recv list to find a hanging rpc=
_task and steal its rpc_client info.

Cheers
  Trond

