From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 47/67] nfs41: verify session channel attribues
Date: Thu,  2 Apr 2009 16:57:25 +0300
Message-ID: <1238680645-14872-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31121 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751749AbZDBN6b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:31 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Invalidate the session if the server returns invalid fore or back channel
attributes.

Use a KERN_WARNING to report the fatal session estabishment error.

Signed-off-by: Andy Adamson <andros@netapp.com>
[refactor nfs4_verify_channel_attrs]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4381939..5ce8999 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4412,6 +4412,51 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		args->bc_attrs.max_reqs);
 }
 
+static int _verify_channel_attr(char *chan, char *attr_name, u32 sent, u32 rcvd)
+{
+	if (rcvd <= sent)
+		return 0;
+	printk(KERN_WARNING "%s: Session INVALID: %s channel %s increased. "
+		"sent=%u rcvd=%u\n", __func__, chan, attr_name, sent, rcvd);
+	return -EINVAL;
+}
+
+#define _verify_fore_channel_attr(_name_) \
+	_verify_channel_attr("fore", #_name_, \
+			     args->fc_attrs._name_, \
+			     session->fc_attrs._name_)
+
+#define _verify_back_channel_attr(_name_) \
+	_verify_channel_attr("back", #_name_, \
+			     args->bc_attrs._name_, \
+			     session->bc_attrs._name_)
+
+/*
+ * The server is not allowed to increase the fore channel header pad size,
+ * maximum response size, or maximum number of operations.
+ *
+ * The back channel attributes are only negotiatied down: We send what the
+ * (back channel) server insists upon.
+ */
+static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
+				     struct nfs4_session *session)
+{
+	int ret = 0;
+
+	ret |= _verify_fore_channel_attr(headerpadsz);
+	ret |= _verify_fore_channel_attr(max_resp_sz);
+	ret |= _verify_fore_channel_attr(max_ops);
+
+	ret |= _verify_back_channel_attr(headerpadsz);
+	ret |= _verify_back_channel_attr(max_rqst_sz);
+	ret |= _verify_back_channel_attr(max_resp_sz);
+	ret |= _verify_back_channel_attr(max_resp_sz_cached);
+	ret |= _verify_back_channel_attr(max_ops);
+	ret |= _verify_back_channel_attr(max_reqs);
+
+	return ret;
+}
+
 static int _nfs4_proc_create_session(struct nfs_client *clp)
 {
 	struct nfs4_session *session = clp->cl_session;
@@ -4434,8 +4479,9 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
 
-	/* Set the negotiated values in the session's channel_attrs struct */
-
+	if (!status)
+		/* Verify the session's negotiated channel_attrs values */
+		status = nfs4_verify_channel_attrs(&args, session);
 	if (!status) {
 		/* Increment the clientid slot sequence id */
 		clp->cl_seqid++;
-- 
1.6.2.1

