Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965899Ab3FUM65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 08:58:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v4 08/14] locks: avoid taking global lock if possible when waking up blocked waiters
Date: Fri, 21 Jun 2013 08:58:16 -0400
Message-Id: <1371819502-26363-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we always hold the i_lock when inserting a new waiter onto the
fl_block list, we can avoid taking the global lock at all if we find
that it's empty when we go to wake up blocked waiters.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ce302d4..84e269f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -548,7 +548,10 @@ static void locks_delete_block(struct file_lock *waiter)
  * the order they blocked. The documentation doesn't require this but
  * it seems like the reasonable thing to do.
  *
- * Must be called with file_lock_lock held!
+ * Must be called with both the i_lock and file_lock_lock held. The fl_block
+ * list itself is protected by the file_lock_list, but by ensuring that the
+ * i_lock is also held on insertions we can avoid taking the file_lock_lock
+ * in some cases when we see that the fl_block list is empty.
  */
 static void __locks_insert_block(struct file_lock *blocker,
 					struct file_lock *waiter)
@@ -576,6 +579,16 @@ static void locks_insert_block(struct file_lock *blocker,
  */
 static void locks_wake_up_blocks(struct file_lock *blocker)
 {
+	/*
+	 * Avoid taking global lock if list is empty. This is safe since new
+	 * blocked requests are only added to the list under the i_lock, and
+	 * the i_lock is always held here. Note that removal from the fl_block
+	 * list does not require the i_lock, so we must recheck list_empty()
+	 * after acquiring the file_lock_lock.
+	 */
+	if (list_empty(&blocker->fl_block))
+		return;
+
 	spin_lock(&file_lock_lock);
 	while (!list_empty(&blocker->fl_block)) {
 		struct file_lock *waiter;
-- 
1.7.1

