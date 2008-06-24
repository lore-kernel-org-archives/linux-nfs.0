From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 02/11] svcrdma: Use RPC reply map for RDMA_WRITE	processing
Date: Mon, 23 Jun 2008 22:02:17 -0500
Message-ID: <486063B9.4000603@opengridcomputing.com>
References: <12120836962076-git-send-email-tom@opengridcomputing.com> <12120836962324-git-send-email-tom@opengridcomputing.com> <12120836963727-git-send-email-tom@opengridcomputing.com> <20080616210442.GB29446@fieldses.org> <485D3186.2000307@opengridcomputing.com> <20080623185126.GD24373@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:38878 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752093AbYFXDCS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 23:02:18 -0400
In-Reply-To: <20080623185126.GD24373@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Sat, Jun 21, 2008 at 11:51:18AM -0500, Tom Tucker wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Thu, May 29, 2008 at 12:54:47PM -0500, Tom Tucker wrote:
>>>   
>>>       
>>>> Use the new svc_rdma_req_map data type for mapping the client side memory
>>>> to the server side memory. Move the DMA mapping to the context pointed to
>>>> by each WR individually so that it is unmapped after the WR completes.
>>>>
>>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>>>
>>>> ---
>>>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  122 ++++++++++++++----------------
>>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
>>>>  2 files changed, 62 insertions(+), 65 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> index fb82b1b..7cd65b7 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> @@ -64,10 +64,9 @@
>>>>   * SGE[sge_count-1]    data from xdr->tail.
>>>>   *
>>>>   */
>>>> -static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>>> -				 struct xdr_buf *xdr,
>>>> -				 struct ib_sge *sge,
>>>> -				 int *sge_count)
>>>> +static void xdr_to_sge(struct svcxprt_rdma *xprt,
>>>> +		       struct xdr_buf *xdr,
>>>> +		       struct svc_rdma_req_map *vec)
>>>>  {
>>>>  	/* Max we need is the length of the XDR / pagesize + one for
>>>>  	 * head + one for tail + one for RPCRDMA header
>>>> @@ -84,14 +83,10 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>>>  	sge_no = 1;
>>>>     
>>>>         
>>> Should the arrays in the svc_rdma_req_map actually be size
>>> RPC_SVC_MAXPAGES+1 to allow for the RPCRDMA header?
>>>
>>>   
>>>       
>> Actually, upon further inspection, this is not a bug. The  
>> RPCSVC_MAXPAGES is used to size the rqstp
>> page array. This array includes a page for the request hdr, reply hdr  
>> and one extra page for alignment. For
>> our use case, the reply hdr page covers the RDMA header.
>>     
>
> OK, that makes sense.  (Let's just fix the comment above so I don't
> forget and ask the same question again next time.)
>
>   
Ok, done.
>> However, I think this payload length should be clamped in a different  
>> way. It seems silly to allocate these
>> things to handle big-data mounts that are rarely used in practice. I  
>> think it's better to have a transport max
>> that is more reasonable by default and a module parameter that is  
>> configurable if you're looking to do big-data
>> mounts.
>>
>> Thoughts?
>>     
>
> This is decided in fs/nfsd/nfssvc.c:nfsd_create_serv(), based on the
> machine's ram size, and can be overridden with the nfsd filesystem's
> maxblksize parameter.
>
> I'm open to suggestions, but my feeling is that it's hard to educate
> people about how to use additional sysctl's, and that it's reasonable to
> waste some memory to get good out-of-the-box performance on streaming
> IO.
>
> See also recent patches from Olga and Dean for similar discussion
> (about WAN tcp performance in their case, since the size of these
> buffers affects the size of the tcp window we advertise).
>
> --b.
>   

