Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:50393 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404AbbAUTOb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 14:14:31 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so10409411pab.12
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2015 11:14:31 -0800 (PST)
Date: Wed, 21 Jan 2015 11:14:22 -0800
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] clean up and generalize swap-over-NFS
Message-ID: <20150121191422.GA4775@mew>
References: <cover.1419044605.git.osandov@osandov.com>
 <20150114031836.GA21198@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150114031836.GA21198@mew>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 13, 2015 at 07:18:36PM -0800, Omar Sandoval wrote:
> On Fri, Dec 19, 2014 at 07:18:24PM -0800, Omar Sandoval wrote:
> > Hi,
> > 
> > This patch series (based on ecb5ec0 in Linus' tree) contains all of the
> > non-BTRFS work that I've done to implement swapfiles on BTRFS. The BTRFS
> > portion is still undergoing development and is now outweighed by the
> > non-BTRFS changes, so I want to get these in separately.
> > 
> > Version 2 changes the generic swapfile interface to use ->read_iter and
> > ->write_iter instead of using ->direct_IO directly in response to
> > discussion on the previous submission. It also adds the iov_iter_is_bvec
> > helper to factor out some common checks.
> > 
> > Version 1 can be found here: https://lkml.org/lkml/2014/12/15/7
> > 
> > Omar Sandoval (5):
> >   iov_iter: add ITER_BVEC helpers
> >   direct-io: don't dirty ITER_BVEC pages on read
> >   nfs: don't dirty ITER_BVEC pages read through direct I/O
> >   swapfile: use ->read_iter and ->write_iter
> >   vfs: update swap_{,de}activate documentation
> > 
> >  Documentation/filesystems/Locking |  7 ++++---
> >  Documentation/filesystems/vfs.txt |  7 ++++---
> >  fs/direct-io.c                    |  8 ++++---
> >  fs/nfs/direct.c                   |  5 ++++-
> >  fs/splice.c                       |  7 ++-----
> >  include/linux/uio.h               |  7 +++++++
> >  mm/iov_iter.c                     | 12 +++++++++++
> >  mm/page_io.c                      | 44 +++++++++++++++++++++++++--------------
> >  mm/swapfile.c                     | 11 +++++++++-
> >  9 files changed, 76 insertions(+), 32 deletions(-)
> > 
> > -- 
> > 2.2.1
> > 
> 
> Hi, everyone,
> 
> Thanks for all of the feedback on the last few iterations of this
> series. If it's alright, I'd like to revive the conversation around
> these patches.
> 
> There are a couple of issues which we were discussing before the
> holidays:
> 
> One concern that Al mentioned was ->read_iter and ->write_iter falling
> back to the buffered I/O case. Like Christoph mentioned, this can be
> prevented by doing the proper checks on the filesystem side (usually
> just making sure that all blocks of a swapfile are allocated, but on
> BTRFS, for example, we also have to check for compressed extents).
> 
> The other concern which Al brought up was that ->read_iter is passed a
> locked page in the iter_bvec and could end up trying to lock it. I'm not
> too sure under what conditions that would happen -- could someone give
> an example? My intuition is that there's no path which will lead us to
> deadlock on a page in the swapcache, but I don't have anything solid to
> back that up.
> 
> Thanks!
> -- 
> Omar

Hi,

Any updates on this?

Thanks,
-- 
Omar
