Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exc01vs1.exchange.cysonet.com ([85.158.200.82]:51190 "EHLO
	exc01vs1.exchange.cysonet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753130AbZCaMRA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 08:17:00 -0400
Date: Tue, 31 Mar 2009 14:16:52 +0200
Subject: Re: Page Cache writeback too slow,   SSD/noop scheduler/ext2
From: Jos Houtman <jos@hyves.nl>
To: Jos Houtman <jos@hyves.nl>, Wu Fengguang <fengguang.wu@intel.com>
CC: Nick Piggin <nickpiggin@yahoo.com.au>, <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>,
        <linux-fsdevel@vger.kernel.org>, <jens.axboe@oracle.com>,
        <akpm@linux-foundation.org>, <hch@infradead.org>,
        <linux-nfs@vger.kernel.org>
Message-ID: <C5F7D654.DE6F%jos@hyves.nl>
In-Reply-To: <C5F6B627.D9D0%jos@hyves.nl>
Content-type: text/plain;
	charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> 
> Next to that I was wondering if there are any plans to make sure that not
> all dirty-files are written back in the same interval.
> 
> In my case all database files are written back each 30 seconds, while I
> would prefer them to be more divided over the interval.

There another question I have: does the writeback go through the io
scheduler? Because no matter the io scheduler or the tuning done, the
writeback algorithm totally starves the reads.

See the url below for an example with CFQ, but deadline or noop all show
this behaviour:
http://94.100.113.33/535450001-535500000/535451701-535451800/535451800_6_L7g
t.jpeg

Is there anything I can do about this behaviour by creating a better
interleaving of the reads and writes?

Jos

