From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 11/14] lockd: handle test_lock deferrals
Date: Sat,  3 Feb 2007 00:34:07 -0500
Message-ID: <16823.1577765711$1170480887@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email->
	<11704808502512-git-send-email-> <11704808513862-git-send-email->
	<1170480851972-git-send-email->
	<11704808513070-git-send-email-> <117048085185-git-send-email->
	<11704808513263-git-send-email-> <11704808513185-git-send-email->
	<11704808511238-git-send-email-> <11704808513085-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDXS-0001HZ-IB
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:17 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDDXS-0001Bx-Ap
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:16 -0800
In-Reply-To: <11704808513085-git-send-email->
Message-Id: <ecc19d4bdf659f8cd1bbe4783625af5040f0b83a.1170479265.git.bfields@citi.umich.edu>
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

Rewrite nlmsvc_testlock() to use the new asynchronous interface: instead of
immediately doing a posix_test_lock(), we first look for a matching block.
If the subsequent test_lock returns anything other than -EINPROGRESS, we
then remove the block we've found and return the results.

If it returns -EINPROGRESS, then we defer the lock request.

In the case where the block we find in the first step has B_QUEUED set,
we bypass the vfs_test_lock entirely, instead using the block to decide how
to respond:
	with nlm_lck_denied if B_TOO_LATE is set.
	with nlm_granted if B_GOT_CALLBACK is set.
	by dropping if neither B_TOO_LATE nor B_GOT_CALLBACK is set

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   61 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 50 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 93f1bc8..91690e3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -447,6 +447,9 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		struct nlm_lock *lock, struct nlm_lock *conflock,
 		struct nlm_cookie *cookie)
 {
+	struct nlm_block *block = NULL;
+	int error;
+
 	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
 				file->f_file->f_path.dentry->d_inode->i_sb->s_id,
 				file->f_file->f_path.dentry->d_inode->i_ino,
@@ -454,19 +457,55 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
-	if (posix_test_lock(file->f_file, &lock->fl, &conflock->fl)) {
-		dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
-				conflock->fl.fl_type,
-				(long long)conflock->fl.fl_start,
-				(long long)conflock->fl.fl_end);
-		conflock->caller = "somehost";	/* FIXME */
-		conflock->len = strlen(conflock->caller);
-		conflock->oh.len = 0;		/* don't return OH info */
-		conflock->svid = conflock->fl.fl_pid;
-		return nlm_lck_denied;
+	/* Get existing block (in case client is busy-waiting) */
+	block = nlmsvc_lookup_block(file, lock);
+
+	if (block == NULL) {
+		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		if (block == NULL)
+			return nlm_granted;
+	}
+	if (block->b_flags & B_QUEUED) {
+		dprintk("lockd: nlmsvc_testlock deferred block %p flags %d fl %p\n",
+			block, block->b_flags, block->b_fl);
+		if (block->b_flags & B_TOO_LATE) {
+			nlmsvc_unlink_block(block);
+			return nlm_lck_denied;
+		}
+		if (block->b_flags & B_GOT_CALLBACK) {
+			if (block->b_fl != NULL) {
+				conflock->fl = *block->b_fl;
+				goto conf_lock;
+			}
+			else {
+				nlmsvc_unlink_block(block);
+				return nlm_granted;
+			}
+		}
+		return nlm_drop_reply;
 	}
 
-	return nlm_granted;
+	error = vfs_test_lock(file->f_file, &lock->fl, &conflock->fl);
+	if (error == -EINPROGRESS)
+		return nlmsvc_defer_lock_rqst(rqstp, block);
+	if (error)
+		return nlm_lck_denied_nolocks;
+	if (conflock->fl.fl_type == F_UNLCK) {
+		nlmsvc_unlink_block(block);
+		return nlm_granted;
+	}
+
+conf_lock:
+	dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
+		conflock->fl.fl_type, (long long)conflock->fl.fl_start,
+		(long long)conflock->fl.fl_end);
+	conflock->caller = "somehost";	/* FIXME */
+	conflock->len = strlen(conflock->caller);
+	conflock->oh.len = 0;		/* don't return OH info */
+	conflock->svid = conflock->fl.fl_pid;
+	if (block)
+		nlmsvc_unlink_block(block);
+	return nlm_lck_denied;
 }
 
 /*
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
