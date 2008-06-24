From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 01/11] svcrdma: Add a type for keeping NFS RPC mapping
Date: Mon, 23 Jun 2008 21:58:21 -0500
Message-ID: <486062CD.6010800@opengridcomputing.com>
References: <12120836962076-git-send-email-tom@opengridcomputing.com> <12120836962324-git-send-email-tom@opengridcomputing.com> <20080616194858.GA29446@fieldses.org> <485D2CEF.404@opengridcomputing.com> <20080623182707.GC24373@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:38862 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752093AbYFXC6V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 22:58:21 -0400
In-Reply-To: <20080623182707.GC24373@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Sat, Jun 21, 2008 at 11:31:43AM -0500, Tom Tucker wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Thu, May 29, 2008 at 12:54:46PM -0500, Tom Tucker wrote:
>>>   
>>>       
>>>> Create a new data structure to hold the remote client address space
>>>> to local server address space mapping.
>>>>
>>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>>>
>>>> ---
>>>>  include/linux/sunrpc/svc_rdma.h          |   27 +++++++++++++++++++++++++++
>>>>  net/sunrpc/xprtrdma/svc_rdma.c           |   23 +++++++++++++++++++++++
>>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   26 ++++++++++++++++++++++++++
>>>>  3 files changed, 76 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>>>> index 05eb466..bd8749c 100644
>>>> --- a/include/linux/sunrpc/svc_rdma.h
>>>> +++ b/include/linux/sunrpc/svc_rdma.h
>>>> @@ -86,6 +86,31 @@ struct svc_rdma_op_ctxt {
>>>>  	struct page *pages[RPCSVC_MAXPAGES];
>>>>  };
>>>>  +/*
>>>> + * NFS_ requests are mapped on the client side by the chunk lists in
>>>> + * the RPCRDMA header. During the fetching of the RPC from the client
>>>> + * and the writing of the reply to the client, the memory in the
>>>> + * client and the memory in the server must be mapped as contiguous
>>>> + * vaddr/len for access by the hardware. These data strucures keep
>>>> + * these mappings.
>>>> + *
>>>> + * For an RDMA_WRITE, the 'sge' maps the RPC REPLY. For RDMA_READ, the
>>>> + * 'sge' in the svc_rdma_req_map maps the server side RPC reply and the
>>>> + * 'ch' field maps the read-list of the RPCRDMA header to the 'sge'
>>>> + * mapping of the reply.
>>>> + */
>>>> +struct svc_rdma_chunk_sge {
>>>> +	int start;		/* sge no for this chunk */
>>>> +	int count;		/* sge count for this chunk */
>>>> +};
>>>> +struct svc_rdma_req_map {
>>>> +	unsigned long count;
>>>> +	union {
>>>> +		struct kvec sge[RPCSVC_MAXPAGES];
>>>> +		struct svc_rdma_chunk_sge ch[RPCSVC_MAXPAGES];
>>>> +	};
>>>> +};
>>>> +
>>>>  #define RDMACTXT_F_LAST_CTXT	2
>>>>   struct svcxprt_rdma {
>>>> @@ -173,6 +198,8 @@ extern int svc_rdma_post_recv(struct svcxprt_rdma *);
>>>>  extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
>>>>  extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
>>>>  extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
>>>> +extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
>>>> +extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
>>>>  extern void svc_sq_reap(struct svcxprt_rdma *);
>>>>  extern void svc_rq_reap(struct svcxprt_rdma *);
>>>>  extern struct svc_xprt_class svc_rdma_class;
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
>>>> index 88c0ca2..545ea72 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
>>>> @@ -69,6 +69,9 @@ atomic_t rdma_stat_rq_prod;
>>>>  atomic_t rdma_stat_sq_poll;
>>>>  atomic_t rdma_stat_sq_prod;
>>>>  +/* Temporary NFS request map cache */
>>>> +struct kmem_cache *svc_rdma_map_cachep = NULL;
>>>>     
>>>>         
>>> No need to initialize globals to NULL.
>>>
>>>   
>>>       
>> I thought only static objects were initialized per the C standard. Or  
>> are you saying that this particular
>> global doesn't need to be initialized because of the way it is used?
>>     
>
> I don't know if the initialization is mandated by the standards or
> whether it's just gcc behavior, but I know I get a complaint every time
> somebody finds one of those....
>
>   

In this case, the initialization is unnecessary, so it can be safely dumped.

> That may partly just be a preference for conciseness, but I think it may
> also allow gcc to put the thing in a different section and save some
> space in the on-disk kernel--I don't know.
>
>   
Right -- un-initialized data goes in a different section, the .bss 
section in particular. Since the .bss section is not "initialized", 
there are no values (zeroes in this case) sitting in the object file 
ready to be mapped into whatever location becomes .bss. By contrast, the 
.data section contains initialized data and the initial values are 
sitting in the object file.

So my question here is a little subtler:

A. Do we discard _all_ zero initializations of non-static globals 
because we can safely assume that .bss is initialzed (not a fan of 
this),  or

B. Don't be an idiot and initialize objects unnecessarily because it 
bloats the kernel object file?

An idiot voting for  B,
Tom

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

