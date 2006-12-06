From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 5/10] lockd: handle fl_notify callbacks
Date: Wed,  6 Dec 2006 00:34:15 -0500
Message-ID: <e9e7fa0047137e5c988edaacc3dc70a84eb02efb.1165380893.git.bfields__12683.5681418472$1165383397$gmane$org@citi.umich.edu>
References: <11653832602203-git-send-email-bfields@fieldses.org> <1165383260627-git-send-email-bfields@fieldses.org> <11653832603105-git-send-email-bfields@fieldses.org> <11653832601058-git-send-email-bfields@fieldses.org> <11653832601635-git-send-email-bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832601635-git-send-email-bfields@fieldses.org>
Message-Id: <e9e7fa0047137e5c988edaacc3dc70a84eb02efb.1165380893.git.bfields@citi.umich.edu>
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com>

Add code to handle file system callback when the lock is finally granted.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   78 ++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 72 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 32f4cc4..90aa4a5 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -367,6 +367,8 @@ static void nlmsvc_free_block(struct kref *kref)
 	nlmsvc_freegrantargs(block->b_call);
 	nlm_release_call(block->b_call);
 	nlm_release_file(block->b_file);
+	if (block->b_fl)
+		kfree(block->b_fl);
 	kfree(block);
 }
 
@@ -631,6 +633,32 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 }
 
 /*
+ * This is a callback from the filesystem for VFS file lock requests.
+ * It will be used if fl_notify is defined and the filesystem can not
+ * respond to the request immediately.
+ * For GETLK request it will copy the reply to the nlm_block.
+ * For SETLK or SETLKW request it will get the local posix lock.
+ * In all cases it will move the block to the head of nlm_blocked q where
+ * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
+ * deferred rpc for GETLK and SETLK.
+ */
+static void
+nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
+			     int result)
+{
+	block->b_flags |= B_GOT_CALLBACK;
+	if (result == 0)
+		block->b_granted = 1;
+	else
+		block->b_flags |= B_TOO_LATE;
+	if (conf) {
+		block->b_fl = kmalloc(sizeof(struct file_lock), GFP_KERNEL);
+		if (block->b_fl)
+			locks_copy_lock(block->b_fl, conf);
+	}
+}
+
+/*
  * Unblock a blocked lock request. This is a callback invoked from the
  * VFS layer when a lock on which we blocked is removed.
  *
@@ -641,18 +669,33 @@ static int
 nlmsvc_notify_blocked(struct file_lock *fl, struct file_lock *conf, int result)
 {
 	struct nlm_block	*block;
+	int rc = -ENOENT;
 
 	dprintk("lockd: nlmsvc_notify_blocked lock %p conf %p result %d\n",
 							fl, conf, result);
+	lock_kernel();
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
+			dprintk("lockd: nlmsvc_notify_blocked block %p flags %d\n",
+							block, block->b_flags);
+			if (block->b_flags & B_QUEUED) {
+				if (block->b_flags & B_TOO_LATE) {
+					rc = -ENOLCK;
+					break;
+				}
+				nlmsvc_update_deferred_block(block, conf, result);
+			}
 			nlmsvc_insert_block(block, 0);
 			svc_wake_up(block->b_daemon);
-			return;
+			rc = 0;
+			break;
 		}
 	}
+	unlock_kernel();
 
-	printk(KERN_WARNING "lockd: notification for unknown block!\n");
+	if (rc == -ENOENT)
+		printk(KERN_WARNING "lockd: notification for unknown block!\n");
+	return rc;
 }
 
 static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
@@ -685,6 +728,8 @@ nlmsvc_grant_blocked(struct nlm_block *block)
 
 	dprintk("lockd: grant blocked lock %p\n", block);
 
+	kref_get(&block->b_count);
+
 	/* Unlink block request from list */
 	nlmsvc_unlink_block(block);
 
@@ -707,11 +752,13 @@ nlmsvc_grant_blocked(struct nlm_block *block)
 	case -EAGAIN:
 		dprintk("lockd: lock still blocked\n");
 		nlmsvc_insert_block(block, NLM_NEVER);
+		nlmsvc_release_block(block);
 		return;
 	default:
 		printk(KERN_WARNING "lockd: unexpected error %d in %s!\n",
 				-error, __FUNCTION__);
 		nlmsvc_insert_block(block, 10 * HZ);
+		nlmsvc_release_block(block);
 		return;
 	}
 
@@ -724,7 +771,6 @@ callback:
 	nlmsvc_insert_block(block, 30 * HZ);
 
 	/* Call the client */
-	kref_get(&block->b_count);
 	if (nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG,
 						&nlmsvc_grant_ops) < 0)
 		nlmsvc_release_block(block);
@@ -799,6 +845,23 @@ nlmsvc_grant_reply(struct nlm_cookie *cookie, u32 status)
 	nlmsvc_release_block(block);
 }
 
+/* Helper function to handle retry of a deferred block.
+ * If it is a blocking lock, call grant_blocked.
+ * For a non-blocking lock or test lock, revisit the request.
+ */
+static void
+retry_deferred_block(struct nlm_block *block)
+{
+	if (!(block->b_flags & B_GOT_CALLBACK))
+		block->b_flags |= B_TOO_LATE;
+	nlmsvc_insert_block(block, NLM_TIMEOUT);
+	dprintk("revisit block %p flags %d\n",	block, block->b_flags);
+	if (block->b_deferred_req) {
+		block->b_deferred_req->revisit(block->b_deferred_req, 0);
+		block->b_deferred_req = NULL;
+	}
+}
+
 /*
  * Retry all blocked locks that have been notified. This is where lockd
  * picks up locks that can be granted, or grant notifications that must
@@ -822,9 +885,12 @@ nlmsvc_retry_blocked(void)
 
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
 			block, block->b_when);
-		kref_get(&block->b_count);
-		nlmsvc_grant_blocked(block);
-		nlmsvc_release_block(block);
+		if (block->b_flags & B_QUEUED) {
+			dprintk("nlmsvc_retry_blocked delete block (%p, granted=%d, flags=%d)\n",
+				block, block->b_granted, block->b_flags);
+			retry_deferred_block(block);
+		} else
+			nlmsvc_grant_blocked(block);
 	}
 
 	return timeout;
-- 
1.4.4.1

