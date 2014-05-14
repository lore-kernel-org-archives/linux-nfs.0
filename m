Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:37162 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754308AbaENO00 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 May 2014 10:26:26 -0400
Message-ID: <53737D15.6020902@opengridcomputing.com>
Date: Wed, 14 May 2014 09:26:29 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chucklever@gmail.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH V2 RFC 2/3] svcrdma: Recvfrom changes
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506174632.18208.28160.stgit@build.ogc.int> <F997E138-FB04-4149-811D-CE68608E8D6B@gmail.com> <00f901cf6eeb$2ff1f630$8fd5e290$@opengridcomputing.com> <3DAF95F3-22D5-4FC5-8C98-5A440E54DC2F@gmail.com>
In-Reply-To: <3DAF95F3-22D5-4FC5-8C98-5A440E54DC2F@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/13/2014 4:44 PM, Chuck Lever wrote:
>>>> +static int rdma_read_chunks(struct svcxprt_rdma *xprt,
>>>> +			    struct rpcrdma_msg *rmsgp,
>>>> +			    struct svc_rqst *rqstp,
>>>> +			    struct svc_rdma_op_ctxt *head)
>>>> {
>>>> -	struct ib_send_wr read_wr;
>>>> -	struct ib_send_wr inv_wr;
>>>> -	int err = 0;
>>>> -	int ch_no;
>>>> -	int ch_count;
>>>> -	int byte_count;
>>>> -	int sge_count;
>>>> -	u64 sgl_offset;
>>>> +	int page_no, ch_count, ret;
>>>> 	struct rpcrdma_read_chunk *ch;
>>>> -	struct svc_rdma_op_ctxt *ctxt = NULL;
>>>> -	struct svc_rdma_req_map *rpl_map;
>>>> -	struct svc_rdma_req_map *chl_map;
>>>> +	u32 page_offset, byte_count;
>>>> +	u64 rs_offset;
>>>> +	rdma_reader_fn reader;
>>>>
>>>> 	/* If no read list is present, return 0 */
>>>> 	ch = svc_rdma_get_read_chunk(rmsgp);
>>>> @@ -408,122 +368,53 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
>>>> 	if (ch_count > RPCSVC_MAXPAGES)
>>>> 		return -EINVAL;
>>> I'm not sure what this ^^^ ch_count check is doing, but maybe I haven't had
>>> enough caffeine this morning. Shouldn't this code be comparing the segment
>>> count, not the chunk count, with MAXPAGES?
>> Isn't ch_count really the number of chunks in the RPC?
> Sort of. Block comment in front of svc_rdma_rcl_chunk_counts() reads:
>
>   74  * Determine number of chunks and total bytes in chunk list. The chunk
>   75  * list has already been verified to fit within the RPCRDMA header.
>
> So, called from rdma_read_chunks(), ch_count is the number of chunks in
> the Read list.
>
> As you point out below, NFS/RDMA passes either a Read or a Write list,
> not both. So it amounts to the same thing as the total number of chunks
> in the RPC.
>
>> I'm not sure what "segment count” you are talking about?
> AFAICT a chunk is a list of segments. Thus one chunk can reference
> many pages, one per segment.

Ok yes.  rdma_read_chunk_frmr()/rdma_read_chunk_lcl() walk the segments 
creating rdma read work requests to pull the data for this chunk.

> If you print ch_count, it is 2 for NFS WRITEs from a Linux client,
> no matter how large the write payload is. Therefore I think the check
> as it is written is not particularly useful.

Why are there 2?

> The returned ch_count here is not used beyond that check, after the
> refactoring patch is applied. The returned byte_count includes all
> chunks in the passed-in chunk list, whereas I think it should count
> only the first chunk in the list.

So I'll investigate this more with the goal of only grabbing the first 
chunk.

>>>
>>>> -	/* Allocate temporary reply and chunk maps */
>>>> -	rpl_map = svc_rdma_get_req_map();
>>>> -	chl_map = svc_rdma_get_req_map();
>>>> -
>>>> -	if (!xprt->sc_frmr_pg_list_len)
>>>> -		sge_count = map_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
>>>> -					    rpl_map, chl_map, ch_count,
>>>> -					    byte_count);
>>>> -	else
>>>> -		sge_count = fast_reg_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
>>>> -						 rpl_map, chl_map, ch_count,
>>>> -						 byte_count);
>>>> -	if (sge_count < 0) {
>>>> -		err = -EIO;
>>>> -		goto out;
>>>> -	}
>>>> -
>>>> -	sgl_offset = 0;
>>>> -	ch_no = 0;
>>>> +	/* The request is completed when the RDMA_READs complete. The
>>>> +	 * head context keeps all the pages that comprise the
>>>> +	 * request.
>>>> +	 */
>>>> +	head->arg.head[0] = rqstp->rq_arg.head[0];
>>>> +	head->arg.tail[0] = rqstp->rq_arg.tail[0];
>>>> +	head->arg.pages = &head->pages[head->count];
>>>> +	head->hdr_count = head->count;
>>>> +	head->arg.page_base = 0;
>>>> +	head->arg.page_len = 0;
>>>> +	head->arg.len = rqstp->rq_arg.len;
>>>> +	head->arg.buflen = rqstp->rq_arg.buflen + PAGE_SIZE;
>>>>
>>>> +	page_no = 0; page_offset = 0;
>>>> 	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
>>>> -	     ch->rc_discrim != 0; ch++, ch_no++) {
>>>> -		u64 rs_offset;
>>>> -next_sge:
>>>> -		ctxt = svc_rdma_get_context(xprt);
>>>> -		ctxt->direction = DMA_FROM_DEVICE;
>>>> -		ctxt->frmr = hdr_ctxt->frmr;
>>>> -		ctxt->read_hdr = NULL;
>>>> -		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
>>>> -		clear_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
>>>> +	     ch->rc_discrim != 0; ch++) {
>>>
>>> As I understand it, this loop is iterating over the items in the RPC
>>> header's read chunk list.
>>>
>>> RFC 5667 section 4 says
>>>
>>> "The server MUST ignore any Read list for other NFS procedures, as well
>>> as additional Read list entries beyond the first in the list."
>>>
>> I interpret this to say the server should ignore an RDMA Write list, if present, when
>> processing an NFS WRITE (because the server emits RDMA Reads to the client in this case).
>> Similarly, it should ignore an RDMA Read list when processing an NFS READ (which generates
>> RDMA Writes from the server->client to fulfill the NFS READ).
> That’s already stated explicitly in a later paragraph. So this text
> is getting at something else, IMO. Here’s the full context:
>   
> 4.  NFS Versions 2 and 3 Mapping
>
>     A single RDMA Write list entry MAY be posted by the client to receive
>     either the opaque file data from a READ request or the pathname from
>     a READLINK request.  The server MUST ignore a Write list for any
>     other NFS procedure, as well as any Write list entries beyond the
>     first in the list.
>
>     Similarly, a single RDMA Read list entry MAY be posted by the client
>     to supply the opaque file data for a WRITE request or the pathname
>     for a SYMLINK request.  The server MUST ignore any Read list for
>     other NFS procedures, as well as additional Read list entries beyond
>     the first in the list.
>
>     Because there are no NFS version 2 or 3 requests that transfer bulk
>     data in both directions, it is not necessary to post requests
>     containing both Write and Read lists.  Any unneeded Read or Write
>     lists are ignored by the server.
>
> If there is a Read list, it can contain one chunk for NFS WRITE and
> SYMLINK operations, otherwise it should contain zero chunks. Anything
> else MUST be ignored (ie, the server mustn’t process the additional
> chunks, and mustn’t throw an error).
>
> Processing the second chunk from the client during NFS WRITE operations
> is incorrect. The additional chunk should be ignored, and the first
> chunk should be padded on the server to make things work right in the
> upper layer (the server’s NFS WRITE XDR decoder).

Ok.  Padding is another issue, and I'd like to defer it until we get 
this refactor patch merged.

>
>>> But rdma_read_chunks() still expects multiple chunks in the incoming list.
>> An RDMA Read list can have multiple chunks, yes?
> It can. But RFC 5667 suggests that particularly for NFS requests, only
> a Read list of zero or one chunks is valid.
>
>>> Should this code follow the RFC and process only the first chunk in
>>> each RPC header, or did I misunderstand the RFC text?
>>>
>>> I'm not sure how the RPC layer should enforce the requirement to ignore
>>> chunks for particular classes of NFS requests. But seems like valid
>>> NFS/RDMA requests will have only zero or one item in each chunk list.
>>>
>>>
>>> The ramification of this change:
>>>
>>> The Linux client sends an extra chunk which is a zero pad to satisfy XDR
>>> alignment. This results in an extra RDMA READ on the wire for a payload
>>> that is never more than 3 bytes of zeros.
>>>
>> This sounds like a logic bug in the server then.
> Perhaps it’s simply that this code was designed before RFC 5667 was
> published. Certainly the client expects the server might work this way.

I don't think so.  Just never implemented correctly.

>> You see these IOs on the wire?
> I see extra iterations in the RDMA READ loop on the server, both before
> and after the refactoring patch.
>
> I haven’t looked at the wire because ib_dump doesn’t work with the mthca
> provider.
>
>>> Section 3.7 of RFC 5666 states:
>>>
>>> "If in turn, no data remains to be decoded from the inline portion, then
>>> the receiver MUST conclude that roundup is present, and therefore it
>>> advances the XDR decode position to that indicated by the next chunk (if
>>> any).  In this way, roundup is passed without ever actually transferring
>>> additional XDR bytes."
>>>
>>> Later, it states:
>>>
>>> "Senders SHOULD therefore avoid encoding individual RDMA Read Chunks for
>>> roundup whenever possible."
>>>
>>> The Solaris NFS/RDMA server does not require this extra chunk, but Linux
>>> appears to need it. When I enable pad optimization on the Linux client,
>>> it works fine with the Solaris server. But the first NFS WRITE with an
>>> odd length against the Linux server causes connection loss and the client
>>> workload hangs.
>>>
>>> At some point I'd like to permanently enable this optimization on the
>>> Linux client. You can try this out with:
>>>
>>> sudo echo 1 > /proc/sys/sunrpc/rdma_pad_optimize
>>>
>>> The default contents of this file leave pad optimization disabled, for
>>> compatibility with the current Linux NFS/RDMA server.
>>>
>>> So rdma_read_chunks() needs to handle the implicit XDR length round-up.
>>> That's probably not hard.
>>>
>>> What I'm asking is:
>>>
>>> Do you agree the server should be changed to comply with section 4 of 5667?
>>>
>> I think it is complying and you are misinterpreting.  But I could be misinterpreting it
>> too :)
>>
>> But we should fix the pad thing.
> That may be enough to support a client that does not send the
> pad bytes in a separate chunk. However, I wonder how such a
> server would behave with the current client.
>
> True, this isn’t a regression, per se. The server is already
> behaving incorrectly without the refactoring patch.
>
> However, Tom’s refactoring rewrites all this logic anyway, and
> it wouldn’t be much of a stretch to make the server comply with
> RFC 5667, at this point.

Can we defer this until the refactor patch is in, then I'll work on a 
new patch for the pad stuff.

Thanks,

Steve.
