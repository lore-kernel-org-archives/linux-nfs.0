Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab0HMVcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:16 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 14/50] pnfs_submit: filelayout data server cache
Date: Fri, 13 Aug 2010 17:31:26 -0400
Message-Id: <1281735122-1496-15-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-14-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |    1 +
 fs/nfs/nfs4filelayout.h    |   29 ++++++++++++-
 fs/nfs/nfs4filelayoutdev.c |   98 +++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 126 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6560866..2e440b6 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -253,6 +253,7 @@ void nfs_put_client(struct nfs_client *clp)
 		nfs_free_client(clp);
 	}
 }
+EXPORT_SYMBOL(nfs_put_client);
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /*
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 4af4c54..f272d0f 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -12,8 +12,35 @@
 #ifndef FS_NFS_NFS4FILELAYOUT_H
 #define FS_NFS_NFS4FILELAYOUT_H
 
-extern void nfs4_fl_free_deviceid_callback(struct kref *);
+#include <linux/kref.h>
+#include <linux/nfs4_pnfs.h>
+#include <linux/pnfs_xdr.h>
+
+#define NFS4_PNFS_DEV_HASH_BITS 5
+#define NFS4_PNFS_DEV_HASH_SIZE (1 << NFS4_PNFS_DEV_HASH_BITS)
+#define NFS4_PNFS_DEV_HASH_MASK (NFS4_PNFS_DEV_HASH_SIZE - 1)
+
+/* Individual ip address */
+struct nfs4_pnfs_ds {
+	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
+	u32 			ds_ip_addr;
+	u32 			ds_port;
+	struct nfs_client	*ds_clp;
+	atomic_t		ds_count;
+	char r_addr[29];
+};
+
+struct nfs4_file_layout_dsaddr {
+	struct nfs4_deviceid	deviceid;
+	u32 			stripe_count;
+	u8			*stripe_indices;
+	u32			ds_num;
+	struct nfs4_pnfs_ds	*ds_list[1];
+};
+
 
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
+extern void nfs4_fl_free_deviceid_callback(struct kref *);
+extern void print_ds(struct nfs4_pnfs_ds *ds);
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 0aee56b..c8b8ca7 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -51,10 +51,106 @@
 #include "internal.h"
 #include "nfs4_fs.h"
 
-#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+#define NFSDBG_FACILITY		NFSDBG_PNFS_LD
+
+DEFINE_SPINLOCK(nfs4_ds_cache_lock);
+static LIST_HEAD(nfs4_data_server_cache);
+
+void
+print_ds(struct nfs4_pnfs_ds *ds)
+{
+	if (ds == NULL) {
+		dprintk("%s NULL device \n", __func__);
+		return;
+	}
+	dprintk("        ip_addr %x\n", ntohl(ds->ds_ip_addr));
+	dprintk("        port %hu\n", ntohs(ds->ds_port));
+	dprintk("        client %p\n", ds->ds_clp);
+	dprintk("        ref count %d\n", atomic_read(&ds->ds_count));
+	if (ds->ds_clp)
+		dprintk("        cl_exchange_flags %x\n",
+					    ds->ds_clp->cl_exchange_flags);
+	dprintk("        ip:port %s\n", ds->r_addr);
+}
+
+void
+print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
+{
+	int i;
+
+	dprintk("%s dsaddr->ds_num %d\n", __func__,
+		dsaddr->ds_num);
+	for (i = 0; i < dsaddr->ds_num; i++)
+		print_ds(dsaddr->ds_list[i]);
+}
+
+/* nfs4_ds_cache_lock is held */
+static inline struct nfs4_pnfs_ds *
+_data_server_lookup(u32 ip_addr, u32 port)
+{
+	struct nfs4_pnfs_ds *ds;
+
+	dprintk("_data_server_lookup: ip_addr=%x port=%hu\n",
+			ntohl(ip_addr), ntohs(port));
+
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
+		if (ds->ds_ip_addr == ip_addr &&
+		    ds->ds_port == port) {
+			return ds;
+		}
+	}
+	return NULL;
+}
+
+static void
+destroy_ds(struct nfs4_pnfs_ds *ds)
+{
+	dprintk("--> %s\n", __func__);
+	print_ds(ds);
+
+	if (ds->ds_clp)
+		nfs_put_client(ds->ds_clp);
+	kfree(ds);
+}
 
 void
 nfs4_fl_free_deviceid_callback(struct kref *kref)
 {
 }
 
+static void
+nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
+		 u32 ip_addr, u32 port, char *r_addr, int len)
+{
+	struct nfs4_pnfs_ds *tmp_ds, *ds;
+
+	*dsp = NULL;
+
+	ds = kzalloc(sizeof(*tmp_ds), GFP_KERNEL);
+	if (!ds)
+		return;
+
+	spin_lock(&nfs4_ds_cache_lock);
+	tmp_ds = _data_server_lookup(ip_addr, port);
+	if (tmp_ds == NULL) {
+		ds->ds_ip_addr = ip_addr;
+		ds->ds_port = port;
+		strncpy(ds->r_addr, r_addr, len);
+		atomic_set(&ds->ds_count, 1);
+		INIT_LIST_HEAD(&ds->ds_node);
+		ds->ds_clp = NULL;
+		list_add(&ds->ds_node, &nfs4_data_server_cache);
+		*dsp = ds;
+		dprintk("%s add new data server ip 0x%x\n", __func__,
+				ds->ds_ip_addr);
+		spin_unlock(&nfs4_ds_cache_lock);
+	} else {
+		atomic_inc(&tmp_ds->ds_count);
+		*dsp = tmp_ds;
+		dprintk("%s data server found ip 0x%x, inc'ed ds_count to %d\n",
+				__func__, tmp_ds->ds_ip_addr,
+				atomic_read(&tmp_ds->ds_count));
+		spin_unlock(&nfs4_ds_cache_lock);
+		kfree(ds);
+	}
+}
-- 
1.6.2.5

