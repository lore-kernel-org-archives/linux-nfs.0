From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
 to empty s_dirty list
Date: Thu, 26 Mar 2009 13:03:27 -0400
Message-ID: <20090326130327.3206e00b@barsoom.rdu.redhat.com>
References: <20090324104657.6907b19e@tleilax.poochiereds.net>
	<20090325012829.GA7506@localhost>
	<20090324221528.2bb7c50b@tleilax.poochiereds.net>
	<20090325025037.GA17374@localhost>
	<20090325075110.028f0d1d@tleilax.poochiereds.net>
	<20090325121742.GA22869@localhost>
	<20090325091325.17c997fd@tleilax.poochiereds.net>
	<49CA2F41.8030804@themaw.net>
	<49CA33E7.6090309@themaw.net>
	<20090325100049.0cc4de87@tleilax.poochiereds.net>
	<20090325141618.GA5684@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Ian Kent <raven@themaw.net>, Dave Chinner <david@fromorbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090325141618.GA5684@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Mar 2009 22:16:18 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> > 
> > Actually, I think you were right. We still have this check in
> > generic_sync_sb_inodes() even with Wu's January 2008 patches:
> > 
> > 	/* Was this inode dirtied after sync_sb_inodes was called? */
> > 	if (time_after(inode->dirtied_when, start))
> > 		break;
> 
> Yeah, ugly code. Jens' per-bdi flush daemons should eliminate it...
> 

I had a look over Jens' patches and they seem to be more concerned with
how the queues and daemons are organized (per-bdi rather than per-sb).
The actual way that inodes flow between the queues and get written out
don't look like they really change with his set.

They also don't eliminate the problematic check above. Regardless of
whether your or Jens' patches make it in, I think we'll still need
something like the following (untested) patch.

If this looks ok, I'll flesh out the comments some and "officially" post
it. Thoughts?

--------------[snip]-----------------

>From d10adff2d5f9a15d19c438119dbb2c410bd26e3c Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Thu, 26 Mar 2009 12:54:52 -0400
Subject: [PATCH] writeback: guard against jiffies wraparound on inode->dirtied_when checks

The dirtied_when value on an inode is supposed to represent the first
time that an inode has one of its pages dirtied. This value is in units
of jiffies. This value is used in several places in the writeback code
to determine when to write out an inode.

The problem is that these checks assume that dirtied_when is updated
periodically. But if an inode is continuously being used for I/O it can
be persistently marked as dirty and will continue to age. Once the time
difference between dirtied_when and the jiffies value it is being
compared to is greater than (or equal to) half the maximum of the
jiffies type, the logic of the time_*() macros inverts and the opposite
of what is needed is returned. On 32-bit architectures that's just under
25 days (assuming HZ == 1000).

As the least-recently dirtied inode, it'll end up being the first one
that pdflush will try to write out. sync_sb_inodes does this check
however:

	/* Was this inode dirtied after sync_sb_inodes was called? */
 	if (time_after(inode->dirtied_when, start))
 		break;

...but now dirtied_when appears to be in the future. sync_sb_inodes
bails out without attempting to write any dirty inodes.  When this
occurs, pdflush will stop writing out inodes for this superblock and
nothing will unwedge it until jiffies moves out of the problematic
window.

This patch fixes this problem by changing the time_after checks against
dirtied_when to also check whether dirtied_when appears to be in the
future. If it does, then we consider the value to be in the past.

This should shrink the problematic window to such a small period as not
to matter.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/fs-writeback.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e3fe991..dba69a5 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -196,8 +196,9 @@ static void redirty_tail(struct inode *inode)
 		struct inode *tail_inode;
 
 		tail_inode = list_entry(sb->s_dirty.next, struct inode, i_list);
-		if (!time_after_eq(inode->dirtied_when,
-				tail_inode->dirtied_when))
+		if (time_before(inode->dirtied_when,
+				tail_inode->dirtied_when) ||
+		    time_after(inode->dirtied_when, jiffies))
 			inode->dirtied_when = jiffies;
 	}
 	list_move(&inode->i_list, &sb->s_dirty);
@@ -231,7 +232,8 @@ static void move_expired_inodes(struct list_head *delaying_queue,
 		struct inode *inode = list_entry(delaying_queue->prev,
 						struct inode, i_list);
 		if (older_than_this &&
-			time_after(inode->dirtied_when, *older_than_this))
+			time_after(inode->dirtied_when, *older_than_this) &&
+			time_before_eq(inode->dirtied_when, jiffies))
 			break;
 		list_move(&inode->i_list, dispatch_queue);
 	}
@@ -493,7 +495,8 @@ void generic_sync_sb_inodes(struct super_block *sb,
 		}
 
 		/* Was this inode dirtied after sync_sb_inodes was called? */
-		if (time_after(inode->dirtied_when, start))
+		if (time_after(inode->dirtied_when, start) &&
+		    time_before_eq(inode->dirtied_when, jiffies))
 			break;
 
 		/* Is another pdflush already flushing this queue? */
-- 
1.5.5.6

