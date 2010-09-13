Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30186 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754677Ab0IMLYy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 07:24:54 -0400
Message-ID: <4C8E0A03.3020500@panasas.com>
Date: Mon, 13 Sep 2010 13:24:51 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Christoph Hellwig <hch@infradead.org>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>	 <1283450419-5648-8-git-send-email-iisaman@netapp.com>	 <20100910235858.GB11231@infradead.org> <1284163679.14078.106.camel@heimdal.trondhjem.org>
In-Reply-To: <1284163679.14078.106.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-11 03:07, Trond Myklebust wrote:
> On Fri, 2010-09-10 at 19:58 -0400, Christoph Hellwig wrote:
>>> +EXPORT_SYMBOL(pnfs_register_layoutdriver);
>>
>> Al exports from nfs.ko needs to be _GPL - this is in no way a public
>> API, just an internal subdivision of the nfs client.
> 
> ACK. We're not committing to supporting a stable ABI here in any way,
> shape or form...

OK, not yet.

However, on the longer run I'd like us to consider formalizing
the kABI for non-GPLed layout drivers.

I think that this is a great selling point as it fully materializes the
extensibility of the layout-type / layout-driver design model.

Benny

> 
> Cheers
>   Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
