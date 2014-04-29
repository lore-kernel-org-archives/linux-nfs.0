Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48100 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933000AbaD2JoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2014 05:44:16 -0400
Date: Tue, 29 Apr 2014 19:44:06 +1000
From: NeilBrown <neilb@suse.de>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC] SCHED: allow wait_on_bit functions to support a
 timeout.
Message-ID: <20140429194406.06c580b8@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/4zntKnRHIUPiHCh.r/ZdMkE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/4zntKnRHIUPiHCh.r/ZdMkE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



It is currently not possible for various wait_on_bit functions to
implement a timeout.
While the "action" function that is called to do the waiting could
certainly use schedule_timeout(), there is no way to carry forward the
remaining timeout after a false wake-up.
As false-wakeups a clearly possible at least due to possible
hash collisions in bit_waitqueue(), this is a real problem.

The 'action' function is currently passed a pointer to the word
containing the bit being waited on.  Of the 27 currently defined
action functions, zero of them use this pointer.
So changing it to something else will be a little noisy but will have
no immediate effect.

This patch changes the 'action' function to take a pointer to the
"struct wait_bit_key", which contains a pointer to the word
containing the bit so nothing is really lost.

It also adds a 'private' field to "struct wait_bit_key", which is
initialized to zero.

An action function can now implement a timeout with something like

static int timed_out_waiter(struct wait_bit_key *key)
{
	unsigned long waited;
	if (key->private =3D=3D 0) {
		key->private =3D jiffies;
		if (key->private =3D=3D 0)
			key->private -=3D 1;
	}
	waited =3D jiffies - key->private;
	if (waited > 10 * HZ)
		return -EAGAIN;
	schedule_timeout(waited - 10 * HZ);
	return 0;
}

If any other need for context in a waiter were found it would be easy
to use ->private for some other purpose, or even extend "struct
wait_bit_key".

My particular need is to support timeouts in nfs_release_page() to
avoid deadlocks with loopback mounted NFS.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 66c5d130c8c2..3f51affd7d0e 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -617,7 +617,7 @@ static void write_endio(struct bio *bio, int error)
 /*
  * This function is called when wait_on_bit is actually waiting.
  */
-static int do_io_schedule(void *word)
+static int do_io_schedule(struct wait_bit_key *key)
 {
 	io_schedule();
=20
diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index ebddef5237e4..efd2c6753e10 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -1032,7 +1032,7 @@ static void start_merge(struct dm_snapshot *s)
 		snapshot_merge_next_chunks(s);
 }
=20
-static int wait_schedule(void *ptr)
+static int wait_schedule(struct wait_bit_key *key)
 {
 	schedule();
=20
diff --git a/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c b/drivers/media/us=
b/dvb-usb-v2/dvb_usb_core.c
index 8a054d66e708..c2677deaf83c 100644
--- a/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
+++ b/drivers/media/usb/dvb-usb-v2/dvb_usb_core.c
@@ -253,7 +253,7 @@ static int dvb_usbv2_adapter_stream_exit(struct dvb_usb=
_adapter *adap)
 	return usb_urb_exitv2(&adap->stream);
 }
=20
-static int wait_schedule(void *ptr)
+static int wait_schedule(struct wait_bit_key *key)
 {
 	schedule();
=20
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 85bbd01f1271..de1926efeb43 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3366,7 +3366,7 @@ done_unlocked:
 	return 0;
 }
=20
-static int eb_wait(void *word)
+static int eb_wait(struct wait_bit_key *key)
 {
 	io_schedule();
 	return 0;
diff --git a/fs/buffer.c b/fs/buffer.c
index 27265a8b43c1..75c22932fd35 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -61,7 +61,7 @@ inline void touch_buffer(struct buffer_head *bh)
 }
 EXPORT_SYMBOL(touch_buffer);
=20
-static int sleep_on_buffer(void *word)
+static int sleep_on_buffer(struct wait_bit_key *key)
 {
 	io_schedule();
 	return 0;
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 8813ff776ba3..b2e1a2ff8991 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3932,7 +3932,7 @@ cifs_sb_master_tcon(struct cifs_sb_info *cifs_sb)
 }
=20
 static int
-cifs_sb_tcon_pending_wait(void *unused)
+cifs_sb_tcon_pending_wait(struct wait_bit_key *unused)
 {
 	schedule();
 	return signal_pending(current) ? -ERESTARTSYS : 0;
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 4226f6680b06..0988cf622f72 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -91,8 +91,8 @@ static inline bool fscache_object_congested(void)
 	return workqueue_congested(WORK_CPU_UNBOUND, fscache_object_wq);
 }
=20
-extern int fscache_wait_bit(void *);
-extern int fscache_wait_bit_interruptible(void *);
+extern int fscache_wait_bit(struct wait_bit_key *);
+extern int fscache_wait_bit_interruptible(struct wait_bit_key *);
 extern int fscache_wait_atomic_t(atomic_t *);
=20
 /*
diff --git a/fs/fscache/main.c b/fs/fscache/main.c
index 7c27907e650c..b393201c1388 100644
--- a/fs/fscache/main.c
+++ b/fs/fscache/main.c
@@ -200,7 +200,7 @@ module_exit(fscache_exit);
 /*
  * wait_on_bit() sleep function for uninterruptible waiting
  */
-int fscache_wait_bit(void *flags)
+int fscache_wait_bit(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
@@ -209,7 +209,7 @@ int fscache_wait_bit(void *flags)
 /*
  * wait_on_bit() sleep function for interruptible waiting
  */
-int fscache_wait_bit_interruptible(void *flags)
+int fscache_wait_bit_interruptible(struct wait_bit_key *key)
 {
 	schedule();
 	return signal_pending(current);
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index ca0be6c69a26..25ff6e95b814 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -862,13 +862,13 @@ void gfs2_holder_uninit(struct gfs2_holder *gh)
  * order to be more informative to the user.
  */
=20
-static int gfs2_glock_holder_wait(void *word)
+static int gfs2_glock_holder_wait(struct wait_bit_key *key)
 {
         schedule();
         return 0;
 }
=20
-static int gfs2_glock_demote_wait(void *word)
+static int gfs2_glock_demote_wait(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/fs/gfs2/lock_dlm.c b/fs/gfs2/lock_dlm.c
index 2a6ba06bee6f..10bfdfec9fa3 100644
--- a/fs/gfs2/lock_dlm.c
+++ b/fs/gfs2/lock_dlm.c
@@ -934,7 +934,7 @@ fail:
 	return error;
 }
=20
-static int dlm_recovery_wait(void *word)
+static int dlm_recovery_wait(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index c6872d09561a..e7ec580da091 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -1071,7 +1071,7 @@ void gfs2_lm_unmount(struct gfs2_sbd *sdp)
 		lm->lm_unmount(sdp);
 }
=20
-static int gfs2_journalid_wait(void *word)
+static int gfs2_journalid_wait(struct wait_bit_key *key)
 {
 	if (signal_pending(current))
 		return -EINTR;
diff --git a/fs/gfs2/recovery.c b/fs/gfs2/recovery.c
index 963b2d75200c..63c371e27228 100644
--- a/fs/gfs2/recovery.c
+++ b/fs/gfs2/recovery.c
@@ -591,7 +591,7 @@ done:
 	wake_up_bit(&jd->jd_flags, JDF_RECOVERY);
 }
=20
-static int gfs2_recovery_wait(void *word)
+static int gfs2_recovery_wait(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 60f60f6181f3..daa0a3a64c28 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -858,7 +858,7 @@ static int gfs2_make_fs_ro(struct gfs2_sbd *sdp)
 	return error;
 }
=20
-static int gfs2_umount_recovery_wait(void *word)
+static int gfs2_umount_recovery_wait(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/fs/inode.c b/fs/inode.c
index 4bcdad3c9361..2ba2da54eebc 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1696,7 +1696,7 @@ int inode_needs_sync(struct inode *inode)
 }
 EXPORT_SYMBOL(inode_needs_sync);
=20
-int inode_wait(void *word)
+int inode_wait(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 60bb365f54a5..b7ed6e229bf3 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -763,7 +763,7 @@ static void warn_dirty_buffer(struct buffer_head *bh)
 	       bdevname(bh->b_bdev, b), (unsigned long long)bh->b_blocknr);
 }
=20
-static int sleep_on_shadow_bh(void *word)
+static int sleep_on_shadow_bh(struct wait_bit_key *key)
 {
 	io_schedule();
 	return 0;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 91c4746fdab1..c26c55e1ad25 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -75,7 +75,7 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
  * nfs_wait_bit_killable - helper for functions that are sleeping on bit l=
ocks
  * @word: long word containing the bit lock
  */
-int nfs_wait_bit_killable(void *word)
+int nfs_wait_bit_killable(struct wait_bit_key *key)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b46cf5a67329..b4f65ca80d65 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -341,7 +341,7 @@ extern int nfs_drop_inode(struct inode *);
 extern void nfs_clear_inode(struct inode *);
 extern void nfs_evict_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
-extern int nfs_wait_bit_killable(void *word);
+extern int nfs_wait_bit_killable(struct wait_bit_key *key);
=20
 /* super.c */
 extern const struct super_operations nfs_sops;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2ffebf2081ce..d48c1001c29c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -258,7 +258,7 @@ void nfs_release_request(struct nfs_page *req)
 	kref_put(&req->wb_kref, nfs_free_request);
 }
=20
-static int nfs_wait_bit_uninterruptible(void *word)
+static int nfs_wait_bit_uninterruptible(struct wait_bit_key *key)
 {
 	io_schedule();
 	return 0;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 3a847de83fab..592be588ce62 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -236,7 +236,7 @@ void *		rpc_malloc(struct rpc_task *, size_t);
 void		rpc_free(void *);
 int		rpciod_up(void);
 void		rpciod_down(void);
-int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(void *)=
);
+int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(struct =
wait_bit_key *));
 #ifdef RPC_DEBUG
 struct net;
 void		rpc_show_tasks(struct net *);
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 559044c79232..d7ce4c908352 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -25,6 +25,7 @@ struct wait_bit_key {
 	void			*flags;
 	int			bit_nr;
 #define WAIT_ATOMIC_T_BIT_NR	-1
+	unsigned long		private;
 };
=20
 struct wait_bit_queue {
@@ -147,12 +148,12 @@ void __wake_up_sync_key(wait_queue_head_t *q, unsigne=
d int mode, int nr, void *k
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_bit(wait_queue_head_t *, void *, int);
-int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(vo=
id *), unsigned);
-int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (=
*)(void *), unsigned);
+int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(st=
ruct wait_bit_key *), unsigned);
+int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (=
*)(struct wait_bit_key *), unsigned);
 void wake_up_bit(void *, int);
 void wake_up_atomic_t(atomic_t *);
-int out_of_line_wait_on_bit(void *, int, int (*)(void *), unsigned);
-int out_of_line_wait_on_bit_lock(void *, int, int (*)(void *), unsigned);
+int out_of_line_wait_on_bit(void *, int, int (*)(struct wait_bit_key *), u=
nsigned);
+int out_of_line_wait_on_bit_lock(void *, int, int (*)(struct wait_bit_key =
*), unsigned);
 int out_of_line_wait_on_atomic_t(atomic_t *, int (*)(atomic_t *), unsigned=
);
 wait_queue_head_t *bit_waitqueue(void *, int);
=20
@@ -868,7 +869,7 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode=
, int sync, void *key);
  * but has no intention of setting it.
  */
 static inline int
-wait_on_bit(void *word, int bit, int (*action)(void *), unsigned mode)
+wait_on_bit(void *word, int bit, int (*action)(struct wait_bit_key *), uns=
igned mode)
 {
 	if (!test_bit(bit, word))
 		return 0;
@@ -892,7 +893,7 @@ wait_on_bit(void *word, int bit, int (*action)(void *),=
 unsigned mode)
  * clear with the intention of setting it, and when done, clearing it.
  */
 static inline int
-wait_on_bit_lock(void *word, int bit, int (*action)(void *), unsigned mode)
+wait_on_bit_lock(void *word, int bit, int (*action)(struct wait_bit_key *)=
, unsigned mode)
 {
 	if (!test_and_set_bit(bit, word))
 		return 0;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 021b8a319b9e..0aeac2801479 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -90,7 +90,7 @@ struct writeback_control {
  * fs/fs-writeback.c
  */=09
 struct bdi_writeback;
-int inode_wait(void *);
+int inode_wait(struct wait_bit_key *);
 void writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 							enum wb_reason reason);
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 1f4bcb3cc21c..64e2183d9e1c 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -28,7 +28,7 @@
 #include <linux/compat.h>
=20
=20
-static int ptrace_trapping_sleep_fn(void *flags)
+static int ptrace_trapping_sleep_fn(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 7d50f794e248..5add4ffe815c 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -319,14 +319,14 @@ EXPORT_SYMBOL(wake_bit_function);
  */
 int __sched
 __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
-			int (*action)(void *), unsigned mode)
+			int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	int ret =3D 0;
=20
 	do {
 		prepare_to_wait(wq, &q->wait, mode);
 		if (test_bit(q->key.bit_nr, q->key.flags))
-			ret =3D (*action)(q->key.flags);
+			ret =3D (*action)(&q->key);
 	} while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
 	finish_wait(wq, &q->wait);
 	return ret;
@@ -334,7 +334,7 @@ __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_qu=
eue *q,
 EXPORT_SYMBOL(__wait_on_bit);
=20
 int __sched out_of_line_wait_on_bit(void *word, int bit,
-					int (*action)(void *), unsigned mode)
+					int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
 	DEFINE_WAIT_BIT(wait, word, bit);
@@ -345,7 +345,7 @@ EXPORT_SYMBOL(out_of_line_wait_on_bit);
=20
 int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
-			int (*action)(void *), unsigned mode)
+			int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	do {
 		int ret;
@@ -353,7 +353,7 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_b=
it_queue *q,
 		prepare_to_wait_exclusive(wq, &q->wait, mode);
 		if (!test_bit(q->key.bit_nr, q->key.flags))
 			continue;
-		ret =3D action(q->key.flags);
+		ret =3D action(&q->key);
 		if (!ret)
 			continue;
 		abort_exclusive_wait(wq, &q->wait, mode, &q->key);
@@ -365,7 +365,7 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_b=
it_queue *q,
 EXPORT_SYMBOL(__wait_on_bit_lock);
=20
 int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
-					int (*action)(void *), unsigned mode)
+					int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
 	DEFINE_WAIT_BIT(wait, word, bit);
diff --git a/mm/filemap.c b/mm/filemap.c
index 7a13f6ac5421..4e9ed37e566d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -176,15 +176,15 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
=20
-static int sleep_on_page(void *word)
+static int sleep_on_page(struct wait_bit_key *key)
 {
 	io_schedule();
 	return 0;
 }
=20
-static int sleep_on_page_killable(void *word)
+static int sleep_on_page_killable(struct wait_bit_key *key)
 {
-	sleep_on_page(word);
+	sleep_on_page(key);
 	return fatal_signal_pending(current) ? -EINTR : 0;
 }
=20
diff --git a/mm/ksm.c b/mm/ksm.c
index 68710e80994a..997b07993e77 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1979,7 +1979,7 @@ void ksm_migrate_page(struct page *newpage, struct pa=
ge *oldpage)
 #endif /* CONFIG_MIGRATION */
=20
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static int just_wait(void *word)
+static int just_wait(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 5e8663c194c1..9d4ecf66202f 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1753,7 +1753,7 @@ static void hci_inq_req(struct hci_request *req, unsi=
gned long opt)
 	hci_req_add(req, HCI_OP_INQUIRY, sizeof(cp), &cp);
 }
=20
-static int wait_inquiry(void *word)
+static int wait_inquiry(struct wait_bit_key *key)
 {
 	schedule();
 	return signal_pending(current);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index ff3cc4bf4b24..132a5e93207a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -250,7 +250,7 @@ void rpc_destroy_wait_queue(struct rpc_wait_queue *queu=
e)
 }
 EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
=20
-static int rpc_wait_bit_killable(void *word)
+static int rpc_wait_bit_killable(struct wait_bit_key *key)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
@@ -309,7 +309,7 @@ static int rpc_complete_task(struct rpc_task *task)
  * to enforce taking of the wq->lock and hence avoid races with
  * rpc_complete_task().
  */
-int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(vo=
id *))
+int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(st=
ruct wait_bit_key *))
 {
 	if (action =3D=3D NULL)
 		action =3D rpc_wait_bit_killable;
diff --git a/security/keys/gc.c b/security/keys/gc.c
index d3222b6d7d59..3b5375cf558e 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -94,7 +94,7 @@ static void key_gc_timer_func(unsigned long data)
 /*
  * wait_on_bit() sleep function for uninterruptible waiting
  */
-static int key_gc_wait_bit(void *flags)
+static int key_gc_wait_bit(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 381411941cc1..ed43d04db4fd 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -24,7 +24,7 @@
 /*
  * wait_on_bit() sleep function for uninterruptible waiting
  */
-static int key_wait_bit(void *flags)
+static int key_wait_bit(struct wait_bit_key *key)
 {
 	schedule();
 	return 0;
@@ -33,7 +33,7 @@ static int key_wait_bit(void *flags)
 /*
  * wait_on_bit() sleep function for interruptible waiting
  */
-static int key_wait_bit_intr(void *flags)
+static int key_wait_bit_intr(struct wait_bit_key *key)
 {
 	schedule();
 	return signal_pending(current) ? -ERESTARTSYS : 0;

--Sig_/4zntKnRHIUPiHCh.r/ZdMkE
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU190Zjnsnt1WYoG5AQIIIA/+LzUic4oUO0HaHRsx2M3rtKlIQsM0Ghot
+C777TX3TQPGEbuPIV0URJz9JPlUOVAAPtdSzf08QclqeJJyqEGP0K5nwgtMtMJ8
OQlNyxiVYf1BU8fRdlZnCUdN8LbqH1jJYGe/xP7JyvS0iEYIrwBa5A4GDGCVWHnp
6GZkp1BpZFl7CMay/VlmZ3efkytOuPd1YppVQYyYxBK6zSJTQ1lK+nlBfA9VW/LT
GTt0LKucVAPrCyIGaU5c9fmuR2WX5o24m9nU8n2GGO49n+oUuk2OMRro2t4HSVsi
ZOIxj0tBaezoPFmoyGthpJsDL0LOS0mSuMiVFdPy230aVqiDFRFCsO6BspVgzVPz
+GV6mB+fQlBC1ARu25vq2Yk+w6ase3f+hZxnpHJZuTxsVeyKQ92Y0HYXVDpVgRMt
34OMV6tullyvEaKO8bCDF2iSqYbrFTXN9vP4637xKq1o7P4YJ8jSnNNQzzwenGrD
Dk+Ux5Iff0TdG+YmDZz6X0JNcjfy9Fjg3BlGyYi8qhjyTKDfcXhWACrD4XgTW9dk
3NYTh8j/R7qZDLS09aJc+5liE/IwMtE7xwG4LVTMiDoYAVmB2Vf17AMjraV7lB57
w88ygvPpj87GsYururFNyf9eYOOeW+yePVGDGtBc+AU0rHJS1UfWUnXyPL81p7ZK
APWweUcU9Ew=
=pcFU
-----END PGP SIGNATURE-----

--Sig_/4zntKnRHIUPiHCh.r/ZdMkE--
