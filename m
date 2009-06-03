From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 03/10] nfsd41: sunrpc: Added rpc server-side backchannel
 handling
Date: Wed, 03 Jun 2009 11:44:28 +0300
Message-ID: <4A2637EC.5000603@panasas.com>
References: <273FE88A07F5D445824060902F70034405FE3129@SACMVEXC1-PRD.hq.netapp.com> <4A24AFD9.40106@panasas.com> <273FE88A07F5D445824060902F70034402030375@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"Adamson, Andy" <William.Adamson@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:8136
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753253AbZFCIoe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2009 04:44:34 -0400
In-Reply-To: <273FE88A07F5D445824060902F70034402030375-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 03, 2009, 9:45 +0300, "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com> wrote:
> We can do that, but it will need to be a subset of the patches since a
> number of them are re-implementing the server backchannel callbacks as
> asynchronous RPCs.  That will require rebasing to bruce's 'for-2.6.31'. 
> Is a subset of the patches useful for the development branch?

If there are squashme's applicable to the development branch, then yes.
I'd like to keep them as close as possible, but don't bother too much
about that since 2.6.31 is right around the corner.

Benny

> 
> - ricardo
> 
> 
> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@panasas.com]
> Sent: Mon 6/1/2009 9:51 PM
> To: Labiaga, Ricardo
> Cc: Trond Myklebust; Adamson, Andy; J. Bruce Fields; pnfs@linux-nfs.org;
> linux-nfs@vger.kernel.org
> Subject: Re: [pnfs] [RFC 03/10] nfsd41: sunrpc: Added rpc server-side
> backchannel handling
> 
> On Jun. 02, 2009, 3:33 +0300, "Labiaga, Ricardo"
> <Ricardo.Labiaga@netapp.com> wrote:
>> Trond, Bruce,
>>
>> Alexandros has coded a number of patches that address the issues raised
>> here by Trond.  Do you want the fixes squashed into the original patch
>> or do you want them submitted separately.
> 
> Can you please also send the unsquashed cleanup patches separately.
> In the given time frame before the upcoming Bakeathon I'm afraid
> we'd want to queue the squashed series for 2.6.31 in the
> nfs{,d}41-for-2.6.31 branches and commit the cleanup patches onto
> our 2.6.30 based development branches.
> 
> Benny
> 
>>
>> Thanks,
>>
>> - ricardo
>>
>>> -----Original Message-----
>>> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
>>> Sent: Thursday, April 30, 2009 5:05 PM
>>> To: Benny Halevy
>>> Cc: Adamson, Andy; J. Bruce Fields; pnfs@linux-nfs.org; linux-
>>> nfs@vger.kernel.org
>>> Subject: Re: [pnfs] [RFC 03/10] nfsd41: sunrpc: Added rpc server-side
>>> backchannel handling
>>>
>>> On Fri, 2009-05-01 at 02:05 +0300, Benny Halevy wrote:
>>>> From: Rahul Iyer <iyer@netapp.com>
>>>>
>>>> FIXME: bhalevy: write up commit message
>>>>
>>>> Signed-off-by: Rahul Iyer <iyer@netapp.com>
>>>> Signed-off-by: Mike Sager <sager@netapp.com>
>>>> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>
>>>> When the call direction is a reply, copy the xid and call direction
>> into
>>> the
>>>> req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header
>> returns
>>>> rpc_garbage.
>>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> [get rid of CONFIG_NFSD_V4_1]
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>>>  include/linux/sunrpc/clnt.h    |    1 +
>>>>  include/linux/sunrpc/svcsock.h |    1 +
>>>>  include/linux/sunrpc/xprt.h    |    2 +
>>>>  net/sunrpc/clnt.c              |    1 +
>>>>  net/sunrpc/svcsock.c           |   68 ++++++++++-
>>>>  net/sunrpc/xprt.c              |   41 ++++++-
>>>>  net/sunrpc/xprtsock.c          |  278
>>> +++++++++++++++++++++++++++++++++++++++-
>>>>  7 files changed, 381 insertions(+), 11 deletions(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/clnt.h
>> b/include/linux/sunrpc/clnt.h
>>>> index c39a210..cf9a8ec 100644
>>>> --- a/include/linux/sunrpc/clnt.h
>>>> +++ b/include/linux/sunrpc/clnt.h
>>>> @@ -110,6 +110,7 @@ struct rpc_create_args {
>>>>     rpc_authflavor_t        authflavor;
>>>>     unsigned long           flags;
>>>>     char                    *client_name;
>>>> +   struct svc_sock         *bc_sock;       /* NFSv4.1 backchannel
>> */
>>>>  };
>>>>
>>>>  /* Values for "flags" field */
>>>> diff --git a/include/linux/sunrpc/svcsock.h
>>> b/include/linux/sunrpc/svcsock.h
>>>> index 8271631..19228f4 100644
>>>> --- a/include/linux/sunrpc/svcsock.h
>>>> +++ b/include/linux/sunrpc/svcsock.h
>>>> @@ -28,6 +28,7 @@ struct svc_sock {
>>>>     /* private TCP part */
>>>>     u32                     sk_reclen;      /* length of record */
>>>>     u32                     sk_tcplen;      /* current read length
>> */
>>>> +   struct rpc_xprt        *sk_bc_xprt;     /* NFSv4.1 backchannel
>> xprt
>>> */
>>>>  };
>>>>
>>>>  /*
>>>> diff --git a/include/linux/sunrpc/xprt.h
>> b/include/linux/sunrpc/xprt.h
>>>> index 1758d9f..063a6a7 100644
>>>> --- a/include/linux/sunrpc/xprt.h
>>>> +++ b/include/linux/sunrpc/xprt.h
>>>> @@ -174,6 +174,7 @@ struct rpc_xprt {
>>>>     spinlock_t              reserve_lock;   /* lock slot table */
>>>>     u32                     xid;            /* Next XID value to use
>> */
>>>>     struct rpc_task *       snd_task;       /* Task blocked in send
>> */
>>>> +   struct svc_sock         *bc_sock;       /* NFSv4.1 backchannel
>> */
>>>>     struct list_head        recv;
>>>>
>>>>     struct {
>>>> @@ -197,6 +198,7 @@ struct xprt_create {
>>>>     struct sockaddr *       srcaddr;        /* optional local
>> address */
>>>>     struct sockaddr *       dstaddr;        /* remote peer address
>> */
>>>>     size_t                  addrlen;
>>>> +   struct svc_sock         *bc_sock;       /* NFSv4.1 backchannel
>> */
>>>>  };
>>>>
>>>>  struct xprt_class {
>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>> index 5abab09..3dc847f 100644
>>>> --- a/net/sunrpc/clnt.c
>>>> +++ b/net/sunrpc/clnt.c
>>>> @@ -266,6 +266,7 @@ struct rpc_clnt *rpc_create(struct
>> rpc_create_args
>>> *args)
>>>>             .srcaddr = args->saddress,
>>>>             .dstaddr = args->address,
>>>>             .addrlen = args->addrsize,
>>>> +           .bc_sock = args->bc_sock,
>>>>     };
>>>>     char servername[48];
>>>>
>>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>>> index 4e6d406..619764e 100644
>>>> --- a/net/sunrpc/svcsock.c
>>>> +++ b/net/sunrpc/svcsock.c
>>>> @@ -49,6 +49,7 @@
>>>>  #include <linux/sunrpc/msg_prot.h>
>>>>  #include <linux/sunrpc/svcsock.h>
>>>>  #include <linux/sunrpc/stats.h>
>>>> +#include <linux/sunrpc/xprt.h>
>>>>
>>>>  #define RPCDBG_FACILITY    RPCDBG_SVCXPRT
>>>>
>>>> @@ -825,6 +826,7 @@ static int svc_tcp_recvfrom(struct svc_rqst
>> *rqstp)
>>>>     int             len;
>>>>     struct kvec *vec;
>>>>     int pnum, vlen;
>>>> +   struct rpc_rqst *req = NULL;
>>>>
>>>>     dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
>>>>             svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
>>>> @@ -891,12 +893,65 @@ static int svc_tcp_recvfrom(struct svc_rqst
>>> *rqstp)
>>>>     len = svsk->sk_reclen;
>>>>     set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>>>>
>>>> +   /*
>>>> +    * We have enough data for the whole tcp record. Let's try and
>> read
>>> the
>>>> +    * first 8 bytes to get the xid and the call direction. We can
>> use
>>> this
>>>> +    * to figure out if this is a call or a reply to a callback. If
>>>> +    * sk_reclen is < 8 (xid and calldir), then this is a malformed
>>> packet.
>>>> +    * In that case, don't bother with the calldir and just read the
>>> data.
>>>> +    * It will be rejected in svc_process.
>>>> +    */
>>>> +
>>>>     vec = rqstp->rq_vec;
>>>>     vec[0] = rqstp->rq_arg.head[0];
>>>>     vlen = PAGE_SIZE;
>>>> +
>>>> +   if (len >= 8) {
>>>> +           u32 *p;
>>>> +           u32 xid;
>>>> +           u32 calldir;
>>>> +
>>>> +           len = svc_recvfrom(rqstp, vec, 1, 8);
>>>> +           if (len < 0)
>>>> +                   goto error;
>>>> +
>>>> +           p = (u32 *)rqstp->rq_arg.head[0].iov_base;
>>>> +           xid = *p++;
>>>> +           calldir = *p;
>>>> +
>>>> +           if (calldir) {
>>>> +                   /* REPLY */
>>>> +                   if (svsk->sk_bc_xprt)
>>>> +                           req = xprt_lookup_rqst(svsk->sk_bc_xprt,
>> xid);
>>>> +                   if (req) {
>>>> +                           memcpy(&req->rq_private_buf,
>> &req->rq_rcv_buf,
>>>> +                                   sizeof(struct xdr_buf));
>>>> +                           /* copy the xid and call direction */
>>>> +
>> memcpy(req->rq_private_buf.head[0].iov_base,
>>>> +                                   rqstp->rq_arg.head[0].iov_base,
>> 8);
>>>> +                           vec[0] = req->rq_private_buf.head[0];
>>>> +                   } else
>>>> +                           printk(KERN_NOTICE
>>>> +                                   "%s: Got unrecognized reply: "
>>>> +                                   "calldir 0x%x sk_bc_xprt %p xid
>> %08x\n",
>>>> +                                   __func__, ntohl(calldir),
>>>> +                                   svsk->sk_bc_xprt, xid);
>>>> +           }
>>>> +
>>>> +           if (!calldir || !req)
>>>> +                   vec[0] = rqstp->rq_arg.head[0];
>>>> +
>>>> +           vec[0].iov_base += 8;
>>>> +           vec[0].iov_len -= 8;
>>>> +           len = svsk->sk_reclen - 8;
>>>> +           vlen -= 8;
>>>> +   }
>>>> +
>>>>     pnum = 1;
>>>>     while (vlen < len) {
>>>> -           vec[pnum].iov_base =
>> page_address(rqstp->rq_pages[pnum]);
>>>> +           vec[pnum].iov_base = (req) ?
>>>> +                   page_address(req->rq_private_buf.pages[pnum -
>> 1]) :
>>>> +                   page_address(rqstp->rq_pages[pnum]);
>>>>             vec[pnum].iov_len = PAGE_SIZE;
>>>>             pnum++;
>>>>             vlen += PAGE_SIZE;
>>>> @@ -908,6 +963,16 @@ static int svc_tcp_recvfrom(struct svc_rqst
>> *rqstp)
>>>>     if (len < 0)
>>>>             goto error;
>>>>
>>>> +   /*
>>>> +    * Account for the 8 bytes we read earlier
>>>> +    */
>>>> +   len += 8;
>>>> +
>>>> +   if (req) {
>>>> +           xprt_complete_rqst(req->rq_task, len);
>>>> +           len = 0;
>>>> +           goto out;
>>>> +   }
>>>>     dprintk("svc: TCP complete record (%d bytes)\n", len);
>>>>     rqstp->rq_arg.len = len;
>>>>     rqstp->rq_arg.page_base = 0;
>>>> @@ -921,6 +986,7 @@ static int svc_tcp_recvfrom(struct svc_rqst
>> *rqstp)
>>>>     rqstp->rq_xprt_ctxt   = NULL;
>>>>     rqstp->rq_prot        = IPPROTO_TCP;
>>>>
>>>> +out:
>>>>     /* Reset TCP read info */
>>>>     svsk->sk_reclen = 0;
>>>>     svsk->sk_tcplen = 0;
>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>> index a0bfe53..03f175e 100644
>>>> --- a/net/sunrpc/xprt.c
>>>> +++ b/net/sunrpc/xprt.c
>>>> @@ -1015,6 +1015,27 @@ void xprt_release(struct rpc_task *task)
>>>>     spin_unlock(&xprt->reserve_lock);
>>>>  }
>>>>
>>>> +/*
>>>> + * The autoclose function for the back channel
>>>> + *
>>>> + * The callback channel should never close the channel,
>>>> + * let the forechannel do that.
>>>> + */
>>>> +static void bc_autoclose(struct work_struct *work)
>>>> +{
>>>> +   return;
>>>> +}
>>>> +
>>>> +
>>>> +/*
>>>> + * The autodisconnect routine for the back channel. We never
>> disconnect
>>>> + */
>>>> +static void
>>>> +bc_init_autodisconnect(unsigned long data)
>>>> +{
>>>> +   return;
>>>> +}
>>>> +
>>>>  /**
>>>>   * xprt_create_transport - create an RPC transport
>>>>   * @args: rpc transport creation arguments
>>>> @@ -1051,9 +1072,16 @@ found:
>>>>
>>>>     INIT_LIST_HEAD(&xprt->free);
>>>>     INIT_LIST_HEAD(&xprt->recv);
>>>> -   INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
>>>> -   setup_timer(&xprt->timer, xprt_init_autodisconnect,
>>>> -                   (unsigned long)xprt);
>>>> +   if (args->bc_sock) {
>>>> +           INIT_WORK(&xprt->task_cleanup, bc_autoclose);
>>>> +           setup_timer(&xprt->timer, bc_init_autodisconnect,
>>>> +                       (unsigned long)xprt);
>>> Hrmph... Why do you need dummy routines here?
>>>
>>>> +   } else {
>>>> +           INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
>>>> +           setup_timer(&xprt->timer, xprt_init_autodisconnect,
>>>> +                       (unsigned long)xprt);
>>>> +   }
>>>> +
>>>>     xprt->last_used = jiffies;
>>>>     xprt->cwnd = RPC_INITCWND;
>>>>     xprt->bind_index = 0;
>>>> @@ -1073,6 +1101,13 @@ found:
>>>>     dprintk("RPC:       created transport %p with %u slots\n", xprt,
>>>>                     xprt->max_reqs);
>>>>
>>>> +   /*
>>>> +    * Since we don't want connections for the backchannel, we set
>>>> +    * the xprt status to connected
>>>> +    */
>>>> +   if (args->bc_sock)
>>>> +           xprt_set_connected(xprt);
>>>> +
>>>>     return xprt;
>>>>  }
>>>>
>>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>>> index d40ff50..067d205 100644
>>>> --- a/net/sunrpc/xprtsock.c
>>>> +++ b/net/sunrpc/xprtsock.c
>>>> @@ -32,6 +32,7 @@
>>>>  #include <linux/tcp.h>
>>>>  #include <linux/sunrpc/clnt.h>
>>>>  #include <linux/sunrpc/sched.h>
>>>> +#include <linux/sunrpc/svcsock.h>
>>>>  #include <linux/sunrpc/xprtsock.h>
>>>>  #include <linux/file.h>
>>>>
>>>> @@ -1966,6 +1967,219 @@ static void xs_tcp_print_stats(struct
>> rpc_xprt
>>> *xprt, struct seq_file *seq)
>>>>                     xprt->stat.bklog_u);
>>>>  }
>>>>
>>>> +/*
>>>> + * The connect worker for the backchannel
>>>> + * This should never be called as we should never need to connect
>>>> + */
>>>> +static void bc_connect_worker(struct work_struct *work)
>>>> +{
>>>> +   BUG();
>>>> +}
>>>> +
>>>> +/*
>>>> + * The set_port routine of the rpc_xprt_ops. This is related to the
>>> portmapper
>>>> + * and should never be called
>>>> + */
>>>> +
>>>> +static void bc_set_port(struct rpc_xprt *xprt, unsigned short port)
>>>> +{
>>>> +   BUG();
>>>> +}
>>>> +
>>>> +/*
>>>> + * The connect routine for the backchannel rpc_xprt ops
>>>> + * Again, should never be called!
>>>> + */
>>>> +
>>>> +static void bc_connect(struct rpc_task *task)
>>>> +{
>>>> +   BUG();
>>>> +}
>>>> +
>>>> +struct rpc_buffer {
>>>> +   size_t  len;
>>>> +   char    data[];
>>>> +};
>>>> +/*
>>>> + * Allocate a bunch of pages for a scratch buffer for the rpc code.
>> The
>>> reason
>>>> + * we allocate pages instead doing a kmalloc like rpc_malloc is
>> because
>>> we want
>>>> + * to use the server side send routines.
>>>> + */
>>>> +void *bc_malloc(struct rpc_task *task, size_t size)
>>>> +{
>>>> +   struct page *page;
>>>> +   struct rpc_buffer *buf;
>>>> +
>>>> +   BUG_ON(size > PAGE_SIZE - sizeof(struct rpc_buffer));
>>>> +   page = alloc_page(GFP_KERNEL);
>>>> +
>>>> +   if (!page)
>>>> +           return NULL;
>>>> +
>>>> +   buf = page_address(page);
>>>> +   buf->len = PAGE_SIZE;
>>>> +
>>>> +   return buf->data;
>>>> +}
>>>> +
>>> __get_free_page()? Why can't you kmalloc() here?
>>>
>>>> +/*
>>>> + * Free the space allocated in the bc_alloc routine
>>>> + */
>>>> +void bc_free(void *buffer)
>>>> +{
>>>> +   struct rpc_buffer *buf;
>>>> +
>>>> +   if (!buffer)
>>>> +           return;
>>>> +
>>>> +   buf = container_of(buffer, struct rpc_buffer, data);
>>>> +   free_pages((unsigned long)buf, get_order(buf->len));
>>> This looks funky... Why can't you just call free_page()? You already
>>> know from bc_malloc() that this is an order 0 page allocation.
>>>
>>>> +}
>>>> +
>>>> +/*
>>>> + * Use the svc_sock to send the callback. Must be called with svsk-
>>>> sk_mutex
>>>> + * held. Borrows heavily from svc_tcp_sendto and
>> xs_tcp_semd_request.
>>>> + */
>>>> +static int bc_sendto(struct rpc_rqst *req)
>>>> +{
>>>> +   int total_len;
>>>> +   int len;
>>>> +   int size;
>>>> +   int result;
>>>> +   struct xdr_buf *xbufp = &req->rq_snd_buf;
>>>> +   struct page **pages = xbufp->pages;
>>>> +   unsigned int flags = MSG_MORE;
>>>> +   unsigned int pglen = xbufp->page_len;
>>>> +   size_t base = xbufp->page_base;
>>>> +   struct rpc_xprt *xprt = req->rq_xprt;
>>>> +   struct sock_xprt *transport =
>>>> +                           container_of(xprt, struct sock_xprt,
>> xprt);
>>>> +   struct socket *sock = transport->sock;
>>>> +
>>>> +   total_len = xbufp->len;
>>>> +
>>>> +   /*
>>>> +    * Set up the rpc header and record marker stuff
>>>> +    */
>>>> +   xs_encode_tcp_record_marker(xbufp);
>>>> +
>>>> +   /*
>>>> +    * The RPC message is divided into 3 pieces:
>>>> +    * - The header: This is what most of the smaller RPC messages
>>> consist
>>>> +    *   of. Often the whole message is in this.
>>>> +    *
>>>> +    *   - xdr->pages: This is a list of pages that contain data,
>> for
>>>> +    *   example in a write request or while using rpcsec gss
>>>> +    *
>>>> +    *   - The tail: This is the rest of the rpc message
>>>> +    *
>>>> +    *  First we send the header, then the pages and then finally
>> the
>>> tail.
>>>> +    *  The code borrows heavily from svc_sendto.
>>>> +    */
>>>> +
>>>> +   /*
>>>> +    * Send the head
>>>> +    */
>>>> +   if (total_len == xbufp->head[0].iov_len)
>>>> +           flags = 0;
>>>> +
>>>> +   len = sock->ops->sendpage(sock, virt_to_page(xbufp-
>>>> head[0].iov_base),
>>>> +                   (unsigned long)xbufp->head[0].iov_base &
>> ~PAGE_MASK,
>>>> +                   xbufp->head[0].iov_len, flags);
>>> Why do you need to do this? The head iovec is supposed to be reserved
>>> for kmalloc()ed memory, which cannot be used together with sendpage().
>>> Somebody, some day is going to mess up and try to put a kmalloced
>> buffer
>>> in here, and will wonder why the above doesn't work.
>>>
>>> If you are sending pages, then please put them in the page list part
>> of
>>> the xdr_buf. There is no rule that the RPC call _must_ have a non-zero
>>> head.
>>>
>>>> +
>>>> +   if (len != xbufp->head[0].iov_len)
>>>> +           goto out;
>>>> +
>>>> +   /*
>>>> +    * send page data
>>>> +    *
>>>> +    * Check the amount of data to be sent. If it is less than the
>>>> +    * remaining page, then send it else send the current page
>>>> +    */
>>>> +
>>>> +   size = PAGE_SIZE - base < pglen ? PAGE_SIZE - base : pglen;
>>>> +   while (pglen > 0) {
>>>> +           if (total_len == size)
>>>> +                   flags = 0;
>>>> +           result = sock->ops->sendpage(sock, *pages, base, size,
>> flags);
>>>> +           if (result > 0)
>>>> +                   len += result;
>>>> +           if (result != size)
>>>> +                   goto out;
>>>> +           total_len -= size;
>>>> +           pglen -= size;
>>>> +           size = PAGE_SIZE < pglen ? PAGE_SIZE : pglen;
>>>> +           base = 0;
>>>> +           pages++;
>>>> +   }
>>>> +   /*
>>>> +    * send tail
>>>> +    */
>>>> +   if (xbufp->tail[0].iov_len) {
>>>> +           result = sock->ops->sendpage(sock,
>>>> +                   xbufp->tail[0].iov_base,
>>>> +                   (unsigned long)xbufp->tail[0].iov_base &
>> ~PAGE_MASK,
>>>> +                   xbufp->tail[0].iov_len,
>>>> +                   0);
>>> Ditto.
>>>
>>>> +
>>>> +           if (result > 0)
>>>> +                   len += result;
>>>> +   }
>>>> +out:
>>>> +   if (len != xbufp->len)
>>>> +           printk(KERN_NOTICE "Error sending entire callback!\n");
>>>              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>> Then what? Shouldn't you be closing the connection here?
>>>
>>>> +
>>>> +   return len;
>>>> +}
>>>> +
>>>> +/*
>>>> + * The send routine. Borrows from svc_send
>>>> + */
>>>> +static int bc_send_request(struct rpc_task *task)
>>>> +{
>>>> +   struct rpc_rqst *req = task->tk_rqstp;
>>>> +   struct rpc_xprt *bc_xprt = req->rq_xprt;
>>>> +   struct svc_xprt *xprt;
>>>> +   struct svc_sock         *svsk;
>>>> +   u32                     len;
>>>> +
>>>> +   dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
>>>> +   /*
>>>> +    * Get the server socket associated with this callback xprt
>>>> +    */
>>>> +   svsk = bc_xprt->bc_sock;
>>>> +   xprt = &svsk->sk_xprt;
>>>> +
>>>> +   mutex_lock(&xprt->xpt_mutex);
>>>           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>>
>>> Eh? What's this, in which patch is it defined, and why is it at all
>>> needed?
>>>
>>>> +   if (test_bit(XPT_DEAD, &xprt->xpt_flags))
>>>                        ^^^^^^^^^^^^^^^^^^^^^^^^^^
>>> Where is this defined, and why is it needed? The xprt already has a
>>> connected/unconnected flag.
>>>
>>>> +           len = -ENOTCONN;
>>>> +   else
>>>> +           len = bc_sendto(req);
>>>> +   mutex_unlock(&xprt->xpt_mutex);
>>>> +
>>>> +   return 0;
>>>> +
>>>> +}
>>>> +
>>>> +/*
>>>> + * The close routine. Since this is client initiated, we do nothing
>>>> + */
>>>> +
>>>> +static void bc_close(struct rpc_xprt *xprt)
>>>> +{
>>>> +   return;
>>>> +}
>>>> +
>>>> +/*
>>>> + * The xprt destroy routine. Again, because this connection is
>> client
>>>> + * initiated, we do nothing
>>>> + */
>>>> +
>>>> +static void bc_destroy(struct rpc_xprt *xprt)
>>>> +{
>>>> +   return;
>>>> +}
>>>> +
>>>>  static struct rpc_xprt_ops xs_udp_ops = {
>>>>     .set_buffer_size        = xs_udp_set_buffer_size,
>>>>     .reserve_xprt           = xprt_reserve_xprt_cong,
>>>> @@ -1999,6 +2213,24 @@ static struct rpc_xprt_ops xs_tcp_ops = {
>>>>     .print_stats            = xs_tcp_print_stats,
>>>>  };
>>>>
>>>> +/*
>>>> + * The rpc_xprt_ops for the server backchannel
>>>> + */
>>>> +
>>>> +static struct rpc_xprt_ops bc_tcp_ops = {
>>>> +   .reserve_xprt           = xprt_reserve_xprt,
>>>> +   .release_xprt           = xprt_release_xprt,
>>>> +   .set_port               = bc_set_port,
>>>> +   .connect                = bc_connect,
>>>> +   .buf_alloc              = bc_malloc,
>>>> +   .buf_free               = bc_free,
>>>> +   .send_request           = bc_send_request,
>>>> +   .set_retrans_timeout    = xprt_set_retrans_timeout_def,
>>>> +   .close                  = bc_close,
>>>> +   .destroy                = bc_destroy,
>>>> +   .print_stats            = xs_tcp_print_stats,
>>>> +};
>>>> +
>>>>  static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
>>>>                                   unsigned int slot_table_size)
>>>>  {
>>>> @@ -2131,13 +2363,29 @@ static struct rpc_xprt *xs_setup_tcp(struct
>>> xprt_create *args)
>>>>     xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>>>>     xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
>>>>
>>>> -   xprt->bind_timeout = XS_BIND_TO;
>>>> -   xprt->connect_timeout = XS_TCP_CONN_TO;
>>>> -   xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>>>> -   xprt->idle_timeout = XS_IDLE_DISC_TO;
>>>> +   if (args->bc_sock) {
>>>> +           /* backchannel */
>>>> +           xprt_set_bound(xprt);
>>>> +           INIT_DELAYED_WORK(&transport->connect_worker,
>>>> +                             bc_connect_worker);
>>> Errm.... Is it really such a good idea to tell the RPC layer that it
>> can
>>> reconnect at any time using a routine that will BUG()?
>>>
>>>> +           xprt->bind_timeout = 0;
>>>> +           xprt->connect_timeout = 0;
>>>> +           xprt->reestablish_timeout = 0;
>>>> +           xprt->idle_timeout = (~0);
>>>>
>>>> -   xprt->ops = &xs_tcp_ops;
>>>> -   xprt->timeout = &xs_tcp_default_timeout;
>>>> +           /*
>>>> +            * The backchannel uses the same socket connection as
>> the
>>>> +            * forechannel
>>>> +            */
>>>> +           xprt->bc_sock = args->bc_sock;
>>>> +           xprt->bc_sock->sk_bc_xprt = xprt;
>>>> +           transport->sock = xprt->bc_sock->sk_sock;
>>>> +           transport->inet = xprt->bc_sock->sk_sk;
>>>> +
>>>> +           xprt->ops = &bc_tcp_ops;
>>>> +
>>>> +           goto next;
>>>> +   }
>>>>
>>>>     switch (addr->sa_family) {
>>>>     case AF_INET:
>>>> @@ -2145,13 +2393,29 @@ static struct rpc_xprt *xs_setup_tcp(struct
>>> xprt_create *args)
>>>>                     xprt_set_bound(xprt);
>>>>
>>>>             INIT_DELAYED_WORK(&transport->connect_worker,
>>> xs_tcp_connect_worker4);
>>>> -           xs_format_ipv4_peer_addresses(xprt, "tcp",
>> RPCBIND_NETID_TCP);
>>>>             break;
>>>>     case AF_INET6:
>>>>             if (((struct sockaddr_in6 *)addr)->sin6_port !=
>> htons(0))
>>>>                     xprt_set_bound(xprt);
>>>>
>>>>             INIT_DELAYED_WORK(&transport->connect_worker,
>>> xs_tcp_connect_worker6);
>>>> +           break;
>>>> +   }
>>>> +   xprt->bind_timeout = XS_BIND_TO;
>>>> +   xprt->connect_timeout = XS_TCP_CONN_TO;
>>>> +   xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>>>> +   xprt->idle_timeout = XS_IDLE_DISC_TO;
>>>> +
>>>> +   xprt->ops = &xs_tcp_ops;
>>>> +
>>>> +next:
>>>> +   xprt->timeout = &xs_tcp_default_timeout;
>>>> +
>>>> +   switch (addr->sa_family) {
>>> Why do we suddenly need 2 switch statements here?
>>>
>>>> +   case AF_INET:
>>>> +           xs_format_ipv4_peer_addresses(xprt, "tcp",
>> RPCBIND_NETID_TCP);
>>>> +           break;
>>>> +   case AF_INET6:
>>>>             xs_format_ipv6_peer_addresses(xprt, "tcp",
>> RPCBIND_NETID_TCP6);
>>>>             break;
>>>>     default:
>>>
>>> _______________________________________________
>>> pNFS mailing list
>>> pNFS@linux-nfs.org
>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
