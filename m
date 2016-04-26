Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:8753 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752610AbcDZW7m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 18:59:42 -0400
Date: Wed, 27 Apr 2016 08:58:45 +1000
From: Dave Chinner <david@fromorbit.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org,
        xfs@oss.sgi.com, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm, debug: report when GFP_NO{FS,IO} is used
 explicitly from memalloc_no{fs,io}_{save,restore} context
Message-ID: <20160426225845.GF26977@dastard>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1461671772-1269-3-git-send-email-mhocko@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 26, 2016 at 01:56:12PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> THIS PATCH IS FOR TESTING ONLY AND NOT MEANT TO HIT LINUS TREE
> 
> It is desirable to reduce the direct GFP_NO{FS,IO} usage at minimum and
> prefer scope usage defined by memalloc_no{fs,io}_{save,restore} API.
> 
> Let's help this process and add a debugging tool to catch when an
> explicit allocation request for GFP_NO{FS,IO} is done from the scope
> context. The printed stacktrace should help to identify the caller
> and evaluate whether it can be changed to use a wider context or whether
> it is called from another potentially dangerous context which needs
> a scope protection as well.

You're going to get a large number of these from XFS. There are call
paths in XFs that get called both inside and outside transaction
context, and many of them are marked with GFP_NOFS to prevent issues
that have cropped up in the past.

Often these are to silence lockdep warnings (e.g. commit b17cb36
("xfs: fix missing KM_NOFS tags to keep lockdep happy")) because
lockdep gets very unhappy about the same functions being called with
different reclaim contexts. e.g.  directory block mapping might
occur from readdir (no transaction context) or within transactions
(create/unlink). hence paths like this are tagged with GFP_NOFS to
stop lockdep emitting false positive warnings....

Removing the GFP_NOFS flags in situations like this is simply going
to restart the flood of false positive lockdep warnings we've
silenced over the years, so perhaps lockdep needs to be made smarter
as well...

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com
