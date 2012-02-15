Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62070 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778Ab2BOVg1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 16:36:27 -0500
Received: by mail-gy0-f174.google.com with SMTP id r11so965647ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 13:36:27 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/13] NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 16:36:25 -0500
Message-ID: <20120215213625.3254.16192.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux NFS client must distinguish between referral events (which
it currently supports) and migration events (which it does not yet
support).

In both types of events, an fs_locations array is returned.  But upper
layers, not the XDR layer, should make the distinction between a
referral and a migration.  There really isn't a way for an XDR decoder
function to distinguish the two, in general.

Slightly adjust the FATTR flags returned by decode_fs_locations()
to set NFS_ATTR_FATTR_V4_LOCATIONS only if a non-empty locations
array was returned from the server.  Then have logic in nfs4proc.c
distinguish whether the locations array is for a referral or
something else.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c       |    6 +++---
 fs/nfs/nfs4xdr.c        |    2 +-
 include/linux/nfs_xdr.h |    7 ++++---
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5629858..aa0d2cd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -75,6 +75,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
+static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -2301,7 +2302,6 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_map_errors(status);
 }
 
-static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
 /*
  * Get locations and (maybe) other attributes of a referral.
  * Note that we'll actually follow the referral later when
@@ -4707,11 +4707,11 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 	if (!(((fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID) ||
 	       (fattr->valid & NFS_ATTR_FATTR_FILEID)) &&
 	      (fattr->valid & NFS_ATTR_FATTR_FSID) &&
-	      (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+	      (fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)))
 		return;
 
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
-		NFS_ATTR_FATTR_NLINK;
+		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_V4_REFERRAL;
 	fattr->mode = S_IFDIR | S_IRUGO | S_IXUGO;
 	fattr->nlink = 2;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 16ee1cf..6b1052a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3614,7 +3614,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			res->nlocations++;
 	}
 	if (res->nlocations != 0)
-		status = NFS_ATTR_FATTR_V4_REFERRAL;
+		status = NFS_ATTR_FATTR_V4_LOCATIONS;
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d409f1c..d609631 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -89,9 +89,10 @@ struct nfs_fattr {
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

