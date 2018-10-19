Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f194.google.com ([209.85.222.194]:44694 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727050AbeJSXgJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:36:09 -0400
Received: by mail-qk1-f194.google.com with SMTP id y8-v6so21195498qka.11
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:34 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 03/11] NFS test for intra vs inter COPY
Date: Fri, 19 Oct 2018 11:29:24 -0400
Message-Id: <20181019152932.32462-4-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 19ec38f8..5abff4d 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -6,6 +6,7 @@
 #ifndef __LINUX_FS_NFS_NFS4_2_H
 #define __LINUX_FS_NFS_NFS4_2_H
 
+#include <linux/sunrpc/addr.h>
 /*
  * FIXME:  four LAYOUTSTATS calls per compound at most! Do we need to support
  * more? Need to consider not to pre-alloc too much for a compound.
@@ -21,4 +22,14 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *,
 				   struct nfs42_layoutstat_data *);
 int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
 
+static inline bool nfs42_files_from_same_server(struct file *in,
+						struct file *out)
+{
+	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
+	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
+
+	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
+				(struct sockaddr *)&c_out->cl_addr);
+}
+
 #endif /* __LINUX_FS_NFS_NFS4_2_H */
-- 
1.8.3.1
