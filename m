Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39575 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678Ab3D2PPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Apr 2013 11:15:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Warn once about servers that incorrectly apply open mode to setattr
Date: Mon, 29 Apr 2013 11:15:34 -0400
Message-Id: <1367248534-33387-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Debugging aid to help identify servers that incorrectly apply open mode
checks to setattr requests that are not changing the file size.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 982b452..9da4bd5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2184,6 +2184,13 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
+			if (!(sattr->ia_valid & ATTR_SIZE)) {
+				pr_warn_once("NFSv4: server %s is incorrectly "
+						"applying open mode checks to "
+						"a SETATTR that is not "
+						"changing file size.\n",
+						server->nfs_client->cl_hostname);
+			}
 			if (state && !(state->state & FMODE_WRITE)) {
 				err = -EBADF;
 				if (sattr->ia_valid & ATTR_OPEN)
-- 
1.8.1.4

