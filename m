Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20223 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbbLMToY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Dec 2015 14:44:24 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v3 1/6] svcrdma: Do not send XDR roundup bytes for a write chunk
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <566CE288.6000808@talpey.com>
Date: Sun, 13 Dec 2015 14:44:21 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BBFA1517-1965-4486-B027-E6CE485E999C@oracle.com>
References: <20151207203851.12988.97804.stgit@klimt.1015granger.net> <20151207204231.12988.59287.stgit@klimt.1015granger.net> <566CE288.6000808@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom-


> On Dec 12, 2015, at 10:14 PM, Tom Talpey <tom@talpey.com> wrote:
> 
> Two small comments.
> 
> On 12/7/2015 12:42 PM, Chuck Lever wrote:
>> Minor optimization: when dealing with write chunk XDR roundup, do
>> not post a Write WR for the zero bytes in the pad. Simply update
>> the write segment in the RPC-over-RDMA header to reflect the extra
>> pad bytes.
>> 
>> The Reply chunk is also a write chunk, but the server does not use
>> send_write_chunks() to send the Reply chunk. That's OK in this case:
>> the server Upper Layer typically marshals the Reply chunk contents
>> in a single contiguous buffer, without a separate tail for the XDR
>> pad.
>> 
>> The comments and the variable naming refer to "chunks" but what is
>> really meant is "segments." The existing code sends only one
>> xdr_write_chunk per RPC reply.
>> 
>> The fix assumes this as well. When the XDR pad in the first write
>> chunk is reached, the assumption is the Write list is complete and
>> send_write_chunks() returns.
>> 
>> That will remain a valid assumption until the server Upper Layer can
>> support multiple bulk payload results per RPC.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c |    7 +++++++
>>  1 file changed, 7 insertions(+)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> index 969a1ab..bad5eaa 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -342,6 +342,13 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>>  						arg_ch->rs_handle,
>>  						arg_ch->rs_offset,
>>  						write_len);
>> +
>> +		/* Do not send XDR pad bytes */
> 
> It might be clearer to say "marshal" instead of "send".

Marshaling each segment happens unconditionally in the
svc_rdma_xdr_encode_array_chunk() call just before this
comment. I really do mean "Do not send" here: the patch
is intended to squelch the RDMA Write of the XDR pad for
this chunk.

Perhaps "Do not write" would be more precise, but Bruce
has already committed this patch, IIRC.


>> +		if (chunk_no && write_len < 4) {
> 
> Why is it necessary to check for chunk_no == 0? It is not
> possible for leading data to ever be padding, nor is a leading
> data element ever less than 4 bytes long. Right?

I'm checking for chunk_no != 0, for exactly the reasons
you mentioned.


> Tom.
> 
>> +			chunk_no++;
>> +			break;
>> +		}
>> +
>>  		chunk_off = 0;
>>  		while (write_len) {
>>  			ret = send_write(xprt, rqstp,

--
Chuck Lever




