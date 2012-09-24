Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52339 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756755Ab2IXRxL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 13:53:11 -0400
Message-ID: <50609DF3.2060204@netapp.com>
Date: Mon, 24 Sep 2012 13:52:51 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
References: <1348508341-19642-1-git-send-email-bjschuma@netapp.com> <20120924174246.GA12238@fieldses.org>
In-Reply-To: <20120924174246.GA12238@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/24/2012 01:42 PM, J. Bruce Fields wrote:
> On Mon, Sep 24, 2012 at 01:39:01PM -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> f39c1bfb5a03e2d255451bff05be0d7255298fa4 (SUNRPC: Fix a UDP transport
>> regression) introduced the "alloc_slot" function for xprt operations,
>> but never created one for the backchannel operations.  This patch fixes
>> a null pointer dereference when mounting NFS over v4.1.
> 
> Thanks, I just rebased some of my work to 3.6 and ran across that!  It
> crashes the 4.1 server very quickly....

That sounds like my story.  It got my peer-to-peer server right away, too.

- Bryan

> 
> --b.
> 
>>
>> Call Trace:
>>  [<ffffffffa0207957>] ? xprt_reserve+0x47/0x50 [sunrpc]
>>  [<ffffffffa02023a4>] call_reserve+0x34/0x60 [sunrpc]
>>  [<ffffffffa020e280>] __rpc_execute+0x90/0x400 [sunrpc]
>>  [<ffffffffa020e61a>] rpc_async_schedule+0x2a/0x40 [sunrpc]
>>  [<ffffffff81073589>] process_one_work+0x139/0x500
>>  [<ffffffff81070e70>] ? alloc_worker+0x70/0x70
>>  [<ffffffffa020e5f0>] ? __rpc_execute+0x400/0x400 [sunrpc]
>>  [<ffffffff81073d1e>] worker_thread+0x15e/0x460
>>  [<ffffffff8145c839>] ? preempt_schedule+0x49/0x70
>>  [<ffffffff81073bc0>] ? rescuer_thread+0x230/0x230
>>  [<ffffffff81079603>] kthread+0x93/0xa0
>>  [<ffffffff81465d04>] kernel_thread_helper+0x4/0x10
>>  [<ffffffff81079570>] ? kthread_freezable_should_stop+0x70/0x70
>>  [<ffffffff81465d00>] ? gs_change+0x13/0x13
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  net/sunrpc/xprtsock.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 86b7777..aaaadfb 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -2521,6 +2521,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
>>  static struct rpc_xprt_ops bc_tcp_ops = {
>>  	.reserve_xprt		= xprt_reserve_xprt,
>>  	.release_xprt		= xprt_release_xprt,
>> +	.alloc_slot		= xprt_alloc_slot,
>>  	.rpcbind		= xs_local_rpcbind,
>>  	.buf_alloc		= bc_malloc,
>>  	.buf_free		= bc_free,
>> -- 
>> 1.7.12.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

