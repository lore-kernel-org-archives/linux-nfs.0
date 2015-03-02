Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:49326 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755754AbbCBVqM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2015 16:46:12 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <Olga.Kornievskaia@netapp.com>
Subject: [PATCH] NFS: Fix stateid used for NFS v4 closes
Date: Mon, 2 Mar 2015 16:46:09 -0500
Message-ID: <1425332769-7047-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After 566fcec60 the client uses the "current stateid" from the
nfs4_state structure to close a file.  This could potentially contain a
delegation stateid, which is disallowed by the protocol and causes
servers to return NFS4ERR_BAD_STATEID.  This patch restores the
(correct) behavior of sending the open stateid to close a file.

Reported-by: Olga Kornievskaia <kolga@netapp.com>
Fixes: 566fcec60 (NFSv4: Fix an atomicity problem in CLOSE)
Signed-off-by: Anna Schumaker <Anna.Schumaker@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a211daf..7b409ff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2691,7 +2691,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
 	is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
 	is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
-	nfs4_stateid_copy(&calldata->arg.stateid, &state->stateid);
+	nfs4_stateid_copy(&calldata->arg.stateid, &state->open_stateid);
 	/* Calculate the change in open mode */
 	calldata->arg.fmode = 0;
 	if (state->n_rdwr == 0) {
-- 
2.3.1

