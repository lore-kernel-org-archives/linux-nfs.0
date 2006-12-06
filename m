From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 9/10] lockd: add code to handle deferred lock requests
Date: Wed,  6 Dec 2006 00:34:19 -0500
Message-ID: <4fbe0004219a67cb6da4d1b3a1cfd16a9cb09ed7.1165380893.git.bfields__1078.23979710719$1165383326$gmane$org@citi.umich.edu>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
	<11653832603105-git-send-email-bfields@fieldses.org>
	<11653832601058-git-send-email-bfields@fieldses.org>
	<11653832601635-git-send-email-bfields@fieldses.org>
	<1165383260424-git-send-email-bfields@fieldses.org>
	<11653832601925-git-send-email-bfields@fieldses.org>
	<1165383260548-git-send-email-bfields@fieldses.org>
	<11653832612071-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrpQH-0006XU-Dq
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:25 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GrpQH-0008BC-W1
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:26 -0800
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832612071-git-send-email-bfields@fieldses.org>
Message-Id: <4fbe0004219a67cb6da4d1b3a1cfd16a9cb09ed7.1165380893.git.bfields@citi.umich.edu>
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

From: Marc Eshel <eshel@almaden.ibm.com>

Rewrite nlmsvc_lock() to use the asynchronous interface.

As with testlock, we answer nlm requests in nlmsvc_lock by first looking up
the block and then using the results we find in the block if B_QUEUED is
set, and calling vfs_lock_file() otherwise.

If this a new lock request and we get -EINPROGRESS return on a non-blocking
request then we defer the request.

Also modify nlmsvc_unlock() to call the filesystem method if appropriate.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   40 ++++++++++++++++++++++++++++++++++------
 fs/lockd/svcsubs.c |    2 +-
 2 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 134a40e..90bac90 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -499,17 +499,44 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	} else
 		lock->fl.fl_flags &= ~FL_SLEEP;
 
-	error = posix_lock_file(file->f_file, &lock->fl);
-	lock->fl.fl_flags &= ~FL_SLEEP;
 
-	dprintk("lockd: posix_lock_file returned %d\n", error);
+	if (block->b_flags & B_QUEUED) {
+		dprintk("lockd: nlmsvc_lock deferred block %p flags %d\n",
+							block, block->b_flags);
+		if (block->b_granted) {
+			nlmsvc_unlink_block(block);
+			ret = nlm_granted;
+			goto out;
+		}
+		if (block->b_flags & B_TOO_LATE) {
+			nlmsvc_unlink_block(block);
+			ret = nlm_lck_denied;
+			goto out;
+		}
+		ret = nlm_drop_reply;
+		goto out;
+	}
 
+	if (!wait)
+		lock->fl.fl_flags &= ~FL_SLEEP;
+	error = vfs_lock_file(file->f_file, &lock->fl);
+	lock->fl.fl_flags &= ~FL_SLEEP;
+
+	dprintk("lockd: vfs_lock_file returned %d\n", error);
 	switch(error) {
 		case 0:
 			ret = nlm_granted;
 			goto out;
 		case -EAGAIN:
+			ret = nlm_lck_denied;
 			break;
+		case -EINPROGRESS:
+			if (wait)
+				break;
+			/* Filesystem lock operation is in progress
+			   Add it to the queue waiting for callback */
+			ret = nlmsvc_defer_lock_rqst(rqstp, block);
+			goto out;
 		case -EDEADLK:
 			ret = nlm_deadlock;
 			goto out;
@@ -623,7 +650,7 @@ nlmsvc_unlock(struct nlm_file *file, struct nlm_lock *lock)
 	nlmsvc_cancel_blocked(file, lock);
 
 	lock->fl.fl_type = F_UNLCK;
-	error = posix_lock_file(file->f_file, &lock->fl);
+	error = vfs_lock_file(file->f_file, &lock->fl);
 
 	return (error < 0)? nlm_lck_denied_nolocks : nlm_granted;
 }
@@ -769,14 +796,15 @@ nlmsvc_grant_blocked(struct nlm_block *block)
 
 	/* Try the lock operation again */
 	lock->fl.fl_flags |= FL_SLEEP;
-	error = posix_lock_file(file->f_file, &lock->fl);
+	error = vfs_lock_file(file->f_file, &lock->fl);
 	lock->fl.fl_flags &= ~FL_SLEEP;
 
 	switch (error) {
 	case 0:
 		break;
 	case -EAGAIN:
-		dprintk("lockd: lock still blocked\n");
+	case -EINPROGRESS:
+		dprintk("lockd: lock still blocked error %d\n", error);
 		nlmsvc_insert_block(block, NLM_NEVER);
 		nlmsvc_release_block(block);
 		return;
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index e83024e..bb2f6b1 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -182,7 +182,7 @@ again:
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
-			if (posix_lock_file(file->f_file, &lock) < 0) {
+			if (vfs_lock_file(file->f_file, &lock) < 0) {
 				printk("lockd: unlock failure in %s:%d\n",
 						__FILE__, __LINE__);
 				return 1;
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
