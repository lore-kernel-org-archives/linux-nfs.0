Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:37871 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932831AbdGKQob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:31 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 11/42] NFS test for intra vs inter COPY
Date: Tue, 11 Jul 2017 12:43:45 -0400
Message-ID: <20170711164416.1982-12-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/internal.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3e24392..dcbcffb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -7,6 +7,7 @@
 #include <linux/security.h>
 #include <linux/crc32.h>
 #include <linux/nfs_page.h>
+#include <linux/sunrpc/addr.h>
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
 
@@ -766,3 +767,12 @@ static inline bool nfs_error_is_fatal(int err)
 		return false;
 	}
 }
+
+static inline bool nfs42_files_from_same_server(struct file *in, struct file *out)
+{
+	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
+	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
+
+	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
+				(struct sockaddr *)&c_out->cl_addr);
+}
-- 
1.8.3.1

