Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:45947 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaCEOHm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 09:07:42 -0500
Received: by mail-ie0-f180.google.com with SMTP id as1so1008039iec.25
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 06:07:42 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/4] NFSv4: Fail the truncate() if the lock/open stateid is invalid
Date: Wed,  5 Mar 2014 09:07:32 -0500
Message-Id: <1394028452-15956-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1394028452-15956-4-git-send-email-trond.myklebust@primarydata.com>
References: <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
 <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
 <1394028452-15956-2-git-send-email-trond.myklebust@primarydata.com>
 <1394028452-15956-3-git-send-email-trond.myklebust@primarydata.com>
 <1394028452-15956-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the open stateid could not be recovered, or the file locks were lost,
then we should fail the truncate() operation altogether.

Reported-by: Andy Adamson <andros@netapp.com>
Link: http://lkml.kernel.org/r/1393954269-3974-1-git-send-email-andros@netapp.com
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4778c55d0336..bc60a0f81019 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2398,13 +2398,16 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 
 	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
 		/* Use that stateid */
-	} else if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
+	} else if (truncate && state != NULL) {
 		struct nfs_lockowner lockowner = {
 			.l_owner = current->files,
 			.l_pid = current->tgid,
 		};
-		nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
-				&lockowner);
+		if (!nfs4_valid_open_stateid(state))
+			return -EBADF;
+		if (nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
+				&lockowner) < 0)
+			return -EBADF;
 	} else
 		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
 
-- 
1.8.5.3

