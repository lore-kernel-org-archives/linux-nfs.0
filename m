Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:6350 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbcFJShW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jun 2016 14:37:22 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Fix SETATTR to always retry on bad_stateid-type error
Date: Fri, 10 Jun 2016 14:37:18 -0400
Message-ID: <1465583838-19029-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's insufficient to only retry SETATTR if we have a delegation
and got a bad_stateid-type error. A DELEGRETURN could be sent
after SETATTR is sent and before the reply comes back thus
no delegation would be found and SETATTR not retried with
zero stateid and instead fail the operation to EIO.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c3..c40d895 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2723,7 +2723,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		.state = state,
 		.inode = inode,
 	};
-	int err;
+	int err, save_err;
 	do {
 		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
 		switch (err) {
@@ -2742,7 +2742,14 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 				goto out;
 			}
 		}
+		save_err = err;
 		err = nfs4_handle_exception(server, err, &exception);
+		switch (save_err) {
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_BAD_STATEID:
+			exception.retry = 1;
+		}
 	} while (exception.retry);
 out:
 	return err;
-- 
1.8.3.1

