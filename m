From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 41/47] nfsd41: introduce nfs4_cb_call_sync for nfs4 and nfs41
Date: Fri, 27 Mar 2009 06:20:07 +0300
Message-ID: <1238124007-8194-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23283 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755701AbZC0DUN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:20:13 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For nfs41 callbacks we need to setup the cb_sequence args and
process the result.  This will be called by code common to
nfs4 and nfs41.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7ada6b1..dd3b739 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -92,6 +92,15 @@ enum nfs_cb_opnum4 {
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
 
+struct nfs4_rpc_args {
+	void                     *args_op;
+	struct nfsd4_cb_sequence *args_seq;
+};
+
+struct nfs4_rpc_res {
+	struct nfsd4_cb_sequence *res_seq;
+};
+
 /*
 * Generic encode routines from fs/nfs/nfs4xdr.c
 */
@@ -589,6 +598,12 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	return;
 }
 
+static int _nfsd4_cb_sync(struct nfs4_client *clp,
+			  const struct rpc_message *msg, int flags)
+{
+	return rpc_call_sync(clp->cl_callback.cb_client, msg, RPC_TASK_SOFT);
+}
+
 #if defined(CONFIG_NFSD_V4_1)
 /*
  * FIXME: cb_sequence should support referring call lists, cachethis, and
@@ -619,6 +634,41 @@ nfs41_cb_sequence_done(struct nfs4_client *clp, struct nfsd4_cb_sequence *res)
 	/* FIXME: support multiple callback slots */
 	mutex_unlock(&clp->cl_cb_mutex);
 }
+
+static int _nfsd41_cb_sync(struct nfs4_client *clp,
+			   struct rpc_message *msg, int flags)
+{
+	struct nfsd4_cb_sequence seq;
+	struct nfs4_rpc_args *args;
+	struct nfs4_rpc_res res;
+	int status;
+
+	args = msg->rpc_argp;
+	args->args_seq = &seq;
+
+	res.res_seq = &seq;
+	msg->rpc_resp = &res;
+
+	nfs41_cb_sequence_setup(clp, &seq);
+	status = _nfsd4_cb_sync(clp, msg, flags);
+	nfs41_cb_sequence_done(clp, &seq);
+
+	return status;
+}
+
+static int nfsd4_cb_sync(struct nfs4_client *clp,
+			 struct rpc_message *msg, int flags)
+{
+	return clp->cl_callback.cb_minorversion ?
+		_nfsd41_cb_sync(clp, msg, flags) :
+		_nfsd4_cb_sync(clp, msg, flags);
+}
+#else  /* CONFIG_NFSD_V4_1 */
+static int nfsd4_cb_sync(struct nfs4_client *clp,
+			 struct rpc_message *msg, int flags)
+{
+	return _nfsd4_cb_sync(clp, msg, flags);
+}
 #endif /* CONFIG_NFSD_V4_1 */
 
 /*
-- 
1.6.2.1

