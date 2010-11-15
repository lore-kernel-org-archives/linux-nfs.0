Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933648Ab0KOUU5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 15:20:57 -0500
Received: from localhost.localdomain (trevor-goldfishers-macbook-pro.local [10.58.50.184] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAFKKclF026972
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 12:20:38 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] pnfs-submit: prevent bad CB_LAYOUTRECALL from crashing client
Date: Mon, 15 Nov 2010 15:20:33 -0500
Message-Id: <1289852433-18323-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

An incorrect recall type sent by the server should result in
the client returning BADXDR, not crashing the client.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    3 +++
 fs/nfs/callback_xdr.c  |    5 ++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b4c68e9..2274b6f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -139,6 +139,9 @@ _recall_matches_lget(struct pnfs_cb_lrecall_info *cb_info,
 		return (ino == cb_info->pcl_ino) &&
 			should_free_lseg(range, &cb_args->cbl_range);
 	default:
+		/* Should never hit here, as decode_layoutrecall_args()
+		 * will verify cb_info from server.
+		 */
 		BUG();
 	}
 }
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index a77877c..2e1a33b 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -246,7 +246,7 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	args->cbl_layoutchanged = ntohl(*p++);
 	args->cbl_recall_type = ntohl(*p++);
 
-	if (likely(args->cbl_recall_type == RETURN_FILE)) {
+	if (args->cbl_recall_type == RETURN_FILE) {
 		args->cbl_range.iomode = iomode;
 		status = decode_fh(xdr, &args->cbl_fh);
 		if (unlikely(status != 0))
@@ -270,6 +270,9 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 		}
 		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
+	} else if (args->cbl_recall_type != RETURN_ALL) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
 	}
 	dprintk("%s: ltype 0x%x iomode %d changed %d recall_type %d\n",
 		__func__,
-- 
1.7.2.1

