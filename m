Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab0HSP3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:29:05 -0400
From: andros@netpp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/5] SQUASHME pnfs_submit: rename getdeviceinfo
Date: Thu, 19 Aug 2010 11:27:53 -0400
Message-Id: <1282231677-4412-2-git-send-email-andros@netpp.com>
In-Reply-To: <1282231677-4412-1-git-send-email-andros@netpp.com>
References: <1282231677-4412-1-git-send-email-andros@netpp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: generic getdeviceinfo

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c        |    8 ++++----
 fs/nfs/nfs4xdr.c         |    8 ++++----
 fs/nfs/pnfs.c            |    2 +-
 fs/nfs/pnfs.h            |    2 +-
 include/linux/nfs4.h     |    2 +-
 include/linux/pnfs_xdr.h |    4 ++--
 6 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 10cf7e2..8c94e1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5767,16 +5767,16 @@ int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool issync)
 	return err;
 }
 
-int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
+int nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
-	struct nfs4_pnfs_getdeviceinfo_arg args = {
+	struct nfs4_getdeviceinfo_args args = {
 		.pdev = pdev,
 	};
-	struct nfs4_pnfs_getdeviceinfo_res res = {
+	struct nfs4_getdeviceinfo_res res = {
 		.pdev = pdev,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_GETDEVICEINFO],
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICEINFO],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bb2cb86..89f7139 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1803,7 +1803,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 #ifdef CONFIG_NFS_V4_1
 static void
 encode_getdeviceinfo(struct xdr_stream *xdr,
-		     const struct nfs4_pnfs_getdeviceinfo_arg *args,
+		     const struct nfs4_getdeviceinfo_args *args,
 		     struct compound_hdr *hdr)
 {
 	int has_bitmap = (args->pdev->dev_notify_types != 0);
@@ -2741,7 +2741,7 @@ static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
  * Encode GETDEVICEINFO request
  */
 static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
-				      struct nfs4_pnfs_getdeviceinfo_arg *args)
+				      struct nfs4_getdeviceinfo_args *args)
 {
 	struct xdr_stream xdr;
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
@@ -6325,7 +6325,7 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
  * Decode GETDEVINFO response
  */
 static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp, uint32_t *p,
-				      struct nfs4_pnfs_getdeviceinfo_res *res)
+				      struct nfs4_getdeviceinfo_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -6651,7 +6651,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
-  PROC(PNFS_GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
+  PROC(GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
   PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
   PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
   PROC(PNFS_LAYOUTRETURN, enc_layoutreturn,  dec_layoutreturn),
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 52d1a79..7bf812f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1460,7 +1460,7 @@ out_free:
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
-	.nfs_getdeviceinfo = nfs4_pnfs_getdeviceinfo,
+	.nfs_getdeviceinfo = nfs4_proc_getdeviceinfo,
 };
 
 EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e39af4f..d6ed419 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -22,7 +22,7 @@
 #include "iostat.h"
 
 /* nfs4proc.c */
-extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
+extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
 extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data,
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 6ee7357..7c54b00 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -556,7 +556,7 @@ enum {
 	NFSPROC4_CLNT_PNFS_LAYOUTGET,
 	NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT,
 	NFSPROC4_CLNT_PNFS_LAYOUTRETURN,
-	NFSPROC4_CLNT_PNFS_GETDEVICEINFO,
+	NFSPROC4_CLNT_GETDEVICEINFO,
 	NFSPROC4_CLNT_PNFS_WRITE,
 	NFSPROC4_CLNT_PNFS_COMMIT,
 };
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index ed16c65..4371c84 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -110,12 +110,12 @@ struct nfs4_pnfs_layoutreturn {
 	int rpc_status;
 };
 
-struct nfs4_pnfs_getdeviceinfo_arg {
+struct nfs4_getdeviceinfo_args {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
 };
 
-struct nfs4_pnfs_getdeviceinfo_res {
+struct nfs4_getdeviceinfo_res {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_res seq_res;
 };
-- 
1.6.2.5

