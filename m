Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35763 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbcD0HvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 03:51:07 -0400
Date: Wed, 27 Apr 2016 09:51:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org,
        xfs@oss.sgi.com, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm: add PF_MEMALLOC_NOFS
Message-ID: <20160427075102.GB2179@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <20160426230702.GG26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160426230702.GG26977@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 27-04-16 09:07:02, Dave Chinner wrote:
> On Tue, Apr 26, 2016 at 01:56:11PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > GFP_NOFS context is used for the following 4 reasons currently
> > 	- to prevent from deadlocks when the lock held by the allocation
> > 	  context would be needed during the memory reclaim
> > 	- to prevent from stack overflows during the reclaim because
> > 	  the allocation is performed from a deep context already
> > 	- to prevent lockups when the allocation context depends on
> > 	  other reclaimers to make a forward progress indirectly
> > 	- just in case because this would be safe from the fs POV
> 
> - silencing lockdep false positives
> 
> > Introduce PF_MEMALLOC_NOFS task specific flag and memalloc_nofs_{save,restore}
> > API to control the scope. This is basically copying
> > memalloc_noio_{save,restore} API we have for other restricted allocation
> > context GFP_NOIO.
> > 
> > Xfs has already had a similar functionality as PF_FSTRANS so let's just
> > give it a more generic name and make it usable for others as well and
> > move the GFP_NOFS context tracking to the page allocator. Xfs has its
> > own accessor functions but let's keep them for now to reduce this patch
> > as minimum.
> 
> Can you split this into two patches? The first simply does this:
> 
> #define PF_MEMALLOC_NOFS PF_FSTRANS
> 
> and changes only the XFS code to use PF_MEMALLOC_NOFS.
> 
> The second patch can then do the rest of the mm API changes that we
> don't actually care about in XFS at all.  That way I can carry all
> the XFS changes in the XFS tree and not have to worry about when
> this stuff gets merged or conflicts with the rest of the work that
> is being done to the mm/ code and whatever tree that eventually
> lands in...

Sure I will do that

-- 
Michal Hocko
SUSE Labs
