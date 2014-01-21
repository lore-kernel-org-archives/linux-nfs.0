Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:46571 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbaAUKIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2014 05:08:07 -0500
MIME-Version: 1.0
In-Reply-To: <1390259843.2501.2.camel@leira.trondhjem.org>
References: <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn>
	<1390259843.2501.2.camel@leira.trondhjem.org>
Date: Tue, 21 Jan 2014 18:08:05 +0800
Message-ID: <CALrKORrZ3Kcuqc1RajQKkZcot0yiswh4VR_WuXHqfRTjn9oGQQ@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Allow one callback request to be received from
 two sk_buff
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: bfields@redhat.com, davem@davemloft.net, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014/1/21 Trond Myklebust <trond.myklebust@primarydata.com>:
> On Mon, 2014-01-20 at 14:59 +0800, shaobingqing wrote:
>> In current code, there only one struct rpc_rqst is prealloced. If one
>> callback request is received from two sk_buff, the xprt_alloc_bc_request
>> would be execute two times with the same transport->xid. The first time
>> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
>> bit of transport->tcp_flags will not be cleared. The second time
>> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
>> pointer will be returned, then xprt_force_disconnect occur. I think one
>> callback request can be allowed to be received from two sk_buff.
>>
>> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
>> ---
>>  net/sunrpc/xprtsock.c |   11 +++++++++--
>>  1 files changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index ee03d35..606950d 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -1271,8 +1271,13 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>>       struct sock_xprt *transport =
>>                               container_of(xprt, struct sock_xprt, xprt);
>>       struct rpc_rqst *req;
>> +     static struct rpc_rqst *req_partial;
>> +
>> +     if (req_partial == NULL)
>> +             req = xprt_alloc_bc_request(xprt);
>> +     else if (req_partial->rq_xid == transport->tcp_xid)
>> +             req = req_partial;
>
> What happens here if req_partial->rq_xid != transport->tcp_xid? AFAICS,
> req will be undefined. Either way, you cannot use a static variable for
> storage here: that isn't re-entrant.

Because metadata sever only have one slot for backchannel request,
req_partial->rq_xid == transport->tcp_xid always happens, if the callback
request just being splited in two sk_buffs. But req_partial->rq_xid !=
transport->tcp_xid may also happens in some special cases, such as
retransmission occurs?
If one callback request is splited in two sk_buffs, xs_tcp_read_callback
will be execute two times. The req_partial should be a static variable,
because  the second execution of xs_tcp_read_callback should use
the rpc_rqst allocated for the first execution, which saves information
copies from the first sk_buff.
I think perhaps the code should be modified like bellows:

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 606950d..02dbb82 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1273,10 +1273,14 @@ static inline int xs_tcp_read_callback(struct
rpc_xprt *xprt,
        struct rpc_rqst *req;
        static struct rpc_rqst *req_partial;

-       if (req_partial == NULL)
+       if (req_partial == NULL) {
                req = xprt_alloc_bc_request(xprt);
-       else if (req_partial->rq_xid == transport->tcp_xid)
+       } else if (req_partial->rq_xid == transport->tcp_xid) {
                req = req_partial;
+       } else {
+               xprt_free_bc_request(req_partial);
+               req = xprt_alloc_bc_request(xprt);
+       }

        if (req == NULL) {
                printk(KERN_WARNING "Callback slot table overflowed\n");
@@ -1303,8 +1307,9 @@ static inline int xs_tcp_read_callback(struct
rpc_xprt *xprt,
                list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
                spin_unlock(&bc_serv->sv_cb_lock);
                wake_up(&bc_serv->sv_cb_waitq);
-       } else
+       } else {
                req_partial = req;
+       }

        req->rq_private_buf.len = transport->tcp_copied;


>
>> -     req = xprt_alloc_bc_request(xprt);
>>       if (req == NULL) {
>>               printk(KERN_WARNING "Callback slot table overflowed\n");
>>               xprt_force_disconnect(xprt);
>> @@ -1285,6 +1290,7 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>>
>>       if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
>>               struct svc_serv *bc_serv = xprt->bc_serv;
>> +             req_partial = NULL;
>>
>>               /*
>>                * Add callback request to callback list.  The callback
>> @@ -1297,7 +1303,8 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>>               list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
>>               spin_unlock(&bc_serv->sv_cb_lock);
>>               wake_up(&bc_serv->sv_cb_waitq);
>> -     }
>> +     } else
>> +             req_partial = req;
>>
>>       req->rq_private_buf.len = transport->tcp_copied;
>>
>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
