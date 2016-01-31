Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34732 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757401AbcAaMuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 07:50:22 -0500
Received: by mail-pa0-f41.google.com with SMTP id uo6so67700290pac.1
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 04:50:22 -0800 (PST)
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: nfsd: supports read buffer from multiples pages
Message-ID: <56AE0302.6050101@gmail.com>
Date: Sun, 31 Jan 2016 20:50:10 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ltp fsync02 will cause nfs sending LAYOUTCOMMIT with length
larger than two pages. nfsd returns NFSERR_BAD_XDR right now.

This patch lets nfsd supports read buffer from multiples pages.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d6ef095..fcf399f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -143,11 +143,11 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	 * Maybe we need a new page, maybe we have just run out
 	 */
 	unsigned int avail = (char *)argp->end - (char *)argp->p;
+	unsigned int copied = 0;
 	__be32 *p;
+
 	if (avail + argp->pagelen < nbytes)
 		return NULL;
-	if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
-		return NULL;
 	/* ok, we can do it with the current plus the next page */
 	if (nbytes <= sizeof(argp->tmp))
 		p = argp->tmp;
@@ -164,9 +164,19 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	 * guarantee p points to at least nbytes bytes.
 	 */
 	memcpy(p, argp->p, avail);
+	copied += avail;
+	nbytes -= avail;
+
+	while (nbytes > PAGE_SIZE) {
+		next_decode_page(argp);
+		memcpy(((char*)p) + copied, argp->p, PAGE_SIZE);
+		copied += PAGE_SIZE;
+		nbytes -= PAGE_SIZE;
+	}
+
 	next_decode_page(argp);
-	memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
-	argp->p += XDR_QUADLEN(nbytes - avail);
+	memcpy(((char*)p) + copied, argp->p, nbytes);
+	argp->p += XDR_QUADLEN(nbytes);
 	return p;
 }
 
-- 
2.5.0

