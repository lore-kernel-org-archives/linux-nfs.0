Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49509 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab1EIThg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:37:36 -0400
Received: by mail-gx0-f174.google.com with SMTP id 21so1941561gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:37:36 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/16] NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:37:29 -0400
Message-ID: <20110509193729.16568.49840.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Our NFS client must distinguish between referral events (which it
currently supports) and migration events (which it does not yet
support).

In both types of events, an fs_locations array is returned.  But upper
layers should make the distinction between a referral and a migration,
not the XDR layer.  There really isn't a generic way for an XDR
decoder function to tell one from the other.

Slightly adjust the FATTR flags returned by decode_fs_locations()
to set NFS_ATTR_FATTR_V4_LOCATIONS only if a non-empty locations
array was returned from the server.  Then have logic in nfs4proc.c
distinguish whether the locations array is for a referral or
something else.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c       |    5 +++--
 fs/nfs/nfs4xdr.c        |    2 +-
 include/linux/nfs_xdr.h |    7 ++++---
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a87686..641691c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2291,7 +2291,8 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 	}
 
 	memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
-	fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
+	if (fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)
+		fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
 	if (!fattr->mode)
 		fattr->mode = S_IFDIR;
 	memset(fhandle, 0, sizeof(struct nfs_fh));
@@ -4656,7 +4657,7 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 {
 	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
 		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
-		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+		(fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)))
 		return;
 
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c3ccd2c..be70be9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3326,7 +3326,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			res->nlocations++;
 	}
 	if (res->nlocations != 0)
-		status = NFS_ATTR_FATTR_V4_REFERRAL;
+		status = NFS_ATTR_FATTR_V4_LOCATIONS;
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 890dce2..26165a5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -82,9 +82,10 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_PRECTIME		(1U << 16)
 #define NFS_ATTR_FATTR_CHANGE		(1U << 17)
 #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
-#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
-#define NFS_ATTR_FATTR_MOUNTPOINT	(1U << 20)	/* Treat as mountpoint */
-#define NFS_ATTR_FATTR_MOUNTED_ON_FILEID		(1U << 21)
+#define NFS_ATTR_FATTR_V4_LOCATIONS	(1U << 19)
+#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 20)	/* NFSv4 referral */
+#define NFS_ATTR_FATTR_MOUNTPOINT	(1U << 21) /* Treat as mountpoint */
+#define NFS_ATTR_FATTR_MOUNTED_ON_FILEID (1U << 22)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \

