Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45640 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754676Ab0IML24 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 07:28:56 -0400
Message-ID: <4C8E0AF5.1000500@panasas.com>
Date: Mon, 13 Sep 2010 13:28:53 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file layout
 driver
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>	 <1283450419-5648-9-git-send-email-iisaman@netapp.com>	 <1284147111.10062.74.camel@heimdal.trondhjem.org>	 <20100910235600.GA11231@infradead.org>	 <1284163433.14078.102.camel@heimdal.trondhjem.org>	 <20100911000749.GA31628@infradead.org> <1284163980.14078.111.camel@heimdal.trondhjem.org>
In-Reply-To: <1284163980.14078.111.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-11 03:13, Trond Myklebust wrote:
> On Fri, 2010-09-10 at 20:07 -0400, Christoph Hellwig wrote:
>> On Fri, Sep 10, 2010 at 08:03:53PM -0400, Trond Myklebust wrote:
>>> So you are saying we should simply equate CONFIG_PNFS_FILE_LAYOUT and
>>> CONFIG_NFS_V4_1 right now? Yep, I'd be fine with that... I'm still
>>> working on the patches to get rid of all these CONFIG options, but
>>> ultimately this is what I'm working towards.
>>
>> If you don't want a separate option that's up to you, but I don't think
>> forcing people to built the pnfs file layout just because they want nfs4.1
>> features is an all that smart idea.
> 
> IMHO it should be fine.
> 
> Most people will be compiling NFS as a module, in which case, the pnfs
> file layout is just another module that can be left out from the final
> binary if people don't want it.
> 
> I'm still waiting to hear from people who want to compile NFSv4.1 in the
> main kernel, but who want pNFS to be modularised.

If a user uses a different layout driver and not the files layout driver
than the latter is just extra baggage.  That said, the way Fred implemented
the Kconfig option, it cannot be disabled independently anyway so it's rather
pointless.

Benny

> 
> Cheers
>   Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
