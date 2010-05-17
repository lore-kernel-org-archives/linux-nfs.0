From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/24] NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()
Date: Sun, 16 May 2010 22:47:50 -0400
Message-ID: <20100517024750.20258.61920.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab0EQCrx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:47:53 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:47:52 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use the proper type for the argument of nfs_stat_to_errno().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    2 +-
 fs/nfs/nfs2xdr.c  |   16 +++++++++-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 07587e8..905df35 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -179,7 +179,7 @@ extern int __init nfs_init_directcache(void);
 extern void nfs_destroy_directcache(void);
 
 /* nfs2xdr.c */
-extern int nfs_stat_to_errno(int);
+extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
 extern __be32 * nfs_decode_dirent(__be32 *, struct nfs_entry *, int);
 
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index eb86e55..f0eab7e 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1015,20 +1015,22 @@ static struct {
 	{ -1,			-EIO		}
 };
 
-/*
- * Convert an NFS error code to a local one.
- * This one is used jointly by NFSv2 and NFSv3.
+/**
+ * nfs_stat_to_errno - convert an NFS status code to a local errno
+ * @status: NFS status code to convert
+ *
+ * Returns a local errno value, or -EIO if the NFS status code is
+ * not recognized.  This function is used jointly by NFSv2 and NFSv3.
  */
-int
-nfs_stat_to_errno(int stat)
+int nfs_stat_to_errno(enum nfs_stat status)
 {
 	int i;
 
 	for (i = 0; nfs_errtbl[i].stat != -1; i++) {
-		if (nfs_errtbl[i].stat == stat)
+		if (nfs_errtbl[i].stat == (int)status)
 			return nfs_errtbl[i].errno;
 	}
-	dprintk("nfs_stat_to_errno: bad nfs status return value: %d\n", stat);
+	dprintk("NFS: Unrecognized nfs status value: %u\n", status);
 	return nfs_errtbl[i].errno;
 }
 

