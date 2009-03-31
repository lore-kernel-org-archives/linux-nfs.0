Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64915 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753482AbZCaMbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 08:31:35 -0400
Date: Tue, 31 Mar 2009 20:31:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Jos Houtman <jos@hyves.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "jens.axboe@oracle.com" <jens.axboe@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "hch@infradead.org" <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Page Cache writeback too slow,   SSD/noop scheduler/ext2
Message-ID: <20090331123112.GA15098@localhost>
References: <C5F6B627.D9D0%jos@hyves.nl> <C5F7D654.DE6F%jos@hyves.nl>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C5F7D654.DE6F%jos@hyves.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 31, 2009 at 08:16:52PM +0800, Jos Houtman wrote:
> > 
> > Next to that I was wondering if there are any plans to make sure that not
> > all dirty-files are written back in the same interval.
> > 
> > In my case all database files are written back each 30 seconds, while I
> > would prefer them to be more divided over the interval.
> 
> There another question I have: does the writeback go through the io
> scheduler? Because no matter the io scheduler or the tuning done, the
> writeback algorithm totally starves the reads.

I noticed this annoying writes-starve-reads problem too. I'll look into it.

> See the url below for an example with CFQ, but deadline or noop all show
> this behaviour:
> http://94.100.113.33/535450001-535500000/535451701-535451800/535451800_6_L7g
> t.jpeg
> 
> Is there anything I can do about this behaviour by creating a better
> interleaving of the reads and writes?

I guess it should be handled in the generic block io layer.  Once we
solved the writes-starve-reads problem, the bursty-writeback behavior
becomes a no-problem for SSD.

Thanks,
Fengguang

