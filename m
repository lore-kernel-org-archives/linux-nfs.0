Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:30650 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbaGBUAE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2014 16:00:04 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport disconnect
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FE0C594@CMEXMB1.ad.emulex.com>
Date: Wed, 2 Jul 2014 15:59:58 -0400
Cc: Steve Wise <swise@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8D65ABF9-DC2B-4906-BBDE-60F03FCEF990@oracle.com>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net> <20140623223942.1634.89063.stgit@manet.1015granger.net> <EE7902D3F51F404C82415C4803930ACD3FE0C540@CMEXMB1.ad.emulex.com> <53B45D7B.4020705@opengridcomputing.com> <C9B761DF-7960-4346-949E-17A9BDD357DB@oracle.com> <005a01cf962e$43d44300$cb7cc900$@opengridcomputing.com> <EE7902D3F51F404C82415C4803930ACD3FE0C594@CMEXMB1.ad.emulex.com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 2, 2014, at 3:48 PM, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:

> 
> 
>> -----Original Message-----
>> From: Steve Wise [mailto:swise@opengridcomputing.com]
>> Sent: Thursday, July 03, 2014 1:16 AM
>> To: 'Chuck Lever'; Devesh Sharma
>> Cc: linux-rdma@vger.kernel.org; 'Linux NFS Mailing List'
>> Subject: RE: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport
>> disconnect
>> 
>> 
>> 
>>> -----Original Message-----
>>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>>> Sent: Wednesday, July 02, 2014 2:40 PM
>>> To: Steve Wise; Devesh Sharma
>>> Cc: linux-rdma@vger.kernel.org; Linux NFS Mailing List
>>> Subject: Re: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport
>>> disconnect
>>> 
>>> 
>>> On Jul 2, 2014, at 3:28 PM, Steve Wise <swise@opengridcomputing.com>
>> wrote:
>>> 
>>>> On 7/2/2014 2:06 PM, Devesh Sharma wrote:
>>>>> This change is very much prone to generate poll_cq errors because
>>>>> of un-cleaned
>>> completions which still
>>>>> point to the non-existent QPs. On the new connection when these
>>>>> completions are polled,
>>> the poll_cq will
>>>>> fail because old QP pointer is already NULL.
>>>>> Did anyone hit this situation during their testing?
>>> 
>>> I tested this aggressively with a fault injector that triggers regular
>>> connection disruption.
>>> 
>>>> Hey Devesh,
>>>> 
>>>> iw_cxgb4 will silently toss CQEs if the QP is not active.
>>> 
>>> xprtrdma relies on getting a completion (either successful or in
>>> error) for every WR it has posted. The goal of this patch is to avoid
>>> throwing away queued completions after a transport disconnect so we
>>> don't lose track of FRMR rkey updates (FAST_REG_MR and LOCAL_INV
>>> completions) and we can capture all RPC replies posted before the
>> connection was lost.
>>> 
>>> Sounds like we also need to keep the QP around, even in error state,
>>> until all known WRs on that QP have completed?
>>> 
> 
> Why not poll and process every completion during rpcrdma_cq_cleanup()….

Yes, I have a patch in the next version of this series that does that.
It just calls rpcrdma_sendcq_upcall() from the connect worker. I will
squash that change into this patch.

Maybe it needs to invoke rpcrdma_recvcq_upcall() there as well.


> 
>> 
>> Perhaps.
>> 
>>> 
>>>> 
>>>> 
>>>>>> -----Original Message-----
>>>>>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>>>>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>>>>>> Sent: Tuesday, June 24, 2014 4:10 AM
>>>>>> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
>>>>>> Subject: [PATCH v1 05/13] xprtrdma: Don't drain CQs on transport
>>>>>> disconnect
>>>>>> 
>>>>>> CQs are not destroyed until unmount. By draining CQs on transport
>>>>>> disconnect, successful completions that can change the
>>>>>> r.frmr.state field can be missed.
>>>>>> 
>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>> ---
>>>>>> net/sunrpc/xprtrdma/verbs.c |    5 -----
>>>>>> 1 file changed, 5 deletions(-)
>>>>>> 
>>>>>> diff --git a/net/sunrpc/xprtrdma/verbs.c
>>>>>> b/net/sunrpc/xprtrdma/verbs.c index 3c7f904..451e100 100644
>>>>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>>>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>>>>> @@ -873,9 +873,6 @@ retry:
>>>>>> 			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
>>>>>> 				" status %i\n", __func__, rc);
>>>>>> 
>>>>>> -		rpcrdma_clean_cq(ep->rep_attr.recv_cq);
>>>>>> -		rpcrdma_clean_cq(ep->rep_attr.send_cq);
>>>>>> -
>>>>>> 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
>>>>>> 		id = rpcrdma_create_id(xprt, ia,
>>>>>> 				(struct sockaddr *)&xprt->rx_data.addr);
>> @@ -985,8 +982,6 @@
>>>>>> rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia
>>>>>> *ia)  {
>>>>>> 	int rc;
>>>>>> 
>>>>>> -	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
>>>>>> -	rpcrdma_clean_cq(ep->rep_attr.send_cq);
>>>>>> 	rc = rdma_disconnect(ia->ri_id);
>>>>>> 	if (!rc) {
>>>>>> 		/* returns without wait if not connected */
>>>>>> 
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe
>>>>>> linux-rdma" in the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>>> N     r  y   b X  ǧv ^ )޺{.n +    {   "  ^n r   z   h    &   G
>>>>> h ( 階
>>> ݢj"   m     z ޖ   f   h   ~ mml==
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>>> in the body of a message to majordomo@vger.kernel.org More
>> majordomo
>>>> info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>> 
>>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



