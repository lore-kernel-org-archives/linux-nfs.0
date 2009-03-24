From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/23] SUNRPC: Fix return type of svc_addr_len()
Date: Tue, 24 Mar 2009 16:37:49 -0400
Message-ID: <B9961123-78C4-414A-BC5D-84BDC85771B7@oracle.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004535.32404.37120.stgit@ingres.1015granger.net> <20090324203206.GH19389@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54062 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761048AbZCXUiK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 16:38:10 -0400
In-Reply-To: <20090324203206.GH19389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 24, 2009, at 4:32 PM, J. Bruce Fields wrote:
> On Wed, Mar 18, 2009 at 08:45:36PM -0400, Chuck Lever wrote:
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
> I'd still like to understand when this can happen, to better  
> understand
> how the error should be handled.
>
> Also:
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

It's clearly a bug to return -EAFNOSUPPORT in a size_t.

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
>
> we're probably leaking something here.
>
> I don't want to fix this until it's understood well enough to fix it
> correctly.

Tom needs respond to this, but I think it would be safe to simply  
BUG() here.

> --b.
>
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

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
