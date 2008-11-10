From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 35/51] nfsd41: introduce nfs4_cb_call_sync for nfs4 and nfs41
Date: Mon, 10 Nov 2008 22:52:41 +0200
Message-ID: <1226350361-11423-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57404 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbYKJUwy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:52:54 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For nfs41 callbacks we need to setup the cb_sequence args and
process the result.  This will be called by code common to
nfs4 and nfs41.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 312fe87..5b17397 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -616,6 +616,12 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	return;
 }
 
+static int _nfs4_cb_sync(struct nfs4_client *clp,
+			 const struct rpc_message *msg, int flags)
+{
+	return rpc_call_sync(clp->cl_callback.cb_client, msg, RPC_TASK_SOFT);
+}
+
 #if defined(CONFIG_NFSD_V4_1)
 /* FIXME: cb_sequence should support referring call lists, cachethis, and multiple slots */
 static int
@@ -644,6 +650,41 @@ nfs41_cb_sequence_done(struct nfs4_client *clp, struct nfs41_cb_sequence *res)
 	/* FIXME: support multiple callback slots */
 	mutex_unlock(&clp->cl_cb_mutex);
 }
+
+static int _nfs41_cb_sync(struct nfs4_client *clp,
+			  struct rpc_message *msg, int flags)
+{
+	struct nfs41_cb_sequence seq;
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
+	status = _nfs4_cb_sync(clp, msg, flags);
+	nfs41_cb_sequence_done(clp, &seq);
+
+	return status;
+}
+
+static int nfs4_cb_sync(struct nfs4_client *clp,
+			     struct rpc_message *msg, int flags)
+{
+	return clp->cl_callback.cb_minorversion ?
+		_nfs41_cb_sync(clp, msg, flags) :
+		_nfs4_cb_sync(clp, msg, flags);
+}
+#else  /* CONFIG_NFSD_V4_1 */
+static int nfs4_cb_sync(struct nfs4_client *clp,
+			     struct rpc_message *msg, int flags)
+{
+	return _nfs4_cb_sync(clp, msg, flags);
+}
 #endif /* CONFIG_NFSD_V4_1 */
 
 /*
-- 
1.6.0.2

