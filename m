Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755325Ab2C0WgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Mar 2012 18:36:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Minor cleanups for nfs4_handle_exception and nfs4_async_handle_error
Date: Tue, 27 Mar 2012 18:35:44 -0400
Message-Id: <1332887744-4222-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1332887744-4222-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
 <1332887744-4222-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1933e67..f82bde0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -270,7 +270,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case 0:
 			return 0;
 		case -NFS4ERR_OPENMODE:
-			if (nfs_have_delegation(inode, FMODE_READ)) {
+			if (inode && nfs_have_delegation(inode, FMODE_READ)) {
 				nfs_inode_return_delegation(inode);
 				exception->retry = 1;
 				return 0;
@@ -282,10 +282,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (state != NULL)
-				nfs_remove_bad_delegation(state->inode);
 			if (state == NULL)
 				break;
+			nfs_remove_bad_delegation(state->inode);
 			nfs4_schedule_stateid_recovery(server, state);
 			goto wait_on_recovery;
 		case -NFS4ERR_EXPIRED:
@@ -3825,8 +3824,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (state != NULL)
-				nfs_remove_bad_delegation(state->inode);
+			if (state == NULL)
+				break;
+			nfs_remove_bad_delegation(state->inode);
 		case -NFS4ERR_OPENMODE:
 			if (state == NULL)
 				break;
-- 
1.7.7.6

