Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50675 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753025AbdEIJVG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:06 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 19/32] nfsd: remove the unused PROC() macro in nfs3proc.c
Date: Tue,  9 May 2017 11:19:57 +0200
Message-Id: <20170509092010.30752-20-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs3proc.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 045c9081eabe..24e035190770 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -647,18 +647,6 @@ nfsd3_proc_commit(struct svc_rqst * rqstp, struct nfsd3_commitargs *argp,
 #define nfsd3_voidres			nfsd3_voidargs
 struct nfsd3_voidargs { int dummy; };
 
-#define PROC(name, argt, rest, relt, cache, respsize)	\
- { (svc_procfunc) nfsd3_proc_##name,		\
-   (kxdrproc_t) nfs3svc_decode_##argt##args,	\
-   (kxdrproc_t) nfs3svc_encode_##rest##res,	\
-   (kxdrproc_t) nfs3svc_release_##relt,		\
-   sizeof(struct nfsd3_##argt##args),		\
-   sizeof(struct nfsd3_##rest##res),		\
-   0,						\
-   cache,					\
-   respsize,					\
- }
-
 #define ST 1		/* status*/
 #define FH 17		/* filehandle with length */
 #define AT 21		/* attributes */
-- 
2.11.0

