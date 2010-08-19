Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54749 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab0HSPYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 11:24:11 -0400
Date: Thu, 19 Aug 2010 11:24:08 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Layton <jlayton@redhat.com>,
        fengguang.wu@gmail.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com,
        chris.mason@oracle.com, konishi.ryusuke@lab.ntt.co.jp
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100819152408.GA29877@infradead.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <1282229905.6199.19.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282229905.6199.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 19, 2010 at 10:58:25AM -0400, Trond Myklebust wrote:
> To me that sounds fine. I've also been trying to wrap my head around the
> differences between 'nonblocking', 'for_background', 'for_reclaim' and
> 'for_kupdate' and how the filesystem is supposed to treat them.

Yeah, it's not clear to me either.  for_background is in fact only used
in nfs, for the priority and the nfs_commit_inode flags, for_kupdate
is only used in nfs, and in a really weird spot in btrfs, and
for_reclaim is used in nfs, and two places in nilfs2 and in shmemfs.

> Aside from the above, I've used 'for_reclaim', 'for_kupdate' and
> 'for_background' in order to adjust the RPC request's queuing priority
> (high in the case of 'for_reclaim' and low for the other two).

Right now writepage calls to the filesystem can come from various
places:

 - the flusher threads
 - VM reclaim (kswapd, memcg, direct reclaim)
 - memory migration
 - filemap_fdatawrite & other calls directly from FS code, also
   including fsync

We have WB_SYNC_ALL set for the second, data integrity pass when doing
a sync from the flusher threads, and when doing data integrity writes
from fs context (most fsync but also a few others).  All these obviously
are high priority.  It's not too easy to set priorities for the others
in my opinion.

