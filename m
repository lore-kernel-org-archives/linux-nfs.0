Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exc01vs1.exchange.cysonet.com ([85.158.200.82]:18825 "EHLO
	exc01vs1.exchange.cysonet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752150AbZC3PrZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 11:47:25 -0400
Date: Mon, 30 Mar 2009 17:47:19 +0100
Subject: Re: Page Cache writeback too slow,   SSD/noop scheduler/ext2
From: Jos Houtman <jos@hyves.nl>
To: Wu Fengguang <fengguang.wu@intel.com>
CC: Nick Piggin <nickpiggin@yahoo.com.au>, <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>,
        <linux-fsdevel@vger.kernel.org>, <jens.axboe@oracle.com>,
        <akpm@linux-foundation.org>, <hch@infradead.org>,
        <linux-nfs@vger.kernel.org>
Message-ID: <C5F6B627.D9D0%jos@hyves.nl>
In-Reply-To: <20090329023238.GA7825@localhost>
Content-type: text/plain;
	charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


>> Thanx for the patch, but for the next time: How should I apply it?
>> it seems to be context aware (@@) and broke on all kernel versions I tried
>> 2.6.28/2.6.28.7/2.6.29
> 
> Do you mean that the patch applies after removing " @@.*$"?

I didn't try that, but this time it worked. So it was probably my error.

> 
> You are right. In your case, there are several big dirty files in sdb1,
> and the sdb write queue is constantly (almost-)congested. The SSD write
> speed is so slow, that in each round of sdb1 writeback, it begins with
> an uncongested queue, but quickly fills up after writing some pages.
> Hence all the inodes will get redirtied because of (nr_to_write > 0).
> 
> The following quick fix should solve the slow-writeback-on-congested-SSD
> problem. However the writeback sequence is suboptimal: it sync-and-requeue
> each file until congested (in your case about 3~600 pages) instead of
> until MAX_WRITEBACK_PAGES=1024 pages.

Yeah that fixed it, but performance dropped due to the more constant
congestion. So I will need to try some different io schedulers.


Next to that I was wondering if there are any plans to make sure that not
all dirty-files are written back in the same interval.

In my case all database files are written back each 30 seconds, while I
would prefer them to be more divided over the interval.

Thanks,

Jos

