Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:45409 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbbICUY4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2015 16:24:56 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2] xprtrdma: take HCA driver refcount at client
To: Doug Ledford <dledford@redhat.com>,
        Devesh Sharma <devesh.sharma@avagotech.com>,
        <linux-rdma@vger.kernel.org>
References: <1438254018-2816-1-git-send-email-devesh.sharma@avagotech.com>
 <55E8A98D.5060903@redhat.com>
CC: <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Message-ID: <55E8AC91.2050208@Netapp.com>
Date: Thu, 3 Sep 2015 16:24:49 -0400
MIME-Version: 1.0
In-Reply-To: <55E8A98D.5060903@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Doug,

On 09/03/2015 04:11 PM, Doug Ledford wrote:
> On 07/30/2015 07:00 AM, Devesh Sharma wrote:
>> Thanks Chuck Lever for the valuable feedback and suggestions.
>>
>> This is a rework of the following patch sent almost a year back:
>> http://www.mail-archive.com/linux-rdma%40vger.kernel.org/msg20730.html
>>
>> In presence of active mount if someone tries to rmmod vendor-driver, the
>> command remains stuck forever waiting for destruction of all rdma-cm-id.
>> in worst case client can crash during shutdown with active mounts.
>>
>> The existing code assumes that ia->ri_id->device cannot change during
>> the lifetime of a transport. xprtrdma do not have support for
>> DEVICE_REMOVAL event either. Lifting that assumption and adding support
>> for DEVICE_REMOVAL event is a long chain of work, and is in plan.
>>
>> The community decided that preventing the hang right now is more
>> important than waiting for architectural changes.
>>
>> Thus, this patch introduces a temporary workaround to acquire HCA driver
>> module reference count during the mount of a nfs-rdma mount point.
>>
>> Cc: chuck.lever@oracle.com
>> Cc: linux-nfs@vger.kernel.org
>> Signed-off-by: Devesh Sharma <devesh.sharma@avagotech.com>
>> Reviewed-by: Sagi Grimberg <sagig@dev.mellanox.co.il>
> 
> Chuck, was this given final approval, and if so, who's tree is it
> expected to go through?  Just trying to make sure I don't need to do
> anything here as I don't see a rejection in my linux-rdma folder, but I
> also didn't see it in the initial 4.3 nfs merge.

This was approved and went through my tree to Trond.  I don't think he's sent out the v4.3 pull request yet, but hopefully it won't be too much longer!

Thanks,
Anna


> 
>> ---
>>  net/sunrpc/xprtrdma/verbs.c |   38 ++++++++++++++++++++++++++++++--------
>>  1 files changed, 30 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 891c4ed..1c3c420 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -52,6 +52,7 @@
>>  #include <linux/prefetch.h>
>>  #include <linux/sunrpc/addr.h>
>>  #include <asm/bitops.h>
>> +#include <linux/module.h> /* try_module_get()/module_put() */
>>  
>>  #include "xprt_rdma.h"
>>  
>> @@ -414,6 +415,14 @@ connected:
>>  	return 0;
>>  }
>>  
>> +static void rpcrdma_destroy_id(struct rdma_cm_id *id)
>> +{
>> +	if (id) {
>> +		module_put(id->device->owner);
>> +		rdma_destroy_id(id);
>> +	}
>> +}
>> +
>>  static struct rdma_cm_id *
>>  rpcrdma_create_id(struct rpcrdma_xprt *xprt,
>>  			struct rpcrdma_ia *ia, struct sockaddr *addr)
>> @@ -440,6 +449,18 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
>>  	}
>>  	wait_for_completion_interruptible_timeout(&ia->ri_done,
>>  				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
>> +
>> +	/* FIXME: We hate to break the notion of ULP<-->Core<-->Provider
>> +	 * by calling try_module_get() on HCA driver. This is to prevent a
>> +	 * system hang or a possible crash during reboot with active nfs-rdma
>> +	 * mount. We will keep this workaround until xprtrdma comes back with a
>> +	 * massive architectural changes to have proper fix.
>> +	 */
>> +	if (!ia->ri_async_rc && !try_module_get(id->device->owner)) {
>> +		dprintk("RPC:       %s: Failed to get device module\n",
>> +			__func__);
>> +		ia->ri_async_rc = -ENODEV;
>> +	}
>>  	rc = ia->ri_async_rc;
>>  	if (rc)
>>  		goto out;
>> @@ -449,16 +470,17 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
>>  	if (rc) {
>>  		dprintk("RPC:       %s: rdma_resolve_route() failed %i\n",
>>  			__func__, rc);
>> -		goto out;
>> +		goto put;
>>  	}
>>  	wait_for_completion_interruptible_timeout(&ia->ri_done,
>>  				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
>>  	rc = ia->ri_async_rc;
>>  	if (rc)
>> -		goto out;
>> +		goto put;
>>  
>>  	return id;
>> -
>> +put:
>> +	module_put(id->device->owner);
>>  out:
>>  	rdma_destroy_id(id);
>>  	return ERR_PTR(rc);
>> @@ -592,7 +614,7 @@ out3:
>>  	ib_dealloc_pd(ia->ri_pd);
>>  	ia->ri_pd = NULL;
>>  out2:
>> -	rdma_destroy_id(ia->ri_id);
>> +	rpcrdma_destroy_id(ia->ri_id);
>>  	ia->ri_id = NULL;
>>  out1:
>>  	return rc;
>> @@ -618,7 +640,7 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>>  	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
>>  		if (ia->ri_id->qp)
>>  			rdma_destroy_qp(ia->ri_id);
>> -		rdma_destroy_id(ia->ri_id);
>> +		rpcrdma_destroy_id(ia->ri_id);
>>  		ia->ri_id = NULL;
>>  	}
>>  
>> @@ -825,7 +847,7 @@ retry:
>>  		if (ia->ri_device != id->device) {
>>  			printk("RPC:       %s: can't reconnect on "
>>  				"different device!\n", __func__);
>> -			rdma_destroy_id(id);
>> +			rpcrdma_destroy_id(id);
>>  			rc = -ENETUNREACH;
>>  			goto out;
>>  		}
>> @@ -834,7 +856,7 @@ retry:
>>  		if (rc) {
>>  			dprintk("RPC:       %s: rdma_create_qp failed %i\n",
>>  				__func__, rc);
>> -			rdma_destroy_id(id);
>> +			rpcrdma_destroy_id(id);
>>  			rc = -ENETUNREACH;
>>  			goto out;
>>  		}
>> @@ -845,7 +867,7 @@ retry:
>>  		write_unlock(&ia->ri_qplock);
>>  
>>  		rdma_destroy_qp(old);
>> -		rdma_destroy_id(old);
>> +		rpcrdma_destroy_id(old);
>>  	} else {
>>  		dprintk("RPC:       %s: connecting...\n", __func__);
>>  		rc = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
>>
> 
> 

