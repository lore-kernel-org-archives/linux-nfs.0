From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 3/10] lockd: request deferral routine
Date: Wed,  6 Dec 2006 00:34:13 -0500
Message-ID: <11653832601058-git-send-email-bfields@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org> <1165383260627-git-send-email-bfields@fieldses.org> <11653832603105-git-send-email-bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832603105-git-send-email-bfields@fieldses.org>
Message-Id: <610c7d52f6363606200fa1016804e7116d580c36.1165380893.git.bfields@citi.umich.edu>
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com>

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
index f523ca2..2ce4dc6 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -437,6 +437,31 @@ static void nlmsvc_freegrantargs(struct nlm_rqst *call)
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
index 862d973..ac865f8 100644
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
1.4.4.1

