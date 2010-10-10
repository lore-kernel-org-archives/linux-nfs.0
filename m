Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30725 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756163Ab0JOGRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:41 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/12] RFC: pnfs: full mount/umount infrastructure
Date: Sun, 10 Oct 2010 11:22:48 -0400
Message-Id: <1286724173-8493-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Allow a module implementing a layout type to register, and
have its mount/umount routines called for filesystems that
the server declares support it.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 Documentation/filesystems/nfs/00-INDEX |    2 +
 Documentation/filesystems/nfs/pnfs.txt |   48 +++++++++++++++++
 fs/nfs/Kconfig                         |    8 ++-
 fs/nfs/pnfs.c                          |   88 +++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                          |    9 +++
 5 files changed, 151 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/pnfs.txt

diff --git a/Documentation/filesystems/nfs/00-INDEX b/Documentation/filesystems/nfs/00-INDEX
index 2f68cd6..e474827 100644
--- a/Documentation/filesystems/nfs/00-INDEX
+++ b/Documentation/filesystems/nfs/00-INDEX
@@ -12,5 +12,7 @@ nfs-rdma.txt
 	- how to install and setup the Linux NFS/RDMA client and server software
 nfsroot.txt
 	- short guide on setting up a diskless box with NFS root filesystem.
+pnfs.txt
+	- short explanation of some of the internals of the pnfs client code
 rpc-cache.txt
 	- introduction to the caching mechanisms in the sunrpc layer.
diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
new file mode 100644
index 0000000..bc0b9cf
--- /dev/null
+++ b/Documentation/filesystems/nfs/pnfs.txt
@@ -0,0 +1,48 @@
+Reference counting in pnfs:
+==========================
+
+The are several inter-related caches.  We have layouts which can
+reference multiple devices, each of which can reference multiple data servers.
+Each data server can be referenced by multiple devices.  Each device
+can be referenced by multiple layouts.  To keep all of this straight,
+we need to reference count.
+
+
+struct pnfs_layout_hdr
+----------------------
+The on-the-wire command LAYOUTGET corresponds to struct
+pnfs_layout_segment, usually referred to by the variable name lseg.
+Each nfs_inode may hold a pointer to a cache of of these layout
+segments in nfsi->layout, of type struct pnfs_layout_hdr.
+
+We reference the header for the inode pointing to it, across each
+outstanding RPC call that references it (LAYOUTGET, LAYOUTRETURN,
+LAYOUTCOMMIT), and for each lseg held within.
+
+Each header is also (when non-empty) put on a list associated with
+struct nfs_client (cl_layouts).  Being put on this list does not bump
+the reference count, as the layout is kept around by the lseg that
+keeps it in the list.
+
+deviceid_cache
+--------------
+lsegs reference device ids, which are resolved per nfs_client and
+layout driver type.  The device ids are held in a RCU cache (struct
+nfs4_deviceid_cache).  The cache itself is referenced across each
+mount.  The entries (struct nfs4_deviceid) themselves are held across
+the lifetime of each lseg referencing them.
+
+RCU is used because the deviceid is basically a write once, read many
+data structure.  The hlist size of 32 buckets needs better
+justification, but seems reasonable given that we can have multiple
+deviceid's per filesystem, and multiple filesystems per nfs_client.
+
+The hash code is copied from the nfsd code base.  A discussion of
+hashing and variations of this algorithm can be found at:
+http://groups.google.com/group/comp.lang.c/browse_thread/thread/9522965e2b8d3809
+
+data server cache
+-----------------
+file driver devices refer to data servers, which are kept in a module
+level cache.  Its reference is held over the lifetime of the deviceid
+pointing to it.
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6c2aad4..a267f3f 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -75,13 +75,17 @@ config NFS_V4
 
 config NFS_V4_1
 	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"
-	depends on NFS_V4 && EXPERIMENTAL
+	depends on NFS_FS && NFS_V4 && EXPERIMENTAL
+	select PNFS_FILE_LAYOUT
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
-	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
+	  (RFC 5661) in the kernel's NFS client.
 
 	  If unsure, say N.
 
+config PNFS_FILE_LAYOUT
+	tristate
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b483026..cf79562 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -32,16 +32,51 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 
-/* STUB that returns the equivalent of "no module found" */
+/* Locking:
+ *
+ * pnfs_spinlock:
+ *      protects pnfs_modules_tbl.
+ */
+static DEFINE_SPINLOCK(pnfs_spinlock);
+
+/*
+ * pnfs_modules_tbl holds all pnfs modules
+ */
+static LIST_HEAD(pnfs_modules_tbl);
+
+/* Return the registered pnfs layout driver module matching given id */
+static struct pnfs_layoutdriver_type *
+find_pnfs_driver_locked(u32 id)
+{
+	struct pnfs_layoutdriver_type *local;
+
+	list_for_each_entry(local, &pnfs_modules_tbl, pnfs_tblid)
+		if (local->id == id)
+			goto out;
+	local = NULL;
+out:
+	dprintk("%s: Searching for id %u, found %p\n", __func__, id, local);
+	return local;
+}
+
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver(u32 id)
 {
-	return NULL;
+	struct pnfs_layoutdriver_type *local;
+
+	spin_lock(&pnfs_spinlock);
+	local = find_pnfs_driver_locked(id);
+	spin_unlock(&pnfs_spinlock);
+	return local;
 }
 
 void
 unset_pnfs_layoutdriver(struct nfs_server *nfss)
 {
+	if (nfss->pnfs_curr_ld) {
+		nfss->pnfs_curr_ld->uninitialize_mountpoint(nfss);
+		module_put(nfss->pnfs_curr_ld->owner);
+	}
 	nfss->pnfs_curr_ld = NULL;
 }
 
@@ -74,7 +109,18 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 			goto out_no_driver;
 		}
 	}
+	if (!try_module_get(ld_type->owner)) {
+		dprintk("%s: Could not grab reference on module\n", __func__);
+		goto out_no_driver;
+	}
 	server->pnfs_curr_ld = ld_type;
+	if (ld_type->initialize_mountpoint(server)) {
+		printk(KERN_ERR
+		       "%s: Error initializing mount point for layout driver %u.\n",
+		       __func__, id);
+		module_put(ld_type->owner);
+		goto out_no_driver;
+	}
 	dprintk("%s: pNFS module for %u set\n", __func__, id);
 	return;
 
@@ -82,3 +128,41 @@ out_no_driver:
 	dprintk("%s: Using NFSv4 I/O\n", __func__);
 	server->pnfs_curr_ld = NULL;
 }
+
+int
+pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
+{
+	int status = -EINVAL;
+	struct pnfs_layoutdriver_type *tmp;
+
+	if (ld_type->id == 0) {
+		printk(KERN_ERR "%s id 0 is reserved\n", __func__);
+		return status;
+	}
+
+	spin_lock(&pnfs_spinlock);
+	tmp = find_pnfs_driver_locked(ld_type->id);
+	if (!tmp) {
+		list_add(&ld_type->pnfs_tblid, &pnfs_modules_tbl);
+		status = 0;
+		dprintk("%s Registering id:%u name:%s\n", __func__, ld_type->id,
+			ld_type->name);
+	} else {
+		printk(KERN_ERR "%s Module with id %d already loaded!\n",
+			__func__, ld_type->id);
+	}
+	spin_unlock(&pnfs_spinlock);
+
+	return status;
+}
+EXPORT_SYMBOL_GPL(pnfs_register_layoutdriver);
+
+void
+pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
+{
+	dprintk("%s Deregistering id:%u\n", __func__, ld_type->id);
+	spin_lock(&pnfs_spinlock);
+	list_del(&ld_type->pnfs_tblid);
+	spin_unlock(&pnfs_spinlock);
+}
+EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c628ef1..61531f3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -36,8 +36,17 @@
 
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
+	struct list_head pnfs_tblid;
+	const u32 id;
+	const char *name;
+	struct module *owner;
+	int (*initialize_mountpoint) (struct nfs_server *);
+	int (*uninitialize_mountpoint) (struct nfs_server *);
 };
 
+extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
+extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
+
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 
-- 
1.7.2.1

