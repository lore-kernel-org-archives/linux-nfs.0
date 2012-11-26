Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35537 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754235Ab2KZOkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/8] nfsd4: reorganize write decoding
Date: Mon, 26 Nov 2012 09:39:55 -0500
Message-Id: <1353940799-11763-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In preparation for moving some of it elsewhere.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   62 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index cfebc9c..579dc70 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1139,12 +1139,30 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
 	DECODE_TAIL;
 }
 
+static int fill_in_write_vector(struct kvec *vec, struct kvec *head, struct page **pagelist, int buflen)
+{
+	int i = 1;
+
+	vec[0].iov_base = head->iov_base;
+	vec[0].iov_len = min_t(int, buflen, head->iov_len);
+	buflen -= vec[0].iov_len;
+
+	while (buflen) {
+		vec[i].iov_base = page_address(pagelist[i - 1]);
+		vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
+		buflen -= vec[i].iov_len;
+		i++;
+	}
+	return i;
+}
+
 static __be32
 nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 {
 	int avail;
-	int v;
 	int len;
+	struct page **pagelist;
+	struct kvec head;
 	DECODE_HEAD;
 
 	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
@@ -1167,27 +1185,29 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 				__FILE__, __LINE__);
 		goto xdr_error;
 	}
-	argp->rqstp->rq_vec[0].iov_base = p;
-	argp->rqstp->rq_vec[0].iov_len = avail;
-	v = 0;
-	len = write->wr_buflen;
-	while (len > argp->rqstp->rq_vec[v].iov_len) {
-		len -= argp->rqstp->rq_vec[v].iov_len;
-		v++;
-		argp->rqstp->rq_vec[v].iov_base = page_address(argp->pagelist[0]);
-		argp->pagelist++;
-		if (argp->pagelen >= PAGE_SIZE) {
-			argp->rqstp->rq_vec[v].iov_len = PAGE_SIZE;
-			argp->pagelen -= PAGE_SIZE;
-		} else {
-			argp->rqstp->rq_vec[v].iov_len = argp->pagelen;
-			argp->pagelen -= len;
-		}
+	head.iov_base = p;
+	head.iov_len = avail;
+	WARN_ON(avail != (XDR_QUADLEN(avail) << 2));
+	pagelist = argp->pagelist;
+
+	len = XDR_QUADLEN(write->wr_buflen) << 2;
+	if (len >= avail) {
+		int pages;
+
+		len -= avail;
+
+		pages = len >> PAGE_SHIFT;
+		argp->pagelist += pages;
+		argp->pagelen -= pages * PAGE_SIZE;
+		len -= pages * PAGE_SIZE;
+
+		argp->p = (__be32 *)page_address(argp->pagelist[0]);
+		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
 	}
-	argp->end = (__be32*) (argp->rqstp->rq_vec[v].iov_base + argp->rqstp->rq_vec[v].iov_len);
-	argp->p = (__be32*)  (argp->rqstp->rq_vec[v].iov_base + (XDR_QUADLEN(len) << 2));
-	argp->rqstp->rq_vec[v].iov_len = len;
-	write->wr_vlen = v+1;
+	argp->p += XDR_QUADLEN(len);
+	write->wr_vlen = fill_in_write_vector(argp->rqstp->rq_vec,
+		&head, pagelist, write->wr_buflen);
+	WARN_ON_ONCE(write->wr_vlen > ARRAY_SIZE(argp->rqstp->rq_vec));
 
 	DECODE_TAIL;
 }
-- 
1.7.9.5

