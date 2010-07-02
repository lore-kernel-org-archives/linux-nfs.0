From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/22] NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s
	argument
Date: Fri, 02 Jul 2010 13:19:34 -0400
Message-ID: <20100702171934.8761.51148.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:51345 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758874Ab0GBRTi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:19:38 -0400
Received: by pwi5 with SMTP id 5so707967pwi.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:19:38 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To distinguish more clearly between the on-the-wire NFSERR_ value and
our local errno values, use the proper type for the argument of
nfs_stat_to_errno().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    2 +-
 fs/nfs/nfs2xdr.c  |   16 +++++++++-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 238bb8a..f516424 100644
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
index 557286e..068e38a 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -870,20 +870,22 @@ static struct {
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
 

