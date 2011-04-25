Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758825Ab1DYSoX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:44:23 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:44:23 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/15] NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:44:21 -0400
Message-ID: <20110425184421.5669.94039.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
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
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1d8e7c3..aa90145 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2263,7 +2263,8 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 	}
 
 	memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
-	fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
+	if (fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)
+		fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
 	if (!fattr->mode)
 		fattr->mode = S_IFDIR;
 	memset(fhandle, 0, sizeof(struct nfs_fh));
@@ -4649,7 +4650,7 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 {
 	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
 		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
-		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+		(fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)))
 		return;
 
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dddfb57..76209b2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3327,7 +3327,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			res->nlocations++;
 	}
 	if (res->nlocations != 0)
-		status = NFS_ATTR_FATTR_V4_REFERRAL;
+		status = NFS_ATTR_FATTR_V4_LOCATIONS;
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 78b101e..26e693e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -83,6 +83,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
 #define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
 #define NFS_ATTR_FATTR_MOUNTPOINT	(1U << 20)	/* Treat as mountpoint */
+#define NFS_ATTR_FATTR_V4_LOCATIONS	(1U << 21)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \

