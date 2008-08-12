From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 5/7] nfsd: don't declare p in ENCODE_SEQID_OP_HEAD
Date: Tue, 12 Aug 2008 20:45:28 +0300
Message-ID: <1218563128-25419-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:42182 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbYHLRpq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:45:46 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After using the encode_stateid helper the "p" pointer declared
by ENCODE_SEQID_OP_HEAD is warned as unused.
In the single site where it is still needed it can be declared
separately using the ENCODE_HEAD macro.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 96da1aa..e102247 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1192,7 +1192,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
  * Header routine to setup seqid operation replay cache
  */
 #define ENCODE_SEQID_OP_HEAD					\
-	__be32 *p;						\
 	__be32 *save;						\
 								\
 	save = resp->p;
@@ -2138,6 +2137,7 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 static __be32
 nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open *open)
 {
+	ENCODE_HEAD;
 	ENCODE_SEQID_OP_HEAD;
 
 	if (nfserr)
-- 
1.5.6.5

