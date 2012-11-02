Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27780 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757073Ab2KBWBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Nov 2012 18:01:01 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFS4: nfs4_opendata_access should return errno
Date: Fri,  2 Nov 2012 18:00:56 -0400
Message-Id: <1351893656-5643-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return errno - not an NFS4ERR_. This worked because NFS4ERR_ACCESS == EACCES.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 45215e3..a75df39 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1719,7 +1719,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 
 	/* even though OPEN succeeded, access is denied. Close the file */
 	nfs4_close_state(state, fmode);
-	return -NFS4ERR_ACCESS;
+	return -EACCES;
 }
 
 /*
-- 
1.7.9.6 (Apple Git-31.1)

