Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:14897 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751209AbaDQB1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 21:27:44 -0400
Date: Thu, 17 Apr 2014 11:27:39 +1000
From: Dave Chinner <david@fromorbit.com>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org,
        Ming Lei <ming.lei@canonical.com>, linux-kernel@vger.kernel.org,
        xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH/RFC 00/19] Support loop-back NFS mounts
Message-ID: <20140417012739.GU15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416104207.75b044e8@tlielax.poochiereds.net>
 <20140417102048.2fc8275c@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140417102048.2fc8275c@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 10:20:48AM +1000, NeilBrown wrote:
> A good example is the deadlock with the flush-* threads.
> flush-* will lock a page, and  then call ->writepage.  If ->writepage
> allocates memory it can enter reclaim, call ->releasepage on NFS, and block
> waiting for a COMMIT to complete.
> The COMMIT might already be running, performing fsync on that same file that
> flush-* is flushing.  It locks each page in turn.  When it  gets to the page
> that flush-* has locked, it will deadlock.

It's nfs_release_page() again....

> In general, if nfsd is allowed to block on local filesystem, and local
> filesystem is allowed to block on NFS, then a deadlock can happen.
> We would need a clear hierarchy
> 
>    __GFP_NETFS > __GFP_FS > __GFP_IO
> 
> for it to work.  I'm not sure the extra level really helps a lot and it would
> be a lot of churn.

I think you are looking at this the wrong way - it's not the other
filesystems that have to avoid memory reclaim recursion, it's the
NFS client mount that is on loopback that needs to avoid recursion.

IMO, the fix should be that the NFS client cannot block on messages sent to the NFSD
on the same host during memory reclaim. That is, nfs_release_page()
cannot send commit messages to the server if the server is on
localhost. Instead, it just tells memory reclaim that it can't
reclaim that page.

If nfs_release_page() no longer blocks in memory reclaim, and all
these nfsd-gets-blocked-in-GFP_KERNEL-memory-allocation recursion
problems go away. Do the same for all the other memory reclaim
operations in the NFS client, and you've got a solution that should
work without needing to walk all over the rest of the kernel....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
