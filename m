Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:44163 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756645Ab0JORrA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Oct 2010 13:47:00 -0400
Message-ID: <4CB89393.6000207@opengridcomputing.com>
Date: Fri, 15 Oct 2010 12:46:59 -0500
From: Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tejun Heo <tj@kernel.org>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Tom Tucker <tom@ogc.us>
Subject: Re: [PATCH linux-2.6.36-rc7] sunrpc/xprtrdma: clean up workqueue
 usage
References: <4CB87807.7050108@kernel.org> <20101015171132.GA18869@fieldses.org>
In-Reply-To: <20101015171132.GA18869@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 10/15/10 12:11 PM, J. Bruce Fields wrote:
> Tom, could you take a look?
>
This looks reasonable to me.

My bet is that it wasn't tested though due to hardware availability. I'll 
test it this weekend and let you know how it goes.

Tom
> --b.
>
> On Fri, Oct 15, 2010 at 05:49:27PM +0200, Tejun Heo wrote:
>> * Create and use svc_rdma_wq instead of using the system workqueue and
>>    flush_scheduled_work().  This workqueue is necessary to serve as
>>    flushing domain for rdma->sc_work which is used to destroy itself
>>    and thus can't be flushed explicitly.
>>
>> * Replace cancel_delayed_work() + flush_scheduled_work() with
>>    cancel_delayed_work_sync().
>>
>> * Implement synchronous connect in xprt_rdma_connect() using
>>    flush_delayed_work() on the rdma_connect work instead of using
>>    flush_scheduled_work().
>>
>> This is to prepare for the deprecation and removal of
>> flush_scheduled_work().
>>
>> Signed-off-by: Tejun Heo<tj@kernel.org>
>> ---
>>   net/sunrpc/xprtrdma/svc_rdma.c           |   11 ++++++++++-
>>   net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++++-
>>   net/sunrpc/xprtrdma/transport.c          |    5 ++---
>>   3 files changed, 17 insertions(+), 5 deletions(-)
>>
>> Index: work/net/sunrpc/xprtrdma/svc_rdma.c
>> ===================================================================
>> --- work.orig/net/sunrpc/xprtrdma/svc_rdma.c
>> +++ work/net/sunrpc/xprtrdma/svc_rdma.c
>> @@ -43,6 +43,7 @@
>>   #include<linux/slab.h>
>>   #include<linux/fs.h>
>>   #include<linux/sysctl.h>
>> +#include<linux/workqueue.h>
>>   #include<linux/sunrpc/clnt.h>
>>   #include<linux/sunrpc/sched.h>
>>   #include<linux/sunrpc/svc_rdma.h>
>> @@ -74,6 +75,8 @@ atomic_t rdma_stat_sq_prod;
>>   struct kmem_cache *svc_rdma_map_cachep;
>>   struct kmem_cache *svc_rdma_ctxt_cachep;
>>
>> +struct workqueue_struct *svc_rdma_wq;
>> +
>>   /*
>>    * This function implements reading and resetting an atomic_t stat
>>    * variable through read/write to a proc file. Any write to the file
>> @@ -231,7 +234,7 @@ static ctl_table svcrdma_root_table[] =
>>   void svc_rdma_cleanup(void)
>>   {
>>   	dprintk("SVCRDMA Module Removed, deregister RPC RDMA transport\n");
>> -	flush_scheduled_work();
>> +	destroy_workqueue(svc_rdma_wq);
>>   	if (svcrdma_table_header) {
>>   		unregister_sysctl_table(svcrdma_table_header);
>>   		svcrdma_table_header = NULL;
>> @@ -249,6 +252,11 @@ int svc_rdma_init(void)
>>   	dprintk("\tsq_depth         : %d\n",
>>   		svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT);
>>   	dprintk("\tmax_inline       : %d\n", svcrdma_max_req_size);
>> +
>> +	svc_rdma_wq = alloc_workqueue("svc_rdma", 0, 0);
>> +	if (!svc_rdma_wq)
>> +		return -ENOMEM;
>> +
>>   	if (!svcrdma_table_header)
>>   		svcrdma_table_header =
>>   			register_sysctl_table(svcrdma_root_table);
>> @@ -283,6 +291,7 @@ int svc_rdma_init(void)
>>   	kmem_cache_destroy(svc_rdma_map_cachep);
>>    err0:
>>   	unregister_sysctl_table(svcrdma_table_header);
>> +	destroy_workqueue(svc_rdma_wq);
>>   	return -ENOMEM;
>>   }
>>   MODULE_AUTHOR("Tom Tucker<tom@opengridcomputing.com>");
>> Index: work/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> ===================================================================
>> --- work.orig/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ work/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -45,6 +45,7 @@
>>   #include<linux/sched.h>
>>   #include<linux/slab.h>
>>   #include<linux/spinlock.h>
>> +#include<linux/workqueue.h>
>>   #include<rdma/ib_verbs.h>
>>   #include<rdma/rdma_cm.h>
>>   #include<linux/sunrpc/svc_rdma.h>
>> @@ -89,6 +90,9 @@ struct svc_xprt_class svc_rdma_class = {
>>   /* WR context cache. Created in svc_rdma.c  */
>>   extern struct kmem_cache *svc_rdma_ctxt_cachep;
>>
>> +/* Workqueue created in svc_rdma.c */
>> +extern struct workqueue_struct *svc_rdma_wq;
>> +
>>   struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
>>   {
>>   	struct svc_rdma_op_ctxt *ctxt;
>> @@ -1184,7 +1188,7 @@ static void svc_rdma_free(struct svc_xpr
>>   	struct svcxprt_rdma *rdma =
>>   		container_of(xprt, struct svcxprt_rdma, sc_xprt);
>>   	INIT_WORK(&rdma->sc_work, __svc_rdma_free);
>> -	schedule_work(&rdma->sc_work);
>> +	queue_work(svc_rdma_wq,&rdma->sc_work);
>>   }
>>
>>   static int svc_rdma_has_wspace(struct svc_xprt *xprt)
>> Index: work/net/sunrpc/xprtrdma/transport.c
>> ===================================================================
>> --- work.orig/net/sunrpc/xprtrdma/transport.c
>> +++ work/net/sunrpc/xprtrdma/transport.c
>> @@ -237,8 +237,7 @@ xprt_rdma_destroy(struct rpc_xprt *xprt)
>>
>>   	dprintk("RPC:       %s: called\n", __func__);
>>
>> -	cancel_delayed_work(&r_xprt->rdma_connect);
>> -	flush_scheduled_work();
>> +	cancel_delayed_work_sync(&r_xprt->rdma_connect);
>>
>>   	xprt_clear_connected(xprt);
>>
>> @@ -460,7 +459,7 @@ xprt_rdma_connect(struct rpc_task *task)
>>   	} else {
>>   		schedule_delayed_work(&r_xprt->rdma_connect, 0);
>>   		if (!RPC_IS_ASYNC(task))
>> -			flush_scheduled_work();
>> +			flush_delayed_work(&r_xprt->rdma_connect);
>>   	}
>>   }
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

