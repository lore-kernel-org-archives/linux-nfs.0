From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/30] NFSv4: Clean up decode_getfattr()
Date: Wed, 11 Mar 2009 14:41:07 -0400
Message-ID: <20090311184107.5578.98147.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22652 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448AbZCKSoP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:15 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3rG021754
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:12 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |   78 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 57 insertions(+), 21 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c1906d2..43c6e50 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2996,55 +2996,91 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	umode_t fmode = 0;
 	uint64_t fileid;
 
-	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
+
+	status = decode_attr_bitmap(xdr, bitmap);
+	if (status < 0)
 		goto xdr_error;
 
-	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
+	status = decode_attr_length(xdr, &attrlen, &savep);
+	if (status < 0)
 		goto xdr_error;
 
 
-	if ((status = decode_attr_type(xdr, bitmap, &type)) != 0)
+	status = decode_attr_type(xdr, bitmap, &type);
+	if (status < 0)
 		goto xdr_error;
 	fattr->mode = nfs_type2fmt[type];
 
-	if ((status = decode_attr_change(xdr, bitmap, &fattr->change_attr)) != 0)
+	status = decode_attr_change(xdr, bitmap, &fattr->change_attr);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_size(xdr, bitmap, &fattr->size)) != 0)
+
+	status = decode_attr_size(xdr, bitmap, &fattr->size);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_fsid(xdr, bitmap, &fattr->fsid)) != 0)
+
+	status = decode_attr_fsid(xdr, bitmap, &fattr->fsid);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_fileid(xdr, bitmap, &fattr->fileid)) != 0)
+
+	status = decode_attr_fileid(xdr, bitmap, &fattr->fileid);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_fs_locations(xdr, bitmap, container_of(fattr,
+
+	status = decode_attr_fs_locations(xdr, bitmap, container_of(fattr,
 						struct nfs4_fs_locations,
-						fattr))) != 0)
+						fattr));
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_mode(xdr, bitmap, &fmode)) != 0)
+
+	status = decode_attr_mode(xdr, bitmap, &fmode);
+	if (status < 0)
 		goto xdr_error;
 	fattr->mode |= fmode;
-	if ((status = decode_attr_nlink(xdr, bitmap, &fattr->nlink)) != 0)
+
+	status = decode_attr_nlink(xdr, bitmap, &fattr->nlink);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_owner(xdr, bitmap, server->nfs_client, &fattr->uid)) != 0)
+
+	status = decode_attr_owner(xdr, bitmap, server->nfs_client, &fattr->uid);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_group(xdr, bitmap, server->nfs_client, &fattr->gid)) != 0)
+
+	status = decode_attr_group(xdr, bitmap, server->nfs_client, &fattr->gid);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_rdev(xdr, bitmap, &fattr->rdev)) != 0)
+
+	status = decode_attr_rdev(xdr, bitmap, &fattr->rdev);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_space_used(xdr, bitmap, &fattr->du.nfs3.used)) != 0)
+
+	status = decode_attr_space_used(xdr, bitmap, &fattr->du.nfs3.used);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_time_access(xdr, bitmap, &fattr->atime)) != 0)
+
+	status = decode_attr_time_access(xdr, bitmap, &fattr->atime);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_time_metadata(xdr, bitmap, &fattr->ctime)) != 0)
+
+	status = decode_attr_time_metadata(xdr, bitmap, &fattr->ctime);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_time_modify(xdr, bitmap, &fattr->mtime)) != 0)
+
+	status = decode_attr_time_modify(xdr, bitmap, &fattr->mtime);
+	if (status < 0)
 		goto xdr_error;
-	if ((status = decode_attr_mounted_on_fileid(xdr, bitmap, &fileid)) != 0)
+
+	status = decode_attr_mounted_on_fileid(xdr, bitmap, &fileid);
+	if (status < 0)
 		goto xdr_error;
 	if (fattr->fileid == 0 && fileid != 0)
 		fattr->fileid = fileid;
-	if ((status = verify_attr_len(xdr, savep, attrlen)) == 0)
+
+	status = verify_attr_len(xdr, savep, attrlen);
+	if (status == 0)
 		fattr->valid = NFS_ATTR_FATTR_V4;
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);

