Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56478 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965249Ab2J3UQI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 16:16:08 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Wait for session recovery to finish before returning
Date: Tue, 30 Oct 2012 16:06:35 -0400
Message-Id: <1351627595-6462-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Currently, we will schedule session recovery and then return to the
caller of nfs4_handle_exception.  This works for most cases, but causes
a hang on the following test case:

	Client				Server
	------				------
	Open file over NFS v4.1
	Write to file
					Expire client
	Try to lock file

The server will return NFS4ERR_BADSESSION, prompting the client to
schedule recovery.  However, the client will continue placing lock
attempts and the open recovery never seems to be scheduled.  The
simplest solution is to wait for session recovery to run before retrying
the lock.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8b04d14..70e0c47 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -338,8 +338,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			dprintk("%s ERROR: %d Reset session\n", __func__,
 				errorcode);
 			nfs4_schedule_session_recovery(clp->cl_session, errorcode);
-			exception->retry = 1;
-			break;
+			goto wait_on_recovery;
 #endif /* defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
-- 
1.8.0

