Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:64855 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934528Ab3DICKj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Apr 2013 22:10:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Add functionality to allow waiting on all outstanding reads to complete
Date: Mon,  8 Apr 2013 22:10:33 -0400
Message-Id: <1365473434-63039-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will later allow NFS locking code to wait for readahead to complete
before releasing byte range locks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         |  1 +
 fs/nfs/internal.h      |  7 +++++++
 fs/nfs/pagelist.c      | 51 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |  7 +++++++
 4 files changed, 66 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 55b840f..c1c7a9d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -561,6 +561,7 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 	l_ctx->lockowner.l_owner = current->files;
 	l_ctx->lockowner.l_pid = current->tgid;
 	INIT_LIST_HEAD(&l_ctx->list);
+	nfs_iocounter_init(&l_ctx->io_count);
 }
 
 static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 541c9eb..91e59a3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -229,6 +229,13 @@ extern void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 			      struct nfs_pgio_header *hdr,
 			      void (*release)(struct nfs_pgio_header *hdr));
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos);
+int nfs_iocounter_wait(struct nfs_io_counter *c);
+
+static inline void nfs_iocounter_init(struct nfs_io_counter *c)
+{
+	c->flags = 0;
+	atomic_set(&c->io_count, 0);
+}
 
 /* nfs2xdr.c */
 extern struct rpc_procinfo nfs_procedures[];
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7f09330..29cfb7a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -84,6 +84,55 @@ nfs_page_free(struct nfs_page *p)
 	kmem_cache_free(nfs_page_cachep, p);
 }
 
+static void
+nfs_iocounter_inc(struct nfs_io_counter *c)
+{
+	atomic_inc(&c->io_count);
+}
+
+static void
+nfs_iocounter_dec(struct nfs_io_counter *c)
+{
+	if (atomic_dec_and_test(&c->io_count)) {
+		clear_bit(NFS_IO_INPROGRESS, &c->flags);
+		smp_mb__after_clear_bit();
+		wake_up_bit(&c->flags, NFS_IO_INPROGRESS);
+	}
+}
+
+static int
+__nfs_iocounter_wait(struct nfs_io_counter *c)
+{
+	wait_queue_head_t *wq = bit_waitqueue(&c->flags, NFS_IO_INPROGRESS);
+	DEFINE_WAIT_BIT(q, &c->flags, NFS_IO_INPROGRESS);
+	int ret = 0;
+
+	do {
+		prepare_to_wait(wq, &q.wait, TASK_KILLABLE);
+		set_bit(NFS_IO_INPROGRESS, &c->flags);
+		if (atomic_read(&c->io_count) == 0)
+			break;
+		ret = nfs_wait_bit_killable(&c->flags);
+	} while (atomic_read(&c->io_count) != 0);
+	finish_wait(wq, &q.wait);
+	return ret;
+}
+
+/**
+ * nfs_iocounter_wait - wait for i/o to complete
+ * @c: nfs_io_counter to use
+ *
+ * returns -ERESTARTSYS if interrupted by a fatal signal.
+ * Otherwise returns 0 once the io_count hits 0.
+ */
+int
+nfs_iocounter_wait(struct nfs_io_counter *c)
+{
+	if (atomic_read(&c->io_count) == 0)
+		return 0;
+	return __nfs_iocounter_wait(c);
+}
+
 /**
  * nfs_create_request - Create an NFS read/write request.
  * @ctx: open context to use
@@ -118,6 +167,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		return ERR_CAST(l_ctx);
 	}
 	req->wb_lock_context = l_ctx;
+	nfs_iocounter_inc(&l_ctx->io_count);
 
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in
@@ -177,6 +227,7 @@ static void nfs_clear_request(struct nfs_page *req)
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
+		nfs_iocounter_dec(&l_ctx->io_count);
 		nfs_put_lock_context(l_ctx);
 		req->wb_lock_context = NULL;
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f6b1956..fc01d5c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -59,11 +59,18 @@ struct nfs_lockowner {
 	pid_t l_pid;
 };
 
+#define NFS_IO_INPROGRESS 0
+struct nfs_io_counter {
+	unsigned long flags;
+	atomic_t io_count;
+};
+
 struct nfs_lock_context {
 	atomic_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
 	struct nfs_lockowner lockowner;
+	struct nfs_io_counter io_count;
 };
 
 struct nfs4_state;
-- 
1.8.1.4

