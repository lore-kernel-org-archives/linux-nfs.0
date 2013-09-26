Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f45.google.com ([209.85.128.45]:65483 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab3IZSkr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:47 -0400
Received: by mail-qe0-f45.google.com with SMTP id 6so1087376qea.18
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:46 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 13/49] pnfsd: filelayout: get device list/info
Date: Thu, 26 Sep 2013 14:40:43 -0400
Message-Id: <1380220843-13278-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Calculate the size of the opaque device_addr4 da_addr_body. Use this size to
compare to the client's gdia_maxcount, and if it's not too small, to reserve
the xdr space once.

Require the file system get_device_info call to return the XDR size of the
device_addr4 da_addr_body in pnfs_xdr_info.bytes_written on NFS4ERR_TOOSMALL
for the gdir_mincount calculation.

Declare a call back into the file system for encoding a multipage stripe
indice.

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: update pNFS server ops to draft 13]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Fix server GETDEVICELIST to comply with NFSv4.1 Draft 13]
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
[pnfsd: Simplify device export ops.]
[pnfsd: Remove device enc/free export ops]
[pnfsd: Use 128 bit deviceid on server]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: filelayout: use nfsd4_compoundres pointer in pnfs_xdr_info]
[pnfsd: filelayout: fix NFS4ERR_TOOSMALL for getdeviceinfo]
[pnfsd: fix filelayout getdeviceinfo devaddr4 length encoding]
[pnfsd: file layout mulitpage getdeviceinfo encode callback]
[Used gfs2_get_device_info from
 pnfs-gfs2: initial GETDEVICE* work for pNFS/GFS2 integration]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs-gfs2: return correct error value in GETDEVICEINFO]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: filelayout: get rid of xdr encoding macros for file layout xdr]
[pnfsd: filelayout: move xdr declarations to nfs4layoutxdr.h]
[pnfsd: get rid of devinfo encoding function vector]
[pnfsd: filelayout: strictly define filelayout_encode_devinfo]
[pnfsd: mv nfs4filelayoutxdr to fs/exportfs]
[pnfsd: filelayout: convert to using exp_xdr]
[exportfs: filelayout: disable dprintk]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: exportfs: fix build warning]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: fix cosmetic checkpatch warnings]
[conditionally build nfs4filelayoutxdr using config option]
[pnfsd: rename device fsid member to sbid]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: EXPORTFS_FILE_LAYOUT should be prompt-less]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/Kconfig                         |   7 ++
 fs/exportfs/Makefile               |   3 +-
 fs/exportfs/nfs4filelayoutxdr.c    | 133 +++++++++++++++++++++++++++++++++++++
 fs/nfsd/Kconfig                    |   1 +
 fs/nfsd/nfs4proc.c                 |   1 +
 fs/nfsd/nfs4xdr.c                  |   1 +
 include/linux/exportfs.h           |   9 +++
 include/linux/nfsd/nfs4layoutxdr.h |  58 ++++++++++++++++
 include/uapi/linux/nfsd/debug.h    |   1 +
 9 files changed, 213 insertions(+), 1 deletion(-)
 create mode 100644 fs/exportfs/nfs4filelayoutxdr.c
 create mode 100644 include/linux/nfsd/nfs4layoutxdr.h

diff --git a/fs/Kconfig b/fs/Kconfig
index c229f82..7c4af37 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -53,6 +53,13 @@ config FS_POSIX_ACL
 config EXPORTFS
 	tristate
 
+config EXPORTFS_FILE_LAYOUT
+	bool
+	depends on PNFSD && EXPORTFS
+	help
+	  Exportfs support for the NFSv4.1 files layout type.
+	  Must be automatically selected by supporting filesystems.
+
 config FILE_LOCKING
 	bool "Enable POSIX file locking API" if EXPERT
 	default y
diff --git a/fs/exportfs/Makefile b/fs/exportfs/Makefile
index d7c5d4d..658207d 100644
--- a/fs/exportfs/Makefile
+++ b/fs/exportfs/Makefile
@@ -3,4 +3,5 @@
 
 obj-$(CONFIG_EXPORTFS) += exportfs.o
 
-exportfs-objs := expfs.o
+exportfs-y				:= expfs.o
+exportfs-$(CONFIG_EXPORTFS_FILE_LAYOUT)	+= nfs4filelayoutxdr.o
diff --git a/fs/exportfs/nfs4filelayoutxdr.c b/fs/exportfs/nfs4filelayoutxdr.c
new file mode 100644
index 0000000..4801bfe
--- /dev/null
+++ b/fs/exportfs/nfs4filelayoutxdr.c
@@ -0,0 +1,133 @@
+/*
+ *  Copyright (c) 2006 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+#include <linux/exp_xdr.h>
+#include <linux/module.h>
+#include <linux/nfsd/nfs4layoutxdr.h>
+
+/* We do our-own dprintk so filesystems are not dependent on sunrpc */
+#ifdef dprintk
+#undef dprintk
+#endif
+#define dprintk(fmt, args, ...)	do { } while (0)
+
+/* Calculate the XDR length of the GETDEVICEINFO4resok structure
+ * excluding the gdir_notification and the gdir_device_addr da_layout_type.
+ */
+static int fl_devinfo_xdr_words(const struct pnfs_filelayout_device *fdev)
+{
+	struct pnfs_filelayout_devaddr *fl_addr;
+	struct pnfs_filelayout_multipath *mp;
+	int i, j, nwords;
+
+	/* da_addr_body length, indice length, indices,
+	 * multipath_list4 length */
+	nwords = 1 + 1 + fdev->fl_stripeindices_length + 1;
+	for (i = 0; i < fdev->fl_device_length; i++) {
+		mp = &fdev->fl_device_list[i];
+		nwords++; /* multipath list length */
+		for (j = 0; j < mp->fl_multipath_length; j++) {
+			fl_addr = mp->fl_multipath_list;
+			nwords += 1 + exp_xdr_qwords(fl_addr->r_netid.len);
+			nwords += 1 + exp_xdr_qwords(fl_addr->r_addr.len);
+		}
+	}
+	dprintk("<-- %s nwords %d\n", __func__, nwords);
+	return nwords;
+}
+
+/* Encodes the nfsv4_1_file_layout_ds_addr4 structure from draft 13
+ * on the response stream.
+ * Use linux error codes (not nfs) since these values are being
+ * returned to the file system.
+ */
+int
+filelayout_encode_devinfo(struct exp_xdr_stream *xdr,
+			  const struct pnfs_filelayout_device *fdev)
+{
+	unsigned int i, j, len = 0, opaque_words;
+	u32 *p_in;
+	u32 index_count = fdev->fl_stripeindices_length;
+	u32 dev_count = fdev->fl_device_length;
+	int error = 0;
+	__be32 *p;
+
+	opaque_words = fl_devinfo_xdr_words(fdev);
+	dprintk("%s: Begin indx_cnt: %u dev_cnt: %u total size %u\n",
+		__func__,
+		index_count,
+		dev_count,
+		opaque_words*4);
+
+	/* check space for opaque length */
+	p = p_in = exp_xdr_reserve_qwords(xdr, opaque_words);
+	if (!p) {
+		error =  -ETOOSMALL;
+		goto out;
+	}
+
+	/* Fill in length later */
+	p++;
+
+	/* encode device list indices */
+	p = exp_xdr_encode_u32(p, index_count);
+	for (i = 0; i < index_count; i++)
+		p = exp_xdr_encode_u32(p, fdev->fl_stripeindices_list[i]);
+
+	/* encode device list */
+	p = exp_xdr_encode_u32(p, dev_count);
+	for (i = 0; i < dev_count; i++) {
+		struct pnfs_filelayout_multipath *mp = &fdev->fl_device_list[i];
+
+		p = exp_xdr_encode_u32(p, mp->fl_multipath_length);
+		for (j = 0; j < mp->fl_multipath_length; j++) {
+			struct pnfs_filelayout_devaddr *da =
+						&mp->fl_multipath_list[j];
+
+			/* Encode device info */
+			p = exp_xdr_encode_opaque(p, da->r_netid.data,
+						     da->r_netid.len);
+			p = exp_xdr_encode_opaque(p, da->r_addr.data,
+						     da->r_addr.len);
+		}
+	}
+
+	/* backfill in length. Subtract 4 for da_addr_body size */
+	len = (char *)p - (char *)p_in;
+	exp_xdr_encode_u32(p_in, len - 4);
+
+	error = 0;
+out:
+	dprintk("%s: End err %d xdrlen %d\n",
+		__func__, error, len);
+	return error;
+}
+EXPORT_SYMBOL(filelayout_encode_devinfo);
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 4d68a8c..1cea26c 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -110,6 +110,7 @@ config NFSD_FAULT_INJECTION
 config PNFSD
 	bool "NFSv4.1 server support for Parallel NFS (pNFS) (EXPERIMENTAL)"
 	depends on NFSD_V4
+	select EXPORTFS_FILE_LAYOUT
 	help
 	  This option enables support for the parallel NFS features of the
 	  minor version 1 of the NFSv4 protocol (RFC5661)
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index feea3a9..81d41a4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -34,6 +34,7 @@
  */
 #include <linux/file.h>
 #include <linux/slab.h>
+#include <linux/nfsd/nfs4layoutxdr.h>
 
 #include "idmap.h"
 #include "cache.h"
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a761514..ed86a2d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -47,6 +47,7 @@
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/exportfs.h>
+#include <linux/nfsd/nfs4layoutxdr.h>
 
 #include "idmap.h"
 #include "acl.h"
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 41b223a..ade74e1 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -2,6 +2,7 @@
 #define LINUX_EXPORTFS_H 1
 
 #include <linux/types.h>
+#include <linux/exp_xdr.h>
 
 struct dentry;
 struct inode;
@@ -211,4 +212,12 @@ extern struct dentry *generic_fh_to_parent(struct super_block *sb,
 	struct fid *fid, int fh_len, int fh_type,
 	struct inode *(*get_inode) (struct super_block *sb, u64 ino, u32 gen));
 
+#if defined(CONFIG_EXPORTFS_FILE_LAYOUT)
+struct pnfs_filelayout_device;
+struct pnfs_filelayout_layout;
+
+extern int filelayout_encode_devinfo(struct exp_xdr_stream *xdr,
+				     const struct pnfs_filelayout_device *fdev);
+
+#endif /* defined(CONFIG_EXPORTFS_FILE_LAYOUT) */
 #endif /* LINUX_EXPORTFS_H */
diff --git a/include/linux/nfsd/nfs4layoutxdr.h b/include/linux/nfsd/nfs4layoutxdr.h
new file mode 100644
index 0000000..752055f
--- /dev/null
+++ b/include/linux/nfsd/nfs4layoutxdr.h
@@ -0,0 +1,58 @@
+/*
+ *  Copyright (c) 2006 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#ifndef NFSD_NFS4LAYOUTXDR_H
+#define NFSD_NFS4LAYOUTXDR_H
+
+#include <linux/sunrpc/xdr.h>
+
+/* the nfsd4_pnfs_devlist dev_addr for the file layout type */
+struct pnfs_filelayout_devaddr {
+	struct xdr_netobj	r_netid;
+	struct xdr_netobj	r_addr;
+};
+
+/* list of multipath servers */
+struct pnfs_filelayout_multipath {
+	u32				fl_multipath_length;
+	struct pnfs_filelayout_devaddr	*fl_multipath_list;
+};
+
+struct pnfs_filelayout_device {
+	u32					fl_stripeindices_length;
+	u32					*fl_stripeindices_list;
+	u32					fl_device_length;
+	struct pnfs_filelayout_multipath	*fl_device_list;
+};
+
+#endif /* NFSD_NFS4LAYOUTXDR_H */
diff --git a/include/uapi/linux/nfsd/debug.h b/include/uapi/linux/nfsd/debug.h
index 168f3a3..7444e9d 100644
--- a/include/uapi/linux/nfsd/debug.h
+++ b/include/uapi/linux/nfsd/debug.h
@@ -33,6 +33,7 @@
 #define NFSDDBG_XDR		0x0100
 #define NFSDDBG_LOCKD		0x0200
 #define NFSDDBG_PNFS		0x0400
+#define NFSDDBG_FILELAYOUT	0x0800
 #define NFSDDBG_ALL		0x7FFF
 #define NFSDDBG_NOCHANGE	0xFFFF
 
-- 
1.8.3.1

