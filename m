Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33719 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750938AbdBRAtO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 19:49:14 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so5152187itc.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2017 16:49:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: If the layout is invalid, it must be updated before retrying
Date: Fri, 17 Feb 2017 19:49:09 -0500
Message-Id: <20170218004909.64909-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we see that our pNFS READ/WRITE/COMMIT operation failed, but we
also see that our layout segment is no longer valid, then we need to
get a new layout segment before retrying.

Fixes: 90816d1ddacf ("NFSv4.1/flexfiles: Don't mark the entire deviceid...")
Cc: stable@vger.kernel.org # v4.2+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0ca4af8cca5d..42e3e9daa328 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1053,9 +1053,6 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	struct nfs_client *mds_client = mds_server->nfs_client;
 	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
-	if (task->tk_status >= 0)
-		return 0;
-
 	switch (task->tk_status) {
 	/* MDS state errors */
 	case -NFS4ERR_DELEG_REVOKED:
@@ -1157,9 +1154,6 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 {
 	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
 
-	if (task->tk_status >= 0)
-		return 0;
-
 	switch (task->tk_status) {
 	/* File access problems. Don't mark the device as unavailable */
 	case -EACCES:
@@ -1195,6 +1189,13 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 {
 	int vers = clp->cl_nfs_mod->rpc_vers->number;
 
+	if (task->tk_status >= 0)
+		return 0;
+
+	/* Handle the case of an invalid layout segment */
+	if (!pnfs_is_valid_lseg(lseg))
+		return -NFS4ERR_RESET_TO_PNFS;
+
 	switch (vers) {
 	case 3:
 		return ff_layout_async_handle_error_v3(task, lseg, idx);
-- 
2.9.3

