From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  11/17] svcrdma: Use standard Linux lists for context
 cache
Date: Tue, 06 May 2008 19:49:14 -0500
Message-ID: <C44666BA.4AFDE%tom@opengridcomputing.com>
References: <20080506213234.GO13484@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:4877 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903AbYEGAt2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 20:49:28 -0400
In-Reply-To: <20080506213234.GO13484@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 5/6/08 4:32 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 02, 2008 at 11:28:26AM -0500, Tom Tucker wrote:
>> Replace the one-off linked list implementation used to implement the
>> context cache with the standard Linux list_head lists. Add a cpmtext
> 
> cmptext == context?
> 
> Some spell checking might help those of us who are already a little lost
> in the alphabet soup here.
> 
> Also, I assume that's referring to sc_ctxt_used.  It's initialized,
> incremented, and decremented, but doesn't actually seem to be used
> anywhere yet?

There's a patch at the end that added a WARN_ON if it's not zero when the
transport is getting destroyed.

> 
> --b.
> 
>> counter to catch resource leaks.
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> 
>> ---
>>  include/linux/sunrpc/svc_rdma.h          |    5 ++-
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   47
>> ++++++++++++++++-------------
>>  2 files changed, 29 insertions(+), 23 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svc_rdma.h
>> b/include/linux/sunrpc/svc_rdma.h
>> index c447c41..7014390 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -72,7 +72,7 @@ extern atomic_t rdma_stat_sq_prod;
>>   */
>>  struct svc_rdma_op_ctxt {
>> struct svc_rdma_op_ctxt *read_hdr;
>> - struct svc_rdma_op_ctxt *next;
>> + struct list_head free_list;
>> struct xdr_buf arg;
>> struct list_head dto_q;
>> enum ib_wr_opcode wr_op;
>> @@ -104,7 +104,8 @@ struct svcxprt_rdma {
>>  
>> struct ib_pd         *sc_pd;
>>  
>> - struct svc_rdma_op_ctxt  *sc_ctxt_head;
>> + atomic_t      sc_ctxt_used;
>> + struct list_head     sc_ctxt_free;
>> int       sc_ctxt_cnt;
>> int       sc_ctxt_bump;
>> int       sc_ctxt_max;
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index c852fd9..c842cc2 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -103,8 +103,8 @@ static int rdma_bump_context_cache(struct svcxprt_rdma
>> *xprt)
>> spin_lock_bh(&xprt->sc_ctxt_lock);
>> if (ctxt) {
>> at_least_one = 1;
>> -   ctxt->next = xprt->sc_ctxt_head;
>> -   xprt->sc_ctxt_head = ctxt;
>> +   INIT_LIST_HEAD(&ctxt->free_list);
>> +   list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
>> } else {
>> /* kmalloc failed...give up for now */
>> xprt->sc_ctxt_cnt--;
>> @@ -123,7 +123,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct
>> svcxprt_rdma *xprt)
>>  
>> while (1) {
>> spin_lock_bh(&xprt->sc_ctxt_lock);
>> -  if (unlikely(xprt->sc_ctxt_head == NULL)) {
>> +  if (unlikely(list_empty(&xprt->sc_ctxt_free))) {
>> /* Try to bump my cache. */
>> spin_unlock_bh(&xprt->sc_ctxt_lock);
>>  
>> @@ -136,12 +136,15 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct
>> svcxprt_rdma *xprt)
>> schedule_timeout_uninterruptible(msecs_to_jiffies(500));
>> continue;
>> }
>> -  ctxt = xprt->sc_ctxt_head;
>> -  xprt->sc_ctxt_head = ctxt->next;
>> +  ctxt = list_entry(xprt->sc_ctxt_free.next,
>> +      struct svc_rdma_op_ctxt,
>> +      free_list);
>> +  list_del_init(&ctxt->free_list);
>> spin_unlock_bh(&xprt->sc_ctxt_lock);
>> ctxt->xprt = xprt;
>> INIT_LIST_HEAD(&ctxt->dto_q);
>> ctxt->count = 0;
>> +  atomic_inc(&xprt->sc_ctxt_used);
>> break;
>> }
>> return ctxt;
>> @@ -163,10 +166,11 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt
>> *ctxt, int free_pages)
>> ctxt->sge[i].addr,
>> ctxt->sge[i].length,
>> ctxt->direction);
>> +
>> spin_lock_bh(&xprt->sc_ctxt_lock);
>> - ctxt->next = xprt->sc_ctxt_head;
>> - xprt->sc_ctxt_head = ctxt;
>> + list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
>> spin_unlock_bh(&xprt->sc_ctxt_lock);
>> + atomic_dec(&xprt->sc_ctxt_used);
>>  }
>>  
>>  /* ib_cq event handler */
>> @@ -409,28 +413,29 @@ static void create_context_cache(struct svcxprt_rdma
>> *xprt,
>> xprt->sc_ctxt_max = ctxt_max;
>> xprt->sc_ctxt_bump = ctxt_bump;
>> xprt->sc_ctxt_cnt = 0;
>> - xprt->sc_ctxt_head = NULL;
>> + atomic_set(&xprt->sc_ctxt_used, 0);
>> +
>> + INIT_LIST_HEAD(&xprt->sc_ctxt_free);
>> for (i = 0; i < ctxt_count; i++) {
>> ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
>> if (ctxt) {
>> -   ctxt->next = xprt->sc_ctxt_head;
>> -   xprt->sc_ctxt_head = ctxt;
>> +   INIT_LIST_HEAD(&ctxt->free_list);
>> +   list_add(&ctxt->free_list, &xprt->sc_ctxt_free);
>> xprt->sc_ctxt_cnt++;
>> }
>> }
>>  }
>>  
>> -static void destroy_context_cache(struct svc_rdma_op_ctxt *ctxt)
>> +static void destroy_context_cache(struct svcxprt_rdma *xprt)
>>  {
>> - struct svc_rdma_op_ctxt *next;
>> - if (!ctxt)
>> -  return;
>> -
>> - do {
>> -  next = ctxt->next;
>> + while (!list_empty(&xprt->sc_ctxt_free)) {
>> +  struct svc_rdma_op_ctxt *ctxt;
>> +  ctxt = list_entry(xprt->sc_ctxt_free.next,
>> +      struct svc_rdma_op_ctxt,
>> +      free_list);
>> +  list_del_init(&ctxt->free_list);
>> kfree(ctxt);
>> -  ctxt = next;
>> - } while (next);
>> + }
>>  }
>>  
>>  static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
>> @@ -467,7 +472,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct
>> svc_serv *serv,
>>     reqs +
>>     cma_xprt->sc_sq_depth +
>>     RPCRDMA_MAX_THREADS + 1); /* max */
>> -  if (!cma_xprt->sc_ctxt_head) {
>> +  if (list_empty(&cma_xprt->sc_ctxt_free)) {
>> kfree(cma_xprt);
>> return NULL;
>> }
>> @@ -971,7 +976,7 @@ static void svc_rdma_free(struct svc_xprt *xprt)
>> if (rdma->sc_pd && !IS_ERR(rdma->sc_pd))
>> ib_dealloc_pd(rdma->sc_pd);
>>  
>> - destroy_context_cache(rdma->sc_ctxt_head);
>> + destroy_context_cache(rdma);
>> kfree(rdma);
>>  }
>>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


