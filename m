Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:41190 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932367AbdELQR7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:59 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 16/33] nfs: use ARRAY_SIZE() in the nfsacl_version3 declaration
Date: Fri, 12 May 2017 18:16:44 +0200
Message-Id: <20170512161701.22468-17-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs3xdr.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index a017ec5c7a9d..85ff1187e637 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -2611,8 +2611,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 static unsigned int nfs3_acl_counts[ARRAY_SIZE(nfs3_acl_procedures)];
 const struct rpc_version nfsacl_version3 = {
 	.number			= 3,
-	.nrprocs		= sizeof(nfs3_acl_procedures)/
-				  sizeof(nfs3_acl_procedures[0]),
+	.nrprocs		= ARRAY_SIZE(nfs3_acl_procedures),
 	.procs			= nfs3_acl_procedures,
 	.counts			= nfs3_acl_counts,
 };
-- 
2.11.0

