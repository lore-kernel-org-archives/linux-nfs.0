From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/33] SUNRPC: Fix read ordering problems with req->rq_private_buf.len
Date: Tue, 22 Apr 2008 11:04:09 -0400
Message-ID: <A2188756-9291-4B36-AF4F-E979F34C2D23@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204049.14124.11174.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <CAC2A944-24A0-4E20-83AE-2A4F88CF5C70@oracle.com> <1208824201.7767.53.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61500 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbYDVPFA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2008 11:05:00 -0400
In-Reply-To: <1208824201.7767.53.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 21, 2008, at 8:30 PM, Trond Myklebust wrote:
> On Mon, 2008-04-21 at 17:19 -0400, Chuck Lever wrote:
>> Hi Trond-
>>
>> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
>>> We want to ensure that req->rq_private_buf.len is updated before
>>> req->rq_received, so that call_decode() doesn't use an old value for
>>> req->rq_rcv_buf.len.
>>>
>>> In 'call_decode()' itself, instead of using task->tk_status (which
>>> is set
>>> using req->rq_received) must use the actual value of
>>> req->rq_private_buf.len when deciding whether or not the received
>>> RPC reply
>>> is too short.
>>>
>>> Finally ensure that we set req->rq_rcv_buf.len to zero when  
>>> retrying a
>>> request. A typo meant that we were resetting req->rq_private_buf.len
>>> in
>>> call_decode(), and then clobbering that value with the old
>>> rq_rcv_buf.len
>>> again in xprt_transmit().
>>
>> After staring at this for a while, the interaction between
>> xprt_complete_rqst and call_decode isn't clear to me.
>>
>> I take it there is no guarantee that the xdr_buf fields and
>> rq_received are completely updated before the task is awoken and
>> call_decode runs?
>
> The call could complete just as the RPC call is being woken up due  
> to a
> timeout.

I assume we also have a problem with concurrently processing  
retransmitted replies to the same RPC request.

These races would be nice to document, or even prevent.

You could add a bit flag to, say, the rpc_rqst structure that signals  
that a reply is already being processed.  Clear the bit in  
xprt_prepare_transmit; then a test_and_set_bit in xprt_lookup_rqst()  
and xprt_timer() would allow only one thread of execution to access  
each rpc_rqst during reply processing.

> In any case, we need to ensure that the ordering of the update
> is correct. We need to know that if a processor sees req- 
> >rq_received as
> being non-zero, then the same processor will see req- 
> >rq_private_buf.len
> as being updated: on something like an alpha processor or a PPC, we  
> need
> to use explicit read and write barriers to ensure this.

Understood.

The problem I'm underscoring here is that we have three largish  
functions -- call_status, call_decode, and call_verify -- each of  
which access these fields.  There is no clear documentation that  
describes the data dependencies between the soft IRQ callbacks and  
these functions (just a couple of one sentence comments that describe  
what is done but not why).

If nothing else, this patch should improve the documentation of the  
ordering requirements in addition to addressing the problems you found.

Btw:

+	if (req->rq_rcv_buf.len < 12) {

Is there an appropriate symbolic constant you can use here instead of  
the naked 12?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
