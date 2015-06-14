Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbbFNVfG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Jun 2015 17:35:06 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id DFAF7BACB7
	for <linux-nfs@vger.kernel.org>; Sun, 14 Jun 2015 21:35:05 +0000 (UTC)
Received: from bcodding-csb.redhat.com (vpn-54-165.rdu2.redhat.com [10.10.54.165])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5ELZ5Fm006610
	for <linux-nfs@vger.kernel.org>; Sun, 14 Jun 2015 17:35:05 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Handle exceptions for SEEK
Date: Sun, 14 Jun 2015 17:35:05 -0400
Message-Id: <e666c4a3bb9da72bffbf5ecb33daba4a25d78a5a.1434317690.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't pass along NFS4ERR_* exceptions to VFS and do recovery if needed.
These exceptions might look like offsets (even though they are negative) and
applications that used the previous behavior of seeking to eof for
SEEK_HOLE, and current offset for SEEK_DATA may be caught off-guard if the server
responds with transient errors such as NFS4ERR_GRACE.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs42proc.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3a9e752..9c3c9d2 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -146,20 +146,27 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 		.rpc_resp = &res,
 	};
 	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_exception exception = { };
 	int status;
 
 	if (!nfs_server_capable(inode, NFS_CAP_SEEK))
 		return -ENOTSUPP;
 
-	status = nfs42_set_rw_stateid(&args.sa_stateid, filep, FMODE_READ);
-	if (status)
-		return status;
-
 	nfs_wb_all(inode);
-	status = nfs4_call_sync(server->client, server, &msg,
-				&args.seq_args, &res.seq_res, 0);
-	if (status == -ENOTSUPP)
-		server->caps &= ~NFS_CAP_SEEK;
+	do {
+		status = nfs42_set_rw_stateid(&args.sa_stateid, filep, FMODE_READ);
+		if (status)
+			return status;
+
+		status = nfs4_call_sync(server->client, server, &msg,
+					&args.seq_args, &res.seq_res, 0);
+		if (status == -ENOTSUPP) {
+			server->caps &= ~NFS_CAP_SEEK;
+			return status;
+		}
+		status = nfs4_handle_exception(server, status, &exception);
+	} while (exception.retry);
+
 	if (status)
 		return status;
 
-- 
1.7.1

