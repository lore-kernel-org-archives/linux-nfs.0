From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 43/47] nfsd41: pass writable attrs mask to nfsd4_decode_fattr
Date: Fri, 27 Mar 2009 06:20:32 +0300
Message-ID: <1238124032-8256-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23872 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753502AbZC0DUh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:20:37 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for EXCLUSIVE4_1

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a1af3a3..96f3eeb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -251,9 +251,14 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 	DECODE_TAIL;
 }
 
+static u32 nfsd_attrmask[] = {
+	NFSD_WRITEABLE_ATTRS_WORD0,
+	NFSD_WRITEABLE_ATTRS_WORD1
+};
+
 static __be32
-nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, struct iattr *iattr,
-    struct nfs4_acl **acl)
+nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
+		   struct iattr *iattr, struct nfs4_acl **acl)
 {
 	int expected_len, len = 0;
 	u32 dummy32;
@@ -271,7 +276,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, struct iattr *ia
 	 */
 	if ((bmval[0] & ~NFSD_SUPPORTED_ATTRS_WORD0) || (bmval[1] & ~NFSD_SUPPORTED_ATTRS_WORD1))
 		return nfserr_attrnotsupp;
-	if ((bmval[0] & ~NFSD_WRITEABLE_ATTRS_WORD0) || (bmval[1] & ~NFSD_WRITEABLE_ATTRS_WORD1))
+	if ((bmval[0] & ~writable[0]) || (bmval[1] & ~writable[1]))
 		return nfserr_inval;
 
 	READ_BUF(4);
@@ -499,7 +504,9 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 	if ((status = check_filename(create->cr_name, create->cr_namelen, nfserr_inval)))
 		return status;
 
-	if ((status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr, &create->cr_acl)))
+	status = nfsd4_decode_fattr(argp, create->cr_bmval, nfsd_attrmask,
+				    &create->cr_iattr, &create->cr_acl);
+	if (status)
 		goto out;
 
 	DECODE_TAIL;
@@ -660,7 +667,9 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		switch (open->op_createmode) {
 		case NFS4_CREATE_UNCHECKED:
 		case NFS4_CREATE_GUARDED:
-			if ((status = nfsd4_decode_fattr(argp, open->op_bmval, &open->op_iattr, &open->op_acl)))
+			status = nfsd4_decode_fattr(argp, open->op_bmval,
+				nfsd_attrmask, &open->op_iattr, &open->op_acl);
+			if (status)
 				goto out;
 			break;
 		case NFS4_CREATE_EXCLUSIVE:
@@ -859,7 +868,7 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
 	status = nfsd4_decode_stateid(argp, &setattr->sa_stateid);
 	if (status)
 		return status;
-	return nfsd4_decode_fattr(argp, setattr->sa_bmval,
+	return nfsd4_decode_fattr(argp, setattr->sa_bmval, nfsd_attrmask,
 				  &setattr->sa_iattr, &setattr->sa_acl);
 }
 
-- 
1.6.2.1

