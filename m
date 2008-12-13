From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
 (RFC)
Date: Sat, 13 Dec 2008 07:40:42 -0500
Message-ID: <20081213074042.2e8223c3@tleilax.poochiereds.net>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com>
	<20081122011555.GA28485@fieldses.org>
	<20081124103313.0c779324@tleilax.poochiereds.net>
	<20081124170653.GF17862@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, teigland@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44483 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbYLMMks convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Dec 2008 07:40:48 -0500
In-Reply-To: <20081124170653.GF17862@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 24 Nov 2008 12:06:53 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> > 
> > It seems to with very basic, cursory testing, but it could be
> > broken and I'm just not seeing it. This code looks like it's only used
> > in a NLM over DLM setup though, so it's hard to comprehensively test
> > it. This scheme is certainly more complex than the current code, though
> > and I'm not sure I have everything right with it.
> 
> I still haven't looked at the code yet.  Probably the first thing I'd
> check would whether the previous code depends on an assumption that each
> grant request results in revisit of exactly one rpc.  I can't see a
> problem.
> 

Hi Bruce,

  I've gone over this code in more detail. I'm fairly certain that this
assumption is not there in the case of a blocking lock. In the case of a
non-blocking lock (or testlock) then I don't *think* this assumption is
there either, but I could use someone to sanity check me there. The
non-blocking case is a lot harder to follow.

Any thoughts on the patch? I had figured this to be a relatively rare
situation, but I've had a couple of people ask me about it recently.
Some KDE/QT apps do this sort of locking in home dirs, so it's
apparently a real-world problem.

The most current patch follows...

Thanks,
Jeff

--------------------[snip]---------------------

>From 6e29be4fea77a57e29c0f67335dcb6750a31fb6a Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Sat, 13 Dec 2008 06:59:01 -0500
Subject: [PATCH] lockd: handle fl_grant callbacks with coalesced locks (RFC)

Dave Teigland opened a bug stating that he was having some problems with
DLM and lockd. Essentially, the problem boiled down to the fact that
when you do a posix lock of a region that touches another lock, the VFS
will coalesce the locks and return a lock that encompasses the whole
range.

The problem here is that DLM then does a fl_grant callback to lockd with
the new coalesced lock. The fl_grant callback then looks through all
of the blocks and eventually returns -ENOENT since none match the
coalesced lock.

I'm having a very hard time tracking down info about how the fl_grant
callback is supposed to work. Is it OK to send an fl_grant callback
with a lock that's larger than the one requested? If so, then lockd
needs to account for that possibility. Also, what exactly is the
purpose of the second arg on fl_grant ("conf" in nlmsvc_grant_deferred)?

What follows is a patch that changes nlmsvc_grant_deferred to account
for the possibility that it may receive an fl_grant that has already
been coalesced. It changes nlmsvc_grant_deferred to walk the entire
list of blocks and grant any blocks that are covered by the range of
the lock in the grant callback, if doing so will not conflict with an
earlier grant.

The patch is still very rough and is probably broken in subtle (and
maybe overt) ways, but it fixes the reproducer that Dave provided. It's
just intended as a starting point for discussion. Can anyone clarify how
fl_grant is supposed to work? Who's wrong here? DLM or NLM?

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svclock.c          |   72 ++++++++++++++++++++++++++++++++++---------
 include/linux/lockd/lockd.h |   35 +++++++++++++++++++++
 2 files changed, 92 insertions(+), 15 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 6063a8e..5ae1c28 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -611,28 +611,65 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 }
 
 /*
+ * Would granting this block cause a conflict with one already granted? Check
+ * by walking the f_blocks list for the file.
+ */
+static bool
+nlmsvc_check_overlap(struct nlm_block *block)
+{
+	struct nlm_block *fblock, *next;
+
+	list_for_each_entry_safe(fblock, next, &block->b_file->f_blocks,
+				 b_flist) {
+		/* skip myself */
+		if (fblock == block)
+			continue;
+
+		/* skip any locks that aren't granted */
+		if (!fblock->b_granted)
+			continue;
+
+		/* do block and fblock have any overlap in their ranges? */
+		if (nlm_overlapping_locks(&block->b_call->a_args.lock.fl,
+					  &fblock->b_call->a_args.lock.fl))
+			return true;
+	}
+
+	/* no conflicts found */
+	return false;
+}
+
+/*
  * This is a callback from the filesystem for VFS file lock requests.
  * It will be used if fl_grant is defined and the filesystem can not
  * respond to the request immediately.
  * For GETLK request it will copy the reply to the nlm_block.
  * For SETLK or SETLKW request it will get the local posix lock.
- * In all cases it will move the block to the head of nlm_blocked q where
+ * It will generally will move the block to the head of nlm_blocked q where
  * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
- * deferred rpc for GETLK and SETLK.
+ * deferred rpc for GETLK and SETLK. The exception is in the case where the
+ * block is not granted.
  */
-static void
+static bool
 nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
 			     int result)
 {
+	bool requeue = true;
+
 	block->b_flags |= B_GOT_CALLBACK;
-	if (result == 0)
-		block->b_granted = 1;
-	else
+	if (result == 0) {
+		if (nlmsvc_check_overlap(block))
+			requeue = false;
+		else
+			block->b_granted = 1;
+	} else
 		block->b_flags |= B_TIMED_OUT;
 	if (conf) {
 		if (block->b_fl)
 			__locks_copy_lock(block->b_fl, conf);
 	}
+
+	return requeue;
 }
 
 static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
@@ -643,22 +680,27 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
 
 	lock_kernel();
 	list_for_each_entry(block, &nlm_blocked, b_list) {
-		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
-			dprintk("lockd: nlmsvc_notify_blocked block %p flags %d\n",
-							block, block->b_flags);
+		if (nlm_lock_in_range(&block->b_call->a_args.lock.fl, fl)) {
+			dprintk("lockd: nlmsvc_notify_blocked block %p flags "
+				"%d\n", block, block->b_flags);
+
 			if (block->b_flags & B_QUEUED) {
 				if (block->b_flags & B_TIMED_OUT) {
-					rc = -ENOLCK;
-					break;
+					if (rc == -ENOENT)
+						rc = -ENOLCK;
+					continue;
 				}
-				nlmsvc_update_deferred_block(block, conf, result);
-			} else if (result == 0)
-				block->b_granted = 1;
+				if (!nlmsvc_update_deferred_block(block, conf,
+								  result))
+					continue;
+			} else if (result == 0) {
+				if (!nlmsvc_check_overlap(block))
+					block->b_granted = 1;
+			}
 
 			nlmsvc_insert_block(block, 0);
 			svc_wake_up(block->b_daemon);
 			rc = 0;
-			break;
 		}
 	}
 	unlock_kernel();
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index f7146e6..4a5406c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -385,6 +385,41 @@ static inline int nlm_compare_locks(const struct file_lock *fl1,
 	     &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
 }
 
+/*
+ * Compare two NLM locks.
+ * When the second lock is of type F_UNLCK, this acts like a wildcard.
+ * Similar to nlm_compare_locks, but also return true as long as fl1's range
+ * is completely covered by fl2.
+ */
+static inline int nlm_lock_in_range(const struct file_lock *fl1,
+				    const struct file_lock *fl2)
+{
+	return	fl1->fl_pid   == fl2->fl_pid
+	     && fl1->fl_owner == fl2->fl_owner
+	     && fl1->fl_start >= fl2->fl_start
+	     && fl1->fl_end   <= fl2->fl_end
+	     && (fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
+}
+
+static inline int nlm_overlapping_locks(const struct file_lock *fl1,
+					const struct file_lock *fl2)
+{
+	/* does fl1 completely cover fl2? */
+	if (fl1->fl_start <= fl2->fl_start && fl1->fl_end >= fl2->fl_end)
+		return 1;
+
+	/* does fl2 completely cover fl1 */
+	if (fl2->fl_start <= fl1->fl_start && fl2->fl_end >= fl1->fl_end)
+		return 1;
+
+	/* does the start or end of fl1 sit inside of fl2? */
+	if ((fl1->fl_start >= fl2->fl_start && fl1->fl_start <= fl2->fl_end) ||
+	    (fl1->fl_end >= fl2->fl_start && fl1->fl_end <= fl2->fl_end))
+		return 1;
+
+	return 0;
+}
+
 extern struct lock_manager_operations nlmsvc_lock_operations;
 
 #endif /* __KERNEL__ */
-- 
1.5.5.1

