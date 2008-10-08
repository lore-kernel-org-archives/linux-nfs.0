From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 10/15] RPC/RDMA: return a consistent error to
  mount, when connect fails.
Date: Wed, 08 Oct 2008 13:40:39 -0400
Message-ID: <RTPCLUEXC1-PRDbpH7100000075@RTPMVEXC1-PRD.hq.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
 <20081008154835.1336.85484.stgit@tmt3.nane.netapp.com>
 <1223487082.7361.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22520 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754557AbYJHRkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:40:52 -0400
In-Reply-To: <1223487082.7361.17.camel@localhost>
References: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <20081008154835.1336.85484.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <1223487082.7361.17.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:31 PM 10/8/2008, Trond Myklebust wrote:
>On Wed, 2008-10-08 at 11:48 -0400, Tom Talpey wrote:
>> The mount system call path does not expect such errors as ECONNREFUSED
>> to be returned from failed transport connection attempts, otherwise it
>> prints simply "internal error". Translate all such errors to ENOTCONN
>> from RPC/RDMA to match sockets behavior.
>
>Hmm... Shouldn't we be passing the ECONNREFUSED error here, and rather
>fix the downstream error paths?

That means fixing /sbin/mount.nfs, and an earlier conversation concluded that
"doing what TCP does" was preferred. The error path from NFS and RPC is,
frankly, more than a little tortuous. The error is translated and filtered in
both layers, after being returned from the transport. Then, the mount command
makes up its own diagnostic from what comes back from the syscall. Well beyond
the scope of RDMA.

Your call. As proposed, it is more compatible with current practice, IMO.

Tom.

>> Signed-off-by: Tom Talpey <talpey@netapp.com>
>> ---
>> 
>>  net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index c4b8011..11ea8da 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -700,7 +700,7 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
>>  			xprt_wake_pending_tasks(xprt, 0);
>>  	} else {
>>  		if (xprt_test_and_clear_connected(xprt))
>> -			xprt_wake_pending_tasks(xprt, ep->rep_connected);
>> +			xprt_wake_pending_tasks(xprt, -ENOTCONN);
>>  	}
>>  	spin_unlock_bh(&xprt->transport_lock);
>>  }
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

