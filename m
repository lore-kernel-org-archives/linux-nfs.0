Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44502 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727333AbeHKS1j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Aug 2018 14:27:39 -0400
Received: by mail-io0-f193.google.com with SMTP id q19-v6so10366429ioh.11
        for <linux-nfs@vger.kernel.org>; Sat, 11 Aug 2018 08:53:02 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Don't busy wait if NFSv4 session draining is interrupted
Date: Sat, 11 Aug 2018 11:52:38 -0400
Message-Id: <20180811155239.81855-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Catch the ERESTARTSYS error so that it can be processed by the callers.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2bf2eaa08ca7..f117bae29769 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -274,7 +274,7 @@ static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
 static int nfs4_begin_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
-	int ret = 0;
+	int ret;
 
 	if (clp->cl_slot_tbl)
 		return nfs4_drain_slot_tbl(clp->cl_slot_tbl);
@@ -1939,7 +1939,9 @@ static int nfs4_establish_lease(struct nfs_client *clp)
 		clp->cl_mvops->reboot_recovery_ops;
 	int status;
 
-	nfs4_begin_drain_session(clp);
+	status = nfs4_begin_drain_session(clp);
+	if (status != 0)
+		return status;
 	cred = nfs4_get_clid_cred(clp);
 	if (cred == NULL)
 		return -ENOENT;
@@ -2027,7 +2029,9 @@ static int nfs4_try_migration(struct nfs_server *server, struct rpc_cred *cred)
 		goto out;
 	}
 
-	nfs4_begin_drain_session(clp);
+	status = nfs4_begin_drain_session(clp);
+	if (status != 0)
+		return status;
 
 	status = nfs4_replace_transport(server, locations);
 	if (status != 0) {
@@ -2374,7 +2378,9 @@ static int nfs4_reset_session(struct nfs_client *clp)
 
 	if (!nfs4_has_session(clp))
 		return 0;
-	nfs4_begin_drain_session(clp);
+	status = nfs4_begin_drain_session(clp);
+	if (status != 0)
+		return status;
 	cred = nfs4_get_clid_cred(clp);
 	status = nfs4_proc_destroy_session(clp->cl_session, cred);
 	switch (status) {
@@ -2417,7 +2423,9 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 
 	if (!nfs4_has_session(clp))
 		return 0;
-	nfs4_begin_drain_session(clp);
+	ret = nfs4_begin_drain_session(clp);
+	if (ret != 0)
+		return ret;
 	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_bind_conn_to_session(clp, cred);
 	if (cred)
-- 
2.17.1
