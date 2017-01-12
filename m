Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58254 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755874AbdALCSN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 21:18:13 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd: fix supported attributes for acl & labels
Date: Wed, 11 Jan 2017 21:17:59 -0500
Message-Id: <1484187481-32723-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Oops--in 916d2d844afd I moved some constants into an array for
convenience, but here I'm accidentally writing to that array.

The effect is that if you ever encounter a filesystem lacking support
for ACLs or security labels, then all queries of supported attributes
will report that attribute as unsupported from then on.

Fixes: 916d2d844afd "nfsd: clean up supported attribute handling"
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 64c262aef633..048b06861f94 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2439,7 +2439,9 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 	p++;                /* to be backfilled later */
 
 	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
-		u32 *supp = nfsd_suppattrs[minorversion];
+		u32 supp[3];
+
+		memcpy(supp, nfsd_suppattrs[minorversion], sizeof(supp));
 
 		if (!IS_POSIXACL(dentry->d_inode))
 			supp[0] &= ~FATTR4_WORD0_ACL;
-- 
2.9.3

