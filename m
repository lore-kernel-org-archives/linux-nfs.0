Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44983 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab3KTIYM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 03:24:12 -0500
Date: Wed, 20 Nov 2013 00:24:11 -0800
From: Christoph Hellwig <hch@infradead.org>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: start documenting some XDR handling functions
Message-ID: <20131120082411.GA30072@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fc10dd7..9423522 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -193,6 +193,15 @@ static int zero_clientid(clientid_t *clid)
 	return (clid->cl_boot == 0) && (clid->cl_id == 0);
 }
 
+/**
+ * defer_free - mark an allocation as deferred freed
+ * @argp: NFSv4 compound argument structure to be freed with
+ * @release: release callback to free @p, typically kfree()
+ * @p: pointer to be freed
+ *
+ * Marks @p to be freed when processing the compound operation
+ * described in @argp finishes.
+ */
 static int
 defer_free(struct nfsd4_compoundargs *argp,
 		void (*release)(const void *), void *p)
@@ -209,6 +218,16 @@ defer_free(struct nfsd4_compoundargs *argp,
 	return 0;
 }
 
+/**
+ * savemem - duplicate a chunk of memory for later processing
+ * @argp: NFSv4 compound argument structure to be freed with
+ * @p: pointer to be duplicated
+ * @nbytes: length to be duplicated
+ *
+ * Returns a pointer to a copy of @nbytes bytes of memory at @p
+ * that are preserved until processing of the NFSv4 compound
+ * operation described by @argp finishes.
+ */
 static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 {
 	if (p == argp->tmp) {
