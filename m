From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 8/14] lockd: save lock state on deferral
Date: Sat,  3 Feb 2007 00:34:04 -0500
Message-ID: <9331.67444677583$1170483221@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email-> <11704808513862-git-send-email-> <1170480851972-git-send-email-> <11704808513070-git-send-email-> <117048085185-git-send-email-> <11704808513263-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11704808513263-git-send-email->
Message-Id: <8096fc4eb11f5c5678197fdee8afe0e2780357fc.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

We need to keep some state for a pending asynchronous lock request, so this
patch adds that state to struct nlm_block.

This also adds a function which defers the request, by calling
rqstp->rq_chandle.defer and storing the resulting deferred request in a
nlm_block structure which we insert into lockd's global block list.  That
new function isn't called yet, so it's dead code until a later patch.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c          |   25 +++++++++++++++++++++++++
 include/linux/lockd/lockd.h |   10 ++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index d2c8020..00e657a 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -331,6 +331,31 @@ static void nlmsvc_freegrantargs(struct nlm_rqst *call)
 }
 
 /*
+ * Deferred lock request handling for non-blocking lock
+ */
+static u32
+nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
+{
+	u32 status = nlm_lck_denied_nolocks;
+
+	block->b_flags |= B_QUEUED;
+
+	nlmsvc_insert_block(block, NLM_TIMEOUT);
+
+	block->b_cache_req = &rqstp->rq_chandle;
+	if (rqstp->rq_chandle.defer) {
+		block->b_deferred_req =
+			rqstp->rq_chandle.defer(block->b_cache_req);
+		if (block->b_deferred_req != NULL)
+			status = nlm_drop_reply;
+	}
+	dprintk("lockd: nlmsvc_defer_lock_rqst block %p flags %d status %d\n",
+		block, block->b_flags, status);
+
+	return status;
+}
+
+/*
  * Attempt to establish a lock, and if it can't be granted, block it
  * if required.
  */
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ac25b56..1df10d7 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -119,6 +119,9 @@ struct nlm_file {
  * couldn't be granted because of a conflicting lock).
  */
 #define NLM_NEVER		(~(unsigned long) 0)
+/* timeout on non-blocking call: */
+#define NLM_TIMEOUT		(7 * HZ)
+
 struct nlm_block {
 	struct kref		b_count;	/* Reference count */
 	struct list_head	b_list;		/* linked list of all blocks */
@@ -130,6 +133,13 @@ struct nlm_block {
 	unsigned int		b_id;		/* block id */
 	unsigned char		b_granted;	/* VFS granted lock */
 	struct nlm_file *	b_file;		/* file in question */
+	struct cache_req *	b_cache_req;	/* deferred request handling */
+	struct file_lock *	b_fl;		/* set for GETLK */
+	struct cache_deferred_req * b_deferred_req;
+	unsigned int		b_flags;	/* block flags */
+#define B_QUEUED		1	/* lock queued */
+#define B_GOT_CALLBACK		2	/* got lock or conflicting lock */
+#define B_TOO_LATE		4	/* too late for non-blocking lock */
 };
 
 /*
-- 
1.5.0.rc1.g72fe

