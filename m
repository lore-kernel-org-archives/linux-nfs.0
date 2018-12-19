Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A0FEC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 07:00:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 221D621841
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 07:00:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="PlVHWP7r"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727159AbeLSHAP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 02:00:15 -0500
Received: from esa3.hgst.iphmx.com ([216.71.153.141]:33107 "EHLO
        esa3.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726898AbeLSHAP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 02:00:15 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1545202816; x=1576738816;
  h=from:to:cc:subject:date:message-id;
  bh=VNaX31uHbRoArz828tmdTRAtacXvmUJhAj5qDMWvtIU=;
  b=PlVHWP7rMrzS769dDitvneQkGt5nDkSAtT0tK5DMQiRrbdjaT2la5LN6
   5aBPfhURtnD1xHl1EVlpC2cl6nI6/G4gf/iEF7tlMOO3A66GkVGkS1kJn
   fCX3wV8DUdQP0Glt7tAGyav5eq1LsfN2b6wtQBQ+J4zHQidRnkiJBDx7k
   lGAQ9XTm4nNRzCCliRcRvMeijsQ0qwIZUNLIl4fQuHxOlQNxNgZAzQKsn
   5QbSpk/SrayxIwuWQT3FQ/Mnj5o4uecqa2ziB20iGjWdFjgHnqIoKPcga
   dI5QJn3mJv0eN/pFbrtSzIf7n0Yn9YkFLu/RZohBdKGihNO18iG71ivTz
   w==;
X-IronPort-AV: E=Sophos;i="5.56,371,1539619200"; 
   d="scan'208";a="101865070"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 19 Dec 2018 15:00:15 +0800
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 18 Dec 2018 22:41:27 -0800
Received: from c02vrauahv29.hgst.com ([10.113.196.25])
  by uls-op-cesaip02.wdc.com with ESMTP; 18 Dec 2018 23:00:12 -0800
From:   Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org,
        Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
Subject: [PATCH v2] sunrpc: Add xprt after nfs4_test_session_trunk()
Date:   Wed, 19 Dec 2018 12:29:57 +0530
Message-Id: <20181219065957.17791-1-santoshkumar.pradhan@wdc.com>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Multipathing: In case of NFSv3, rpc_clnt_test_and_add_xprt() adds
the xprt to xprt switch (i.e. xps) if rpc_call_null_helper() returns
success. But in case of NFSv4.1, it needs to do EXCHANGEID to verify
the path along with check for session trunking.

Add the xprt in nfs4_test_session_trunk() only when
nfs4_detect_session_trunking() returns success. Also release refcount
hold by rpc_clnt_setup_test_and_add_xprt().

Signed-off-by: Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
Tested-by: Suresh Jayaraman <suresh.jayaraman@wdc.com>
Reported-by: Aditya Agnihotri <aditya.agnihotri@wdc.com>
---
 fs/nfs/internal.h           | 6 +++---
 fs/nfs/nfs4_fs.h            | 3 ++-
 fs/nfs/nfs4proc.c           | 8 +++++---
 include/linux/sunrpc/clnt.h | 4 ++--
 net/sunrpc/clnt.c           | 3 +++
 5 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8357ff69962f..ecd02f9531ba 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -569,9 +569,9 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
-extern int nfs4_test_session_trunk(struct rpc_clnt *,
-				struct rpc_xprt *,
-				void *);
+extern void nfs4_test_session_trunk(struct rpc_clnt *clnt,
+				struct rpc_xprt *xprt,
+				void *data);
 
 static inline struct inode *nfs_igrab_and_active(struct inode *inode)
 {
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1b994b527518..240cbb9bafce 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -65,7 +65,8 @@ struct nfs4_minor_version_ops {
 			nfs4_stateid *, struct rpc_cred *);
 	struct nfs_seqid *
 		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
-	int	(*session_trunk)(struct rpc_clnt *, struct rpc_xprt *, void *);
+	void	(*session_trunk)(struct rpc_clnt *clnt,
+			struct rpc_xprt *xprt, void *data);
 	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 867457d6dfbe..20668276cb66 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8088,7 +8088,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
  * @xprt: the rpc_xprt to test
  * @data: call data for _nfs4_proc_exchange_id.
  */
-int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
+void nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
 			    void *data)
 {
 	struct nfs4_add_xprt_data *adata = (struct nfs4_add_xprt_data *)data;
@@ -8105,15 +8105,17 @@ int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
 	/* Test connection for session trunking. Async exchange_id call */
 	task = nfs4_run_exchange_id(adata->clp, adata->cred, sp4_how, xprt);
 	if (IS_ERR(task))
-		return PTR_ERR(task);
+		return;
 
 	status = task->tk_status;
 	if (status == 0)
 		status = nfs4_detect_session_trunking(adata->clp,
 				task->tk_msg.rpc_resp, xprt);
 
+	if (status == 0)
+		rpc_clnt_xprt_switch_add_xprt(clnt, xprt);
+
 	rpc_put_task(task);
-	return status;
 }
 EXPORT_SYMBOL_GPL(nfs4_test_session_trunk);
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 73d5c4a870fa..2564e42bce0e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -127,8 +127,8 @@ struct rpc_create_args {
 };
 
 struct rpc_add_xprt_test {
-	int (*add_xprt_test)(struct rpc_clnt *,
-		struct rpc_xprt *,
+	void (*add_xprt_test)(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
 		void *calldata);
 	void *data;
 };
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c6782aa47525..509886ed9ce5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2666,6 +2666,9 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 	/* rpc_xprt_switch and rpc_xprt are deferrenced by add_xprt_test() */
 	xtest->add_xprt_test(clnt, xprt, xtest->data);
 
+	xprt_put(xprt);
+	xprt_switch_put(xps);
+
 	/* so that rpc_clnt_add_xprt does not call rpc_xprt_switch_add_xprt */
 	return 1;
 out_err:
-- 
2.20.1

