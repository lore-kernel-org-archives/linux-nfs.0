Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa06-02.prod.phx3.secureserver.net ([173.201.192.103]:43828
	"EHLO p3plsmtpa06-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757339AbbGUAKl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 20:10:41 -0400
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
To: Chuck Lever <chuck.lever@oracle.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
 <20150720222608.GA12005@obsidianresearch.com>
 <73A27338-7EFC-4F54-A15E-09B9D5145242@oracle.com>
 <20150720224134.GA12278@obsidianresearch.com>
 <D54C793F-7420-4FC8-9BCA-32C19EC492AA@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <55AD8E1D.2010803@talpey.com>
Date: Mon, 20 Jul 2015 17:11:09 -0700
MIME-Version: 1.0
In-Reply-To: <D54C793F-7420-4FC8-9BCA-32C19EC492AA@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/20/2015 4:36 PM, Chuck Lever wrote:
>
> On Jul 20, 2015, at 6:41 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
>
>> On Mon, Jul 20, 2015 at 06:31:11PM -0400, Chuck Lever wrote:
>>>
>>> On Jul 20, 2015, at 6:26 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
>>>
>>>> On Mon, Jul 20, 2015 at 03:03:11PM -0400, Chuck Lever wrote:
>>>>> +	iov->length = size;
>>>>> +	iov->lkey = ia->ri_have_dma_lkey ?
>>>>> +				ia->ri_dma_lkey : ia->ri_bind_mem->lkey;
>>>>> +	rb->rg_size = size;
>>>>> +	rb->rg_owner = NULL;
>>>>> 	return rb;
>>>>
>>>> There is something odd looking about this..
>>>>
>>>> ri_bind_mem is only setup in the RPCRDMA_ALLPHYSICAL and
>>>> RPCRDMA_MTHCAFMR cases.
>>>>
>>>> RPCRDMA_FRMR doesn't set it up.
>>>>
>>>> So this code in rpcrdma_alloc_regbuf is never called for the FRMR
>>>> case?
>>>>
>>>> If yes, then, how is FRMR working? There is absolutely no reason to
>>>> use FRMR to register local send buffers, just use the global all
>>>> memory lkey...
>>>>
>>>> If no, then that is an oops?
>>>
>>> I’ve tested this code, no oops.
>>>
>>> FRWR always uses the DMA lkey. xprtrdma does not use FRWR if
>>> IB_DEVICE_LOCAL_DMA_LKEY is not asserted.
>>
>> Ah, I see. Ok.
>>
>> Is there a reason to link FRWR and LOCAL_DMA_LKEY together?
>
> Tom would know.

Tom Talpey or Tom Tucker? I don't think I used a dma_lkey at all
in the original work, but there were some changes later.

I thought not all rnic's supported a dma_lkey. So requiring it
seems like a bad idea, to me.

>> Just use
>> the code you have for fmr with frwr to get the lkey, probably move it
>> to rpcrdma_ia_open .. Physical MR should create a 2nd MR dedicated for
>> rkey use.

But FMR is not supported by modern mlx5 and cxgb4?
