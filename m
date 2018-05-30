Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38509 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932090AbeE3SGZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:25 -0400
Received: by mail-it0-f66.google.com with SMTP id q4-v6so24656438ite.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:25 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:23 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/19] pnfs: Move nfs4_opendata into nfs4_fs.h
Date: Wed, 30 May 2018 14:05:42 -0400
Message-Id: <20180530180553.38769-9-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-8-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

It will be needed now by the pnfs code.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4_fs.h  | 25 +++++++++++++++++++++++++
 fs/nfs/nfs4proc.c | 25 -------------------------
 fs/nfs/pnfs.c     |  1 +
 3 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 06a41aa2fdb2..137e18abb7e7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -212,6 +212,31 @@ struct nfs4_state_recovery_ops {
 		struct rpc_cred *);
 };
 
+struct nfs4_opendata {
+	struct kref kref;
+	struct nfs_openargs o_arg;
+	struct nfs_openres o_res;
+	struct nfs_open_confirmargs c_arg;
+	struct nfs_open_confirmres c_res;
+	struct nfs4_string owner_name;
+	struct nfs4_string group_name;
+	struct nfs4_label *a_label;
+	struct nfs_fattr f_attr;
+	struct nfs4_label *f_label;
+	struct dentry *dir;
+	struct dentry *dentry;
+	struct nfs4_state_owner *owner;
+	struct nfs4_state *state;
+	struct iattr attrs;
+	struct nfs4_layoutget *lgp;
+	unsigned long timestamp;
+	bool rpc_done;
+	bool file_created;
+	bool is_recover;
+	bool cancelled;
+	int rpc_status;
+};
+
 struct nfs4_add_xprt_data {
 	struct nfs_client	*clp;
 	struct rpc_cred		*cred;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 54f2987483fa..771439971759 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1065,31 +1065,6 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
 	spin_unlock(&dir->i_lock);
 }
 
-struct nfs4_opendata {
-	struct kref kref;
-	struct nfs_openargs o_arg;
-	struct nfs_openres o_res;
-	struct nfs_open_confirmargs c_arg;
-	struct nfs_open_confirmres c_res;
-	struct nfs4_string owner_name;
-	struct nfs4_string group_name;
-	struct nfs4_label *a_label;
-	struct nfs_fattr f_attr;
-	struct nfs4_label *f_label;
-	struct dentry *dir;
-	struct dentry *dentry;
-	struct nfs4_state_owner *owner;
-	struct nfs4_state *state;
-	struct iattr attrs;
-	struct nfs4_layoutget *lgp;
-	unsigned long timestamp;
-	bool rpc_done;
-	bool file_created;
-	bool is_recover;
-	bool cancelled;
-	int rpc_status;
-};
-
 struct nfs4_open_createattrs {
 	struct nfs4_label *label;
 	struct iattr *sattr;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 363420d0f3a0..11148414b9b6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -37,6 +37,7 @@
 #include "nfs4trace.h"
 #include "delegation.h"
 #include "nfs42.h"
+#include "nfs4_fs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 #define PNFS_LAYOUTGET_RETRY_TIMEOUT (120*HZ)
-- 
2.17.0

