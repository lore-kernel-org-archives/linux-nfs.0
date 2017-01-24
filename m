Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750715AbdAXQeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 11:34:22 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.0: always send mode in SETATTR after EXCLUSIVE4
Date: Tue, 24 Jan 2017 11:34:20 -0500
Message-Id: <029c7e4d21831aee79a6016146156ae2a89b68ca.1485275546.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some nfsv4.0 servers may return a mode for the verifier following an open
with EXCLUSIVE4 createmode, but this does not mean the client should skip
setting the mode in the following SETATTR.  It should only do that for
EXCLUSIVE4_1 or UNGAURDED createmode.

Fixes: 5334c5bdac92 ("NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ecc151697fd4..4cbe5867dde8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2700,7 +2700,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
 		sattr->ia_valid |= ATTR_MTIME;
 
 	/* Except MODE, it seems harmless of setting twice. */
-	if ((attrset[1] & FATTR4_WORD1_MODE))
+	if (opendata->o_arg.createmode != NFS4_CREATE_EXCLUSIVE &&
+		attrset[1] & FATTR4_WORD1_MODE)
 		sattr->ia_valid &= ~ATTR_MODE;
 
 	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
-- 
2.9.3

