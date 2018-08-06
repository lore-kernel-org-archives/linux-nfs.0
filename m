Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:19451 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732430AbeHFRcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Aug 2018 13:32:33 -0400
Subject: Re: [PATCH] xprtrdma: Fix disconnect regression
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180728144051.3612.82362.stgit@manet.1015granger.net>
 <C1EBC369-00D2-4E78-AA05-63BABA329910@oracle.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <8696e2c9-720e-3b54-76c3-c9b1bd61731f@Netapp.com>
Date: Mon, 6 Aug 2018 11:22:45 -0400
MIME-Version: 1.0
In-Reply-To: <C1EBC369-00D2-4E78-AA05-63BABA329910@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 08/06/2018 10:00 AM, Chuck Lever wrote:
> 
> 
>> On Jul 28, 2018, at 10:46 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> I found that injecting disconnects with v4.18-rc resulted in
>> random failures of the multi-threaded git regression test.
>>
>> The root cause appears to be that, after a reconnect, the
>> RPC/RDMA transport is waking pending RPCs before the transport has
>> posted enough Receive buffers to receive the Replies. If a Reply
>> arrives before enough Receive buffers are posted, the connection
>> is dropped. A few connection drops happen in quick succession as
>> the client and server struggle to regain credit synchronization.
>>
>> This regression was introduced with commit 7c8d9e7c8863 ("xprtrdma:
>> Move Receive posting to Receive handler"). The client is supposed to
>> post a single Receive when a connection is established because
>> it's not supposed to send more than one RPC Call before it gets
>> a fresh credit grant in the first RPC Reply [RFC 8166, Section
>> 3.3.3].
>>
>> Unfortunately there appears to be a longstanding bug in the Linux
>> client's credit accounting mechanism. On connect, it simply dumps
>> all pending RPC Calls onto the new connection. It's possible it has
>> done this ever since the RPC/RDMA transport was added to the kernel
>> ten years ago.
>>
>> Servers have so far been tolerant of this bad behavior. Currently no
>> server implementation ever changes its credit grant over reconnects,
>> and servers always repost enough Receives before connections are
>> fully established.
>>
>> The Linux client implementation used to post a Receive before each
>> of these Calls. This has covered up the flooding send behavior.
>>
>> I could try to correct this old bug so that the client sends exactly
>> one RPC Call and waits for a Reply. Since we are so close to the
>> next merge window, I'm going to instead provide a simple patch to
>> post enough Receives before a reconnect completes (based on the
>> number of credits granted to the previous connection).
>>
>> The spurious disconnects will be gone, but the client will still
>> send multiple RPC Calls immediately after a reconnect.
>>
>> Addressing the latter problem will wait for a merge window because
>> a) I expect it to be a large change requiring lots of testing, and
>> b) obviously the Linux client has interoperated successfully since
>> day zero while still being broken.
>>
>> Fixes: 7c8d9e7c8863 ("xprtrdma: Move Receive posting to ... ")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/verbs.c |    5 ++---
>> 1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> Hi Anna-
>>
>> Would it be possible to get this into linux-next and then v4.18-rc ?
>> I know this is very late, but I found this issue only recently and
>> it took a few days to nail down a simple fix.
> 
> Hi Anna, what's the status of this fix?

I have it queued up for 4.19 right now, with a cc:stable so it'll be backported once it's added.  Sorry that I didn't see your note about getting it into v4.18 earlier :( 

Anna

> 
> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 16161a3..e8d1024 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -280,7 +280,6 @@
>> 		++xprt->rx_xprt.connect_cookie;
>> 		connstate = -ECONNABORTED;
>> connected:
>> -		xprt->rx_buf.rb_credits = 1;
>> 		ep->rep_connected = connstate;
>> 		rpcrdma_conn_func(ep);
>> 		wake_up_all(&ep->rep_connect_wait);
>> @@ -755,6 +754,7 @@
>> 	}
>>
>> 	ep->rep_connected = 0;
>> +	rpcrdma_post_recvs(r_xprt, true);
>>
>> 	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);
>> 	if (rc) {
>> @@ -773,8 +773,6 @@
>>
>> 	dprintk("RPC:       %s: connected\n", __func__);
>>
>> -	rpcrdma_post_recvs(r_xprt, true);
>> -
>> out:
>> 	if (rc)
>> 		ep->rep_connected = rc;
>> @@ -1171,6 +1169,7 @@ struct rpcrdma_req *
>> 		list_add(&req->rl_list, &buf->rb_send_bufs);
>> 	}
>>
>> +	buf->rb_credits = 1;
>> 	buf->rb_posted_receives = 0;
>> 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
