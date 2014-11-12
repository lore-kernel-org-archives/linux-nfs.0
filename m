Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:37211 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaKLWcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 17:32:22 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so14618493ieb.32
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 14:32:21 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] NFSv4: Ensure that we call FREE_STATEID when NFSv4.x stateids are revoked
Date: Wed, 12 Nov 2014 17:31:53 -0500
Message-Id: <1415831514-47005-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415831514-47005-4-git-send-email-trond.myklebust@primarydata.com>
References: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-2-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-3-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.x (x>0) requires us to call TEST_STATEID+FREE_STATEID if a stateid is
revoked. We will currently fail to do this if the stateid is a delegation.

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 3 ---
 fs/nfs/nfs4proc.c              | 8 --------
 2 files changed, 11 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 46fab1cb455a..7afb52f6a25a 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -145,9 +145,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -NFS4ERR_DELEG_REVOKED:
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_BAD_STATEID:
-		if (state == NULL)
-			break;
-		nfs_remove_bad_delegation(state->inode);
 	case -NFS4ERR_OPENMODE:
 		if (state == NULL)
 			break;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4b7166f4e1cf..69dc20a743f9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -370,11 +370,6 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (inode != NULL && nfs4_have_delegation(inode, FMODE_READ)) {
-				nfs_remove_bad_delegation(inode);
-				exception->retry = 1;
-				break;
-			}
 			if (state == NULL)
 				break;
 			ret = nfs4_schedule_stateid_recovery(server, state);
@@ -4844,9 +4839,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (state == NULL)
-				break;
-			nfs_remove_bad_delegation(state->inode);
 		case -NFS4ERR_OPENMODE:
 			if (state == NULL)
 				break;
-- 
1.9.3

