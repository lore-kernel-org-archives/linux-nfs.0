Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39575 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792Ab3D2PPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Apr 2013 11:15:38 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Servers should only check SETATTR stateid open mode on size change
Date: Mon, 29 Apr 2013 11:15:33 -0400
Message-Id: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 and NFSv4.1 specs are both clear that the server should only check
stateid open mode if a SETATTR specifies the size attribute. If the
open mode is not one that allows writing, then it returns NFS4ERR_OPENMODE.

In the case where the SETATTR is not changing the size, the client will
still pass it the delegation stateid to ensure that the server does not
recall that delegation. In that case, the server should _ignore_ the
delegation open mode, and simply apply standard permission checks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3bc847c..982b452 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2142,20 +2142,25 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		.rpc_cred	= cred,
         };
 	unsigned long timestamp = jiffies;
+	fmode_t fmode;
+	bool truncate;
 	int status;
 
 	nfs_fattr_init(fattr);
 
-	if (state != NULL && nfs4_valid_open_stateid(state)) {
+	/* Servers should only apply open mode checks for file size changes */
+	truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
+	fmode = truncate ? FMODE_WRITE : FMODE_READ;
+
+	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
+		/* Use that stateid */
+	} else if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
 		struct nfs_lockowner lockowner = {
 			.l_owner = current->files,
 			.l_pid = current->tgid,
 		};
 		nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
 				&lockowner);
-	} else if (nfs4_copy_delegation_stateid(&arg.stateid, inode,
-				FMODE_WRITE)) {
-		/* Use that stateid */
 	} else
 		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
 
-- 
1.8.1.4

