Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:7620 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932538AbbCQWlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:24 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 09/10] NFSD: add nfs4interssc.c
Date: Tue, 17 Mar 2015 18:31:37 -0400
Message-ID: <1426631498-14772-10-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/Makefile       |   2 +-
 fs/nfsd/nfs4interssc.c | 110 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 111 insertions(+), 1 deletion(-)
 create mode 100644 fs/nfsd/nfs4interssc.c

diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9a6028e..6355e83 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -16,5 +16,5 @@ nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
-			   nfs4acl.o nfs4callback.o nfs4recover.o
+			   nfs4acl.o nfs4callback.o nfs4recover.o nfs4interssc.o
 nfsd-$(CONFIG_NFSD_PNFS) += nfs4layouts.o blocklayout.o blocklayoutxdr.o
diff --git a/fs/nfsd/nfs4interssc.c b/fs/nfsd/nfs4interssc.c
new file mode 100644
index 0000000..bdc73fc
--- /dev/null
+++ b/fs/nfsd/nfs4interssc.c
@@ -0,0 +1,110 @@
+/*
+ * linux/fs/nfsd/nfs4interssc.c
+ *
+ * Copyright (C) 2014 Andy Adamson <andros@netapp.com>
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+
+
+/* Inter server side copy module list */
+static DEFINE_SPINLOCK(ssc_spinlock);
+static LIST_HEAD(ssc_modules_tbl);
+
+static struct nfs42_inter_ssc_ops *
+find_ssc_module_locked(int version) {
+	struct nfs42_inter_ssc_ops *local;
+
+	list_for_each_entry(local, &ssc_modules_tbl, ssc_mtable)
+		if (local->ssc_version == version)
+			goto out;
+	local = NULL;
+out:
+	printk("%s: Searching for version %u, found %p\n", __func__, version,
+		local);
+	return local;
+};
+
+static struct nfs42_inter_ssc_ops *
+find_ssc_module(u32 version)
+{
+	struct nfs42_inter_ssc_ops *local;
+
+	spin_lock(&ssc_spinlock);
+	local = find_ssc_module_locked(version);
+	if (local != NULL && !try_module_get(local->ssc_owner)) {
+		printk("%s: Could not grab reference on module\n", __func__);
+		local = NULL;
+	}
+	spin_unlock(&ssc_spinlock);
+	return local;
+}
+
+/**
+ * Ref counting for icopp?
+ */
+void
+set_ssc_module(struct nfs42_inter_ssc_ops **icopp, u32 version) {
+	struct nfs42_inter_ssc_ops *icop;
+
+	icop = find_ssc_module(version);
+	if (icop == NULL) {
+		request_module("nfs42-interserver-copy");
+		icop = find_ssc_module(version);
+		if (icop == NULL) {
+			printk("%s: No Module found for %u.\n",
+				__func__, version);
+			*icopp = NULL;
+			return;
+		}
+	}
+	*icopp = icop;
+	return;
+};
+
+void
+unset_ssc_module(struct nfs42_inter_ssc_ops *icop)
+{
+	printk("--> %s\n", __func__);
+	module_put(icop->ssc_owner);
+}
+
+int
+nfsd4_register_intecopy_driver(struct nfs42_inter_ssc_ops *ico, u32 version)
+{
+	struct nfs42_inter_ssc_ops *tmp;
+	int status = -EINVAL;
+
+	if (version != 42) {
+		printk(KERN_ERR "NFS: %s invalid module version %d\n",
+			__func__, version);
+		return status;
+	}
+
+	spin_lock(&ssc_spinlock);
+	tmp = find_ssc_module_locked(version);
+	if (tmp == NULL) {
+		list_add(&ico->ssc_mtable, &ssc_modules_tbl);
+		status = 0;
+		printk("%s Registering version:%u name:%s\n", __func__,
+			ico->ssc_version, ico->ssc_name);
+	} else {
+		printk(KERN_ERR "NFS: %s Module version %d already loaded!\n",
+			__func__, ico->ssc_version);
+	}
+	spin_unlock(&ssc_spinlock);
+	return status;
+}
+EXPORT_SYMBOL_GPL(nfsd4_register_intecopy_driver);
+
+void
+nfsd4_unregister_intecopy_driver(struct nfs42_inter_ssc_ops *ico)
+{
+	printk("%s Deregistering version:%u\n", __func__, ico->ssc_version);
+	spin_lock(&ssc_spinlock);
+	list_del(&ico->ssc_mtable);
+	spin_unlock(&ssc_spinlock);
+}
+EXPORT_SYMBOL_GPL(nfsd4_unregister_intecopy_driver);
-- 
1.8.3.1

