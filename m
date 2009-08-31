From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory attribute
Date: Mon, 31 Aug 2009 15:16:11 -0400
Message-ID: <1251746171.25048.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704AbZHaTRF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 15:17:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The fact that the filesystem is present does _not_ imply that the
fs_locations attribute should be marked as "unsupported".

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/nfs4xdr.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)


diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2dcc7fe..1b07183 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1825,8 +1825,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			goto out_resource;
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
-		if (!exp->ex_fslocs.locations)
-			word0 &= ~FATTR4_WORD0_FS_LOCATIONS;
 		if (!word2) {
 			WRITE32(2);
 			WRITE32(word0);

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
