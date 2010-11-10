Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:34333 "HELO
	exprod5og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755768Ab0KJNl7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 08:41:59 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-submit: fixups for nfsv4.1 callbacks
Date: Wed, 10 Nov 2010 15:41:54 +0200
Message-Id: <1289396514-23034-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CDAA02D.20204@panasas.com>
References: <4CDAA02D.20204@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   53 +++++++++++++++++++++--------------------------
 1 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6e21add..3a19cec 100644
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
@@ -420,11 +418,7 @@ __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 		res = NFS4ERR_OP_NOT_IN_SESSION;
 		goto out;
 	}
-	/* the callback must come from the MDS personality */
-	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
-		res = NFS4ERR_INVAL;
-		goto out;
-	}
+
 	res = do_callback_layoutrecall(clp, args);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, res);
@@ -623,6 +617,12 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
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
@@ -702,11 +702,6 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
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
1.7.2.3

