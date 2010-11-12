Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943Ab0KLItY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:24 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fH025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:12 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/22] SQUASHME: pnfs-submit: fixups for nfsv4.1 callbacks
Date: Fri, 12 Nov 2010 03:48:29 -0500
Message-Id: <1289551724-18575-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   52 +++++++++++++++++++++--------------------------
 1 files changed, 23 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 53a85648..2e62155 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -21,6 +21,12 @@
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 #endif
 
+static struct nfs_client *
+find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
+{
+	return cps->session ? cps->session->clp : nfs_find_client(addr, 4);
+}
+
 __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 			     struct cb_getattrres *res,
 			     struct cb_process_state *cps)
@@ -32,13 +38,9 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	if (cps->session) { /* set in cb_sequence */
-		clp = cps->session->clp;
-	} else {
-		clp = nfs_find_client(args->addr, 4);
-		if (clp == NULL)
-			goto out;
-	}
+	clp = find_client_from_cps(cps, args->addr);
+	if (clp == NULL)
+		goto out;
 
 	dprintk("NFS: GETATTR callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
@@ -81,13 +83,9 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	if (cps->session) { /* set in cb_sequence */
-		clp = cps->session->clp;
-	} else {
-		clp = nfs_find_client(args->addr, 4);
-		if (clp == NULL)
-			goto out;
-	}
+	clp = find_client_from_cps(cps, args->addr);
+	if (clp == NULL)
+		goto out;
 
 	dprintk("NFS: RECALL callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
@@ -111,11 +109,11 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 			}
 			iput(inode);
 		}
-		if (!cps->session) {
-			clp = nfs_find_client_next(prev);
-			nfs_put_client(prev);
-		}
-	} while (!cps->session && clp != NULL);
+		if (cps->session)
+			break;
+		clp = nfs_find_client_next(prev);
+		nfs_put_client(prev);
+	} while (clp != NULL);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
@@ -376,11 +374,6 @@ __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 	else
 		goto out;
 
-	/* the callback must come from the MDS personality */
-	res = cpu_to_be32(NFS4ERR_NOTSUPP);
-	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
-		goto out;
-
 	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
 	/*
 	 * In the _ALL or _FSID case, we need the inode to get
@@ -579,6 +572,12 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	if (status)
 		goto out_putclient;
 
+	/* The callback must come from the MDS personality */
+	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
+		status = htonl(NFS4ERR_INVAL);
+		goto out_putclient;
+	}
+
 	/*
 	 * Check for pending referring calls.  If a match is found, a
 	 * related callback was received before the response to the original
@@ -658,11 +657,6 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 	dprintk("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
-	/* the callback must come from the MDS personality */
-	status = cpu_to_be32(NFS4ERR_NOTSUPP);
-	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
-		goto out;
-
 	status = cpu_to_be32(NFS4ERR_INVAL);
 	if (!validate_bitmap_values((const unsigned long *)
 				    &args->craa_type_mask))
-- 
1.7.2.1

