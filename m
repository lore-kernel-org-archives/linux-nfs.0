From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 13/14] lockd: add code to handle deferred lock requests
Date: Sat,  3 Feb 2007 00:34:09 -0500
Message-ID: <45678.1026362025$1170480890@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email->
	<11704808502512-git-send-email-> <11704808513862-git-send-email->
	<1170480851972-git-send-email->
	<11704808513070-git-send-email-> <117048085185-git-send-email->
	<11704808513263-git-send-email-> <11704808513185-git-send-email->
	<11704808511238-git-send-email-> <11704808513085-git-send-email->
	<11704808521765-git-send-email-> <11704808523686-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDXS-0001HV-1m
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:17 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDDXS-0001C3-Ou
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:16 -0800
In-Reply-To: <11704808523686-git-send-email->
Message-Id: <b18934dedc3dd49bd1578256944c8fb756db2a6c.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
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

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

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
index 32202fa..61137b6 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -393,17 +393,44 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
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
+	error = vfs_lock_file(file->f_file, F_SETLK, &lock->fl);
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
@@ -519,7 +546,7 @@ nlmsvc_unlock(struct nlm_file *file, struct nlm_lock *lock)
 	nlmsvc_cancel_blocked(file, lock);
 
 	lock->fl.fl_type = F_UNLCK;
-	error = posix_lock_file(file->f_file, &lock->fl);
+	error = vfs_lock_file(file->f_file, F_SETLK, &lock->fl);
 
 	return (error < 0)? nlm_lck_denied_nolocks : nlm_granted;
 }
@@ -665,14 +692,15 @@ nlmsvc_grant_blocked(struct nlm_block *block)
 
 	/* Try the lock operation again */
 	lock->fl.fl_flags |= FL_SLEEP;
-	error = posix_lock_file(file->f_file, &lock->fl);
+	error = vfs_lock_file(file->f_file, F_SETLK, &lock->fl);
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
index c0df00c..cede998 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -182,7 +182,7 @@ again:
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
-			if (posix_lock_file(file->f_file, &lock) < 0) {
+			if (vfs_lock_file(file->f_file, F_SETLK, &lock) < 0) {
 				printk("lockd: unlock failure in %s:%d\n",
 						__FILE__, __LINE__);
 				return 1;
-- 
1.5.0.rc1.g72fe


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
