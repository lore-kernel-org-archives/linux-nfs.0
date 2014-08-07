Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:35713 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757414AbaHGQVD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 12:21:03 -0400
Date: Thu, 7 Aug 2014 18:20:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger
	than page size
Message-ID: <20140807162059.GA23188@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de> <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com> <20140807112537.GA3437@lst.de> <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com> <20140807121052.GA5678@lst.de> <CA+a=Yy4YmBzYFUTHb72hyZ1--N_w6YDZhmbFEAU11YTt+1qxOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+a=Yy4YmBzYFUTHb72hyZ1--N_w6YDZhmbFEAU11YTt+1qxOg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 07, 2014 at 09:43:09PM +0800, Peng Tao wrote:
> we can't assume all pages written back have their pari pages (for 8K
> block size e.g.) read in read_pagelists(). A page can also be read in
> via MDS read. So what we need is a hook into nfs_readpage to read or
> zero additional pages. But we might not even have a layout there.

We can't assume the page is there for writeback either, what all this
mess exists for.  That's why we really shouldn't even attempt to support
a a block size large than the page size, and that's also why the local
Linux filesystems strictly refuse to support it.  If you want to hack
around it you will run into problems in either case.

I also don't really see why a server would insist on this large block
size, there really isn't any major benefit in doing that today (aka the last 20
years) now that we have extent based filesystems.
