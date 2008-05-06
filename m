From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  8/17] svcrdma: Return error from rdma_read_xdr so
 caller knows to free context
Date: Mon, 05 May 2008 21:05:37 -0500
Message-ID: <C4452721.4958A%tom@opengridcomputing.com>
References: <20080505225207.GJ12814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:5445 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755921AbYEFC2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 22:28:23 -0400
In-Reply-To: <20080505225207.GJ12814@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 5/5/08 5:52 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 02, 2008 at 11:28:40AM -0500, Tom Tucker wrote:
>> The rdma_read_xdr function did discriminate between no read-list and
>     ^^^
>     did not?
> 
Ack.

>> an error posting the read-list. This results a leak of a page in the
>> context when an asyncrhonous error occurs on the transport.
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> 
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   17 +++++++++++++----
>>  1 files changed, 13 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index f3a108a..0ac375a 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -260,11 +260,16 @@ static int rdma_read_max_sge(struct svcxprt_rdma *xprt,
>> int sge_count)
>>   * On our side, we need to read into a pagelist. The first page immediately
>>   * follows the RPC header.
>>   *
>> - * This function returns 1 to indicate success. The data is not yet in
>> + * This function returns:
>> + * 0 - No error and no read-list found.
>> + *
>> + * 1 - Successful read-list processing. The data is not yet in
>>   * the pagelist and therefore the RPC request must be deferred. The
>>   * I/O completion will enqueue the transport again and
>>   * svc_rdma_recvfrom will complete the request.
>>   *
>> + * <0 - Error processing/posting read-list.
>> + *
>>   * NOTE: The ctxt must not be touched after the last WR has been posted
>>   * because the I/O completion processing may occur on another
>>   * processor and free / modify the context. Ne touche pas!
>> @@ -398,7 +403,7 @@ next_sge:
>> svc_rdma_put_context(head, 1);
>> head = ctxt;
>> }
>> -  return 0;
>> +  return err;
>> }
>>  
>> return 1;
>> @@ -536,8 +541,12 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>> * it. Not that in this case, we don't return the RQ credit
>> * until after the read completes.
>> */
>> - if (rdma_read_xdr(rdma_xprt, rmsgp, rqstp, ctxt)) {
>> -  svc_xprt_received(xprt);
>> + ret = rdma_read_xdr(rdma_xprt, rmsgp, rqstp, ctxt);
>> + if (ret) {
>> +  if (ret > 0)
>> +   svc_xprt_received(xprt);
>> +  else
>> +   svc_rdma_put_context(ctxt, 1);
>> return 0;
>> }
>>  
> 
> Possibly slightly more straightforward?:
> 
> /* Read read-list data. */
> ret = rdma_read_xdr(rdma_xprt, rmsgp, rqstp, ctxt);
> if (ret < 0) {
> svc_rdma_put_context(ctxt, 1);
> return 0;
> }
> if (ret > 0) {
> /*
> * We need to wait; defer the request.  Note that in
> * this case, we don't return the RQ credit until after
> * the read completes.
> */
> svc_xprt_received(xprt);
> return 0;
> }
> ...
> 

Yep. I rewrote that code three different ways and never liked it. I think
you've got it right first try... :-)

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


