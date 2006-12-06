From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 7/10] lockd: handle test_lock deferrals
Date: Wed,  6 Dec 2006 00:34:17 -0500
Message-ID: <c214e0a0062abdbb72f0810c25ab7688e51b4dbd.1165380893.git.bfields__42157.5957713232$1165383329$gmane$org@citi.umich.edu>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
	<11653832603105-git-send-email-bfields@fieldses.org>
	<11653832601058-git-send-email-bfields@fieldses.org>
	<11653832601635-git-send-email-bfields@fieldses.org>
	<1165383260424-git-send-email-bfields@fieldses.org>
	<11653832601925-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrpQH-0006Xa-Ng
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:25 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GrpQI-0008BB-Gi
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:27 -0800
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832601925-git-send-email-bfields@fieldses.org>
Message-Id: <c214e0a0062abdbb72f0810c25ab7688e51b4dbd.1165380893.git.bfields@citi.umich.edu>
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
 fs/lockd/svclock.c |   59 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 48 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e342046..21185a7 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -553,6 +553,9 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		struct nlm_lock *lock, struct nlm_lock *conflock,
 		struct nlm_cookie *cookie)
 {
+	struct nlm_block *block = NULL;
+	int error;
+
 	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
 				file->f_file->f_dentry->d_inode->i_sb->s_id,
 				file->f_file->f_dentry->d_inode->i_ino,
@@ -560,19 +563,53 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
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
 	}
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
+ 	}
 
-	return nlm_granted;
+	error = vfs_test_lock(file->f_file, &lock->fl, &conflock->fl);
+	if (!error) {
+		nlmsvc_unlink_block(block);
+		return nlm_granted;
+        }
+	if (error == -EINPROGRESS)
+		return nlmsvc_defer_lock_rqst(rqstp, block);
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
1.4.4.1


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
