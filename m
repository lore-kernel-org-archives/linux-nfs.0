From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/40] SUNRPC: Fix return type of svc_addr_len()
Date: Wed, 18 Mar 2009 18:40:40 -0400
Message-ID: <F61ACAB8-5548-4081-879C-F74383628A35@oracle.com>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net> <20090312160706.16019.81338.stgit@ingres.1015granger.net> <20090318220852.GE18894@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:28336 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759436AbZCRWlJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 18:41:09 -0400
In-Reply-To: <20090318220852.GE18894@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 18, 2009, at Mar 18, 2009, 6:08 PM, J. Bruce Fields wrote:
> On Thu, Mar 12, 2009 at 12:07:06PM -0400, Chuck Lever wrote:
>> The svc_addr_len() helper function can return a negative errno value,
>> but its return type is size_t, which is unsigned.
>>
>> The RDMA transport code passes this return value directly to  
>> memset(),
>> without checking first if it's negative.  This could cause memset()  
>> to
>> clobber a large piece of memory if svc_addr_len() has returned an
>> error.
>
> Is this something that can in fact happen, and if so, in what
> circumstances?

If @sa contains an address whose family is not recognized by  
svc_addr_len(), it will return -EAFNOSUPPORT.  That's mostly likely to  
occur because of a programming error, but we still want to minimize  
the risk of memory or data corruption.

> And what ends up happening to the -EAFNOSUPPORT error?

I think, since the caller returns void, that call turns into a no-op,  
and no connection is made.  But Tom should verify.

> Tracing up through the callers, I get lost somewhere in the ib code.
> Maybe Tom can rescue me....
>
> --b.
>
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> include/linux/sunrpc/svc_xprt.h          |    3 ++-
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 ++++++++++++++--
>> 2 files changed, 16 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
>> svc_xprt.h
>> index 0127dac..c2aa8cd 100644
>> --- a/include/linux/sunrpc/svc_xprt.h
>> +++ b/include/linux/sunrpc/svc_xprt.h
>> @@ -113,7 +113,7 @@ static inline unsigned short  
>> svc_addr_port(struct sockaddr *sa)
>> 	return ret;
>> }
>>
>> -static inline size_t svc_addr_len(struct sockaddr *sa)
>> +static inline int svc_addr_len(const struct sockaddr *sa)
>> {
>> 	switch (sa->sa_family) {
>> 	case AF_INET:
>> @@ -121,6 +121,7 @@ static inline size_t svc_addr_len(struct  
>> sockaddr *sa)
>> 	case AF_INET6:
>> 		return sizeof(struct sockaddr_in6);
>> 	}
>> +
>> 	return -EAFNOSUPPORT;
>> }
>>
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/ 
>> xprtrdma/svc_rdma_transport.c
>> index 3d810e7..d1ec6f9 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -546,6 +546,7 @@ static void handle_connect_req(struct  
>> rdma_cm_id *new_cma_id, size_t client_ird)
>> 	struct svcxprt_rdma *listen_xprt = new_cma_id->context;
>> 	struct svcxprt_rdma *newxprt;
>> 	struct sockaddr *sa;
>> +	int len;
>>
>> 	/* Create a new transport */
>> 	newxprt = rdma_create_xprt(listen_xprt->sc_xprt.xpt_server, 0);
>> @@ -563,9 +564,20 @@ static void handle_connect_req(struct  
>> rdma_cm_id *new_cma_id, size_t client_ird)
>>
>> 	/* Set the local and remote addresses in the transport */
>> 	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
>> -	svc_xprt_set_remote(&newxprt->sc_xprt, sa, svc_addr_len(sa));
>> +	len = svc_addr_len(sa);
>> +	if (len < 0) {
>> +		dprintk("svcrdma: dst_addr has a bad address family\n");
>> +		return;
>> +	}
>> +	svc_xprt_set_remote(&newxprt->sc_xprt, sa, len);
>> +
>> 	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.src_addr;
>> -	svc_xprt_set_local(&newxprt->sc_xprt, sa, svc_addr_len(sa));
>> +	len = svc_addr_len(sa);
>> +	if (len < 0) {
>> +		dprintk("svcrdma: src_addr has a bad address family\n");
>> +		return;
>> +	}
>> +	svc_xprt_set_local(&newxprt->sc_xprt, sa, len);
>>
>> 	/*
>> 	 * Enqueue the new transport on the accept queue of the listening
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




