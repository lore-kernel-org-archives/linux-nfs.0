Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21338 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbbFASpN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 14:45:13 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 01/10] svcrdma: Fix byte-swapping in svc_rdma_sendto.c
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150601184047.GE26489@fieldses.org>
Date: Mon, 1 Jun 2015 14:47:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <26074859-F4ED-4314-8548-60161595D855@oracle.com>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net> <20150526174837.7061.88468.stgit@klimt.1015granger.net> <20150601184047.GE26489@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 1, 2015, at 2:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, May 26, 2015 at 01:48:37PM -0400, Chuck Lever wrote:
>> In send_write_chunks(), we have:
>> 
>> 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
>> 	     xfer_len && chunk_no < arg_ary->wc_nchunks;
>> 	     chunk_no++) {
>> 		 . . .
>> 	}
>> 
>> Note that arg_ary->wc_nchunk is in network byte-order. For the
>> comparison to work correctly, both have to be in native byte-order.
>> 
>> In send_reply_chunks, we have:
>> 
>> 	write_len = min(xfer_len, htonl(ch->rs_length));
>> 
>> xfer_len is in native byte-order, and ch->rs_length is in
>> network byte-order. be32_to_cpu() is the correct byte swap
>> for ch->rs_length.
>> 
>> As an additional clean up, replace ntohl() with be32_to_cpu() in
>> a few other places.
> 
> Why?  (Not arguing, really, just wondering.)

It’s just clean up to match the rest of the code. And it kind of marks
the places that have been reviewed.


> --b.
> 
>> 
>> This appears to address a problem with large rsize hangs while
>> using PHYSICAL memory registration. I suspect that is the only
>> registration mode that uses more than one chunk element.
>> 
>> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=248
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c |   14 ++++++++------
>> 1 files changed, 8 insertions(+), 6 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> index 7de33d1..109e967 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -240,6 +240,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>> 	u32 xdr_off;
>> 	int chunk_off;
>> 	int chunk_no;
>> +	int nchunks;
>> 	struct rpcrdma_write_array *arg_ary;
>> 	struct rpcrdma_write_array *res_ary;
>> 	int ret;
>> @@ -251,14 +252,15 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>> 		&rdma_resp->rm_body.rm_chunks[1];
>> 
>> 	/* Write chunks start at the pagelist */
>> +	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
>> 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
>> -	     xfer_len && chunk_no < arg_ary->wc_nchunks;
>> +	     xfer_len && chunk_no < nchunks;
>> 	     chunk_no++) {
>> 		struct rpcrdma_segment *arg_ch;
>> 		u64 rs_offset;
>> 
>> 		arg_ch = &arg_ary->wc_array[chunk_no].wc_target;
>> -		write_len = min(xfer_len, ntohl(arg_ch->rs_length));
>> +		write_len = min(xfer_len, be32_to_cpu(arg_ch->rs_length));
>> 
>> 		/* Prepare the response chunk given the length actually
>> 		 * written */
>> @@ -270,7 +272,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>> 		chunk_off = 0;
>> 		while (write_len) {
>> 			ret = send_write(xprt, rqstp,
>> -					 ntohl(arg_ch->rs_handle),
>> +					 be32_to_cpu(arg_ch->rs_handle),
>> 					 rs_offset + chunk_off,
>> 					 xdr_off,
>> 					 write_len,
>> @@ -318,13 +320,13 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
>> 		&rdma_resp->rm_body.rm_chunks[2];
>> 
>> 	/* xdr offset starts at RPC message */
>> -	nchunks = ntohl(arg_ary->wc_nchunks);
>> +	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
>> 	for (xdr_off = 0, chunk_no = 0;
>> 	     xfer_len && chunk_no < nchunks;
>> 	     chunk_no++) {
>> 		u64 rs_offset;
>> 		ch = &arg_ary->wc_array[chunk_no].wc_target;
>> -		write_len = min(xfer_len, htonl(ch->rs_length));
>> +		write_len = min(xfer_len, be32_to_cpu(ch->rs_length));
>> 
>> 		/* Prepare the reply chunk given the length actually
>> 		 * written */
>> @@ -335,7 +337,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
>> 		chunk_off = 0;
>> 		while (write_len) {
>> 			ret = send_write(xprt, rqstp,
>> -					 ntohl(ch->rs_handle),
>> +					 be32_to_cpu(ch->rs_handle),
>> 					 rs_offset + chunk_off,
>> 					 xdr_off,
>> 					 write_len,

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



