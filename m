Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923Ab1CISOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 13:14:02 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH Cthon2011 fixes 1/3] NFSv4.1: Retry CREATE_SESSION on NFS4ERR_DELAY
Date: Wed,  9 Mar 2011 13:13:44 -0500
Message-Id: <1299694426-5620-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Fix bug where we currently retry the EXCHANGEID call again, eventhough
we already have a valid clientid.  Instead, delay and retry the CREATE_SESSION
call.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4proc.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 36b3c44..8edb1fc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5083,10 +5083,20 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 	int status;
 	unsigned *ptr;
 	struct nfs4_session *session = clp->cl_session;
+	long timeout = 0;
+	int err;
 
 	dprintk("--> %s clp=%p session=%p\n", __func__, clp, session);
 
-	status = _nfs4_proc_create_session(clp);
+	do {
+		status = _nfs4_proc_create_session(clp);
+		if (status == -NFS4ERR_DELAY) {
+			err = nfs4_delay(clp->cl_rpcclient, &timeout);
+			if (err)
+				status = err;
+		}
+	} while (status == -NFS4ERR_DELAY);
+
 	if (status)
 		goto out;
 
-- 
1.6.6

