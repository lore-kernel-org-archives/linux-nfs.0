Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:23435 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbaHZFoI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 01:44:08 -0400
Message-ID: <53FC1E93.2060800@oracle.com>
Date: Tue, 26 Aug 2014 13:43:47 +0800
From: Junxiao Bi <junxiao.bi@oracle.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Mel Gorman <mgorman@suse.com>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
References: <53F6F772.6020708@oracle.com>	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com> <20140825164852.50723141@notabene.brown>
In-Reply-To: <20140825164852.50723141@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/25/2014 02:48 PM, NeilBrown wrote:
> On Fri, 22 Aug 2014 18:49:31 -0400 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> 
>> Junxiao Bi reports seeing the following deadlock:
>>
>> @ crash> bt 1539
>> @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
>> @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
>> @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
>> @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
>> @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
>> @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
>> @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
>> @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
>> @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
>> @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
>> @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
>> @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
>> @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
> 
> This stack trace (from 2.6.32) cannot happen in mainline, though it took me a
> while to remember/discover exactly why.
> 
> try_to_free_pages() creates a 'struct scan_control' with ->target_mem_cgroup
> set to NULL.
> shrink_page_list() checks ->target_mem_cgroup using global_reclaim() and if
> it is NULL, wait_on_page_writeback is *not* called.
> 
> So we can only hit this deadlock if mem-cgroup limits are imposed on a
> process which is using NFS - which is quite possible but probably not common.
> 
> The fact that a dead-lock can happen only when memcg limits are imposed seems
> very fragile.  People aren't going to test that case much so there could well
> be other deadlock possibilities lurking.
> 
> Mel: might there be some other way we could get out of this deadlock?
> Could the wait_on_page_writeback() in shrink_page_list() be made a timed-out
> wait or something?  Any other wait out of this deadlock other than setting
> PF_MEMALLOC_NOIO everywhere?

Not only the wait_on_page_writeback() cause the deadlock but also the
next pageout()-> (mapping->a_ops->writepage), Trond's second patch fix
this. So fix the wait_on_page_writeback is not enough to fix deadlock.

Thanks,
Junxiao.
> 
> Thanks,
> NeilBrown
> 
> 
> 
>> @ #12 [ffff88178f64d978] kmem_getpages at ffffffff8110e18b
>> @ #13 [ffff88178f64d9a8] fallback_alloc at ffffffff8110e35e
>> @ #14 [ffff88178f64da08] ____cache_alloc_node at ffffffff8110e51f
>> @ #15 [ffff88178f64da48] __kmalloc at ffffffff8110efba
>> @ #16 [ffff88178f64da98] xs_setup_xprt at ffffffffa00a563f [sunrpc]
>> @ #17 [ffff88178f64dad8] xs_setup_tcp at ffffffffa00a7648 [sunrpc]
>> @ #18 [ffff88178f64daf8] xprt_create_transport at ffffffffa00a478f [sunrpc]
>> @ #19 [ffff88178f64db18] rpc_create at ffffffffa00a2d7a [sunrpc]
>> @ #20 [ffff88178f64dbf8] rpcb_create at ffffffffa00b026b [sunrpc]
>> @ #21 [ffff88178f64dc98] rpcb_getport_async at ffffffffa00b0c94 [sunrpc]
>> @ #22 [ffff88178f64ddf8] call_bind at ffffffffa00a11f8 [sunrpc]
>> @ #23 [ffff88178f64de18] __rpc_execute at ffffffffa00a88ef [sunrpc]
>> @ #24 [ffff88178f64de58] rpc_async_schedule at ffffffffa00a9187 [sunrpc]
>> @ #25 [ffff88178f64de78] worker_thread at ffffffff81072ed2
>> @ #26 [ffff88178f64dee8] kthread at ffffffff81076df3
>> @ #27 [ffff88178f64df48] kernel_thread at ffffffff81012e2a
>> @ crash>
>>
>> Junxiao notes that the problem is not limited to the rpcbind client. In
>> fact we can trigger the exact same problem when trying to reconnect to
>> the server, and we find ourselves calling sock_alloc().
>>
>> The following solution should work for all kernels that support the
>> PF_MEMALLOC_NOIO flag (i.e. Linux 3.9 and newer).
>>
>> Link: http://lkml.kernel.org/r/53F6F772.6020708@oracle.com
>> Reported-by: Junxiao Bi <junxiao.bi@oracle.com>
>> Cc: stable@vger.kernel.org # 3.9+
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/sched.c    |  5 +++--
>>  net/sunrpc/xprtsock.c | 15 ++++++++-------
>>  2 files changed, 11 insertions(+), 9 deletions(-)
>>
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index 9358c79fd589..ab3aff71ff93 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -19,6 +19,7 @@
>>  #include <linux/spinlock.h>
>>  #include <linux/mutex.h>
>>  #include <linux/freezer.h>
>> +#include <linux/sched.h>
>>  
>>  #include <linux/sunrpc/clnt.h>
>>  
>> @@ -821,9 +822,9 @@ void rpc_execute(struct rpc_task *task)
>>  
>>  static void rpc_async_schedule(struct work_struct *work)
>>  {
>> -	current->flags |= PF_FSTRANS;
>> +	current->flags |= PF_FSTRANS | PF_MEMALLOC_NOIO;
>>  	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
>> -	current->flags &= ~PF_FSTRANS;
>> +	current->flags &= ~(PF_FSTRANS | PF_MEMALLOC_NOIO);
>>  }
>>  
>>  /**
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 43cd89eacfab..1d6d4d84b299 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -38,6 +38,7 @@
>>  #include <linux/sunrpc/svcsock.h>
>>  #include <linux/sunrpc/xprtsock.h>
>>  #include <linux/file.h>
>> +#include <linux/sched.h>
>>  #ifdef CONFIG_SUNRPC_BACKCHANNEL
>>  #include <linux/sunrpc/bc_xprt.h>
>>  #endif
>> @@ -1927,7 +1928,7 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
>>  	struct socket *sock;
>>  	int status = -EIO;
>>  
>> -	current->flags |= PF_FSTRANS;
>> +	current->flags |= PF_FSTRANS | PF_MEMALLOC_NOIO;
>>  
>>  	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
>>  	status = __sock_create(xprt->xprt_net, AF_LOCAL,
>> @@ -1968,7 +1969,7 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
>>  out:
>>  	xprt_clear_connecting(xprt);
>>  	xprt_wake_pending_tasks(xprt, status);
>> -	current->flags &= ~PF_FSTRANS;
>> +	current->flags &= ~(PF_FSTRANS | PF_MEMALLOC_NOIO);
>>  	return status;
>>  }
>>  
>> @@ -2071,7 +2072,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
>>  	struct socket *sock = transport->sock;
>>  	int status = -EIO;
>>  
>> -	current->flags |= PF_FSTRANS;
>> +	current->flags |= PF_FSTRANS | PF_MEMALLOC_NOIO;
>>  
>>  	/* Start by resetting any existing state */
>>  	xs_reset_transport(transport);
>> @@ -2092,7 +2093,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
>>  out:
>>  	xprt_clear_connecting(xprt);
>>  	xprt_wake_pending_tasks(xprt, status);
>> -	current->flags &= ~PF_FSTRANS;
>> +	current->flags &= ~(PF_FSTRANS | PF_MEMALLOC_NOIO);
>>  }
>>  
>>  /*
>> @@ -2229,7 +2230,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>>  	struct rpc_xprt *xprt = &transport->xprt;
>>  	int status = -EIO;
>>  
>> -	current->flags |= PF_FSTRANS;
>> +	current->flags |= PF_FSTRANS | PF_MEMALLOC_NOIO;
>>  
>>  	if (!sock) {
>>  		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
>> @@ -2276,7 +2277,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>>  	case -EINPROGRESS:
>>  	case -EALREADY:
>>  		xprt_clear_connecting(xprt);
>> -		current->flags &= ~PF_FSTRANS;
>> +		current->flags &= ~(PF_FSTRANS | PF_MEMALLOC_NOIO);
>>  		return;
>>  	case -EINVAL:
>>  		/* Happens, for instance, if the user specified a link
>> @@ -2294,7 +2295,7 @@ out_eagain:
>>  out:
>>  	xprt_clear_connecting(xprt);
>>  	xprt_wake_pending_tasks(xprt, status);
>> -	current->flags &= ~PF_FSTRANS;
>> +	current->flags &= ~(PF_FSTRANS | PF_MEMALLOC_NOIO);
>>  }
>>  
>>  /**
> 

