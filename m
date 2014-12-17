Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:15030 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428AbaLQSrc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 13:47:32 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFS: try RPC_AUTH_GSS_KRB5 after RPC_AUTH_GSS_KRB5I for cl_rpcclient
Date: Wed, 17 Dec 2014 13:47:23 -0500
Message-ID: <1418842043-15074-2-git-send-email-andros@netapp.com>
In-Reply-To: <1418842043-15074-1-git-send-email-andros@netapp.com>
References: <1418842043-15074-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Some servers implement KRB5 but not KRB5I. With out this patch, said servers
will use AUTH_UNIX for state creation, even when exporting a volume with krb5.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5194933..a56ad3f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2063,6 +2063,21 @@ again:
 			nfs4_root_machine_cred(clp);
 			goto again;
 		}
+		if (clnt->cl_auth->au_flavor == RPC_AUTH_GSS_KRB5I) {
+			clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_GSS_KRB5);
+			if (IS_ERR(clnt)) {
+				status = PTR_ERR(clnt);
+				break;
+			}
+			/* Note: this is safe because we haven't yet marked the
+			 * client as ready, so we are the only user of
+			 * clp->cl_rpcclient
+			 */
+			clnt = xchg(&clp->cl_rpcclient, clnt);
+			rpc_shutdown_client(clnt);
+			clnt = clp->cl_rpcclient;
+			goto again;
+		}
 		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX)
 			break;
 	case -NFS4ERR_CLID_INUSE:
-- 
1.8.3.1

