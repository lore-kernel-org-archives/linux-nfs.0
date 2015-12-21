Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49319 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbbLUWMA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Dec 2015 17:12:00 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v4 01/11] svcrdma: Do not send XDR roundup bytes for a write chunk
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151221212959.GE7869@fieldses.org>
Date: Mon, 21 Dec 2015 17:11:56 -0500
Cc: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DF5B7D29-0C6C-47EF-8E3E-74BF137D7F95@oracle.com>
References: <20151214211951.12932.99017.stgit@klimt.1015granger.net> <20151214213009.12932.60521.stgit@klimt.1015granger.net> <20151221210708.GD7869@fieldses.org> <D0AD304E-0356-48DE-A68D-F9F8930D854D@oracle.com> <20151221212959.GE7869@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 21, 2015, at 4:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Mon, Dec 21, 2015 at 04:15:23PM -0500, Chuck Lever wrote:
>> 
>>> On Dec 21, 2015, at 4:07 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Mon, Dec 14, 2015 at 04:30:09PM -0500, Chuck Lever wrote:
>>>> Minor optimization: when dealing with write chunk XDR roundup, do
>>>> not post a Write WR for the zero bytes in the pad. Simply update
>>>> the write segment in the RPC-over-RDMA header to reflect the extra
>>>> pad bytes.
>>>> 
>>>> The Reply chunk is also a write chunk, but the server does not use
>>>> send_write_chunks() to send the Reply chunk. That's OK in this case:
>>>> the server Upper Layer typically marshals the Reply chunk contents
>>>> in a single contiguous buffer, without a separate tail for the XDR
>>>> pad.
>>>> 
>>>> The comments and the variable naming refer to "chunks" but what is
>>>> really meant is "segments." The existing code sends only one
>>>> xdr_write_chunk per RPC reply.
>>>> 
>>>> The fix assumes this as well. When the XDR pad in the first write
>>>> chunk is reached, the assumption is the Write list is complete and
>>>> send_write_chunks() returns.
>>>> 
>>>> That will remain a valid assumption until the server Upper Layer can
>>>> support multiple bulk payload results per RPC.
>>>> 
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> net/sunrpc/xprtrdma/svc_rdma_sendto.c |    7 +++++++
>>>> 1 file changed, 7 insertions(+)
>>>> 
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> index 969a1ab..bad5eaa 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>>>> @@ -342,6 +342,13 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>>>> 						arg_ch->rs_handle,
>>>> 						arg_ch->rs_offset,
>>>> 						write_len);
>>>> +
>>>> +		/* Do not send XDR pad bytes */
>>>> +		if (chunk_no && write_len < 4) {
>>>> +			chunk_no++;
>>>> +			break;
>>> 
>>> I'm pretty lost in this code.  Why does (chunk_no && write_len < 4) mean
>>> this is xdr padding?
>> 
>> Chunk zero is always data. Padding is always going to be
>> after the first chunk. Any chunk after chunk zero that is
>> shorter than XDR quad alignment is going to be a pad.
> 
> I don't really know what a chunk is....  Looking at the code:
> 
> 	write_len = min(xfer_len, be32_to_cpu(arg_ch->rs_length));
> 
> so I guess the assumption is just that those rs_length's are always a
> multiple of four?

The example you recently gave was a two-byte NFS READ
that crosses a page boundary.

In that case, the NFSD would pass down an xdr_buf that
has one byte in a page, one byte in another page, and
a two-byte XDR pad. The logic introduced by this
optimization would be fooled, and neither the second
byte nor the XDR pad would be written to the client.

Unless you can think of a way to recognize an XDR pad
in the xdr_buf 100% of the time, you should drop this
patch.

As far as I know, none of the other patches in this
series depend on this optimization, so please merge
them if you can.


> --b.
> 
>> 
>> Probably too clever. Is there a better way to detect
>> the XDR pad?
>> 
>> 
>>>> +		}
>>>> +
>>>> 		chunk_off = 0;
>>>> 		while (write_len) {
>>>> 			ret = send_write(xprt, rqstp,
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




