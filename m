Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35287 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbbFPP3V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 11:29:21 -0400
Received: by iesa3 with SMTP id a3so15267373ies.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 08:29:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix stateid recovery on revoked delegations
Date: Tue, 16 Jun 2015 11:29:14 -0400
Message-Id: <1434468554-7557-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we fix the non-NULL stateid case as well.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6bcdecd61125..0fc1b0cdda98 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -356,6 +356,9 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 		case 0:
 			return 0;
 		case -NFS4ERR_OPENMODE:
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_BAD_STATEID:
 			if (inode && nfs4_have_delegation(inode, FMODE_READ)) {
 				nfs4_inode_return_delegation(inode);
 				exception->retry = 1;
@@ -367,21 +370,6 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 			if (ret < 0)
 				break;
 			goto wait_on_recovery;
-		case -NFS4ERR_DELEG_REVOKED:
-		case -NFS4ERR_ADMIN_REVOKED:
-		case -NFS4ERR_BAD_STATEID:
-			if (state == NULL) {
-				if (inode && nfs4_have_delegation(inode,
-						FMODE_READ)) {
-					nfs4_inode_return_delegation(inode);
-					exception->retry = 1;
-				}
-				break;
-			}
-			ret = nfs4_schedule_stateid_recovery(server, state);
-			if (ret < 0)
-				break;
-			goto wait_on_recovery;
 		case -NFS4ERR_EXPIRED:
 			if (state != NULL) {
 				ret = nfs4_schedule_stateid_recovery(server, state);
-- 
2.4.3

