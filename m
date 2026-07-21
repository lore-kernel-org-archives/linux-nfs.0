Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1182419CD1D
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 16:23:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784650992; cv=none; b=hwHJOwnuNW6p45TDAJ966amINjw7U0IMe90kQviUjwvCMzUlya43VhUrt0wKBh3v1kgwT93tRwNb+JNVAXmDzt/30PRSXgJmT8pmlodgNMAcoTNwJTeO2WFkMp0K3yXpaZ/yfumZwEhkRiJ+7xN7/482Mz4qb6IhUvUnpPEe35A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784650992; c=relaxed/simple;
	bh=UL3h9xVX3vvSP5Q5zTTM4q5y1UR8pjghtjuAWf11EXc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=T626UB2NjZ0UjAXp6ptsnE8ldHA0XqJUz/ggsnKb+P2sKdrdsNDE8s9ebSXQj5KkZ7arLYIUgj21d7fcIMaPOWuHt1TyzdFrKZ0OVbgs/pYhUsON4WcMH2X/fa6bOLZNlC/5WYBUCgzKmR7kXgd8LqJynSOBtioc9cdMgRiomfg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=U7wZUxRe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="U7wZUxRe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 606231F00A3D;
	Tue, 21 Jul 2026 16:23:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784650990;
	bh=SC+RaZuksBHWXVGvBHK6ChXeNsRdTi+1CwO6eSAuGOU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=U7wZUxRej5YE0wlqGS90qynVu7iT94T9YGJ5NLfHJEskoPu9DnXbrsT04tTrskSxd
	 o+DYKLmJsLuLRyhHXdx1ETLPxTR0RlxpulQW+2K4k1nn9fsELSELCoVLjcsFG3S22k
	 Z+fUkmy5S6rJwEZYJM7juIO1NRCAel4RF8unwMn2mk8i9sI9Jbau+ZDj2F0eoppsxb
	 TrYgIaO5chEhxbyQRr66ugjEvVkKs+be3LN1sEpir/odOQYZR1/78heE7rs94OENEV
	 cXH75PXxFnqpdfTbNMtF9HSrzdsC//CGAtwF8TFVQ3VM2KmuMReqygJwVDEgE3fPXi
	 NPVLmot6aJjAA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/4] NFSD: Hoist nfs42_ssc_open() into fs/nfs_common/nfs_ssc.c
Date: Tue, 21 Jul 2026 12:23:04 -0400
Message-ID: <20260721162306.894558-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260721162306.894558-1-cel@kernel.org>
References: <20260721162306.894558-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Refactor: The infrastructure and details for calling the client's
ssc_open method can be hidden in nfs_ssc.c. This reduces the SSC
footprint in fs/nfsd/nfs4proc.c, a step toward removing that
file's dependency on <linux/nfs_fs.h>, which indirectly includes
<uapi/linux/nfs.h>.

The open and close functions are named "nfsd42_" since they are
meant to be invoked only by NFSD.

Cc: Olga Kornievskaia <okorniev@redhat.com>
Cc: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/nfs_ssc.c | 56 +++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4proc.c      | 17 +++----------
 include/linux/nfs_ssc.h | 23 +++++++----------
 3 files changed, 66 insertions(+), 30 deletions(-)

diff --git a/fs/nfs_common/nfs_ssc.c b/fs/nfs_common/nfs_ssc.c
index 8d8b7344ab4f..a8e79ec68701 100644
--- a/fs/nfs_common/nfs_ssc.c
+++ b/fs/nfs_common/nfs_ssc.c
@@ -12,9 +12,61 @@
 #include <linux/nfs_ssc.h>
 #include "../nfs/nfs4_fs.h"
 
+struct nfs_ssc_client_ops_tbl {
+	const struct nfs4_ssc_client_ops *ssc_nfs4_ops;
+};
 
-struct nfs_ssc_client_ops_tbl nfs_ssc_client_tbl;
-EXPORT_SYMBOL_GPL(nfs_ssc_client_tbl);
+static struct nfs_ssc_client_ops_tbl nfs_ssc_client_tbl __read_mostly;
+
+/**
+ * nfsd42_ssc_open - Open a file to be used for server-to-server copy
+ * @ss_mnt: active mount point on which the source file resides
+ * @src_fh: file handle of the source file to be copied
+ * @stateid: stateid to use for COPY operation
+ *
+ * Caller must close the returned file using nfsd42_ssc_close().
+ *
+ * Return: an open file, or an ERR_PTR on error
+ */
+struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
+			     nfs4_stateid *stateid)
+{
+	/*
+	 * Built under CONFIG_NFS_V4_2_SSC_HELPER, which the NFS client
+	 * enables on its own. The dispatch below is live only when the
+	 * server also sets CONFIG_NFSD_V4_2_INTER_SSC; without it the
+	 * source file cannot be opened, so callers get -EIO.
+	 */
+#if IS_ENABLED(CONFIG_NFSD_V4_2_INTER_SSC)
+	const struct nfs4_ssc_client_ops *ops = nfs_ssc_client_tbl.ssc_nfs4_ops;
+
+	if (ops)
+		return ops->sco_open(ss_mnt, src_fh, stateid);
+#endif
+
+	return ERR_PTR(-EIO);
+}
+EXPORT_SYMBOL_GPL(nfsd42_ssc_open);
+
+/**
+ * nfsd42_ssc_close - Close a file opened with nfsd42_ssc_open()
+ * @filp: struct file to be closed
+ *
+ * The real cleanup happens unconditionally in nfsd4_cleanup_inter_ssc().
+ * The vfsmount is pinned until this function is called, preventing
+ * the client from unregistering its SSC ops.
+ */
+void nfsd42_ssc_close(struct file *filp)
+{
+	/* Live only under CONFIG_NFSD_V4_2_INTER_SSC; see nfsd42_ssc_open(). */
+#if IS_ENABLED(CONFIG_NFSD_V4_2_INTER_SSC)
+	const struct nfs4_ssc_client_ops *ops = nfs_ssc_client_tbl.ssc_nfs4_ops;
+
+	if (ops)
+		ops->sco_close(filp);
+#endif
+}
+EXPORT_SYMBOL_GPL(nfsd42_ssc_close);
 
 #ifdef CONFIG_NFS_V4_2
 /**
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 83715ba38b6a..dbea2da7b1ea 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1692,11 +1692,6 @@ void nfsd4_cancel_copy_by_sb(struct net *net, struct super_block *sb)
 
 #ifdef CONFIG_NFSD_V4_2_INTER_SSC
 
-extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
-				   struct nfs_fh *src_fh,
-				   nfs4_stateid *stateid);
-extern void nfs42_ssc_close(struct file *filep);
-
 #define NFSD42_INTERSSC_MOUNTOPS "vers=4.2,addr=%s,sec=sys"
 
 /*
@@ -1919,7 +1914,7 @@ nfsd4_cleanup_inter_ssc(struct nfsd4_ssc_umount_item *nsui, struct file *filp,
 	struct nfsd_net *nn = net_generic(dst->nf_net, nfsd_net_id);
 	long timeout = msecs_to_jiffies(nfsd4_ssc_umount_timeout);
 
-	nfs42_ssc_close(filp);
+	nfsd42_ssc_close(filp);
 	fput(filp);
 
 	spin_lock(&nn->nfsd_ssc_lock);
@@ -1951,12 +1946,6 @@ nfsd4_cleanup_inter_ssc(struct nfsd4_ssc_umount_item *nsui, struct file *filp,
 {
 }
 
-static struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
-				   struct nfs_fh *src_fh,
-				   nfs4_stateid *stateid)
-{
-	return NULL;
-}
 #endif /* CONFIG_NFSD_V4_2_INTER_SSC */
 
 static __be32
@@ -2179,8 +2168,8 @@ static int nfsd4_do_async_copy(void *data)
 	if (nfsd4_ssc_is_inter(copy)) {
 		struct file *filp;
 
-		filp = nfs42_ssc_open(copy->ss_nsui->nsui_vfsmount,
-				      &copy->c_fh, &copy->stateid);
+		filp = nfsd42_ssc_open(copy->ss_nsui->nsui_vfsmount,
+				       &copy->c_fh, &copy->stateid);
 		if (IS_ERR(filp)) {
 			switch (PTR_ERR(filp)) {
 			case -EBADF:
diff --git a/include/linux/nfs_ssc.h b/include/linux/nfs_ssc.h
index ba236dba8975..fc0d5d48dec2 100644
--- a/include/linux/nfs_ssc.h
+++ b/include/linux/nfs_ssc.h
@@ -10,8 +10,6 @@
 #include <linux/nfs_fs.h>
 #include <linux/sunrpc/svc.h>
 
-extern struct nfs_ssc_client_ops_tbl nfs_ssc_client_tbl;
-
 /*
  * NFS_V4
  */
@@ -21,29 +19,26 @@ struct nfs4_ssc_client_ops {
 	void (*sco_close)(struct file *filep);
 };
 
-struct nfs_ssc_client_ops_tbl {
-	const struct nfs4_ssc_client_ops *ssc_nfs4_ops;
-};
-
 extern void nfs42_ssc_register_ops(void);
 extern void nfs42_ssc_unregister_ops(void);
 
 extern void nfs42_ssc_register(const struct nfs4_ssc_client_ops *ops);
 extern void nfs42_ssc_unregister(const struct nfs4_ssc_client_ops *ops);
 
-#ifdef CONFIG_NFSD_V4_2_INTER_SSC
-static inline struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
-		struct nfs_fh *src_fh, nfs4_stateid *stateid)
+#if IS_ENABLED(CONFIG_NFS_V4_2_SSC_HELPER)
+struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
+			     nfs4_stateid *stateid);
+void nfsd42_ssc_close(struct file *filp);
+#else
+static inline struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt,
+					   struct nfs_fh *src_fh,
+					   nfs4_stateid *stateid)
 {
-	if (nfs_ssc_client_tbl.ssc_nfs4_ops)
-		return (*nfs_ssc_client_tbl.ssc_nfs4_ops->sco_open)(ss_mnt, src_fh, stateid);
 	return ERR_PTR(-EIO);
 }
 
-static inline void nfs42_ssc_close(struct file *filep)
+static inline void nfsd42_ssc_close(struct file *filp)
 {
-	if (nfs_ssc_client_tbl.ssc_nfs4_ops)
-		(*nfs_ssc_client_tbl.ssc_nfs4_ops->sco_close)(filep);
 }
 #endif
 
-- 
2.54.0

