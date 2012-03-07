Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25812 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965218Ab2CGWk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 17:40:57 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Return the delegation if the server returns NFS4ERR_OPENMODE
Date: Wed,  7 Mar 2012 17:40:49 -0500
Message-Id: <1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
 <1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com>
 <1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a setattr() fails because of an NFS4ERR_OPENMODE error, it is
probably due to us holding a read delegation. Ensure that the
recovery routines return that delegation in this case.

Reported-by: Miklos Szeredi <miklos@szeredi.hu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |   13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5c9b20b..8ccaf24 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -193,6 +193,7 @@ struct nfs4_exception {
 	long timeout;
 	int retry;
 	struct nfs4_state *state;
+	struct inode *inode;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3d26bab..bfcaa03 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -259,18 +259,28 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state *state = exception->state;
+	struct inode *inode = exception->inode;
 	int ret = errorcode;
 
 	exception->retry = 0;
 	switch(errorcode) {
 		case 0:
 			return 0;
+		case -NFS4ERR_OPENMODE:
+			if (nfs_have_delegation(inode, FMODE_READ)) {
+				nfs_inode_return_delegation(inode);
+				exception->retry = 1;
+				return 0;
+			}
+			if (state == NULL)
+				break;
+			nfs4_schedule_stateid_recovery(server, state);
+			goto wait_on_recovery;
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
 			if (state != NULL)
 				nfs_remove_bad_delegation(state->inode);
-		case -NFS4ERR_OPENMODE:
 			if (state == NULL)
 				break;
 			nfs4_schedule_stateid_recovery(server, state);
@@ -1908,6 +1918,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = {
 		.state = state,
+		.inode = inode,
 	};
 	int err;
 	do {
-- 
1.7.7.6

