From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  2/17] svcrdma: Fix race with dto_tasklet in
 svc_rdma_send
Date: Tue, 06 May 2008 19:45:08 -0500
Message-ID: <C44665C4.4AFC2%tom@opengridcomputing.com>
References: <20080506211851.GM13484@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:13391 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418AbYEGApX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 20:45:23 -0400
In-Reply-To: <20080506211851.GM13484@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 5/6/08 4:18 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, May 05, 2008 at 09:26:02PM -0500, Tom Tucker wrote:
>> 
>> 
>> 
>> On 5/5/08 5:06 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> 
>>> On Fri, May 02, 2008 at 11:28:34AM -0500, Tom Tucker wrote:
>>>> The svc_rdma_send function will attempt to reap SQ WR to make room for
>>>> a new request if it finds the SQ full. This function races with the
>>>> dto_tasklet that also reaps SQ WR. To avoid calling the function
>>>> unnecessarily use test_and_clear_bit with the RDMAXPRT_SQ_PENDING
>>>> flag to serialize access to the sq_cq_reap function.
>>> 
>>> OK.  I won't pretend to understand much of this, but--would it be worth
>>> pulling out the added code here into a helper function, since it now
>>> exists in two different places?  (Especially if correctness depends on
>>> the same thing happening in both the places this bit can be cleared.)
>> 
>> Yes. Good suggestions.
>> 
>> BTW, this code is here because the SQ is undersized for big data. Since a
>> single NFS_READ/WRITE can result in an attempt to fetch a large amount of
>> data from the client (2M) and depending on certain HW resources this can
>> result in a lot of WR being posted to the SQ.
> 
> WR is write request, SQ is send queue?  (In which case this happens on
> nfs read operations?)  I'm behind....
> 
>> That said, there is a change coming in the 2.6.27 time frame that supports
>> what is called Fast NSMR register. This allows the transport to effectively
>> DMA map the entire transfer size (32k -- 2M) all as a single SGE. This will
>> take a lot of pressure off the SQ and effectively make this code
>> unnecessary.
> 
> OK!
> 
> Ideally we'd have patches for 2.6.27 in linux-next for a little while
> first, so we should try to have that ready in a month or so, when the
> -rc's start looking final.

It may be .28 then.  A lot of pieces have to come together...

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


