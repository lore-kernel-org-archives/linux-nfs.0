Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51611 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161557Ab3DEOIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 10:08:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: minor cb_recall simplification
Date: Fri,  5 Apr 2013 10:08:03 -0400
Message-Id: <1365170886-2267-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1365170886-2267-1-git-send-email-bfields@redhat.com>
References: <1365170886-2267-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 99bc85f..be3ff0f 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -817,8 +817,7 @@ static bool nfsd41_cb_get_slot(struct nfs4_client *clp, struct rpc_task *task)
 static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
-	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
+	struct nfs4_client *clp = cb->cb_clp;
 	u32 minorversion = clp->cl_minorversion;
 
 	cb->cb_minorversion = minorversion;
@@ -839,8 +838,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
-	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
+	struct nfs4_client *clp = cb->cb_clp;
 
 	dprintk("%s: minorversion=%d\n", __func__,
 		clp->cl_minorversion);
@@ -863,7 +861,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
+	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
 
 	nfsd4_cb_done(task, calldata);
-- 
1.7.11.7

