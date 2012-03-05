Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63818 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756773Ab2CEQub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 11:50:31 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/16] NFSv4: Add a helper for encoding opaque data
Date: Mon,  5 Mar 2012 11:50:10 -0500
Message-Id: <1330966221-17164-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330966221-17164-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1330966221-17164-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index af11e8b..de4cb5c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -885,6 +885,14 @@ static __be32 *reserve_space(struct xdr_stream *xdr, size_t nbytes)
 	return p;
 }
 
+static void encode_opaque_fixed(struct xdr_stream *xdr, const void *buf, size_t len)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, len);
+	xdr_encode_opaque_fixed(p, buf, len);
+}
+
 static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
 	__be32 *p;
@@ -922,11 +930,7 @@ static void encode_nops(struct compound_hdr *hdr)
 
 static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
 {
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
-	BUG_ON(p == NULL);
-	xdr_encode_opaque_fixed(p, verf->data, NFS4_VERIFIER_SIZE);
+	encode_opaque_fixed(xdr, verf->data, NFS4_VERIFIER_SIZE);
 }
 
 static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
-- 
1.7.7.6

