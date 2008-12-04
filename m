From: andros@netapp.com
Subject: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Thu,  4 Dec 2008 12:09:10 -0500
Message-ID: <1228410550-17040-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22929 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849AbYLDRJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 12:09:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Callers of nfs_probe_fsinfo return ERR_PTR errors. NFSv4 errors need to be
mapped.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7547600..e12495c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -817,7 +817,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 
 out_error:
 	dprintk("nfs_probe_fsinfo: error = %d\n", -error);
-	return error;
+	return nfs4_map_errors(error);
 }
 
 /*
-- 
1.5.4.3

