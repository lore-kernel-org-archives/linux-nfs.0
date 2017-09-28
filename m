Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:18048 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751813AbdI1R2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:42 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 02/11] NFS test for intra vs inter COPY
Date: Thu, 28 Sep 2017 13:28:30 -0400
Message-ID: <20170928172839.50741-3-kolga@netapp.com>
In-Reply-To: <20170928172839.50741-1-kolga@netapp.com>
References: <20170928172839.50741-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 6b9decf..b8affc8 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -5,6 +5,7 @@
 #ifndef __LINUX_FS_NFS_NFS4_2_H
 #define __LINUX_FS_NFS_NFS4_2_H
 
+#include <linux/sunrpc/addr.h>
 /*
  * FIXME:  four LAYOUTSTATS calls per compound at most! Do we need to support
  * more? Need to consider not to pre-alloc too much for a compound.
@@ -22,5 +23,14 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *,
 int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
 int nfs42_proc_offload_status(struct file *, nfs4_stateid *,
 			      struct nfs42_offload_status_res *);
+
+static inline bool nfs42_files_from_same_server(struct file *in, struct file *out)
+{
+	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
+	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
+
+	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
+				(struct sockaddr *)&c_out->cl_addr);
+}
 #endif /* CONFIG_NFS_V4_2) */
 #endif /* __LINUX_FS_NFS_NFS4_2_H */
-- 
1.8.3.1

