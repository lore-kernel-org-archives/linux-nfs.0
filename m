Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21332 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751240Ab0IMOhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 10:37:41 -0400
Message-ID: <4C8E3733.2000607@panasas.com>
Date: Mon, 13 Sep 2010 16:37:39 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>	 <1283450419-5648-8-git-send-email-iisaman@netapp.com>	 <20100910235858.GB11231@infradead.org>	 <1284163679.14078.106.camel@heimdal.trondhjem.org>	 <4C8E0A03.3020500@panasas.com> <1284380997.2825.2.camel@heimdal.trondhjem.org>
In-Reply-To: <1284380997.2825.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-13 14:29, Trond Myklebust wrote:
> On Mon, 2010-09-13 at 13:24 +0200, Benny Halevy wrote:
>> On 2010-09-11 03:07, Trond Myklebust wrote:
>>> On Fri, 2010-09-10 at 19:58 -0400, Christoph Hellwig wrote:
>>>>> +EXPORT_SYMBOL(pnfs_register_layoutdriver);
>>>>
>>>> Al exports from nfs.ko needs to be _GPL - this is in no way a public
>>>> API, just an internal subdivision of the nfs client.
>>>
>>> ACK. We're not committing to supporting a stable ABI here in any way,
>>> shape or form...
>>
>> OK, not yet.
>>
>> However, on the longer run I'd like us to consider formalizing
>> the kABI for non-GPLed layout drivers.
>>
>> I think that this is a great selling point as it fully materializes the
>> extensibility of the layout-type / layout-driver design model.
> 
> No. I'm not committing to a kabi, ever...

Care to explain your reasoning in some more details?

> 
> Trond
> 
