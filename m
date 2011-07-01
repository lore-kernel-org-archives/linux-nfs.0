Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3478 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932178Ab1GATnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 15:43:53 -0400
From: Joe Perches <joe@perches.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 11/12] sunrpc: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:12 -0700
Message-Id: <c0a6d5adc9030bc97bf905b92a4406bdcd638810.1309549244.git.joe@perches.com>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Make the case labels the same indent as the switch.

git diff -w shows 80 column line reflowing.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/auth_gss.c |   46 +++++++++++++++++++--------------------
 net/sunrpc/clnt.c              |   25 ++++++++++-----------
 net/sunrpc/rpc_pipe.c          |   14 ++++++------
 3 files changed, 41 insertions(+), 44 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 339ba64..16177d2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1421,18 +1421,16 @@ gss_wrap_req(struct rpc_task *task,
 		goto out;
 	}
 	switch (gss_cred->gc_service) {
-		case RPC_GSS_SVC_NONE:
-			gss_wrap_req_encode(encode, rqstp, p, obj);
-			status = 0;
-			break;
-		case RPC_GSS_SVC_INTEGRITY:
-			status = gss_wrap_req_integ(cred, ctx, encode,
-								rqstp, p, obj);
-			break;
-		case RPC_GSS_SVC_PRIVACY:
-			status = gss_wrap_req_priv(cred, ctx, encode,
-					rqstp, p, obj);
-			break;
+	case RPC_GSS_SVC_NONE:
+		gss_wrap_req_encode(encode, rqstp, p, obj);
+		status = 0;
+		break;
+	case RPC_GSS_SVC_INTEGRITY:
+		status = gss_wrap_req_integ(cred, ctx, encode, rqstp, p, obj);
+		break;
+	case RPC_GSS_SVC_PRIVACY:
+		status = gss_wrap_req_priv(cred, ctx, encode, rqstp, p, obj);
+		break;
 	}
 out:
 	gss_put_ctx(ctx);
@@ -1531,18 +1529,18 @@ gss_unwrap_resp(struct rpc_task *task,
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA)
 		goto out_decode;
 	switch (gss_cred->gc_service) {
-		case RPC_GSS_SVC_NONE:
-			break;
-		case RPC_GSS_SVC_INTEGRITY:
-			status = gss_unwrap_resp_integ(cred, ctx, rqstp, &p);
-			if (status)
-				goto out;
-			break;
-		case RPC_GSS_SVC_PRIVACY:
-			status = gss_unwrap_resp_priv(cred, ctx, rqstp, &p);
-			if (status)
-				goto out;
-			break;
+	case RPC_GSS_SVC_NONE:
+		break;
+	case RPC_GSS_SVC_INTEGRITY:
+		status = gss_unwrap_resp_integ(cred, ctx, rqstp, &p);
+		if (status)
+			goto out;
+		break;
+	case RPC_GSS_SVC_PRIVACY:
+		status = gss_unwrap_resp_priv(cred, ctx, rqstp, &p);
+		if (status)
+			goto out;
+		break;
 	}
 	/* take into account extra slack for integrity and privacy cases: */
 	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b84d739..2c1ffb9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1663,19 +1663,18 @@ rpc_verify_header(struct rpc_task *task)
 		if (--len < 0)
 			goto out_overflow;
 		switch ((n = ntohl(*p++))) {
-			case RPC_AUTH_ERROR:
-				break;
-			case RPC_MISMATCH:
-				dprintk("RPC: %5u %s: RPC call version "
-						"mismatch!\n",
-						task->tk_pid, __func__);
-				error = -EPROTONOSUPPORT;
-				goto out_err;
-			default:
-				dprintk("RPC: %5u %s: RPC call rejected, "
-						"unknown error: %x\n",
-						task->tk_pid, __func__, n);
-				goto out_eio;
+		case RPC_AUTH_ERROR:
+			break;
+		case RPC_MISMATCH:
+			dprintk("RPC: %5u %s: RPC call version mismatch!\n",
+				task->tk_pid, __func__);
+			error = -EPROTONOSUPPORT;
+			goto out_err;
+		default:
+			dprintk("RPC: %5u %s: RPC call rejected, "
+				"unknown error: %x\n",
+				task->tk_pid, __func__, n);
+			goto out_eio;
 		}
 		if (--len < 0)
 			goto out_overflow;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 72bc536..b181e34 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -456,13 +456,13 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
 	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-	switch(mode & S_IFMT) {
-		case S_IFDIR:
-			inode->i_fop = &simple_dir_operations;
-			inode->i_op = &simple_dir_inode_operations;
-			inc_nlink(inode);
-		default:
-			break;
+	switch (mode & S_IFMT) {
+	case S_IFDIR:
+		inode->i_fop = &simple_dir_operations;
+		inode->i_op = &simple_dir_inode_operations;
+		inc_nlink(inode);
+	default:
+		break;
 	}
 	return inode;
 }
-- 
1.7.6.rc1

