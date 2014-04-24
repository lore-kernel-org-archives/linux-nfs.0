Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:57881 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485AbaDXBVV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 21:21:21 -0400
Date: Thu, 24 Apr 2014 11:20:22 +1000
From: Dave Chinner <david@fromorbit.com>
To: NeilBrown <neilb@suse.de>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH/RFC 0/5] Support loop-back NFS mounts - take 2
Message-ID: <20140424012022.GX15995@dastard>
References: <20140423022441.4725.89693.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140423022441.4725.89693.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 23, 2014 at 12:40:58PM +1000, NeilBrown wrote:
> This is a somewhat shorter patchset for loop-back NFS support than
> last time, thanks to the excellent feedback and particularly to Dave
> Chinner.  Thanks.
> 
> Avoiding the wait-for-congestion which can trigger a livelock is much
> the same, though I've reduced the cases in which the wait is
> by-passed.
> I did this using current->backing_dev_info which is otherwise serving
> no purpose on the current kernel.
> 
> Avoiding the deadlocks has been turned on its head.
> Instead of nfsd checking if it is a loop-back mount and setting
> PF_FSTRANS, which then needs lots of changes too PF_FSTRANS and
> __GFP_FS handling, it is now NFS which checks for a loop-back
> filesystem.
> 
> There is more verbosity in that patch (Fifth of Five) but the essence
> is that nfs_release_page will now not wait indefinitely for a COMMIT
> request to complete when sent to the local host.  It still waits a
> little while as some delay can be important. But it won't wait
> forever.
> The duration of "a little while" is currently 100ms, though I do
> wonder if a bigger number would serve just as well.
> 
> Unlike the previous series, this set should remove deadlocks that
> could happen during the actual fail-over process.  This is achieved by
> having nfs_release_page monitor the connection and if it changes from
> a remote to a local connection, or just disconnects, then it will
> timeout.  It currently polls every second, though this probably could
> be longer too.  It only needs to be the same order of magnitude as the
> time it takes node failure to be detected and failover to happen, and
> I suspect that is closer to 1 minute.  So maybe a 10 or 20 second poll
> interval would be just as good.
> 
> Implementing this timeout requires some horrible code as the
> wait_on_bit functions don't support timeouts.  If the general approach
> is found acceptable I'll explore ways to improve the timeout code.
> 
> Comments, criticism, etc very welcome as always,

Looks much less intrusive to me, and doesn't appear to affect any
other filesystem or the recursion patterns of memory reclaim,
so I like it very much more than the previous patchset. Nice work!
:)

The code changes are really outside my area of expertise now, so I
don't really feel qualified to review the changes. However, consider
the overall approach:

Acked-by: Dave Chinner <dchinner@redhat.com>

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
