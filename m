Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:39486 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933600Ab3D3WtY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Apr 2013 18:49:24 -0400
Received: by mail-ie0-f180.google.com with SMTP id to1so1312529ieb.25
        for <linux-nfs@vger.kernel.org>; Tue, 30 Apr 2013 15:49:24 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFSD: Kill some mixed sign comparisons in
 fs/nfsd/nfs4xdr.c
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 30 Apr 2013 18:49:03 -0400
Message-ID: <20130430224903.21406.2877.stgit@seurat.1015granger.net>
In-Reply-To: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
References: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4xdr.c |    9 ++++-----
 fs/nfsd/xdr4.h    |    2 +-
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 758a1f3..39d60a0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -244,7 +244,7 @@ static __be32
 nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		   struct iattr *iattr, struct nfs4_acl **acl)
 {
-	int expected_len, len = 0;
+	u32 expected_len, len = 0;
 	u32 dummy32;
 	char *buf;
 	int host_err;
@@ -1132,8 +1132,7 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
 static __be32
 nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 {
-	int avail;
-	int len;
+	u32 avail, len;
 	DECODE_HEAD;
 
 	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
@@ -1200,7 +1199,7 @@ static __be32
 nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 			 struct nfsd4_exchange_id *exid)
 {
-	int dummy, tmp;
+	u32 dummy, tmp;
 	DECODE_HEAD;
 
 	READ_BUF(NFS4_VERIFIER_SIZE);
@@ -3033,7 +3032,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 static __be32
 nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_readdir *readdir)
 {
-	int maxcount;
+	unsigned int maxcount;
 	loff_t offset;
 	__be32 *page, *savep, *tailbase;
 	__be32 *p;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 546f898..c84aea7 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -482,7 +482,7 @@ struct nfsd4_compoundargs {
 	__be32 *			p;
 	__be32 *			end;
 	struct page **			pagelist;
-	int				pagelen;
+	unsigned int			pagelen;
 	__be32				tmp[8];
 	__be32 *			tmpp;
 	struct tmpbuf {

