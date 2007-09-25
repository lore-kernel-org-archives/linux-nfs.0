From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NLM: Fix a circular lock dependency in lockd
Date: Tue, 25 Sep 2007 15:55:03 -0400
Message-ID: <1190750103.7330.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Linus Torvalds <torvalds@linux-foundation.org>,
	stable@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758778AbXIYTz1@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

The problem is that the garbage collector for the 'host' structures
nlm_gc_hosts(), holds nlm_host_mutex while calling down to
nlmsvc_mark_resources, which, eventually takes the file->f_mutex.

We cannot therefore call nlmsvc_lookup_host() from within
nlmsvc_create_block, since the caller will already hold file->f_mutex, so
the attempt to grab nlm_host_mutex may deadlock.

Fix the problem by calling nlmsvc_lookup_host() outside the file->f_mutex.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/svclock.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index a21e4bc..d098c7a 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -171,19 +171,14 @@ found:
  * GRANTED_RES message by cookie, without having to rely on the client's IP
  * address. --okir
  */
-static inline struct nlm_block *
-nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_file *file,
-		struct nlm_lock *lock, struct nlm_cookie *cookie)
+static struct nlm_block *
+nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
+		    struct nlm_file *file, struct nlm_lock *lock,
+		    struct nlm_cookie *cookie)
 {
 	struct nlm_block	*block;
-	struct nlm_host		*host;
 	struct nlm_rqst		*call = NULL;
 
-	/* Create host handle for callback */
-	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
-	if (host == NULL)
-		return NULL;
-
 	call = nlm_alloc_call(host);
 	if (call == NULL)
 		return NULL;
@@ -366,6 +361,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
 {
 	struct nlm_block	*block = NULL;
+	struct nlm_host		*host;
 	int			error;
 	__be32			ret;
 
@@ -377,6 +373,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 				(long long)lock->fl.fl_end,
 				wait);
 
+	/* Create host handle for callback */
+	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
+	if (host == NULL)
+		return nlm_lck_denied_nolocks;
 
 	/* Lock file against concurrent access */
 	mutex_lock(&file->f_mutex);
@@ -385,7 +385,8 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	 */
 	block = nlmsvc_lookup_block(file, lock);
 	if (block == NULL) {
-		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
+				lock, cookie);
 		ret = nlm_lck_denied_nolocks;
 		if (block == NULL)
 			goto out;
@@ -449,6 +450,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 out:
 	mutex_unlock(&file->f_mutex);
 	nlmsvc_release_block(block);
+	nlm_release_host(host);
 	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
 	return ret;
 }
@@ -477,10 +479,15 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 
 	if (block == NULL) {
 		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
+		struct nlm_host	*host;
 
 		if (conf == NULL)
 			return nlm_granted;
-		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		/* Create host handle for callback */
+		host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
+		if (host == NULL)
+			return nlm_lck_denied_nolocks;
+		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
 		if (block == NULL) {
 			kfree(conf);
 			return nlm_granted;
