Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:19893 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbcBEVIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2016 16:08:52 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC Version 1 6/6] NFS schedule bind_conn_to_session for new NFSv4.1 transport
Date: Fri, 5 Feb 2016 16:08:38 -0500
Message-ID: <1454706518-4641-7-git-send-email-andros@netapp.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Complete session trunking with the BIND_CONN_TO_SESSION call.
NFS cleanup after session trunking transport added

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 6736805..b0423f7 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -423,8 +423,17 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				.servername = clp->cl_hostname,
 			};
 			/* Add this address as an alias */
-			rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
-					rpc_clnt_test_and_add_xprt, NULL);
+			error = rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
+					     rpc_clnt_test_and_add_xprt, NULL);
+			if (!error) {
+				nfs4_schedule_session_recovery(old->cl_session,
+					-NFS4ERR_CONN_NOT_BOUND_TO_SESSION);
+
+				/** Cancel the 2nd mount */
+				pr_info("NFS:  Session trunk. CANCEL MOUNT\n");
+				error = -EINVAL;
+				goto error;
+			}
 		}
 		clp->cl_preserve_clid = true;
 	}
-- 
1.8.3.1

