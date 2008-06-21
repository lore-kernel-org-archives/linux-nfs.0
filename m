From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 10/11] svcrdma: Create a kmem cache for the WR contexts
Date: Sat, 21 Jun 2008 12:08:42 -0500
Message-ID: <485D359A.2030301@opengridcomputing.com>
References: <12120836962324-git-send-email-tom@opengridcomputing.com> <12120836963727-git-send-email-tom@opengridcomputing.com> <1212083697950-git-send-email-tom@opengridcomputing.com> <1212083697236-git-send-email-tom@opengridcomputing.com> <12120836973390-git-send-email-tom@opengridcomputing.com> <12120836973638-git-send-email-tom@opengridcomputing.com> <12120836973072-git-send-email-tom@opengridcomputing.com> <12120836972503-git-send-email-tom@opengridcomputing.com> <12120836973166-git-send-email-tom@opengridcomputing.com> <12120836972648-git-send-email-tom@opengridcomputing.com> <20080616212447.GC29446@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36075 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751709AbYFURIm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jun 2008 13:08:42 -0400
In-Reply-To: <20080616212447.GC29446@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, May 29, 2008 at 12:54:55PM -0500, Tom Tucker wrote:
>   
>> Create a kmem cache to hold WR contexts. Next we will convert
>> the WR context get and put services to use this kmem cache.
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma.c |   24 ++++++++++++++++++++----
>>  1 files changed, 20 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
>> index 1959a9d..8a7d34b 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
>> @@ -69,8 +69,9 @@ atomic_t rdma_stat_rq_prod;
>>  atomic_t rdma_stat_sq_poll;
>>  atomic_t rdma_stat_sq_prod;
>>  
>> -/* Temporary NFS request map cache */
>> +/* Temporary NFS request map and context caches */
>>  struct kmem_cache *svc_rdma_map_cachep = NULL;
>> +struct kmem_cache *svc_rdma_ctxt_cachep = NULL;
>>     
>
> No need to initialize this one either.
>
>   
Given the way it's used, agreed.
>>  
>>  /*
>>   * This function implements reading and resetting an atomic_t stat
>> @@ -247,6 +248,8 @@ void svc_rdma_cleanup(void)
>>  	svc_unreg_xprt_class(&svc_rdma_class);
>>  	if (svc_rdma_map_cachep)
>>  		kmem_cache_destroy(svc_rdma_map_cachep);
>> +	if (svc_rdma_ctxt_cachep)
>> +		kmem_cache_destroy(svc_rdma_ctxt_cachep);
>>     
>
> And the conditional is probably unnecessary again.
>
>   
ok.
> --b.
>
>   
>>  }
>>  
>>  int svc_rdma_init(void)
>> @@ -269,14 +272,27 @@ int svc_rdma_init(void)
>>  						NULL);
>>  	if (!svc_rdma_map_cachep) {
>>  		printk(KERN_INFO "Could not allocate map cache.\n");
>> -		goto err;
>> +		goto err0;
>> +	}
>> +
>> +	/* Create the temporary context cache */
>> +	svc_rdma_ctxt_cachep =
>> +		kmem_cache_create("svc_rdma_ctxt_cache",
>> +				  sizeof(struct svc_rdma_op_ctxt),
>> +				  0,
>> +				  SLAB_HWCACHE_ALIGN,
>> +				  NULL);
>> +	if (!svc_rdma_ctxt_cachep) {
>> +		printk(KERN_INFO "Could not allocate WR ctxt cache.\n");
>> +		goto err1;
>>  	}
>>  
>>  	/* Register RDMA with the SVC transport switch */
>>  	svc_reg_xprt_class(&svc_rdma_class);
>>  	return 0;
>> -
>> - err:
>> + err1:
>> +	kmem_cache_destroy(svc_rdma_map_cachep);
>> + err0:
>>  	if (svcrdma_table_header) {
>>  		unregister_sysctl_table(svcrdma_table_header);
>>  		svcrdma_table_header = NULL;
>>     

