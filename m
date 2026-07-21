Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98D9E3E49D2
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 16:23:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784650993; cv=none; b=n5seLXJertMigGpi0z0wJTSCABQgq2ohLBzuo0jNj3beP+z27NlGcdzK+29RmfwtR6ZUpZ5Vp0mVEix81rH+fVnjZ7C1lPJ15Bu9RtwCTEg1eJjDm76zTqgJPxXLsKqKOtvueN2Wg/Ve7dCiPO5mKLy8+Re0TgZrFrjb5e5FaTw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784650993; c=relaxed/simple;
	bh=T665Fr4527LNPFTYGKwzuvZ5g+N9GPdcNtDJKedh2I0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MeHtFX91v2BY/otJ84QWBEsMJGYDralH4giD1yqqj/s59fxL8Q4MmfQjdadeV0IesRZDVHvv89HyVIdCTJDauKmvKxxxZ/Re4d9x8VjglOHPUTM+X5FFSXIE9Bc4xA87j7UdAtd6zYZIlJghDgXLXXuJKinjTO1Gl9tSf7YPBXU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GQvWpQNb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GQvWpQNb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D35C21F000E9;
	Tue, 21 Jul 2026 16:23:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784650992;
	bh=ipck4gtZlE/Q1ZwOehYs/XTxhWc/FV+m8FQ/vOyXYJA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GQvWpQNbaiL0djALC5FZ88hs7Jrd1ZBzfnQIZEkX0gdTQEnX1vYsRurjfeJp8swZW
	 ZeLlYgtiOzN3Sbo2dvn5Rqfjr/bUOZCQMDlcgLNWZbuCnTvt4Rd1p6LU1qfBffaERw
	 BmLzkegyf50JhU2jQDDs+w0KVqnQGS6t/WwL5WVsSH4MkhB+RV1RQn+1kdyOrlOuJd
	 OGeuZd4Zo1Qyg+2k6U5T/OV+WltKq38A16ydRSnGiKpO2tFzS9nRXBWKA8uE4ZfF1j
	 4P8kg6F0fMlbmY7BDJSxcMhAlRzZxwpe6bmowz0/qXTfRkchpBwQUtOGA8ChIIadNs
	 Jy7C3R3w4Nxjw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] NFSD: Split linux/nfs_ssc.h
Date: Tue, 21 Jul 2026 12:23:06 -0400
Message-ID: <20260721162306.894558-5-cel@kernel.org>
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

The nfs_ssc.h header contains both client- and server-side data
structures, which means each of those implementations has to pull in
headers from the other.

Create a linux/nfsd_ssc.h for the server side APIs which no longer
includes uapi/linux/nfs.h either directly or indirectly. Because
nfsd_ssc.h drops the transitive include of the NFS client headers,
fs/nfsd/nfs4proc.c now includes <linux/pagemap.h> directly for
filemap_check_wb_err().

struct nfsd4_ssc_umount_item is private to nfsd. Move it into
fs/nfsd/xdr4.h alongside its only consumers rather than into the
exported nfsd_ssc.h.

As an added clean-up, add missing header guard macros and the
struct file and struct vfsmount forward declarations the server
prototypes need.

Cc: Olga Kornievskaia <okorniev@redhat.com>
Cc: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/nfs_ssc.c  |  2 +-
 fs/nfsd/nfs4proc.c       |  3 ++-
 fs/nfsd/nfs4state.c      |  2 +-
 fs/nfsd/xdr4.h           | 13 ++++++++++++
 include/linux/nfs_ssc.h  | 45 ++++++++++------------------------------
 include/linux/nfsd_ssc.h | 38 +++++++++++++++++++++++++++++++++
 6 files changed, 66 insertions(+), 37 deletions(-)
 create mode 100644 include/linux/nfsd_ssc.h

diff --git a/fs/nfs_common/nfs_ssc.c b/fs/nfs_common/nfs_ssc.c
index ef158008b803..e521e3c836fe 100644
--- a/fs/nfs_common/nfs_ssc.c
+++ b/fs/nfs_common/nfs_ssc.c
@@ -10,7 +10,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/nfs_ssc.h>
-#include "../nfs/nfs4_fs.h"
+#include <linux/nfsd_ssc.h>
 
 struct nfs_ssc_client_ops_tbl {
 	const struct nfs4_ssc_client_ops __rcu *ssc_nfs4_ops;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dbea2da7b1ea..a39880208761 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -38,9 +38,10 @@
 #include <linux/slab.h>
 #include <linux/kthread.h>
 #include <linux/namei.h>
+#include <linux/pagemap.h>
 
 #include <linux/sunrpc/addr.h>
-#include <linux/nfs_ssc.h>
+#include <linux/nfsd_ssc.h>
 
 #include "attr4.h"
 #include "idmap.h"
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e78d4fe5fbfb..d7731bb4959c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -45,7 +45,7 @@
 #include <linux/string_helpers.h>
 #include <linux/fsnotify.h>
 #include <linux/rhashtable.h>
-#include <linux/nfs_ssc.h>
+#include <linux/nfsd_ssc.h>
 
 #include "xdr4.h"
 #include "nfs4ctl.h"
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index e833407859c8..7bbb375874ef 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -597,6 +597,19 @@ struct nfsd4_cb_offload {
 	u32			co_referring_seqno;
 };
 
+struct nfsd4_ssc_umount_item {
+	struct list_head	nsui_list;
+	bool			nsui_busy;
+	/*
+	 * nsui_refcnt inited to 2, 1 on list and 1 for consumer. Entry
+	 * is removed when refcnt drops to 1 and nsui_expire expires.
+	 */
+	refcount_t		nsui_refcnt;
+	unsigned long		nsui_expire;
+	struct vfsmount		*nsui_vfsmount;
+	char			nsui_ipaddr[RPC_MAX_ADDRBUFLEN + 1];
+};
+
 struct nfsd4_copy {
 	/* request */
 	stateid_t		cp_src_stateid;
diff --git a/include/linux/nfs_ssc.h b/include/linux/nfs_ssc.h
index b392d56a4dc2..c199ea23e7eb 100644
--- a/include/linux/nfs_ssc.h
+++ b/include/linux/nfs_ssc.h
@@ -2,17 +2,22 @@
 /*
  * include/linux/nfs_ssc.h
  *
+ * NFSv4.2 server-to-server copy, NFS client side APIs
+ *
  * Author: Dai Ngo <dai.ngo@oracle.com>
  *
  * Copyright (c) 2020, Oracle and/or its affiliates.
  */
 
-#include <linux/nfs_fs.h>
-#include <linux/sunrpc/svc.h>
+#ifndef _LINUX_NFS_SSC_H
+#define _LINUX_NFS_SSC_H
+
+#include <linux/nfs_fh.h>
+#include <linux/nfs4.h>
+
+struct file;
+struct vfsmount;
 
-/*
- * NFS_V4
- */
 struct nfs4_ssc_client_ops {
 	struct module *owner;
 	struct file *(*sco_open)(struct vfsmount *ss_mnt,
@@ -26,32 +31,4 @@ extern void nfs42_ssc_unregister_ops(void);
 extern void nfs42_ssc_register(const struct nfs4_ssc_client_ops *ops);
 extern void nfs42_ssc_unregister(const struct nfs4_ssc_client_ops *ops);
 
-#if IS_ENABLED(CONFIG_NFS_V4_2_SSC_HELPER)
-struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
-			     nfs4_stateid *stateid);
-void nfsd42_ssc_close(struct file *filp);
-#else
-static inline struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt,
-					   struct nfs_fh *src_fh,
-					   nfs4_stateid *stateid)
-{
-	return ERR_PTR(-EIO);
-}
-
-static inline void nfsd42_ssc_close(struct file *filp)
-{
-}
-#endif
-
-struct nfsd4_ssc_umount_item {
-	struct list_head nsui_list;
-	bool nsui_busy;
-	/*
-	 * nsui_refcnt inited to 2, 1 on list and 1 for consumer. Entry
-	 * is removed when refcnt drops to 1 and nsui_expire expires.
-	 */
-	refcount_t nsui_refcnt;
-	unsigned long nsui_expire;
-	struct vfsmount *nsui_vfsmount;
-	char nsui_ipaddr[RPC_MAX_ADDRBUFLEN + 1];
-};
+#endif /* _LINUX_NFS_SSC_H */
diff --git a/include/linux/nfsd_ssc.h b/include/linux/nfsd_ssc.h
new file mode 100644
index 000000000000..7001410f01c2
--- /dev/null
+++ b/include/linux/nfsd_ssc.h
@@ -0,0 +1,38 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * include/linux/nfsd_ssc.h
+ *
+ * NFSv4.2 server-to-server copy, NFS server side APIs
+ *
+ * Author: Dai Ngo <dai.ngo@oracle.com>
+ *
+ * Copyright (c) 2020, Oracle and/or its affiliates.
+ */
+
+#ifndef _LINUX_NFSD_SSC_H
+#define _LINUX_NFSD_SSC_H
+
+#include <linux/nfs_fh.h>
+#include <linux/nfs4.h>
+
+struct file;
+struct vfsmount;
+
+#if IS_ENABLED(CONFIG_NFS_V4_2_SSC_HELPER)
+struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
+			     nfs4_stateid *stateid);
+void nfsd42_ssc_close(struct file *filp);
+#else
+static inline struct file *nfsd42_ssc_open(struct vfsmount *ss_mnt,
+					   struct nfs_fh *src_fh,
+					   nfs4_stateid *stateid)
+{
+	return ERR_PTR(-EIO);
+}
+
+static inline void nfsd42_ssc_close(struct file *filp)
+{
+}
+#endif
+
+#endif /* _LINUX_NFSD_SSC_H */
-- 
2.54.0

