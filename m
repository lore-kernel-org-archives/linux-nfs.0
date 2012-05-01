Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60152 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757593Ab2EAPpz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 5/6] nfsd4: fix free_stateid return endianness
Date: Tue,  1 May 2012 11:45:48 -0400
Message-Id: <1335887149-30420-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1335887149-30420-1-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f7cc411..f839be1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3362,7 +3362,7 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
-nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, int nfserr,
+nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 			  struct nfsd4_free_stateid *free_stateid)
 {
 	__be32 *p;
@@ -3371,7 +3371,7 @@ nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, int nfserr,
 		return nfserr;
 
 	RESERVE_SPACE(4);
-	WRITE32(nfserr);
+	*p++ = nfserr;
 	ADJUST_ARGS();
 	return nfserr;
 }
-- 
1.7.9.5

