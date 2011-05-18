Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50393 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933692Ab1ERTNw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2011 15:13:52 -0400
Received: by pzk9 with SMTP id 9so842444pzk.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2011 12:13:52 -0700 (PDT)
In-Reply-To: <20110518103918.5489879e@corrin.poochiereds.net>
References: <1305059200-412-1-git-send-email-andros@netapp.com>
	<1305059200-412-2-git-send-email-andros@netapp.com>
	<20110518103918.5489879e@corrin.poochiereds.net>
Date: Wed, 18 May 2011 15:13:51 -0400
Message-ID: <BANLkTinKs+5HorS=otxjEv8g8xWJpUoK8w@mail.gmail.com>
Subject: Re: [RFC V2 1/1] SUNRPC: dynamic rpc_slot allocator
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 18, 2011 at 10:39 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Tue, 10 May 2011 16:26:40 -0400
> andros@netapp.com wrote:
>
>> From: Andy Adamson <andros@netapp.com>
>>
>> Add a dynamic rpc slot allocator at the beginning of the RPC call_transmit
>> state.  The allocator is triggered by a new rpc_xprt bit XPRT_ADD_SLOT.
>>
>> The dynamic slot allocator uses GFP_NOWAIT and will return without
>> allocating a slot if GFP_NOWAIT allocation fails. This is OK because the
>> XPRT_ADD_SLOT bit will be set the next time UDP calls xprt_alloc, or the
>> next time the TCP write_space callback is called.
>>
>> XXX Is this really true? XXX
>> Change the rpc_xprt allocation, including the intial slot table entries, to
>> GFP_ATOMIC as it can be called in the file system writeout path.
>>
>> In the UDP and BC_TCP case, this means we no longer allocate slots we don't
>> need. In the TCP case, this means we follow the TCP window size up to
>> RPC_MAX_SLOT_TABLE.
>>
>> Current transport slot allocation:
>>
>> RDMA: No change, allocate xprt_rdma_slot_table_entries slots in
>>       xprt_setup_rdma.
>>
>> UDP:  Changed: Start with RPC_MIN_SLOT_TABLE slots and dynamically add
>>       up to xprt_udp_slot_table_entries slots.
>>       Allocate RPC_MIN_SLOT_TABLE in xs_setup_udp. Add a set_add_slot
>>       operation so that if xprt_alloc can not find a slot on the free list,
>>       and max_reqs < xprt_udp_slot_table_entries, XPRT_ADD_SLOT is set and
>>       a slot is dynamically allocated.
>>
>> TCP:  Changed: Start with xprt_tcp_slot_table_entries slots and dynamically
>>       add up to the TCP window size or (upper bound) RPC_MAX_SLOT_TABLE slots.
>>       Allocate xprt_tcp_slot_table_entries in xs_setup_tcp. Set XPRT_ADD_SLOT
>>       in xs_tcp_write_space so that we hookup TCP congestion feedback into
>>       the dynamic rpc_slot allocation so that the RPC layer can fully utilize
>>       the negotiated TCP window.
>>
>
> So UDP will start with a very small number of slots and grow
> dynamically, but TCP will start with a relatively large number and grow
> up to a hard fixed limit once those are exhausted. I'm not sure I
> understand the reasoning behind the difference there. Why not start TCP
> with an equally small number of fixed slots.

The current code can - by setting the
/proc/sys/sunrpc/tcp_slot_table_entries low.   I did this because the
same code will service NFSv4.1 where the client will still need to ask
for a reasonable number of slots because that is all the server might
give out. The server is in control of the number of session slots, so
the server will need to notice when the client is using all the slots
and hand out some more.

>
> Also, why have a maximum at all for the TCP case? If we have the
> ability to send another frame, I see no need to hold back.

Fair enough.

-->Andy
>
>> BC_TCP: Changed: The back channel will not use more than two slots.
>>       Allocate RPC_MIN_SLOT_TABLE slots instead of xprt_tcp_slot_table_entries
>>       slots in xs_setup_bc_tcp.
>>
>> Signed-off-by: Andy Adamson <andros@netap.com>
>> ---
>>  include/linux/sunrpc/xprt.h |    8 ++++
>>  net/sunrpc/clnt.c           |    4 ++
>>  net/sunrpc/xprt.c           |   90 +++++++++++++++++++++++++++++++++++++------
>>  net/sunrpc/xprtsock.c       |   34 +++++++++++++++-
>>  4 files changed, 121 insertions(+), 15 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>> index a0f998c..6c3c78e 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -115,6 +115,7 @@ struct rpc_xprt_ops {
>>       void            (*release_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
>>       void            (*rpcbind)(struct rpc_task *task);
>>       void            (*set_port)(struct rpc_xprt *xprt, unsigned short port);
>> +     void            (*set_add_slot)(struct rpc_xprt *xprt);
>>       void            (*connect)(struct rpc_task *task);
>>       void *          (*buf_alloc)(struct rpc_task *task, size_t size);
>>       void            (*buf_free)(void *buffer);
>> @@ -307,6 +308,7 @@ void                      xprt_release_rqst_cong(struct rpc_task *task);
>>  void                 xprt_disconnect_done(struct rpc_xprt *xprt);
>>  void                 xprt_force_disconnect(struct rpc_xprt *xprt);
>>  void                 xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
>> +void                 xprt_nowait_add_slot(struct rpc_xprt *xprt);
>>
>>  /*
>>   * Reserved bit positions in xprt->state
>> @@ -321,6 +323,7 @@ void                      xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
>>  #define XPRT_CONNECTION_ABORT        (7)
>>  #define XPRT_CONNECTION_CLOSE        (8)
>>  #define XPRT_INITIALIZED     (9)
>> +#define XPRT_ADD_SLOT                (10)
>>
>>  static inline void xprt_set_connected(struct rpc_xprt *xprt)
>>  {
>> @@ -391,6 +394,11 @@ static inline int xprt_test_and_set_binding(struct rpc_xprt *xprt)
>>       return test_and_set_bit(XPRT_BINDING, &xprt->state);
>>  }
>>
>> +static inline void xprt_set_add_slot(struct rpc_xprt *xprt)
>> +{
>> +     set_bit(XPRT_ADD_SLOT, &xprt->state);
>> +}
>> +
>>  #endif /* __KERNEL__*/
>>
>>  #endif /* _LINUX_SUNRPC_XPRT_H */
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 8d83f9d..82e69fe 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1276,6 +1276,10 @@ call_transmit(struct rpc_task *task)
>>       task->tk_action = call_status;
>>       if (task->tk_status < 0)
>>               return;
>> +
>> +     /* Add a slot if XPRT_ADD_SLOT is set */
>> +     xprt_nowait_add_slot(task->tk_xprt);
>> +
>>       task->tk_status = xprt_prepare_transmit(task);
>>       if (task->tk_status != 0)
>>               return;
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index ce5eb68..6d11d95 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -942,6 +942,8 @@ static void xprt_alloc_slot(struct rpc_task *task)
>>               xprt_request_init(task, xprt);
>>               return;
>>       }
>> +     if (xprt->ops->set_add_slot)
>> +             xprt->ops->set_add_slot(xprt);
>>       dprintk("RPC:       waiting for request slot\n");
>>       task->tk_status = -EAGAIN;
>>       task->tk_timeout = 0;
>> @@ -958,24 +960,94 @@ static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
>>       spin_unlock(&xprt->reserve_lock);
>>  }
>>
>> -struct rpc_xprt *xprt_alloc(struct net *net, int size, int max_req)
>> +
>> +/*
>> + * Initial slot table allocation called only at rpc_xprt allocation.
>> + * No need to take the xprt->reserve_lock.
>> + * GFP_ATOMIC used because an RPC can be triggered in the writeout path.
>> + *
>> + */
>> +static int xprt_alloc_slot_table_entries(struct rpc_xprt *xprt, int num_req)
>> +{
>> +     struct rpc_rqst *req;
>> +     int i;
>> +
>> +     for (i = 0; i < num_req; i++) {
>> +             req = kzalloc(sizeof(*req), GFP_ATOMIC);
>> +             if (!req)
>> +                     return -ENOMEM;
>> +             list_add(&req->rq_list, &xprt->free);
>> +     }
>
> Do we really need GFP_ATOMIC here? We don't use it today with the
> fixed-size slot table and this is just called when allocating the xprt
> (aka mount time), right? I think GFP_KERNEL might be more appropriate
> here.

If I understood correctly, Trond gave an argument for this being in
the fs writeout path.

>
>> +     dprintk("<-- %s mempool_alloc %d reqs\n", __func__,
>> +             xprt->max_reqs);
>                ^^^^^^^^^^^^^
>        nit: not really a mempool anymore...

:) oops! I'll change the printk


>
>> +     return 0;
>> +}
>> +
>> +static void
>> +xprt_free_slot_table_entries(struct rpc_xprt *xprt)
>> +{
>> +     struct rpc_rqst *req;
>> +     int cnt = 0;
>> +
>> +     while (!list_empty(&xprt->free)) {
>> +             req = list_entry(xprt->free.next, struct rpc_rqst, rq_list);
>> +             list_del(&req->rq_list);
>> +             kfree(req);
>> +             cnt++;
>> +     }
>> +     dprintk("<-- %s freed %d reqs\n", __func__, cnt);
>> +}
>> +
>> +/*
>> + * Dynamic rpc_slot allocator. GFP_NOWAIT will not cause rpciod to sleep.
>> + * Return NULL if allocation can't be serviced immediately.
>> + * Triggered by write_space callback.
>> + */
>> +void
>> +xprt_nowait_add_slot(struct rpc_xprt *xprt)
>> +{
>> +     struct rpc_rqst *req;
>> +
>> +     if (!test_and_clear_bit(XPRT_ADD_SLOT, &xprt->state))
>> +             return;
>> +
>> +     if (xprt->max_reqs == RPC_MAX_SLOT_TABLE) {
>> +             dprintk("RPC    %s: %p has RPC_MAX_SLOT_TABLE %d slots\n",
>> +                     __func__, xprt, RPC_MAX_SLOT_TABLE);
>> +             return;
>> +     }
>> +     req = kzalloc(sizeof(*req), GFP_NOWAIT);
>> +     if (!req)
>> +             return;
>> +     spin_lock(&xprt->reserve_lock);
>> +     list_add(&req->rq_list, &xprt->free);
>> +     xprt->max_reqs += 1;
>> +     spin_unlock(&xprt->reserve_lock);
>> +
>> +     dprintk("RPC    %s added rpc_slot to transport %p max_req %d\n",
>> +             __func__, xprt, xprt->max_reqs);
>> +}
>> +
>> +struct rpc_xprt *xprt_alloc(struct net *net, int size, int num_req)
>>  {
>>       struct rpc_xprt *xprt;
>>
>> -     xprt = kzalloc(size, GFP_KERNEL);
>> +     xprt = kzalloc(size, GFP_ATOMIC);
>                ^^^^^^^^^^^^^
>        Again, this is called at mount time primarily. I don't see any
>        need for GFP_ATOMIC. If we're that low on memory, it's probably
>        best to just fail the mount.
>
>>       if (xprt == NULL)
>>               goto out;
>>       atomic_set(&xprt->count, 1);
>>
>> -     xprt->max_reqs = max_req;
>> -     xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
>> -     if (xprt->slot == NULL)
>> +     xprt->max_reqs = num_req;
>> +     /* allocate slots and place them on the free list */
>> +     INIT_LIST_HEAD(&xprt->free);
>> +     if (xprt_alloc_slot_table_entries(xprt, num_req) != 0)
>>               goto out_free;
>>
>>       xprt->xprt_net = get_net(net);
>>       return xprt;
>>
>>  out_free:
>> +     xprt_free_slot_table_entries(xprt);
>>       kfree(xprt);
>>  out:
>>       return NULL;
>> @@ -985,7 +1057,7 @@ EXPORT_SYMBOL_GPL(xprt_alloc);
>>  void xprt_free(struct rpc_xprt *xprt)
>>  {
>>       put_net(xprt->xprt_net);
>> -     kfree(xprt->slot);
>> +     xprt_free_slot_table_entries(xprt);
>>       kfree(xprt);
>>  }
>>  EXPORT_SYMBOL_GPL(xprt_free);
>> @@ -1081,7 +1153,6 @@ void xprt_release(struct rpc_task *task)
>>  struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
>>  {
>>       struct rpc_xprt *xprt;
>> -     struct rpc_rqst *req;
>>       struct xprt_class *t;
>>
>>       spin_lock(&xprt_list_lock);
>> @@ -1109,7 +1180,6 @@ found:
>>       spin_lock_init(&xprt->transport_lock);
>>       spin_lock_init(&xprt->reserve_lock);
>>
>> -     INIT_LIST_HEAD(&xprt->free);
>>       INIT_LIST_HEAD(&xprt->recv);
>>  #if defined(CONFIG_NFS_V4_1)
>>       spin_lock_init(&xprt->bc_pa_lock);
>> @@ -1132,10 +1202,6 @@ found:
>>       rpc_init_wait_queue(&xprt->resend, "xprt_resend");
>>       rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
>>
>> -     /* initialize free list */
>> -     for (req = &xprt->slot[xprt->max_reqs-1]; req >= &xprt->slot[0]; req--)
>> -             list_add(&req->rq_list, &xprt->free);
>> -
>>       xprt_init_xid(xprt);
>>
>>       dprintk("RPC:       created transport %p with %u slots\n", xprt,
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index bf005d3..310c73a 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -1405,6 +1405,29 @@ static void xs_write_space(struct sock *sk)
>>       xprt_write_space(xprt);
>>  }
>>
>> +/*
>> + * called from xs_tcp_write_space to dynamically add a slot
>> + * in response to the TCP window size.
>> + */
>> +static void xs_tcp_add_slot(struct sock *sk)
>> +{
>> +     struct rpc_xprt *xprt;
>> +
>> +     if (unlikely(!(xprt = xprt_from_sock(sk))))
>> +                return;
>> +
>> +     dprintk("%s xprt %p\n", __func__, xprt);
>> +     xprt_set_add_slot(xprt);
>> +}
>> +
>> +/* set_add_slot xprt operation for UDP */
>> +static void xs_udp_set_add_slot(struct rpc_xprt *xprt)
>> +{
>> +     dprintk("--> %s xprt %p\n", __func__, xprt);
>> +     if (xprt->max_reqs < xprt_udp_slot_table_entries)
>> +             xprt_set_add_slot(xprt);
>> +}
>> +
>>  /**
>>   * xs_udp_write_space - callback invoked when socket buffer space
>>   *                             becomes available
>> @@ -1417,6 +1440,7 @@ static void xs_write_space(struct sock *sk)
>>   */
>>  static void xs_udp_write_space(struct sock *sk)
>>  {
>> +     dprintk("--> %s\n", __func__);
>>       read_lock_bh(&sk->sk_callback_lock);
>>
>>       /* from net/core/sock.c:sock_def_write_space */
>> @@ -1438,11 +1462,14 @@ static void xs_udp_write_space(struct sock *sk)
>>   */
>>  static void xs_tcp_write_space(struct sock *sk)
>>  {
>> +     dprintk("--> %s\n", __func__);
>>       read_lock_bh(&sk->sk_callback_lock);
>>
>>       /* from net/core/stream.c:sk_stream_write_space */
>> -     if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
>> +     if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
>> +             xs_tcp_add_slot(sk);
>>               xs_write_space(sk);
>> +     }
>>
>
> I guess I don't quite understand how this works...
>
> It looks like whenever we get a sk_write_space callback that is bigger
> than the sk_stream_min_wspace threshold, we allow for the addition of
> one more dynamic slot.
>
> Ok, so expanding those inlines give us:
>
>    (sk->sk_sndbuf - sk->sk_wmem_queued) >= (sk->sk_wmem_queued >> 1)
>
> So the test is whether there's enough send buffer space left to hold
> half of what we already have queued.
>
> It seems like we could allow for more slots to be open than just one in
> many of those cases.

Since we don't remove rpc_slots when the TCP window shrinks, and since
the TCP window can bounce from larger to smaller before it settles
down to a more or less steady state, I think it's best to approach the
addition of rpc_slots conservatively and add one slot per write_space
callback.

>
>>       read_unlock_bh(&sk->sk_callback_lock);
>>  }
>> @@ -2095,6 +2122,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
>>       .release_xprt           = xprt_release_xprt_cong,
>>       .rpcbind                = rpcb_getport_async,
>>       .set_port               = xs_set_port,
>> +     .set_add_slot           = xs_udp_set_add_slot,
>>       .connect                = xs_connect,
>>       .buf_alloc              = rpc_malloc,
>>       .buf_free               = rpc_free,
>> @@ -2216,7 +2244,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
>>       struct sock_xprt *transport;
>>       struct rpc_xprt *ret;
>>
>> -     xprt = xs_setup_xprt(args, xprt_udp_slot_table_entries);
>> +     xprt = xs_setup_xprt(args, RPC_MIN_SLOT_TABLE);
>>       if (IS_ERR(xprt))
>>               return xprt;
>>       transport = container_of(xprt, struct sock_xprt, xprt);
>> @@ -2371,7 +2399,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>>                */
>>                return args->bc_xprt->xpt_bc_xprt;
>>       }
>> -     xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
>> +     xprt = xs_setup_xprt(args, RPC_MIN_SLOT_TABLE);
>>       if (IS_ERR(xprt))
>>               return xprt;
>>       transport = container_of(xprt, struct sock_xprt, xprt);
>
>
> --
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
