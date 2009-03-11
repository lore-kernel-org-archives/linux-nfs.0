From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/30] NFS: Shrink the struct nfs_fattr
Date: Wed, 11 Mar 2009 14:41:07 -0400
Message-ID: <20090311184106.5578.87232.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391AbZCKSoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:10 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi45G012186
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:08 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need the bitmap[] field anymore, since the 'valid' field tells us
all we need to know about which attributes were filled in...
Also move the pre-op attributes in order to improve the structure packing.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c        |    3 ---
 include/linux/nfs_xdr.h |    7 +++----
 2 files changed, 3 insertions(+), 7 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7d220da..9f1df83 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3002,9 +3002,6 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto xdr_error;
 
-	fattr->bitmap[0] = bitmap[0];
-	fattr->bitmap[1] = bitmap[1];
-
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto xdr_error;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b99295e..6013acb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -28,9 +28,6 @@ static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid
 
 struct nfs_fattr {
 	unsigned int		valid;		/* which fields are valid */
-	__u64			pre_size;	/* pre_op_attr.size	  */
-	struct timespec		pre_mtime;	/* pre_op_attr.mtime	  */
-	struct timespec		pre_ctime;	/* pre_op_attr.ctime	  */
 	enum nfs_ftype		type;		/* always use NFSv2 types */
 	__u32			mode;
 	__u32			nlink;
@@ -52,9 +49,11 @@ struct nfs_fattr {
 	struct timespec		atime;
 	struct timespec		mtime;
 	struct timespec		ctime;
-	__u32			bitmap[2];	/* NFSv4 returned attribute bitmap */
 	__u64			change_attr;	/* NFSv4 change attribute */
 	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
+	__u64			pre_size;	/* pre_op_attr.size	  */
+	struct timespec		pre_mtime;	/* pre_op_attr.mtime	  */
+	struct timespec		pre_ctime;	/* pre_op_attr.ctime	  */
 	unsigned long		time_start;
 	unsigned long		gencount;
 };

