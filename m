Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52145 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab1CNM5W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:57:22 -0400
Received: by mail-iy0-f174.google.com with SMTP id 26so4900509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:57:22 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/12] NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:57:20 -0400
Message-ID: <20110314125720.2413.28564.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Our NFS client must distinguish between referral events (which it
currently supports) and migration events (which it does not yet
support).

In both types of events, an fs_locations array is returned, but the
upper layers should make the distinction between a referral and a
migration, not the XDR layer.  There really isn't a way for an
XDR decoder to tell one from the other.

Slightly adjust the FATTR flags returned by decode_fs_locations()
to set NFS_ATTR_FATTR_V4_LOCATIONS, and then have logic in nfs4proc.c
distinguish whether the locations array is for a referral or
something else.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c       |    5 +++--
 fs/nfs/nfs4xdr.c        |    2 +-
 include/linux/nfs_xdr.h |    3 ++-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 491b068..1e72e5f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2202,7 +2202,8 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 	}
 
 	memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
-	fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
+	if (fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)
+		fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
 	if (!fattr->mode)
 		fattr->mode = S_IFDIR;
 	memset(fhandle, 0, sizeof(struct nfs_fh));
@@ -4517,7 +4518,7 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 {
 	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
 		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
-		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+		(fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)))
 		return;
 
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e2c168..9d2c9d2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3204,7 +3204,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			res->nlocations++;
 	}
 	if (res->nlocations != 0)
-		status = NFS_ATTR_FATTR_V4_REFERRAL;
+		status = NFS_ATTR_FATTR_V4_LOCATIONS;
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b006857..2492487 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -77,7 +77,8 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_PRECTIME		(1U << 16)
 #define NFS_ATTR_FATTR_CHANGE		(1U << 17)
 #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
-#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
+#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)
+#define NFS_ATTR_FATTR_V4_LOCATIONS	(1U << 20)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \

