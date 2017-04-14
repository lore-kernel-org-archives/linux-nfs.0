Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34137 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdDNQKK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2017 12:10:10 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 09/14] svcrdma: Report Write/Reply chunk overruns
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170414155634.GC5362@fieldses.org>
Date: Fri, 14 Apr 2017 12:10:03 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FCC0F429-0799-4416-9A61-ABD19C773AA9@oracle.com>
References: <20170409163820.15073.43257.stgit@klimt.1015granger.net> <20170409170641.15073.82788.stgit@klimt.1015granger.net> <20170414155634.GC5362@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 14, 2017, at 11:56 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Sun, Apr 09, 2017 at 01:06:41PM -0400, Chuck Lever wrote:
>> Observed at Connectathon 2017.
>> 
>> If a client has underestimated the size of a Write or Reply chunk,
>> the Linux server writes as much payload data as it can, then it
>> recognizes there was a problem and closes the connection without
>> sending the transport header.
> 
> Why would the client underestimate?  Is this a client-side bug?

It can be a bug, and the behavior in this case is that the
client retransmits indefinitely and deadlocks the transport,
because the client's upper layer never sees a reply.

But as you know there are some NFS operations where the client
cannot predict in advance how large the reply will be. In
particular the upper bound size of an NFSACL GETACL reply or
certain NFSv4 GETATTR attributes are not predictable. These
I might categorize as protocol bugs.

A client can do its best by posting a very large reply buffer
for such operations, but since these situations typically
are in practice rare, but NFSv4 GETATTR can be a relatively
common operation, clients post a few dozen KB for the reply
buffer and call it a day.

In these cases (if they should ever fail IRL), returning an
error is polite and allows operation of other RPCs on that
transport to continue.


> --b.
> 
>> 
>> This creates a couple of problems:
>> 
>> <> The client never receives indication of the server-side failure,
>>   so it continues to retransmit the bad RPC. Forward progress on
>>   the transport is blocked.
>> 
>> <> The reply payload pages are not moved out of the svc_rqst, thus
>>   they can be released by the RPC server before the RDMA Writes
>>   have completed.
>> 
>> The new rdma_rw-ized helpers return a distinct error code when a
>> Write/Reply chunk overrun occurs, so it's now easy for the caller
>> (svc_rdma_sendto) to recognize this case.
>> 
>> Instead of dropping the connection, post an RDMA_ERROR message. The
>> client now sees an RDMA_ERROR and can properly terminate the RPC
>> transaction.
>> 
>> As part of the new logic, set up the same delayed release for these
>> payload pages as would have occurred in the normal case.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
>> ---
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c |   58 ++++++++++++++++++++++++++++++++-
>> 1 file changed, 56 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> index 0b646e8..e514f68 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -621,6 +621,48 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
>> 	return ret;
>> }
>> 
>> +/* Given the client-provided Write and Reply chunks, the server was not
>> + * able to form a complete reply. Return an RDMA_ERROR message so the
>> + * client can retire this RPC transaction. As above, the Send completion
>> + * routine releases payload pages that were part of a previous RDMA Write.
>> + *
>> + * Remote Invalidation is skipped for simplicity.
>> + */
>> +static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
>> +				   __be32 *rdma_resp, struct svc_rqst *rqstp)
>> +{
>> +	struct svc_rdma_op_ctxt *ctxt;
>> +	__be32 *p;
>> +	int ret;
>> +
>> +	ctxt = svc_rdma_get_context(rdma);
>> +
>> +	/* Replace the original transport header with an
>> +	 * RDMA_ERROR response. XID etc are preserved.
>> +	 */
>> +	p = rdma_resp + 3;
>> +	*p++ = rdma_error;
>> +	*p   = err_chunk;
>> +
>> +	ret = svc_rdma_map_reply_hdr(rdma, ctxt, rdma_resp, 20);
>> +	if (ret < 0)
>> +		goto err;
>> +
>> +	svc_rdma_save_io_pages(rqstp, ctxt);
>> +
>> +	ret = svc_rdma_post_send_wr(rdma, ctxt, 1 + ret, 0);
>> +	if (ret)
>> +		goto err;
>> +
>> +	return 0;
>> +
>> +err:
>> +	pr_err("svcrdma: failed to post Send WR (%d)\n", ret);
>> +	svc_rdma_unmap_dma(ctxt);
>> +	svc_rdma_put_context(ctxt, 1);
>> +	return ret;
>> +}
>> +
>> void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
>> {
>> }
>> @@ -683,13 +725,13 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>> 		/* XXX: Presume the client sent only one Write chunk */
>> 		ret = svc_rdma_send_write_chunk(rdma, wr_lst, xdr);
>> 		if (ret < 0)
>> -			goto err1;
>> +			goto err2;
>> 		svc_rdma_xdr_encode_write_list(rdma_resp, wr_lst, ret);
>> 	}
>> 	if (rp_ch) {
>> 		ret = svc_rdma_send_reply_chunk(rdma, rp_ch, wr_lst, xdr);
>> 		if (ret < 0)
>> -			goto err1;
>> +			goto err2;
>> 		svc_rdma_xdr_encode_reply_chunk(rdma_resp, rp_ch, ret);
>> 	}
>> 
>> @@ -702,6 +744,18 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>> 		goto err0;
>> 	return 0;
>> 
>> + err2:
>> +	if (ret != -E2BIG)
>> +		goto err1;
>> +
>> +	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
>> +	if (ret)
>> +		goto err1;
>> +	ret = svc_rdma_send_error_msg(rdma, rdma_resp, rqstp);
>> +	if (ret < 0)
>> +		goto err0;
>> +	return 0;
>> +
>>  err1:
>> 	put_page(res_page);
>>  err0:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



