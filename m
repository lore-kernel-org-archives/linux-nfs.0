Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35915 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbcFTQbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:31:37 -0400
Subject: [PATCH v3 24/25] NFS: Don't drop CB requests with invalid principals
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:11:52 -0400
Message-ID: <20160620161152.10809.29988.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before commit 778be232a207 ("NFS do not find client in NFSv4
pg_authenticate"), the Linux callback server replied with
RPC_AUTH_ERROR / RPC_AUTH_BADCRED, instead of dropping the CB
request. Let's restore that behavior so the server has a chance to
do something useful about it, and provide a warning that helps
admins correct the problem.

Fixes: 778be232a207 ("NFS do not find client in NFSv4 ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/callback_xdr.c |    6 +++++-
 net/sunrpc/svc.c      |    5 +++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index d81f96a..656f68f 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -925,7 +925,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	if (hdr_arg.minorversion == 0) {
 		cps.clp = nfs4_find_client_ident(SVC_NET(rqstp), hdr_arg.cb_ident);
 		if (!cps.clp || !check_gss_callback_principal(cps.clp, rqstp))
-			return rpc_drop_reply;
+			goto out_invalidcred;
 	}
 
 	cps.minorversion = hdr_arg.minorversion;
@@ -953,6 +953,10 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	nfs_put_client(cps.clp);
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
+
+out_invalidcred:
+	pr_warn_ratelimited("NFS: NFSv4 callback contains invalid cred\n");
+	return rpc_autherr_badcred;
 }
 
 /*
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 87290a5..c5b0cb4 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1194,6 +1194,11 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
 		}
+		if (*statp == rpc_autherr_badcred) {
+			if (procp->pc_release)
+				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+			goto err_bad_auth;
+		}
 		if (*statp == rpc_success &&
 		    (xdr = procp->pc_encode) &&
 		    !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {

