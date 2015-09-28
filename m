Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:48438 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933483AbbI1O5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2015 10:57:23 -0400
Subject: Re: [PATCH 1/3] xprtrdma: disconnect and flush cqs before freeing
 buffers
To: Steve Wise <swise@opengridcomputing.com>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
References: <20150921172423.9761.92399.stgit@build2.ogc.int>
 <56094F16.3040608@opengridcomputing.com> <56095286.6030201@Netapp.com>
 <005401d0f9fd$16399920$42accb60$@opengridcomputing.com>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <5609554F.3050201@Netapp.com>
Date: Mon, 28 Sep 2015 10:57:19 -0400
MIME-Version: 1.0
In-Reply-To: <005401d0f9fd$16399920$42accb60$@opengridcomputing.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/28/2015 10:50 AM, Steve Wise wrote:
> 
> 
>> -----Original Message-----
>> From: Anna Schumaker [mailto:Anna.Schumaker@netapp.com]
>> Sent: Monday, September 28, 2015 9:45 AM
>> To: Steve Wise; trond.myklebust@primarydata.com; bfields@fieldses.org
>> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
>> Subject: Re: [PATCH 1/3] xprtrdma: disconnect and flush cqs before freeing buffers
>>
>> Hi Steve,
>>
>> On 09/28/2015 10:30 AM, Steve Wise wrote:
>>> On 9/21/2015 12:24 PM, Steve Wise wrote:
>>>> Otherwise a FRMR completion can cause a touch-after-free crash.
>>>>
>>>> In xprt_rdma_destroy(), call rpcrdma_buffer_destroy() only after calling
>>>> rpcrdma_ep_destroy().
>>>>
>>>> In rpcrdma_ep_destroy(), disconnect the cm_id first which should flush the
>>>> qp, then drain the cqs, then destroy the qp, and finally destroy the cqs.
>>>>
>>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>>> Tested-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>
>>> Hey Trond,  I'm hoping this can make 4.3-rc (and stable if you agree).
>>
>> This patch looks fine to me.  I'll pass it on to Trond!
>>
>> I'll save patch 3/3 for the Linux 4.4 merge.
>>
>> Thanks,
>> Anna
>>
> 
> Thanks.  Going forward I'll make sure you are CC'd for client patches too!  I wasn't sure if you are formally taking all xprtrdma patches and sending them to Trond...

Yeah, I'm taking all the client RDMA patches.  I'm glad that's cleared up now! :)

Anna

> 
> Steve.
> 
> 

