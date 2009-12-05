From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCHSET 00/12 repost] nfsd: #includes cleanup
Date: Fri, 4 Dec 2009 20:03:10 -0500
Message-ID: <20091205010310.GE22497@fieldses.org>
References: <4B1802D0.8060206@panasas.com> <20091205010004.GC22497@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46626 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757550AbZLEBCC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 20:02:02 -0500
In-Reply-To: <20091205010004.GC22497@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 04, 2009 at 08:00:04PM -0500, J. Bruce Fields wrote:
> On Thu, Dec 03, 2009 at 08:26:24PM +0200, Boaz Harrosh wrote:
> > 
> > Hi Bruce
> > 
> > I'm reposting the all set together
> 
> Applied locally (but pushed to branch for linux-next), thanks.

We can also move most of nfsfh.h.  I didn't try to figure out exactly
what needed to be shared and why, but at least moved what obviously
didn't need to be shared.

--b.

commit ad98ebfdb488cfce46bfc9d75825fdc2ff1a96b9
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Dec 4 19:36:06 2009 -0500

    nfsd: move most of nfsfh.h to fs/nfsd
    
    Most of this can be trivially moved to a private header as well.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index cd377a7..c9e45e3 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -22,6 +22,7 @@
 #include <net/ipv6.h>
 
 #include "nfsd.h"
+#include "nfsfh.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
new file mode 100644
index 0000000..cdfb8c6
--- /dev/null
+++ b/fs/nfsd/nfsfh.h
@@ -0,0 +1,208 @@
+/* Copyright (C) 1995, 1996, 1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org> */
+
+#ifndef _LINUX_NFSD_FH_INT_H
+#define _LINUX_NFSD_FH_INT_H
+
+#include <linux/nfsd/nfsfh.h>
+
+enum nfsd_fsid {
+	FSID_DEV = 0,
+	FSID_NUM,
+	FSID_MAJOR_MINOR,
+	FSID_ENCODE_DEV,
+	FSID_UUID4_INUM,
+	FSID_UUID8,
+	FSID_UUID16,
+	FSID_UUID16_INUM,
+};
+
+enum fsid_source {
+	FSIDSOURCE_DEV,
+	FSIDSOURCE_FSID,
+	FSIDSOURCE_UUID,
+};
+extern enum fsid_source fsid_source(struct svc_fh *fhp);
+
+
+/* This might look a little large to "inline" but in all calls except
+ * one, 'vers' is constant so moste of the function disappears.
+ */
+static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
+			   u32 fsid, unsigned char *uuid)
+{
+	u32 *up;
+	switch(vers) {
+	case FSID_DEV:
+		fsidv[0] = htonl((MAJOR(dev)<<16) |
+				 MINOR(dev));
+		fsidv[1] = ino_t_to_u32(ino);
+		break;
+	case FSID_NUM:
+		fsidv[0] = fsid;
+		break;
+	case FSID_MAJOR_MINOR:
+		fsidv[0] = htonl(MAJOR(dev));
+		fsidv[1] = htonl(MINOR(dev));
+		fsidv[2] = ino_t_to_u32(ino);
+		break;
+
+	case FSID_ENCODE_DEV:
+		fsidv[0] = new_encode_dev(dev);
+		fsidv[1] = ino_t_to_u32(ino);
+		break;
+
+	case FSID_UUID4_INUM:
+		/* 4 byte fsid and inode number */
+		up = (u32*)uuid;
+		fsidv[0] = ino_t_to_u32(ino);
+		fsidv[1] = up[0] ^ up[1] ^ up[2] ^ up[3];
+		break;
+
+	case FSID_UUID8:
+		/* 8 byte fsid  */
+		up = (u32*)uuid;
+		fsidv[0] = up[0] ^ up[2];
+		fsidv[1] = up[1] ^ up[3];
+		break;
+
+	case FSID_UUID16:
+		/* 16 byte fsid - NFSv3+ only */
+		memcpy(fsidv, uuid, 16);
+		break;
+
+	case FSID_UUID16_INUM:
+		/* 8 byte inode and 16 byte fsid */
+		*(u64*)fsidv = (u64)ino;
+		memcpy(fsidv+2, uuid, 16);
+		break;
+	default: BUG();
+	}
+}
+
+static inline int key_len(int type)
+{
+	switch(type) {
+	case FSID_DEV:		return 8;
+	case FSID_NUM: 		return 4;
+	case FSID_MAJOR_MINOR:	return 12;
+	case FSID_ENCODE_DEV:	return 8;
+	case FSID_UUID4_INUM:	return 8;
+	case FSID_UUID8:	return 8;
+	case FSID_UUID16:	return 16;
+	case FSID_UUID16_INUM:	return 24;
+	default: return 0;
+	}
+}
+
+/*
+ * Shorthand for dprintk()'s
+ */
+extern char * SVCFH_fmt(struct svc_fh *fhp);
+
+/*
+ * Function prototypes
+ */
+__be32	fh_verify(struct svc_rqst *, struct svc_fh *, int, int);
+__be32	fh_compose(struct svc_fh *, struct svc_export *, struct dentry *, struct svc_fh *);
+__be32	fh_update(struct svc_fh *);
+void	fh_put(struct svc_fh *);
+
+static __inline__ struct svc_fh *
+fh_copy(struct svc_fh *dst, struct svc_fh *src)
+{
+	WARN_ON(src->fh_dentry || src->fh_locked);
+			
+	*dst = *src;
+	return dst;
+}
+
+static inline void
+fh_copy_shallow(struct knfsd_fh *dst, struct knfsd_fh *src)
+{
+	dst->fh_size = src->fh_size;
+	memcpy(&dst->fh_base, &src->fh_base, src->fh_size);
+}
+
+static __inline__ struct svc_fh *
+fh_init(struct svc_fh *fhp, int maxsize)
+{
+	memset(fhp, 0, sizeof(*fhp));
+	fhp->fh_maxsize = maxsize;
+	return fhp;
+}
+
+#ifdef CONFIG_NFSD_V3
+/*
+ * Fill in the pre_op attr for the wcc data
+ */
+static inline void
+fill_pre_wcc(struct svc_fh *fhp)
+{
+	struct inode    *inode;
+
+	inode = fhp->fh_dentry->d_inode;
+	if (!fhp->fh_pre_saved) {
+		fhp->fh_pre_mtime = inode->i_mtime;
+		fhp->fh_pre_ctime = inode->i_ctime;
+		fhp->fh_pre_size  = inode->i_size;
+		fhp->fh_pre_change = inode->i_version;
+		fhp->fh_pre_saved = 1;
+	}
+}
+
+extern void fill_post_wcc(struct svc_fh *);
+#else
+#define	fill_pre_wcc(ignored)
+#define fill_post_wcc(notused)
+#endif /* CONFIG_NFSD_V3 */
+
+
+/*
+ * Lock a file handle/inode
+ * NOTE: both fh_lock and fh_unlock are done "by hand" in
+ * vfs.c:nfsd_rename as it needs to grab 2 i_mutex's at once
+ * so, any changes here should be reflected there.
+ */
+
+static inline void
+fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
+{
+	struct dentry	*dentry = fhp->fh_dentry;
+	struct inode	*inode;
+
+	BUG_ON(!dentry);
+
+	if (fhp->fh_locked) {
+		printk(KERN_WARNING "fh_lock: %s/%s already locked!\n",
+			dentry->d_parent->d_name.name, dentry->d_name.name);
+		return;
+	}
+
+	inode = dentry->d_inode;
+	mutex_lock_nested(&inode->i_mutex, subclass);
+	fill_pre_wcc(fhp);
+	fhp->fh_locked = 1;
+}
+
+static inline void
+fh_lock(struct svc_fh *fhp)
+{
+	fh_lock_nested(fhp, I_MUTEX_NORMAL);
+}
+
+/*
+ * Unlock a file handle/inode
+ */
+static inline void
+fh_unlock(struct svc_fh *fhp)
+{
+	BUG_ON(!fhp->fh_dentry);
+
+	if (fhp->fh_locked) {
+		fill_post_wcc(fhp);
+		mutex_unlock(&fhp->fh_dentry->d_inode->i_mutex);
+		fhp->fh_locked = 0;
+	}
+}
+
+#endif /* _LINUX_NFSD_FH_INT_H */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2af7568..775b8d2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -38,6 +38,7 @@
 #define _NFSD4_STATE_H
 
 #include <linux/nfsd/nfsfh.h>
+#include "nfsfh.h"
 
 typedef struct {
 	u32             cl_boot;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index f4fa6d3..4b1de0a 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -5,6 +5,8 @@
 #ifndef LINUX_NFSD_VFS_H
 #define LINUX_NFSD_VFS_H
 
+#include "nfsfh.h"
+
 /*
  * Flags for nfsd_permission
  */
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 235ee5c..87fe6f6 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -9,6 +9,7 @@
 
 #include <linux/vfs.h>
 #include "nfsd.h"
+#include "nfsfh.h"
 
 struct nfsd_fhandle {
 	struct svc_fh		fh;
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 49523ed..65e333a 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -162,205 +162,6 @@ typedef struct svc_fh {
 
 } svc_fh;
 
-enum nfsd_fsid {
-	FSID_DEV = 0,
-	FSID_NUM,
-	FSID_MAJOR_MINOR,
-	FSID_ENCODE_DEV,
-	FSID_UUID4_INUM,
-	FSID_UUID8,
-	FSID_UUID16,
-	FSID_UUID16_INUM,
-};
-
-enum fsid_source {
-	FSIDSOURCE_DEV,
-	FSIDSOURCE_FSID,
-	FSIDSOURCE_UUID,
-};
-extern enum fsid_source fsid_source(struct svc_fh *fhp);
-
-
-/* This might look a little large to "inline" but in all calls except
- * one, 'vers' is constant so moste of the function disappears.
- */
-static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
-			   u32 fsid, unsigned char *uuid)
-{
-	u32 *up;
-	switch(vers) {
-	case FSID_DEV:
-		fsidv[0] = htonl((MAJOR(dev)<<16) |
-				 MINOR(dev));
-		fsidv[1] = ino_t_to_u32(ino);
-		break;
-	case FSID_NUM:
-		fsidv[0] = fsid;
-		break;
-	case FSID_MAJOR_MINOR:
-		fsidv[0] = htonl(MAJOR(dev));
-		fsidv[1] = htonl(MINOR(dev));
-		fsidv[2] = ino_t_to_u32(ino);
-		break;
-
-	case FSID_ENCODE_DEV:
-		fsidv[0] = new_encode_dev(dev);
-		fsidv[1] = ino_t_to_u32(ino);
-		break;
-
-	case FSID_UUID4_INUM:
-		/* 4 byte fsid and inode number */
-		up = (u32*)uuid;
-		fsidv[0] = ino_t_to_u32(ino);
-		fsidv[1] = up[0] ^ up[1] ^ up[2] ^ up[3];
-		break;
-
-	case FSID_UUID8:
-		/* 8 byte fsid  */
-		up = (u32*)uuid;
-		fsidv[0] = up[0] ^ up[2];
-		fsidv[1] = up[1] ^ up[3];
-		break;
-
-	case FSID_UUID16:
-		/* 16 byte fsid - NFSv3+ only */
-		memcpy(fsidv, uuid, 16);
-		break;
-
-	case FSID_UUID16_INUM:
-		/* 8 byte inode and 16 byte fsid */
-		*(u64*)fsidv = (u64)ino;
-		memcpy(fsidv+2, uuid, 16);
-		break;
-	default: BUG();
-	}
-}
-
-static inline int key_len(int type)
-{
-	switch(type) {
-	case FSID_DEV:		return 8;
-	case FSID_NUM: 		return 4;
-	case FSID_MAJOR_MINOR:	return 12;
-	case FSID_ENCODE_DEV:	return 8;
-	case FSID_UUID4_INUM:	return 8;
-	case FSID_UUID8:	return 8;
-	case FSID_UUID16:	return 16;
-	case FSID_UUID16_INUM:	return 24;
-	default: return 0;
-	}
-}
-
-/*
- * Shorthand for dprintk()'s
- */
-extern char * SVCFH_fmt(struct svc_fh *fhp);
-
-/*
- * Function prototypes
- */
-__be32	fh_verify(struct svc_rqst *, struct svc_fh *, int, int);
-__be32	fh_compose(struct svc_fh *, struct svc_export *, struct dentry *, struct svc_fh *);
-__be32	fh_update(struct svc_fh *);
-void	fh_put(struct svc_fh *);
-
-static __inline__ struct svc_fh *
-fh_copy(struct svc_fh *dst, struct svc_fh *src)
-{
-	WARN_ON(src->fh_dentry || src->fh_locked);
-			
-	*dst = *src;
-	return dst;
-}
-
-static inline void
-fh_copy_shallow(struct knfsd_fh *dst, struct knfsd_fh *src)
-{
-	dst->fh_size = src->fh_size;
-	memcpy(&dst->fh_base, &src->fh_base, src->fh_size);
-}
-
-static __inline__ struct svc_fh *
-fh_init(struct svc_fh *fhp, int maxsize)
-{
-	memset(fhp, 0, sizeof(*fhp));
-	fhp->fh_maxsize = maxsize;
-	return fhp;
-}
-
-#ifdef CONFIG_NFSD_V3
-/*
- * Fill in the pre_op attr for the wcc data
- */
-static inline void
-fill_pre_wcc(struct svc_fh *fhp)
-{
-	struct inode    *inode;
-
-	inode = fhp->fh_dentry->d_inode;
-	if (!fhp->fh_pre_saved) {
-		fhp->fh_pre_mtime = inode->i_mtime;
-		fhp->fh_pre_ctime = inode->i_ctime;
-		fhp->fh_pre_size  = inode->i_size;
-		fhp->fh_pre_change = inode->i_version;
-		fhp->fh_pre_saved = 1;
-	}
-}
-
-extern void fill_post_wcc(struct svc_fh *);
-#else
-#define	fill_pre_wcc(ignored)
-#define fill_post_wcc(notused)
-#endif /* CONFIG_NFSD_V3 */
-
-
-/*
- * Lock a file handle/inode
- * NOTE: both fh_lock and fh_unlock are done "by hand" in
- * vfs.c:nfsd_rename as it needs to grab 2 i_mutex's at once
- * so, any changes here should be reflected there.
- */
-
-static inline void
-fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
-{
-	struct dentry	*dentry = fhp->fh_dentry;
-	struct inode	*inode;
-
-	BUG_ON(!dentry);
-
-	if (fhp->fh_locked) {
-		printk(KERN_WARNING "fh_lock: %s/%s already locked!\n",
-			dentry->d_parent->d_name.name, dentry->d_name.name);
-		return;
-	}
-
-	inode = dentry->d_inode;
-	mutex_lock_nested(&inode->i_mutex, subclass);
-	fill_pre_wcc(fhp);
-	fhp->fh_locked = 1;
-}
-
-static inline void
-fh_lock(struct svc_fh *fhp)
-{
-	fh_lock_nested(fhp, I_MUTEX_NORMAL);
-}
-
-/*
- * Unlock a file handle/inode
- */
-static inline void
-fh_unlock(struct svc_fh *fhp)
-{
-	BUG_ON(!fhp->fh_dentry);
-
-	if (fhp->fh_locked) {
-		fill_post_wcc(fhp);
-		mutex_unlock(&fhp->fh_dentry->d_inode->i_mutex);
-		fhp->fh_locked = 0;
-	}
-}
 #endif /* __KERNEL__ */
 
 
