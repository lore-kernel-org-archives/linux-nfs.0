Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:39593 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaCDRbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 12:31:20 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/4] NFSv4 _nfs4_do_setattr use zero stateid on lost lock
Date: Tue, 4 Mar 2014 12:31:08 -0500
Message-ID: <1393954269-3974-4-git-send-email-andros@netapp.com>
In-Reply-To: <1393954269-3974-1-git-send-email-andros@netapp.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use the zero stateid if nfs4_select_rw_stateid indicates a lost lock (-EIO)

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index de8e7f5..efe940c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2458,18 +2458,22 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
 	fmode = truncate ? FMODE_WRITE : FMODE_READ;
 
-	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
-		/* Use that stateid */
-	} else if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
+	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode))
+		/* Use delegation stateid */
+		goto do_call;
+	if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
 		struct nfs_lockowner lockowner = {
 			.l_owner = current->files,
 			.l_pid = current->tgid,
 		};
-		nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
-				&lockowner);
-	} else
-		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
+		/* Use zero stateid if lock is lost (-EIO fall through) */
+		if (nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
+						&lockowner) != -EIO)
+			goto do_call;
+	}
+	nfs4_stateid_copy(&arg.stateid, &zero_stateid);
 
+do_call:
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
-- 
1.8.3.1

