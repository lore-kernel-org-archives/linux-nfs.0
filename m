From: Jos Houtman <jos@hyves.nl>
Subject: Re: Page Cache writeback too slow,   SSD/noop scheduler/ext2
Date: Tue, 31 Mar 2009 16:10:38 +0200
Message-ID: <C5F7F0FE.DED5%jos@hyves.nl>
References: <20090331123112.GA15098@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	<linux-kernel@vger.kernel.org>, Jeff Layton <jlayton@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	<linux-fsdevel@vger.kernel.org>, <jens.axboe@oracle.com>,
	<akpm@linux-foundation.org>, <hch@infradead.org>,
	<linux-nfs@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090331123112.GA15098@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> There another question I have: does the writeback go through the io
>> scheduler? Because no matter the io scheduler or the tuning done, the
>> writeback algorithm totally starves the reads.
> 
> I noticed this annoying writes-starve-reads problem too. I'll look into it.

Thanks
 
> 
>> Is there anything I can do about this behaviour by creating a better
>> interleaving of the reads and writes?
> 
> I guess it should be handled in the generic block io layer.  Once we
> solved the writes-starve-reads problem, the bursty-writeback behavior
> becomes a no-problem for SSD.

Yeah this was the part where I figured the io-schedulers kicked in, but
obviously I was wrong :P.

If I can do anything more to help this along, let me know.


Thanks

Jos



