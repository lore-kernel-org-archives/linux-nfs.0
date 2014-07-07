Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43367 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbaGHCs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 22:48:57 -0400
From: NeilBrown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 07 Jul 2014 15:16:04 +1000
Subject: [PATCH 1/2] SCHED: remove proliferation of wait_on_bit action
 functions.
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>,
        linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>,
        David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>,
        Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <20140707051603.28027.72349.stgit@notabene.brown>
In-Reply-To: <20140707051530.28027.48411.stgit@notabene.brown>
References: <20140707051530.28027.48411.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current "wait_on_bit" interface requires an 'action' function
to be provided which does the actual waiting.
There are over 20 such functions, many of them identical.
Most cases can be satisfied by one of just two functions, one
which uses io_schedule() and one which just uses schedule().

So:
 Rename wait_on_bit and        wait_on_bit_lock to
        wait_on_bit_action and wait_on_bit_lock_action
 to make it explicit that they need an action function.

 Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
 which are *not* given an action function but implicitly use
 a standard one.
 The decision to error-out if a signal is pending is now made
 based on the 'mode' argument rather than being encoded in the action
 function.


 All instances of the old wait_on_bit and wait_on_bit_lock which
 can use the new version have been changed accordingly and their
 action functions have been discarded.
 wait_on_bit{_lock} does not return any specific error code in the
 event of a signal so the caller must check for non-zero and
 interpolate their own error code as appropriate.

The wait_on_bit() call in __fscache_wait_on_invalidate() was ambiguous
as it specified TASK_UNINTERRUPTIBLE but used
fscache_wait_bit_interruptible as an action function.
David Howells confirms this should be uniformly "uninterruptible"

The main remaining user of wait_on_bit{,_lock}_action is NFS which
needs to use a freezer-aware schedule() call.

A comment in fs/gfs2/glock.c notes that having multiple 'action'
functions is useful as they display differently in the 'wchan' field
of 'ps'. (and /proc/$PID/wchan).
As the new bit_wait{,_io} functions are tagged "__sched", they will
not show up at all, but something higher in the stack.  So the
distinction will still be visible, only with different function names
(gds2_glock_wait versus gfs2_glock_dq_wait in the gfs2/glock.c case).

Since first version of this patch (against 3.15) two new action
functions appeared, on in NFS and one in CIFS.  CIFS also now uses
an action function that makes the same freezer aware schedule call
as NFS.


Signed-off-by: NeilBrown <neilb@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Acked-by: David Howells <dhowells@redhat.com> (fscache, keys)
Acked-by: Steven Whitehouse <swhiteho@redhat.com> (gfs2)
---
 Documentation/filesystems/caching/operations.txt |    2 
 drivers/md/dm-bufio.c                            |   41 +++-----
 drivers/md/dm-snap.c                             |   10 --
 drivers/media/usb/dvb-usb-v2/dvb_usb_core.c      |   12 --
 fs/btrfs/extent_io.c                             |   10 --
 fs/buffer.c                                      |   11 --
 fs/cifs/connect.c                                |   10 --
 fs/cifs/file.c                                   |    9 --
 fs/cifs/inode.c                                  |    4 -
 fs/cifs/misc.c                                   |    2 
 fs/fs-writeback.c                                |    3 -
 fs/fscache/cookie.c                              |    7 +
 fs/fscache/internal.h                            |    2 
 fs/fscache/main.c                                |   18 ---
 fs/fscache/page.c                                |    4 -
 fs/gfs2/glock.c                                  |   25 -----
 fs/gfs2/lock_dlm.c                               |    8 --
 fs/gfs2/ops_fstype.c                             |   11 --
 fs/gfs2/recovery.c                               |    8 --
 fs/gfs2/super.c                                  |    8 --
 fs/inode.c                                       |    7 -
 fs/jbd2/transaction.c                            |   10 --
 fs/nfs/file.c                                    |    4 -
 fs/nfs/filelayout/filelayoutdev.c                |    4 -
 fs/nfs/inode.c                                   |    4 -
 fs/nfs/nfs4state.c                               |    4 -
 fs/nfs/pagelist.c                                |   12 --
 fs/nfs/pnfs.c                                    |    2 
 fs/nfs/write.c                                   |    4 -
 include/linux/wait.h                             |  115 +++++++++++++++++++++-
 include/linux/writeback.h                        |    3 -
 kernel/ptrace.c                                  |    8 --
 kernel/sched/wait.c                              |   18 +++
 mm/filemap.c                                     |   20 +---
 mm/ksm.c                                         |    8 --
 net/bluetooth/hci_core.c                         |    8 --
 security/keys/gc.c                               |   11 --
 security/keys/request_key.c                      |   23 ----
 38 files changed, 195 insertions(+), 275 deletions(-)

diff --git a/Documentation/filesystems/caching/operations.txt b/Documentation/filesystems/caching/operations.txt
index bee2a5f93d60..a1c052cbba35 100644
--- a/Documentation/filesystems/caching/operations.txt
+++ b/Documentation/filesystems/caching/operations.txt
@@ -90,7 +90,7 @@ operations:
      to be cleared before proceeding:
 
 		wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
-			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 
 
  (2) The operation may be fast asynchronous (FSCACHE_OP_FAST), in which case it
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 4e84095833db..96c92b75452f 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -615,16 +615,6 @@ static void write_endio(struct bio *bio, int error)
 }
 
 /*
- * This function is called when wait_on_bit is actually waiting.
- */
-static int do_io_schedule(void *word)
-{
-	io_schedule();
-
-	return 0;
-}
-
-/*
  * Initiate a write on a dirty buffer, but don't wait for it.
  *
  * - If the buffer is not dirty, exit.
@@ -640,8 +630,7 @@ static void __write_dirty_buffer(struct dm_buffer *b,
 		return;
 
 	clear_bit(B_DIRTY, &b->state);
-	wait_on_bit_lock(&b->state, B_WRITING,
-			 do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_lock_io(&b->state, B_WRITING, TASK_UNINTERRUPTIBLE);
 
 	if (!write_list)
 		submit_io(b, WRITE, b->block, write_endio);
@@ -675,9 +664,9 @@ static void __make_buffer_clean(struct dm_buffer *b)
 	if (!b->state)	/* fast case */
 		return;
 
-	wait_on_bit(&b->state, B_READING, do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE);
 	__write_dirty_buffer(b, NULL);
-	wait_on_bit(&b->state, B_WRITING, do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&b->state, B_WRITING, TASK_UNINTERRUPTIBLE);
 }
 
 /*
@@ -1030,7 +1019,7 @@ static void *new_read(struct dm_bufio_client *c, sector_t block,
 	if (need_submit)
 		submit_io(b, READ, b->block, read_endio);
 
-	wait_on_bit(&b->state, B_READING, do_io_schedule, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE);
 
 	if (b->read_error) {
 		int error = b->read_error;
@@ -1209,15 +1198,13 @@ again:
 				dropped_lock = 1;
 				b->hold_count++;
 				dm_bufio_unlock(c);
-				wait_on_bit(&b->state, B_WRITING,
-					    do_io_schedule,
-					    TASK_UNINTERRUPTIBLE);
+				wait_on_bit_io(&b->state, B_WRITING,
+					       TASK_UNINTERRUPTIBLE);
 				dm_bufio_lock(c);
 				b->hold_count--;
 			} else
-				wait_on_bit(&b->state, B_WRITING,
-					    do_io_schedule,
-					    TASK_UNINTERRUPTIBLE);
+				wait_on_bit_io(&b->state, B_WRITING,
+					       TASK_UNINTERRUPTIBLE);
 		}
 
 		if (!test_bit(B_DIRTY, &b->state) &&
@@ -1321,15 +1308,15 @@ retry:
 
 	__write_dirty_buffer(b, NULL);
 	if (b->hold_count == 1) {
-		wait_on_bit(&b->state, B_WRITING,
-			    do_io_schedule, TASK_UNINTERRUPTIBLE);
+		wait_on_bit_io(&b->state, B_WRITING,
+			       TASK_UNINTERRUPTIBLE);
 		set_bit(B_DIRTY, &b->state);
 		__unlink_buffer(b);
 		__link_buffer(b, new_block, LIST_DIRTY);
 	} else {
 		sector_t old_block;
-		wait_on_bit_lock(&b->state, B_WRITING,
-				 do_io_schedule, TASK_UNINTERRUPTIBLE);
+		wait_on_bit_lock_io(&b->state, B_WRITING,
+				    TASK_UNINTERRUPTIBLE);
 		/*
 		 * Relink buffer to "new_block" so that write_callback
 		 * sees "new_block" as a block number.
@@ -1341,8 +1328,8 @@ retry:
 		__unlink_buffer(b);
 		__link_buffer(b, new_block, b->list_mode);
 		submit_io(b, WRITE, new_block, write_endio);
-		wait_on_bit(&b->state, B_WRITING,
-			    do_io_schedule, TASK_UNINTERRUPTIBLE);
+		wait_on_bit_io(&b->state, B_WRITING,
+			       TASK_UNINTERRUPTIBLE);
 		__unlink_buffer(b);
 		__link_buffer(b, old_block, b->list_mode);
 	}
diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index 5bd2290cfb1e..864b03f47727 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -1032,21 +1032,13 @@ static void start_merge(struct dm_snapshot *s)
 		snapshot_merge_next_chunks(s);
 }
 
-static int wait_schedule(void *ptr)
-{
-	schedule();
-
-	return 0;
-}
-
 /*
  * Stop the merging process and wait until it finishes.
  */
 static void stop_merge(struct dm_snapshot *s)
 {
 	set_bit(SHUTDOWN_MERGE, &s->state_bits);
-	wait_on_bit(&s->state_bits, RUNNING_MERGE, wait_schedule,
-		    TASK_UNINTERRUPTIBLE);
+	wait_on_bit(&s->state_bits, RUNNING_MERGE, TASK_UNINTERRUPTIBLE);
 	clear_bit(SHUTDOWN_MERGE, &s->state_bits);
 }
 
diff --git a/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c b/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
index e35580618936..f296394bb7c5 100644
--- a/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
+++ b/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
@@ -253,13 +253,6 @@ static int dvb_usbv2_adapter_stream_exit(struct dvb_usb_adapter *adap)
 	return usb_urb_exitv2(&adap->stream);
 }
 
-static int wait_schedule(void *ptr)
-{
-	schedule();
-
-	return 0;
-}
-
 static int dvb_usb_start_feed(struct dvb_demux_feed *dvbdmxfeed)
 {
 	struct dvb_usb_adapter *adap = dvbdmxfeed->demux->priv;
@@ -273,8 +266,7 @@ static int dvb_usb_start_feed(struct dvb_demux_feed *dvbdmxfeed)
 			dvbdmxfeed->pid, dvbdmxfeed->index);
 
 	/* wait init is done */
-	wait_on_bit(&adap->state_bits, ADAP_INIT, wait_schedule,
-			TASK_UNINTERRUPTIBLE);
+	wait_on_bit(&adap->state_bits, ADAP_INIT, TASK_UNINTERRUPTIBLE);
 
 	if (adap->active_fe == -1)
 		return -EINVAL;
@@ -568,7 +560,7 @@ static int dvb_usb_fe_sleep(struct dvb_frontend *fe)
 
 	if (!adap->suspend_resume_active) {
 		set_bit(ADAP_SLEEP, &adap->state_bits);
-		wait_on_bit(&adap->state_bits, ADAP_STREAMING, wait_schedule,
+		wait_on_bit(&adap->state_bits, ADAP_STREAMING,
 				TASK_UNINTERRUPTIBLE);
 	}
 
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index a389820d158b..3e11aab9f391 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3437,16 +3437,10 @@ done_unlocked:
 	return 0;
 }
 
-static int eb_wait(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 void wait_on_extent_buffer_writeback(struct extent_buffer *eb)
 {
-	wait_on_bit(&eb->bflags, EXTENT_BUFFER_WRITEBACK, eb_wait,
-		    TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&eb->bflags, EXTENT_BUFFER_WRITEBACK,
+		       TASK_UNINTERRUPTIBLE);
 }
 
 static noinline_for_stack int
diff --git a/fs/buffer.c b/fs/buffer.c
index eba6e4f621ce..8f05111bbb8b 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -61,16 +61,9 @@ inline void touch_buffer(struct buffer_head *bh)
 }
 EXPORT_SYMBOL(touch_buffer);
 
-static int sleep_on_buffer(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 void __lock_buffer(struct buffer_head *bh)
 {
-	wait_on_bit_lock(&bh->b_state, BH_Lock, sleep_on_buffer,
-							TASK_UNINTERRUPTIBLE);
+	wait_on_bit_lock_io(&bh->b_state, BH_Lock, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_buffer);
 
@@ -123,7 +116,7 @@ EXPORT_SYMBOL(buffer_check_dirty_writeback);
  */
 void __wait_on_buffer(struct buffer_head * bh)
 {
-	wait_on_bit(&bh->b_state, BH_Lock, sleep_on_buffer, TASK_UNINTERRUPTIBLE);
+	wait_on_bit_io(&bh->b_state, BH_Lock, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__wait_on_buffer);
 
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 20d75b8ddb26..b98366f21f9e 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3934,13 +3934,6 @@ cifs_sb_master_tcon(struct cifs_sb_info *cifs_sb)
 	return tlink_tcon(cifs_sb_master_tlink(cifs_sb));
 }
 
-static int
-cifs_sb_tcon_pending_wait(void *unused)
-{
-	schedule();
-	return signal_pending(current) ? -ERESTARTSYS : 0;
-}
-
 /* find and return a tlink with given uid */
 static struct tcon_link *
 tlink_rb_search(struct rb_root *root, kuid_t uid)
@@ -4039,11 +4032,10 @@ cifs_sb_tlink(struct cifs_sb_info *cifs_sb)
 	} else {
 wait_for_construction:
 		ret = wait_on_bit(&tlink->tl_flags, TCON_LINK_PENDING,
-				  cifs_sb_tcon_pending_wait,
 				  TASK_INTERRUPTIBLE);
 		if (ret) {
 			cifs_put_tlink(tlink);
-			return ERR_PTR(ret);
+			return ERR_PTR(-ERESTARTSYS);
 		}
 
 		/* if it's good, return it */
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index e90a1e9aa627..b88b1ade4d3d 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3618,13 +3618,6 @@ static int cifs_launder_page(struct page *page)
 	return rc;
 }
 
-static int
-cifs_pending_writers_wait(void *unused)
-{
-	schedule();
-	return 0;
-}
-
 void cifs_oplock_break(struct work_struct *work)
 {
 	struct cifsFileInfo *cfile = container_of(work, struct cifsFileInfo,
@@ -3636,7 +3629,7 @@ void cifs_oplock_break(struct work_struct *work)
 	int rc = 0;
 
 	wait_on_bit(&cinode->flags, CIFS_INODE_PENDING_WRITERS,
-			cifs_pending_writers_wait, TASK_UNINTERRUPTIBLE);
+			TASK_UNINTERRUPTIBLE);
 
 	server->ops->downgrade_oplock(server, cinode,
 		test_bit(CIFS_INODE_DOWNGRADE_OPLOCK_TO_L2, &cinode->flags));
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index a174605f6afa..213c4580b4e3 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1794,8 +1794,8 @@ cifs_revalidate_mapping(struct inode *inode)
 	int rc;
 	unsigned long *flags = &CIFS_I(inode)->flags;
 
-	rc = wait_on_bit_lock(flags, CIFS_INO_LOCK, cifs_wait_bit_killable,
-				TASK_KILLABLE);
+	rc = wait_on_bit_lock_action(flags, CIFS_INO_LOCK, cifs_wait_bit_killable,
+				     TASK_KILLABLE);
 	if (rc)
 		return rc;
 
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index 3b0c62e622da..6bf55d0ed494 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -582,7 +582,7 @@ int cifs_get_writer(struct cifsInodeInfo *cinode)
 
 start:
 	rc = wait_on_bit(&cinode->flags, CIFS_INODE_PENDING_OPLOCK_BREAK,
-				   cifs_oplock_break_wait, TASK_KILLABLE);
+			 TASK_KILLABLE);
 	if (rc)
 		return rc;
 
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index be568b7311d6..ef9bef118342 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -342,7 +342,8 @@ static void __inode_wait_for_writeback(struct inode *inode)
 	wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
 	while (inode->i_state & I_SYNC) {
 		spin_unlock(&inode->i_lock);
-		__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
+		__wait_on_bit(wqh, &wq, bit_wait,
+			      TASK_UNINTERRUPTIBLE);
 		spin_lock(&inode->i_lock);
 	}
 }
diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index aec01be91b0a..89acec742e0b 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -160,7 +160,7 @@ void __fscache_enable_cookie(struct fscache_cookie *cookie,
 	_enter("%p", cookie);
 
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
-			 fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			 TASK_UNINTERRUPTIBLE);
 
 	if (test_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags))
 		goto out_unlock;
@@ -255,7 +255,7 @@ static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie)
 	if (!fscache_defer_lookup) {
 		_debug("non-deferred lookup %p", &cookie->flags);
 		wait_on_bit(&cookie->flags, FSCACHE_COOKIE_LOOKING_UP,
-			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		_debug("complete");
 		if (test_bit(FSCACHE_COOKIE_UNAVAILABLE, &cookie->flags))
 			goto unavailable;
@@ -463,7 +463,6 @@ void __fscache_wait_on_invalidate(struct fscache_cookie *cookie)
 	_enter("%p", cookie);
 
 	wait_on_bit(&cookie->flags, FSCACHE_COOKIE_INVALIDATING,
-		    fscache_wait_bit_interruptible,
 		    TASK_UNINTERRUPTIBLE);
 
 	_leave("");
@@ -525,7 +524,7 @@ void __fscache_disable_cookie(struct fscache_cookie *cookie, bool invalidate)
 	}
 
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
-			 fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			 TASK_UNINTERRUPTIBLE);
 	if (!test_and_clear_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags))
 		goto out_unlock_enable;
 
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index bc6c08fcfddd..7872a62ef30c 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -97,8 +97,6 @@ static inline bool fscache_object_congested(void)
 	return workqueue_congested(WORK_CPU_UNBOUND, fscache_object_wq);
 }
 
-extern int fscache_wait_bit(void *);
-extern int fscache_wait_bit_interruptible(void *);
 extern int fscache_wait_atomic_t(atomic_t *);
 
 /*
diff --git a/fs/fscache/main.c b/fs/fscache/main.c
index 63f868e869b9..a31b83c5cbd9 100644
--- a/fs/fscache/main.c
+++ b/fs/fscache/main.c
@@ -197,24 +197,6 @@ static void __exit fscache_exit(void)
 module_exit(fscache_exit);
 
 /*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-int fscache_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
- * wait_on_bit() sleep function for interruptible waiting
- */
-int fscache_wait_bit_interruptible(void *flags)
-{
-	schedule();
-	return signal_pending(current);
-}
-
-/*
  * wait_on_atomic_t() sleep function for uninterruptible waiting
  */
 int fscache_wait_atomic_t(atomic_t *p)
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index ed70714503fa..85332b9d19d1 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -298,7 +298,6 @@ int fscache_wait_for_deferred_lookup(struct fscache_cookie *cookie)
 
 	jif = jiffies;
 	if (wait_on_bit(&cookie->flags, FSCACHE_COOKIE_LOOKING_UP,
-			fscache_wait_bit_interruptible,
 			TASK_INTERRUPTIBLE) != 0) {
 		fscache_stat(&fscache_n_retrievals_intr);
 		_leave(" = -ERESTARTSYS");
@@ -342,7 +341,6 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
 	if (stat_op_waits)
 		fscache_stat(stat_op_waits);
 	if (wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
-			fscache_wait_bit_interruptible,
 			TASK_INTERRUPTIBLE) != 0) {
 		ret = fscache_cancel_op(op, do_cancel);
 		if (ret == 0)
@@ -351,7 +349,7 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
 		/* it's been removed from the pending queue by another party,
 		 * so we should get to run shortly */
 		wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
-			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 	}
 	_debug("<<< GO");
 
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index c355f7320e44..770e16716d81 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -856,27 +856,6 @@ void gfs2_holder_uninit(struct gfs2_holder *gh)
 }
 
 /**
- * gfs2_glock_holder_wait
- * @word: unused
- *
- * This function and gfs2_glock_demote_wait both show up in the WCHAN
- * field. Thus I've separated these otherwise identical functions in
- * order to be more informative to the user.
- */
-
-static int gfs2_glock_holder_wait(void *word)
-{
-        schedule();
-        return 0;
-}
-
-static int gfs2_glock_demote_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
-/**
  * gfs2_glock_wait - wait on a glock acquisition
  * @gh: the glock holder
  *
@@ -888,7 +867,7 @@ int gfs2_glock_wait(struct gfs2_holder *gh)
 	unsigned long time1 = jiffies;
 
 	might_sleep();
-	wait_on_bit(&gh->gh_iflags, HIF_WAIT, gfs2_glock_holder_wait, TASK_UNINTERRUPTIBLE);
+	wait_on_bit(&gh->gh_iflags, HIF_WAIT, TASK_UNINTERRUPTIBLE);
 	if (time_after(jiffies, time1 + HZ)) /* have we waited > a second? */
 		/* Lengthen the minimum hold time. */
 		gh->gh_gl->gl_hold_time = min(gh->gh_gl->gl_hold_time +
@@ -1128,7 +1107,7 @@ void gfs2_glock_dq_wait(struct gfs2_holder *gh)
 	struct gfs2_glock *gl = gh->gh_gl;
 	gfs2_glock_dq(gh);
 	might_sleep();
-	wait_on_bit(&gl->gl_flags, GLF_DEMOTE, gfs2_glock_demote_wait, TASK_UNINTERRUPTIBLE);
+	wait_on_bit(&gl->gl_flags, GLF_DEMOTE, TASK_UNINTERRUPTIBLE);
 }
 
 /**
diff --git a/fs/gfs2/lock_dlm.c b/fs/gfs2/lock_dlm.c
index 91f274de1246..992ca5b1e045 100644
--- a/fs/gfs2/lock_dlm.c
+++ b/fs/gfs2/lock_dlm.c
@@ -936,12 +936,6 @@ fail:
 	return error;
 }
 
-static int dlm_recovery_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 static int control_first_done(struct gfs2_sbd *sdp)
 {
 	struct lm_lockstruct *ls = &sdp->sd_lockstruct;
@@ -976,7 +970,7 @@ restart:
 		fs_info(sdp, "control_first_done wait gen %u\n", start_gen);
 
 		wait_on_bit(&ls->ls_recover_flags, DFL_DLM_RECOVERY,
-			    dlm_recovery_wait, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		goto restart;
 	}
 
diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index bc564c0d6d16..d3eae244076e 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -1024,20 +1024,13 @@ void gfs2_lm_unmount(struct gfs2_sbd *sdp)
 		lm->lm_unmount(sdp);
 }
 
-static int gfs2_journalid_wait(void *word)
-{
-	if (signal_pending(current))
-		return -EINTR;
-	schedule();
-	return 0;
-}
-
 static int wait_on_journal(struct gfs2_sbd *sdp)
 {
 	if (sdp->sd_lockstruct.ls_ops->lm_mount == NULL)
 		return 0;
 
-	return wait_on_bit(&sdp->sd_flags, SDF_NOJOURNALID, gfs2_journalid_wait, TASK_INTERRUPTIBLE);
+	return wait_on_bit(&sdp->sd_flags, SDF_NOJOURNALID, TASK_INTERRUPTIBLE)
+		? -EINTR : 0;
 }
 
 void gfs2_online_uevent(struct gfs2_sbd *sdp)
diff --git a/fs/gfs2/recovery.c b/fs/gfs2/recovery.c
index 94555d4c5698..573bd3b758fa 100644
--- a/fs/gfs2/recovery.c
+++ b/fs/gfs2/recovery.c
@@ -591,12 +591,6 @@ done:
 	wake_up_bit(&jd->jd_flags, JDF_RECOVERY);
 }
 
-static int gfs2_recovery_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 int gfs2_recover_journal(struct gfs2_jdesc *jd, bool wait)
 {
 	int rv;
@@ -609,7 +603,7 @@ int gfs2_recover_journal(struct gfs2_jdesc *jd, bool wait)
 	BUG_ON(!rv);
 
 	if (wait)
-		wait_on_bit(&jd->jd_flags, JDF_RECOVERY, gfs2_recovery_wait,
+		wait_on_bit(&jd->jd_flags, JDF_RECOVERY,
 			    TASK_UNINTERRUPTIBLE);
 
 	return wait ? jd->jd_recover_error : 0;
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 1319b5c4ec68..2607ff13d486 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -864,12 +864,6 @@ static int gfs2_make_fs_ro(struct gfs2_sbd *sdp)
 	return error;
 }
 
-static int gfs2_umount_recovery_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 /**
  * gfs2_put_super - Unmount the filesystem
  * @sb: The VFS superblock
@@ -894,7 +888,7 @@ restart:
 			continue;
 		spin_unlock(&sdp->sd_jindex_spin);
 		wait_on_bit(&jd->jd_flags, JDF_RECOVERY,
-			    gfs2_umount_recovery_wait, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		goto restart;
 	}
 	spin_unlock(&sdp->sd_jindex_spin);
diff --git a/fs/inode.c b/fs/inode.c
index 6eecb7ff0b9a..5938f3928944 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1695,13 +1695,6 @@ int inode_needs_sync(struct inode *inode)
 }
 EXPORT_SYMBOL(inode_needs_sync);
 
-int inode_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-EXPORT_SYMBOL(inode_wait);
-
 /*
  * If we try to find an inode in the inode hash while it is being
  * deleted, we have to wait until the filesystem completes its
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 38cfcf5f6fce..44ab297cecba 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -763,12 +763,6 @@ static void warn_dirty_buffer(struct buffer_head *bh)
 	       bdevname(bh->b_bdev, b), (unsigned long long)bh->b_blocknr);
 }
 
-static int sleep_on_shadow_bh(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 /*
  * If the buffer is already part of the current transaction, then there
  * is nothing we need to do.  If it is already part of a prior
@@ -906,8 +900,8 @@ repeat:
 		if (buffer_shadow(bh)) {
 			JBUFFER_TRACE(jh, "on shadow: sleep");
 			jbd_unlock_bh_state(bh);
-			wait_on_bit(&bh->b_state, BH_Shadow,
-				    sleep_on_shadow_bh, TASK_UNINTERRUPTIBLE);
+			wait_on_bit_io(&bh->b_state, BH_Shadow,
+				       TASK_UNINTERRUPTIBLE);
 			goto repeat;
 		}
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4042ff58fe3f..524dd80d1898 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -361,8 +361,8 @@ start:
 	 * Prevent starvation issues if someone is doing a consistency
 	 * sync-to-disk
 	 */
-	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
+	ret = wait_on_bit_action(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
+				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (ret)
 		return ret;
 
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 44bf0140a4c7..e2a0361e24c6 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -783,8 +783,8 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 static void nfs4_wait_ds_connect(struct nfs4_pnfs_ds *ds)
 {
 	might_sleep();
-	wait_on_bit(&ds->ds_state, NFS4DS_CONNECTING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
+	wait_on_bit_action(&ds->ds_state, NFS4DS_CONNECTING,
+			   nfs_wait_bit_killable, TASK_KILLABLE);
 }
 
 static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9927913c97c2..b7b710e7d08e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1074,8 +1074,8 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 	 * the bit lock here if it looks like we're going to be doing that.
 	 */
 	for (;;) {
-		ret = wait_on_bit(bitlock, NFS_INO_INVALIDATING,
-				  nfs_wait_bit_killable, TASK_KILLABLE);
+		ret = wait_on_bit_action(bitlock, NFS_INO_INVALIDATING,
+					 nfs_wait_bit_killable, TASK_KILLABLE);
 		if (ret)
 			goto out;
 		spin_lock(&inode->i_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 848f6853c59e..42f121182167 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1251,8 +1251,8 @@ int nfs4_wait_clnt_recover(struct nfs_client *clp)
 	might_sleep();
 
 	atomic_inc(&clp->cl_count);
-	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
+	res = wait_on_bit_action(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
+				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (res)
 		goto out;
 	if (clp->cl_cons_state < 0)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b6ee3a6ee96d..6104d3500b49 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -138,12 +138,6 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
 	return __nfs_iocounter_wait(c);
 }
 
-static int nfs_wait_bit_uninterruptible(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 /*
  * nfs_page_group_lock - lock the head of the page group
  * @req - request in group that is to be locked
@@ -158,7 +152,6 @@ nfs_page_group_lock(struct nfs_page *req)
 	WARN_ON_ONCE(head != head->wb_head);
 
 	wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
-			nfs_wait_bit_uninterruptible,
 			TASK_UNINTERRUPTIBLE);
 }
 
@@ -425,9 +418,8 @@ void nfs_release_request(struct nfs_page *req)
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-	return wait_on_bit(&req->wb_flags, PG_BUSY,
-			nfs_wait_bit_uninterruptible,
-			TASK_UNINTERRUPTIBLE);
+	return wait_on_bit_io(&req->wb_flags, PG_BUSY,
+			      TASK_UNINTERRUPTIBLE);
 }
 
 /*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6fdcd233d6f7..a8914b335617 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1885,7 +1885,7 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	if (test_and_set_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) {
 		if (!sync)
 			goto out;
-		status = wait_on_bit_lock(&nfsi->flags,
+		status = wait_on_bit_lock_action(&nfsi->flags,
 				NFS_INO_LAYOUTCOMMITTING,
 				nfs_wait_bit_killable,
 				TASK_KILLABLE);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 98ff061ccaf3..f05f321f9d3d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -397,7 +397,7 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	int err;
 
 	/* Stop dirtying of new pages while we sync */
-	err = wait_on_bit_lock(bitlock, NFS_INO_FLUSHING,
+	err = wait_on_bit_lock_action(bitlock, NFS_INO_FLUSHING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
 	if (err)
 		goto out_err;
@@ -1475,7 +1475,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 			return error;
 		if (!may_wait)
 			goto out_mark_dirty;
-		error = wait_on_bit(&NFS_I(inode)->flags,
+		error = wait_on_bit_action(&NFS_I(inode)->flags,
 				NFS_INO_COMMIT,
 				nfs_wait_bit_killable,
 				TASK_KILLABLE);
diff --git a/include/linux/wait.h b/include/linux/wait.h
index bd68819f0815..73960ff09e56 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -854,11 +854,14 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 		(wait)->flags = 0;					\
 	} while (0)
 
+
+extern int bit_wait(void *);
+extern int bit_wait_io(void *);
+
 /**
  * wait_on_bit - wait for a bit to be cleared
  * @word: the word being waited on, a kernel virtual address
  * @bit: the bit of the word being waited on
- * @action: the function used to sleep, which may take special actions
  * @mode: the task state to sleep in
  *
  * There is a standard hashed waitqueue table for generic use. This
@@ -867,9 +870,62 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
  * call wait_on_bit() in threads waiting for the bit to clear.
  * One uses wait_on_bit() where one is waiting for the bit to clear,
  * but has no intention of setting it.
+ * Returned value will be zero if the bit was cleared, or non-zero
+ * if the process received a signal and the mode permitted wakeup
+ * on that signal.
+ */
+static inline int
+wait_on_bit(void *word, int bit, unsigned mode)
+{
+	if (!test_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit(word, bit,
+				       bit_wait,
+				       mode);
+}
+
+/**
+ * wait_on_bit_io - wait for a bit to be cleared
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared.  This is similar to wait_on_bit(), but calls
+ * io_schedule() instead of schedule() for the actual waiting.
+ *
+ * Returned value will be zero if the bit was cleared, or non-zero
+ * if the process received a signal and the mode permitted wakeup
+ * on that signal.
+ */
+static inline int
+wait_on_bit_io(void *word, int bit, unsigned mode)
+{
+	if (!test_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit(word, bit,
+				       bit_wait_io,
+				       mode);
+}
+
+/**
+ * wait_on_bit_action - wait for a bit to be cleared
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @action: the function used to sleep, which may take special actions
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared, and allow the waiting action to be specified.
+ * This is like wait_on_bit() but allows fine control of how the waiting
+ * is done.
+ *
+ * Returned value will be zero if the bit was cleared, or non-zero
+ * if the process received a signal and the mode permitted wakeup
+ * on that signal.
  */
 static inline int
-wait_on_bit(void *word, int bit, int (*action)(void *), unsigned mode)
+wait_on_bit_action(void *word, int bit, int (*action)(void *), unsigned mode)
 {
 	if (!test_bit(bit, word))
 		return 0;
@@ -880,7 +936,6 @@ wait_on_bit(void *word, int bit, int (*action)(void *), unsigned mode)
  * wait_on_bit_lock - wait for a bit to be cleared, when wanting to set it
  * @word: the word being waited on, a kernel virtual address
  * @bit: the bit of the word being waited on
- * @action: the function used to sleep, which may take special actions
  * @mode: the task state to sleep in
  *
  * There is a standard hashed waitqueue table for generic use. This
@@ -891,9 +946,61 @@ wait_on_bit(void *word, int bit, int (*action)(void *), unsigned mode)
  * wait_on_bit() in threads waiting to be able to set the bit.
  * One uses wait_on_bit_lock() where one is waiting for the bit to
  * clear with the intention of setting it, and when done, clearing it.
+ *
+ * Returns zero if the bit was (eventually) found to be clear and was
+ * set.  Returns non-zero if a signal was delivered to the process and
+ * the @mode allows that signal to wake the process.
+ */
+static inline int
+wait_on_bit_lock(void *word, int bit, unsigned mode)
+{
+	if (!test_and_set_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit_lock(word, bit, bit_wait, mode);
+}
+
+/**
+ * wait_on_bit_lock_io - wait for a bit to be cleared, when wanting to set it
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared and then to atomically set it.  This is similar
+ * to wait_on_bit(), but calls io_schedule() instead of schedule()
+ * for the actual waiting.
+ *
+ * Returns zero if the bit was (eventually) found to be clear and was
+ * set.  Returns non-zero if a signal was delivered to the process and
+ * the @mode allows that signal to wake the process.
+ */
+static inline int
+wait_on_bit_lock_io(void *word, int bit, unsigned mode)
+{
+	if (!test_and_set_bit(bit, word))
+		return 0;
+	return out_of_line_wait_on_bit_lock(word, bit, bit_wait_io, mode);
+}
+
+/**
+ * wait_on_bit_lock_action - wait for a bit to be cleared, when wanting to set it
+ * @word: the word being waited on, a kernel virtual address
+ * @bit: the bit of the word being waited on
+ * @action: the function used to sleep, which may take special actions
+ * @mode: the task state to sleep in
+ *
+ * Use the standard hashed waitqueue table to wait for a bit
+ * to be cleared and then to set it, and allow the waiting action
+ * to be specified.
+ * This is like wait_on_bit() but allows fine control of how the waiting
+ * is done.
+ *
+ * Returns zero if the bit was (eventually) found to be clear and was
+ * set.  Returns non-zero if a signal was delivered to the process and
+ * the @mode allows that signal to wake the process.
  */
 static inline int
-wait_on_bit_lock(void *word, int bit, int (*action)(void *), unsigned mode)
+wait_on_bit_lock_action(void *word, int bit, int (*action)(void *), unsigned mode)
 {
 	if (!test_and_set_bit(bit, word))
 		return 0;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 5777c13849ba..a219be961c0a 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -90,7 +90,6 @@ struct writeback_control {
  * fs/fs-writeback.c
  */	
 struct bdi_writeback;
-int inode_wait(void *);
 void writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 							enum wb_reason reason);
@@ -105,7 +104,7 @@ void inode_wait_for_writeback(struct inode *inode);
 static inline void wait_on_inode(struct inode *inode)
 {
 	might_sleep();
-	wait_on_bit(&inode->i_state, __I_NEW, inode_wait, TASK_UNINTERRUPTIBLE);
+	wait_on_bit(&inode->i_state, __I_NEW, TASK_UNINTERRUPTIBLE);
 }
 
 /*
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index adf98622cb32..54e75226c2c4 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -28,12 +28,6 @@
 #include <linux/compat.h>
 
 
-static int ptrace_trapping_sleep_fn(void *flags)
-{
-	schedule();
-	return 0;
-}
-
 /*
  * ptrace a task: make the debugger its new parent and
  * move it to the ptrace list.
@@ -371,7 +365,7 @@ unlock_creds:
 out:
 	if (!retval) {
 		wait_on_bit(&task->jobctl, JOBCTL_TRAPPING_BIT,
-			    ptrace_trapping_sleep_fn, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		proc_ptrace_connector(task, PTRACE_ATTACH);
 	}
 
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 0ffa20ae657b..a104879e88f2 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -502,3 +502,21 @@ void wake_up_atomic_t(atomic_t *p)
 	__wake_up_bit(atomic_t_waitqueue(p), p, WAIT_ATOMIC_T_BIT_NR);
 }
 EXPORT_SYMBOL(wake_up_atomic_t);
+
+__sched int bit_wait(void *word)
+{
+	if (signal_pending_state(current->state, current))
+		return 1;
+	schedule();
+	return 0;
+}
+EXPORT_SYMBOL(bit_wait);
+
+__sched int bit_wait_io(void *word)
+{
+	if (signal_pending_state(current->state, current))
+		return 1;
+	io_schedule();
+	return 0;
+}
+EXPORT_SYMBOL(bit_wait_io);
diff --git a/mm/filemap.c b/mm/filemap.c
index dafb06f70a09..d175917e2411 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -241,18 +241,6 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
-static int sleep_on_page(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
-static int sleep_on_page_killable(void *word)
-{
-	sleep_on_page(word);
-	return fatal_signal_pending(current) ? -EINTR : 0;
-}
-
 static int filemap_check_errors(struct address_space *mapping)
 {
 	int ret = 0;
@@ -692,7 +680,7 @@ void wait_on_page_bit(struct page *page, int bit_nr)
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
 
 	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, sleep_on_page,
+		__wait_on_bit(page_waitqueue(page), &wait, bit_wait_io,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
@@ -705,7 +693,7 @@ int wait_on_page_bit_killable(struct page *page, int bit_nr)
 		return 0;
 
 	return __wait_on_bit(page_waitqueue(page), &wait,
-			     sleep_on_page_killable, TASK_KILLABLE);
+			     bit_wait_io, TASK_KILLABLE);
 }
 
 /**
@@ -806,7 +794,7 @@ void __lock_page(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
+	__wait_on_bit_lock(page_waitqueue(page), &wait, bit_wait_io,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
@@ -816,7 +804,7 @@ int __lock_page_killable(struct page *page)
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
 	return __wait_on_bit_lock(page_waitqueue(page), &wait,
-					sleep_on_page_killable, TASK_KILLABLE);
+					bit_wait_io, TASK_KILLABLE);
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 346ddc9e4c0d..fb7590222706 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1978,18 +1978,12 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static int just_wait(void *word)
-{
-	schedule();
-	return 0;
-}
-
 static void wait_while_offlining(void)
 {
 	while (ksm_run & KSM_RUN_OFFLINE) {
 		mutex_unlock(&ksm_thread_mutex);
 		wait_on_bit(&ksm_run, ilog2(KSM_RUN_OFFLINE),
-				just_wait, TASK_UNINTERRUPTIBLE);
+			    TASK_UNINTERRUPTIBLE);
 		mutex_lock(&ksm_thread_mutex);
 	}
 }
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 0a43cce9a914..e090bffe1bf8 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2186,12 +2186,6 @@ static void hci_inq_req(struct hci_request *req, unsigned long opt)
 	hci_req_add(req, HCI_OP_INQUIRY, sizeof(cp), &cp);
 }
 
-static int wait_inquiry(void *word)
-{
-	schedule();
-	return signal_pending(current);
-}
-
 int hci_inquiry(void __user *arg)
 {
 	__u8 __user *ptr = arg;
@@ -2242,7 +2236,7 @@ int hci_inquiry(void __user *arg)
 		/* Wait until Inquiry procedure finishes (HCI_INQUIRY flag is
 		 * cleared). If it is interrupted by a signal, return -EINTR.
 		 */
-		if (wait_on_bit(&hdev->flags, HCI_INQUIRY, wait_inquiry,
+		if (wait_on_bit(&hdev->flags, HCI_INQUIRY,
 				TASK_INTERRUPTIBLE))
 			return -EINTR;
 	}
diff --git a/security/keys/gc.c b/security/keys/gc.c
index d3222b6d7d59..9609a7f0faea 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -92,15 +92,6 @@ static void key_gc_timer_func(unsigned long data)
 }
 
 /*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-static int key_gc_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
  * Reap keys of dead type.
  *
  * We use three flags to make sure we see three complete cycles of the garbage
@@ -123,7 +114,7 @@ void key_gc_keytype(struct key_type *ktype)
 	schedule_work(&key_gc_work);
 
 	kdebug("sleep");
-	wait_on_bit(&key_gc_flags, KEY_GC_REAPING_KEYTYPE, key_gc_wait_bit,
+	wait_on_bit(&key_gc_flags, KEY_GC_REAPING_KEYTYPE,
 		    TASK_UNINTERRUPTIBLE);
 
 	key_gc_dead_keytype = NULL;
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 381411941cc1..26a94f18af94 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -21,24 +21,6 @@
 
 #define key_negative_timeout	60	/* default timeout on a negative key's existence */
 
-/*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-static int key_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
- * wait_on_bit() sleep function for interruptible waiting
- */
-static int key_wait_bit_intr(void *flags)
-{
-	schedule();
-	return signal_pending(current) ? -ERESTARTSYS : 0;
-}
-
 /**
  * complete_request_key - Complete the construction of a key.
  * @cons: The key construction record.
@@ -592,10 +574,9 @@ int wait_for_key_construction(struct key *key, bool intr)
 	int ret;
 
 	ret = wait_on_bit(&key->flags, KEY_FLAG_USER_CONSTRUCT,
-			  intr ? key_wait_bit_intr : key_wait_bit,
 			  intr ? TASK_INTERRUPTIBLE : TASK_UNINTERRUPTIBLE);
-	if (ret < 0)
-		return ret;
+	if (ret)
+		return -ERESTARTSYS;
 	if (test_bit(KEY_FLAG_NEGATIVE, &key->flags)) {
 		smp_rmb();
 		return key->type_data.reject_error;


