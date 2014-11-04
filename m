Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36527 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaKDXge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 18:36:34 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn18so389402igb.9
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2014 15:36:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: Ensure that we call FREE_STATEID when NFSv4.x stateids are revoked
Date: Tue,  4 Nov 2014 17:36:27 -0600
Message-Id: <1415144188-17193-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415144188-17193-1-git-send-email-trond.myklebust@primarydata.com>
References: <1415144188-17193-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.x (x>0) requires us to call TEST_STATEID+FREE_STATEID if a stateid is
revoked. We will currently fail to do this if the stateid is a delegation.

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d8f352d8c75f..6cf49af3092d 100644
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
@@ -4849,9 +4844,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
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

