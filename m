Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:64762 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757415Ab0LNOzE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:55:04 -0500
Received: by mail-gw0-f42.google.com with SMTP id 20so538996gwb.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:55:03 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/31] NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s
	argument
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:55:00 -0500
Message-ID: <20101214145500.2293.93090.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

To distinguish more clearly between the on-the-wire NFSERR_ value and
our local errno values, use the proper type for the argument of
nfs_stat_to_errno().

Add a documenting comment appropriate for a global function shared
outside this source file.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/internal.h |    2 +-
 fs/nfs/nfs2xdr.c  |   18 ++++++++++--------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b8db6f9..5532acb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -185,7 +185,7 @@ extern int __init nfs_init_directcache(void);
 extern void nfs_destroy_directcache(void);
 
 /* nfs2xdr.c */
-extern int nfs_stat_to_errno(int);
+extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
 extern __be32 *nfs_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index c799773..2da9824 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -804,7 +804,7 @@ nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
  * We need to translate between nfs status return values and
  * the local errno values which may not be the same.
  */
-static struct {
+static const struct {
 	int stat;
 	int errno;
 } nfs_errtbl[] = {
@@ -844,20 +844,22 @@ static struct {
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
 

