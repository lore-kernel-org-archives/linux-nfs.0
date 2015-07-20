Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35553 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbbGTWVo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 18:21:44 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55AD6E43.60205@talpey.com>
Date: Mon, 20 Jul 2015 18:21:25 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6AEC449B-7E77-4DD1-BE6F-A68F6D8D022D@oracle.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net> <20150720190311.10997.12636.stgit@manet.1015granger.net> <55AD5B48.3010906@talpey.com> <06BCEDB0-1589-454B-BDD1-9937290AAD29@oracle.com> <55AD6E43.60205@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 20, 2015, at 5:55 PM, Tom Talpey <tom@talpey.com> wrote:

> On 7/20/2015 1:55 PM, Chuck Lever wrote:
>> On Jul 20, 2015, at 4:34 PM, Tom Talpey <tom@talpey.com> wrote:
>> 
>>> On 7/20/2015 12:03 PM, Chuck Lever wrote:
>>>> All HCA providers have an ib_get_dma_mr() verb. Thus
>>>> rpcrdma_ia_open() will either grab the device's local_dma_key if one
>>>> is available, or it will call ib_get_dma_mr() which is a 100%
>>>> guaranteed fallback.
>>> 
>>> I recall that in the past, some providers did not support mapping
>>> all of the machine's potential physical memory with a single dma_mr.
>>> If an rnic did/does not support 44-ish bits of length per region,
>>> for example.
>> 
>> The buffers affected by this change are small, so I’m confident that
>> restriction would not be a problem here.
> 
> It's not about the buffer size, it's about the region. Because the
> get_dma_mr does not specify a base address and length, the rnic must
> basically attempt to map a base of zero and a length of the largest
> physical offset.

Understood now, but:


> This is not the case with the previous phys_reg_mr, which specified
> the exact phys page range.

rpcrdma_ia_open() fails immediately if IB_DEVICE_LOCAL_DMA_LKEY
is not asserted _and_ ib_get_dma_mr() fails. We never get to the
logic in rpcrdma_regbuf_alloc() in that case, so ib_reg_phys_mr()
would still never be invoked. That really is dead code.

If you prefer, I can adjust the patch description to remove the
“100% guaranteed fallback” line.


--
Chuck Lever



