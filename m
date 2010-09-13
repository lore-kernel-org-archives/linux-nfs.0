Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41655 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751836Ab0IMPOv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 11:14:51 -0400
Message-ID: <4C8E3FE7.8000404@panasas.com>
Date: Mon, 13 Sep 2010 17:14:47 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com> <1283450419-5648-8-git-send-email-iisaman@netapp.com> <1284146604.10062.68.camel@heimdal.trondhjem.org> <4C8E05CD.7090407@panasas.com> <20100913144444.GA31105@infradead.org>
In-Reply-To: <20100913144444.GA31105@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/13/2010 04:44 PM, Christoph Hellwig wrote:
> On Mon, Sep 13, 2010 at 01:06:53PM +0200, Boaz Harrosh wrote:
>> Me two BTW.
>> I will later need a per super-block resources, mainly slabs and work_q.
> 
> Slab caches are always globals, as should workqueues be.  With Tejun's
> recent work most work queues should go away completely.
> 

Right, sorry wrong terminology. I have pages pre-allocation for raid calculation
I always keep a minimum of full stripe raid pages per SB and scale up to the amount
of concurrent writes, with some lazy deallocation. It's all very preliminary.

The thread is so I can issue async writes/reads from io completion. So you
are right this should be global now.

>> I think we should just pass nfss to the LD and let it take care of accessing
>> nfss->nfs_client for the device cache. (It is done so later in the tree, right?)
> 
> You can add this later once a laypout driver actually needing it is
> introduced.
> 

You are right in principle, but this is one place that should be considered
from higher view. What happens is that we can only make the call after an
actual mount when we know the version/pnfs-usage/layout-type to be used.
Then when we know that, we have a per-nfs_client initialization to do.
Later in both blocks and objects we have other things to do peculiar to
each. The one call vector could serve them all. And the overall name of
that vector is therefore init_mountpoint(). The original code was passing
nfs-server as proper for it's name. Later attempts to hide the code future
and comply with files-only needs changed that to be an nfs-client pointer
since that was the only thing used. Now the name is wrong and the place
it is called from is confusing.

I think it is just simple, more clear, to just call it what it is and
pass the proper pointer. For the binary code it is all the same. For
code readability and review, an attempt to clarify just made it more
complicated. So why not just drop it.

Boaz
