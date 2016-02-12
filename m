Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48837 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbcBLReO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 12:34:14 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH RFC] sunrpc: Advertise maximum backchannel payload size
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtRyoeM6LtE5xFn5_GaNxHppQKYaR4e8-nrGCc4c_4X_8Q@mail.gmail.com>
Date: Fri, 12 Feb 2016 12:34:02 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <17C72DCB-C653-4590-A3B6-3C13D1E04B34@oracle.com>
References: <20160212161758.32662.73404.stgit@manet.1015granger.net> <CAHQdGtRyoeM6LtE5xFn5_GaNxHppQKYaR4e8-nrGCc4c_4X_8Q@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 12, 2016, at 12:27 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> On Fri, Feb 12, 2016 at 11:52 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> RPC-over-RDMA Version One transports have a limit on how large
>> a backward direction RPC (backchannel) message can be. Ensure
>> that the NFSv4.x CREATE_SESSION operation advertises the
>> correct value to servers.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> This patch makes the client advertise the maximum size of a
>> backchannel RPC message, which is 996 bytes with the current RDMA
>> transport implementation.
>> 
>> I wanted to propose this patch for v4.6, but it breaks
>> Linux-to-Linux NFSv4.1 over RDMA. When attempting a mount, the Linux
>> client reports this in its log:
>> 
>> NFS: state manager: lease expired failed on NFSv4 server klimt-ib with error 525
>> NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
>> 
>> Then the mount command hangs (interruptibly).
> 
> Agreed: We should have nfs4_handle_reclaim_lease_error() call
> nfs_mark_client_ready() on all fatal errors during session
> initialisation (i.e. as long as we're still in
> NFS_CS_SESSION_INITING).
> 
>> On the Linux server, CREATE_SESSION calls check_backchannel_attrs()
>> which checks the maxreq_sz and maxresp_sz on the backchannel and
>> returns NFS4ERR_TOOSMALL because it wants maxreq_sz to be larger
>> than 1044 bytes.
>> 
>> [ The client could do a better job of recovering, perhaps. Should it
>>  fall back to NFSv4.0 if vers= was not specified, and otherwise
>>  have mount exit with an error code? ]
>> 
>> We have:
>> 
>> #define NFSD_CB_MAX_REQ_SZ      ((NFS4_enc_cb_recall_sz + \
>>                                 RPC_MAX_HEADER_WITH_AUTH) * sizeof(__be32))
>> 
>> NFS4_enc_cb_recall_sz is 51 and RPC_MAX_HEADER_WITH_AUTH is 210.
>> 
>> The comment in check_backchannel_attrs() says:
>> 
>> /*
>> * These RPC_MAX_HEADER macros are overkill, especially since we
>> * don't even do gss on the backchannel yet.  But this is still
>> * less than 1k.  Tighten up this estimate in the unlikely event
>> * it turns out to be a problem for some client:
>> */
>> 
>> It seems that "still less than 1k" is not strictly true.
>> 
>> To address this, a new minimum could be chosen that assumes that
>> RPC_AUTH_GSS is not going to be used for now.
>> 
>> Thoughts?
> 
> Why make this a transport variable? It seems more appropriate to just
> have it be a per-transport function.

I assume you are talking about the addition of the
max_bc_payload field to struct rpc_xprt. Sure, I
can add another method to rpc_xprt_ops instead,
and have rpc_max_bc_payload invoke that.


>> fs/nfs/nfs4proc.c               |   10 ++++++----
>> include/linux/sunrpc/clnt.h     |    1 +
>> include/linux/sunrpc/xprt.h     |    1 +
>> net/sunrpc/clnt.c               |   15 +++++++++++++++
>> net/sunrpc/xprtrdma/transport.c |    1 +
>> net/sunrpc/xprtsock.c           |    4 ++++
>> 6 files changed, 28 insertions(+), 4 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 4bfc33a..a0e2cda 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -7295,9 +7295,11 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
>>  * always set csa_cachethis to FALSE because the current implementation
>>  * of the back channel DRC only supports caching the CB_SEQUENCE operation.
>>  */
>> -static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
>> +static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args,
>> +                                   struct rpc_clnt *clnt)
>> {
>>        unsigned int max_rqst_sz, max_resp_sz;
>> +       unsigned int max_bc_payload = rpc_max_bc_payload(clnt);
>> 
>>        max_rqst_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxwrite_overhead;
>>        max_resp_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxread_overhead;
>> @@ -7315,8 +7317,8 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
>>                args->fc_attrs.max_ops, args->fc_attrs.max_reqs);
>> 
>>        /* Back channel attributes */
>> -       args->bc_attrs.max_rqst_sz = PAGE_SIZE;
>> -       args->bc_attrs.max_resp_sz = PAGE_SIZE;
>> +       args->bc_attrs.max_rqst_sz = max_bc_payload;
>> +       args->bc_attrs.max_resp_sz = max_bc_payload;
>>        args->bc_attrs.max_resp_sz_cached = 0;
>>        args->bc_attrs.max_ops = NFS4_MAX_BACK_CHANNEL_OPS;
>>        args->bc_attrs.max_reqs = 1;
>> @@ -7420,7 +7422,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
>>        };
>>        int status;
>> 
>> -       nfs4_init_channel_attrs(&args);
>> +       nfs4_init_channel_attrs(&args, clp->cl_rpcclient);
>>        args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
>> 
>>        status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>> index 131032f..1cad92e 100644
>> --- a/include/linux/sunrpc/clnt.h
>> +++ b/include/linux/sunrpc/clnt.h
>> @@ -175,6 +175,7 @@ void                rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
>> int            rpc_protocol(struct rpc_clnt *);
>> struct net *   rpc_net_ns(struct rpc_clnt *);
>> size_t         rpc_max_payload(struct rpc_clnt *);
>> +size_t         rpc_max_bc_payload(struct rpc_clnt *);
>> unsigned long  rpc_get_timeout(struct rpc_clnt *clnt);
>> void           rpc_force_rebind(struct rpc_clnt *);
>> size_t         rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>> index 69ef5b3..d32c319 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -179,6 +179,7 @@ struct rpc_xprt {
>> 
>>        size_t                  max_payload;    /* largest RPC payload size,
>>                                                   in bytes */
>> +       size_t                  max_bc_payload; /* max bytes per bc payload */
>>        unsigned int            tsh_size;       /* size of transport specific
>>                                                   header */
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index b7f2104..ac3dbde 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1335,6 +1335,21 @@ size_t rpc_max_payload(struct rpc_clnt *clnt)
>> EXPORT_SYMBOL_GPL(rpc_max_payload);
>> 
>> /**
>> + * rpc_max_bc_payload - Get maximum backchannel payload size, in bytes
>> + * @clnt: RPC client to query
>> + */
>> +size_t rpc_max_bc_payload(struct rpc_clnt *clnt)
>> +{
>> +       size_t ret;
>> +
>> +       rcu_read_lock();
>> +       ret = rcu_dereference(clnt->cl_xprt)->max_bc_payload;
>> +       rcu_read_unlock();
>> +       return ret;
>> +}
>> +EXPORT_SYMBOL_GPL(rpc_max_bc_payload);
>> +
>> +/**
>>  * rpc_get_timeout - Get timeout for transport in units of HZ
>>  * @clnt: RPC client to query
>>  */
>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>> index b1b009f..06fe152 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -402,6 +402,7 @@ xprt_setup_rdma(struct xprt_create *args)
>>        xprt->max_payload <<= PAGE_SHIFT;
>>        dprintk("RPC:       %s: transport data payload maximum: %zu bytes\n",
>>                __func__, xprt->max_payload);
>> +       xprt->max_bc_payload = cdata.inline_rsize - RPCRDMA_HDRLEN_MIN;
>> 
>>        if (!try_module_get(THIS_MODULE))
>>                goto out4;
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index fde2138..910e192 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -2781,6 +2781,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>>        xprt->prot = 0;
>>        xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>>        xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
>> +       xprt->max_bc_payload = PAGE_SIZE;
>> 
>>        xprt->bind_timeout = XS_BIND_TO;
>>        xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>> @@ -2852,6 +2853,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>>        xprt->tsh_size = 0;
>>        /* XXX: header size can vary due to auth type, IPv6, etc. */
>>        xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
>> +       xprt->max_bc_payload = PAGE_SIZE;
>> 
>>        xprt->bind_timeout = XS_BIND_TO;
>>        xprt->reestablish_timeout = XS_UDP_REEST_TO;
>> @@ -2931,6 +2933,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>>        xprt->prot = IPPROTO_TCP;
>>        xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>>        xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
>> +       xprt->max_bc_payload = PAGE_SIZE;
>> 
>>        xprt->bind_timeout = XS_BIND_TO;
>>        xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>> @@ -3000,6 +3003,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>>        xprt->prot = IPPROTO_TCP;
>>        xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>>        xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
>> +       xprt->max_bc_payload = PAGE_SIZE;
>>        xprt->timeout = &xs_tcp_default_timeout;
>> 
>>        /* backchannel */
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




