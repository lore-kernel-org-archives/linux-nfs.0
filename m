Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f195.google.com ([209.85.222.195]:33402 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726762AbeILBYv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 21:24:51 -0400
Received: by mail-qk1-f195.google.com with SMTP id z78-v6so17657278qka.0
        for <linux-nfs@vger.kernel.org>; Tue, 11 Sep 2018 13:23:53 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Reduce indentation of nfs4_recovery_handle_error()
Date: Tue, 11 Sep 2018 16:23:48 -0400
Message-Id: <20180911202348.23160-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180911202348.23160-1-Anna.Schumaker@Netapp.com>
References: <20180911202348.23160-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This is to match kernel coding style for switch statements.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4state.c | 64 +++++++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8a399dc17e19..816f526bbcb3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1800,38 +1800,38 @@ static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
 static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 {
 	switch (error) {
-		case 0:
-			break;
-		case -NFS4ERR_CB_PATH_DOWN:
-			nfs40_handle_cb_pathdown(clp);
-			break;
-		case -NFS4ERR_NO_GRACE:
-			nfs4_state_end_reclaim_reboot(clp);
-			break;
-		case -NFS4ERR_STALE_CLIENTID:
-			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-			nfs4_state_start_reclaim_reboot(clp);
-			break;
-		case -NFS4ERR_EXPIRED:
-			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-			nfs4_state_start_reclaim_nograce(clp);
-			break;
-		case -NFS4ERR_BADSESSION:
-		case -NFS4ERR_BADSLOT:
-		case -NFS4ERR_BAD_HIGH_SLOT:
-		case -NFS4ERR_DEADSESSION:
-		case -NFS4ERR_SEQ_FALSE_RETRY:
-		case -NFS4ERR_SEQ_MISORDERED:
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-			/* Zero session reset errors */
-			break;
-		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
-			set_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
-			break;
-		default:
-			dprintk("%s: failed to handle error %d for server %s\n",
-					__func__, error, clp->cl_hostname);
-			return error;
+	case 0:
+		break;
+	case -NFS4ERR_CB_PATH_DOWN:
+		nfs40_handle_cb_pathdown(clp);
+		break;
+	case -NFS4ERR_NO_GRACE:
+		nfs4_state_end_reclaim_reboot(clp);
+		break;
+	case -NFS4ERR_STALE_CLIENTID:
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		nfs4_state_start_reclaim_reboot(clp);
+		break;
+	case -NFS4ERR_EXPIRED:
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		nfs4_state_start_reclaim_nograce(clp);
+		break;
+	case -NFS4ERR_BADSESSION:
+	case -NFS4ERR_BADSLOT:
+	case -NFS4ERR_BAD_HIGH_SLOT:
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_SEQ_FALSE_RETRY:
+	case -NFS4ERR_SEQ_MISORDERED:
+		set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+		/* Zero session reset errors */
+		break;
+	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		set_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
+		break;
+	default:
+		dprintk("%s: failed to handle error %d for server %s\n",
+				__func__, error, clp->cl_hostname);
+		return error;
 	}
 	dprintk("%s: handled error %d for server %s\n", __func__, error,
 			clp->cl_hostname);
-- 
2.18.0
