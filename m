From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 11/12] svcrdma: Add a message log string to indicate if
 FastReg is being used
Date: Thu, 09 Oct 2008 01:37:05 -0500
Message-ID: <48EDA691.9080108@opengridcomputing.com>
References: <1223069629-5267-3-git-send-email-tom@opengridcomputing.com> <1223069629-5267-4-git-send-email-tom@opengridcomputing.com> <1223069629-5267-5-git-send-email-tom@opengridcomputing.com> <1223069629-5267-6-git-send-email-tom@opengridcomputing.com> <1223069629-5267-7-git-send-email-tom@opengridcomputing.com> <1223069629-5267-8-git-send-email-tom@opengridcomputing.com> <1223069629-5267-9-git-send-email-tom@opengridcomputing.com> <1223069629-5267-10-git-send-email-tom@opengridcomputing.com> <1223069629-5267-11-git-send-email-tom@opengridcomputing.com> <1223069629-5267-12-git-send-email-tom@opengridcomputing.com> <20081008224840.GF14527@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:3375 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751687AbYJIGhH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 02:37:07 -0400
In-Reply-To: <20081008224840.GF14527@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Oct 03, 2008 at 04:33:48PM -0500, Tom Tucker wrote:
>   
>> Add a log message that allows the administrator to determine if server memory
>> is exposed on a particular client connection. This message can be disabled
>> by writing 0 to the /proc/sys/sunrpc/svc_rdma/show_conn_info file.
>>     
>
> I could grudgingly live with the idea of a log message here as a
> temporary fix while we figure out something better, but I'm not happy
> about making it bigger and adding a sysctl.
>
>   
I would happily remove all of this. I believed you thought it important 
that we actively informed the administrator.
Maybe I over-reacted.
> If we just want a hack for now, I'd be inclined to leave this printk a
> dprintk, add the extra information to the dprintk, and tell people to
> turn on transport debugging and watch a client connect.  Ugly, but at
> least it'll be obvious it's not an api that's going to stick around.
>
>   
Id' love to get rid of it...
> Beyond the short-term: is there some other way of getting this
> information from userspace?  Since this is a property of the interface
> device, it'd seem natural to communicate the information in something
> like a sysfs file for the device, or whatever's used to query properties
> of network interfaces.
>
>   
> I'm a bit surprised the information isn't already there.  Aren't
> userspace applications eventually also supposed to be able to use rdma?
> Don't they need to query network interfaces for their capabilities?
>
>   
All of this information is available from  a full-function user-mode API.

This code makes devices more secure than they used to be. So there is no 
negative security regression here. 
This patchset simply improves the security for newer devices that 
support the new features.

If you tell me to yank this out, it will make my day.

Tom
> --b.
>
>   
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>
>> ---
>>  include/linux/sunrpc/svc_rdma.h          |    1 +
>>  net/sunrpc/xprtrdma/svc_rdma.c           |    8 ++++
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   63 ++++++++++++++++++-----------
>>  3 files changed, 48 insertions(+), 24 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index c14fe86..7ee0a76 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -52,6 +52,7 @@
>>  extern unsigned int svcrdma_ord;
>>  extern unsigned int svcrdma_max_requests;
>>  extern unsigned int svcrdma_max_req_size;
>> +extern unsigned int svcrdma_show_conn_info;
>>  
>>  extern atomic_t rdma_stat_recv;
>>  extern atomic_t rdma_stat_read;
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
>> index 8710117..493e243 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
>> @@ -58,6 +58,7 @@ static unsigned int max_max_requests = 16384;
>>  unsigned int svcrdma_max_req_size = RPCRDMA_MAX_REQ_SIZE;
>>  static unsigned int min_max_inline = 4096;
>>  static unsigned int max_max_inline = 65536;
>> +unsigned int svcrdma_show_conn_info = 1;
>>  
>>  atomic_t rdma_stat_recv;
>>  atomic_t rdma_stat_read;
>> @@ -145,6 +146,13 @@ static ctl_table svcrdma_parm_table[] = {
>>  		.extra1		= &min_ord,
>>  		.extra2		= &max_ord,
>>  	},
>> +	{
>> +		.procname	= "show_conn_info",
>> +		.data		= &svcrdma_show_conn_info,
>> +		.maxlen		= sizeof(svcrdma_show_conn_info),
>> +		.mode		= 0644,
>> +		.proc_handler	= &proc_dointvec,
>> +	},
>>  
>>  	{
>>  		.procname	= "rdma_stat_read",
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index bd17023..3d97032 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -833,6 +833,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>  	struct rdma_conn_param conn_param;
>>  	struct ib_qp_init_attr qp_attr;
>>  	struct ib_device_attr devattr;
>> +	char *transport_string;
>> +	char *security_string;
>>  	int dma_mr_acc;
>>  	int need_dma_mr;
>>  	int ret;
>> @@ -981,10 +983,13 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>  	/*
>>  	 * Determine if a DMA MR is required and if so, what privs are required
>>  	 */
>> +	security_string = "Safe. Only RPC memory exposed.";
>>  	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
>>  	case RDMA_TRANSPORT_IWARP:
>> +		transport_string = "iWARP";
>>  		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
>>  		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
>> +			security_string = "Unsafe: Server memory exposed.";
>>  			need_dma_mr = 1;
>>  			dma_mr_acc =
>>  				(IB_ACCESS_LOCAL_WRITE |
>> @@ -996,6 +1001,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>  			need_dma_mr = 0;
>>  		break;
>>  	case RDMA_TRANSPORT_IB:
>> +		transport_string = "IB";
>>  		if (!(devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
>>  			need_dma_mr = 1;
>>  			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
>> @@ -1052,30 +1058,39 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>  		goto errout;
>>  	}
>>  
>> -	dprintk("svcrdma: new connection %p accepted with the following "
>> -		"attributes:\n"
>> -		"    local_ip        : %d.%d.%d.%d\n"
>> -		"    local_port	     : %d\n"
>> -		"    remote_ip       : %d.%d.%d.%d\n"
>> -		"    remote_port     : %d\n"
>> -		"    max_sge         : %d\n"
>> -		"    sq_depth        : %d\n"
>> -		"    max_requests    : %d\n"
>> -		"    ord             : %d\n",
>> -		newxprt,
>> -		NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> -			 route.addr.src_addr)->sin_addr.s_addr),
>> -		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> -		       route.addr.src_addr)->sin_port),
>> -		NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> -			 route.addr.dst_addr)->sin_addr.s_addr),
>> -		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> -		       route.addr.dst_addr)->sin_port),
>> -		newxprt->sc_max_sge,
>> -		newxprt->sc_sq_depth,
>> -		newxprt->sc_max_requests,
>> -		newxprt->sc_ord);
>> -
>> +	if (!svcrdma_show_conn_info)
>> +		goto out;
>> +
>> +	printk(KERN_INFO "svcrdma: New connection accepted with the following "
>> +	       "attributes:\n"
>> +	       "    transport       : %s\n"
>> +	       "    local_ip        : %d.%d.%d.%d\n"
>> +	       "    local_port      : %d\n"
>> +	       "    remote_ip       : %d.%d.%d.%d\n"
>> +	       "    remote_port     : %d\n"
>> +	       "    max_sge         : %d\n"
>> +	       "    sq_depth        : %d\n"
>> +	       "    max_requests    : %d\n"
>> +	       "    ord             : %d\n"
>> +	       "    using fastreg?  : %c\n"
>> +	       "    memory exposure : %s\n",
>> +	       transport_string,
>> +	       NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> +			route.addr.src_addr)->sin_addr.s_addr),
>> +	       ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> +		      route.addr.src_addr)->sin_port),
>> +	       NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> +			route.addr.dst_addr)->sin_addr.s_addr),
>> +	       ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
>> +		      route.addr.dst_addr)->sin_port),
>> +	       newxprt->sc_max_sge,
>> +	       newxprt->sc_sq_depth,
>> +	       newxprt->sc_max_requests,
>> +	       newxprt->sc_ord,
>> +	       newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG ? 'Y' : 'N',
>> +	       security_string);
>> +
>> + out:
>>  	return &newxprt->sc_xprt;
>>  
>>   errout:
>>     
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

