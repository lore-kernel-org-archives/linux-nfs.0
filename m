From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 4/10] locks: add fl_notify arguments
Date: Wed,  6 Dec 2006 00:34:14 -0500
Message-ID: <11653832601635-git-send-email-bfields@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
	<11653832603105-git-send-email-bfields@fieldses.org>
	<11653832601058-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrpQL-0006YP-Qf
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:29 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GrpQM-0006dL-UB
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:31 -0800
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832601058-git-send-email-bfields@fieldses.org>
Message-Id: <665bfdae3a5b77bb7755f4735069b7188f815d89.1165380893.git.bfields@citi.umich.edu>
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@fieldses.org>

We're using fl_notify to asynchronously return the result of a lock
request.  So we want fl_notify to be able to return a status and, if
appropriate, a conflicting lock.

This only current caller of fl_notify is in the blocked case, in which case
we don't use these extra arguments.

We also allow fl_notify to return an error.  (Also ignored for now.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |    7 ++++---
 fs/locks.c         |    2 +-
 include/linux/fs.h |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 2ce4dc6..32f4cc4 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -637,12 +637,13 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
  * This function doesn't grant the blocked lock instantly, but rather moves
  * the block to the head of nlm_blocked where it can be picked up by lockd.
  */
-static void
-nlmsvc_notify_blocked(struct file_lock *fl)
+static int
+nlmsvc_notify_blocked(struct file_lock *fl, struct file_lock *conf, int result)
 {
 	struct nlm_block	*block;
 
-	dprintk("lockd: VFS unblock notification for block %p\n", fl);
+	dprintk("lockd: nlmsvc_notify_blocked lock %p conf %p result %d\n",
+							fl, conf, result);
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
 			nlmsvc_insert_block(block, 0);
diff --git a/fs/locks.c b/fs/locks.c
index 451a61a..959347e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -544,7 +544,7 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 				struct file_lock, fl_block);
 		__locks_delete_block(waiter);
 		if (waiter->fl_lmops && waiter->fl_lmops->fl_notify)
-			waiter->fl_lmops->fl_notify(waiter);
+			waiter->fl_lmops->fl_notify(waiter, NULL, -EAGAIN);
 		else
 			wake_up(&waiter->fl_wait);
 	}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b1d287b..9b57afc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -795,7 +795,7 @@ struct file_lock_operations {
 
 struct lock_manager_operations {
 	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
-	void (*fl_notify)(struct file_lock *);	/* unblock callback */
+	int (*fl_notify)(struct file_lock *, struct file_lock *, int);
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *);
-- 
1.4.4.1


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
