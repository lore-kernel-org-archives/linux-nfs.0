From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 8/10] lockd: always preallocate block in nlmsvc_lock()
Date: Wed,  6 Dec 2006 00:34:18 -0500
Message-ID: <aee338c430e7f0a9afe63ea80d0278b97b01eeee.1165380893.git.bfields__15171.4240004823$1165383339$gmane$org@citi.umich.edu>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
	<11653832603105-git-send-email-bfields@fieldses.org>
	<11653832601058-git-send-email-bfields@fieldses.org>
	<11653832601635-git-send-email-bfields@fieldses.org>
	<1165383260424-git-send-email-bfields@fieldses.org>
	<11653832601925-git-send-email-bfields@fieldses.org>
	<1165383260548-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrpQI-0006Y0-By
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:26 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GrpQJ-0008BD-EX
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:27 -0800
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <1165383260548-git-send-email-bfields@fieldses.org>
Message-Id: <aee338c430e7f0a9afe63ea80d0278b97b01eeee.1165380893.git.bfields@citi.umich.edu>
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

Normally we could skip ever having to allocate a block in the case where
the client asks for a non-blocking lock, or asks for a blocking lock that
succeeds immediately.

However we're going to want to always look up a block first in order to
check whether we're revisiting a deferred lock call, and to be prepared to
handle the case where the filesystem returns -EINPROGRESS--in that case we
want to make sure the lock we've given the filesystem is the one embedded
in the block that we'll use to track the deferred request.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   34 +++++++++++-----------------------
 1 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 21185a7..134a40e 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -471,7 +471,7 @@ __be32
 nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
 {
-	struct nlm_block	*block, *newblock = NULL;
+	struct nlm_block	*block = NULL;
 	int			error;
 	__be32			ret;
 
@@ -484,17 +484,20 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 				wait);
 
 
-	lock->fl.fl_flags &= ~FL_SLEEP;
-again:
 	/* Lock file against concurrent access */
 	mutex_lock(&file->f_mutex);
-	/* Get existing block (in case client is busy-waiting) */
+	/* Get existing block (in case client is busy-waiting)
+	 * or create new block
+	 */
 	block = nlmsvc_lookup_block(file, lock);
 	if (block == NULL) {
-		if (newblock != NULL)
-			lock = &newblock->b_call->a_args.lock;
-	} else
+		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		ret = nlm_lck_denied_nolocks;
+		if (block == NULL)
+			goto out;
 		lock = &block->b_call->a_args.lock;
+	} else
+		lock->fl.fl_flags &= ~FL_SLEEP;
 
 	error = posix_lock_file(file->f_file, &lock->fl);
 	lock->fl.fl_flags &= ~FL_SLEEP;
@@ -520,26 +523,11 @@ again:
 		goto out;
 
 	ret = nlm_lck_blocked;
-	if (block != NULL)
-		goto out;
-
-	/* If we don't have a block, create and initialize it. Then
-	 * retry because we may have slept in kmalloc. */
-	/* We have to release f_mutex as nlmsvc_create_block may try to
-	 * to claim it while doing host garbage collection */
-	if (newblock == NULL) {
-		mutex_unlock(&file->f_mutex);
-		dprintk("lockd: blocking on this lock (allocating).\n");
-		if (!(newblock = nlmsvc_create_block(rqstp, file, lock, cookie)))
-			return nlm_lck_denied_nolocks;
-		goto again;
-	}
 
 	/* Append to list of blocked */
-	nlmsvc_insert_block(newblock, NLM_NEVER);
+	nlmsvc_insert_block(block, NLM_NEVER);
 out:
 	mutex_unlock(&file->f_mutex);
-	nlmsvc_release_block(newblock);
 	nlmsvc_release_block(block);
 	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
 	return ret;
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
