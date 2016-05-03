Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32885 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270AbcECPNQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2016 11:13:16 -0400
Date: Tue, 3 May 2016 17:13:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: NeilBrown <mr@neil.brown.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Dave Chinner <david@fromorbit.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>,
        ceph-devel@vger.kernel.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] scop GFP_NOFS api
Message-ID: <20160503151312.GA4470@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <8737q5ugcx.fsf@notabene.neil.brown.name>
 <20160429120418.GK21977@dhcp22.suse.cz>
 <87twiiu5gs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87twiiu5gs.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Sun 01-05-16 07:55:31, NeilBrown wrote:
[...]
> One particular problem with your process-context idea is that it isn't
> inherited across threads.
> Steve Whitehouse's example in gfs shows how allocation dependencies can
> even cross into user space.

Hmm, I am still not sure I understand that example completely but making
a dependency between direct reclaim and userspace can hardly work.
Especially when the direct reclaim might be sitting on top of hard to
guess pile of locks. So unless I've missed anything what Steve has
described is a clear NOFS context.

> A more localized one that I have seen is that NFSv4 sometimes needs to
> start up a state-management thread (particularly if the server
> restarted).
> It uses kthread_run(), which doesn't actually create the thread but asks
> kthreadd to do it.  If NFS writeout is waiting for state management it
> would need to make sure that kthreadd runs in allocation context to
> avoid deadlock.
> I feel that I've forgotten some important detail here and this might
> have been fixed somehow, but the point still stands that the allocation
> context can cross from thread to thread and can effectively become
> anything and everything.

Not sure I understand your point here but relying on kthread_run
from GFP_NOFS context has always been deadlock prone with or without
scope GFP_NOFS semantic so I am not really sure I see your point
here. Similarly relying on a work item which doesn't have a dedicated
WQ_MEM_RECLAIM WQ is deadlock prone.  You simply shouldn't do that.

> It is OK to wait for memory to be freed.  It is not OK to wait for any
> particular piece of memory to be freed because you don't always know who
> is waiting for you, or who you really are waiting on to free that
> memory.
> 
> Whenever trying to free memory I think you need to do best-effort
> without blocking.

I agree with that. Or at least you have to wait on something that is
_guaranteed_ to make a forward progress. I am not really that sure this
is easy to achieve with the current code base.

-- 
Michal Hocko
SUSE Labs
