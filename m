Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35543 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356Ab2KZOkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/8] nfsd4: move more write parameters into xdr argument
Date: Mon, 26 Nov 2012 09:39:56 -0500
Message-Id: <1353940799-11763-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In preparation for moving some of this elsewhere.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   20 +++++++++-----------
 fs/nfsd/xdr4.h    |    2 ++
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 579dc70..cb9f9017 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1139,16 +1139,17 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
 	DECODE_TAIL;
 }
 
-static int fill_in_write_vector(struct kvec *vec, struct kvec *head, struct page **pagelist, int buflen)
+static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 {
 	int i = 1;
+	int buflen = write->wr_buflen;
 
-	vec[0].iov_base = head->iov_base;
-	vec[0].iov_len = min_t(int, buflen, head->iov_len);
+	vec[0].iov_base = write->wr_head.iov_base;
+	vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len);
 	buflen -= vec[0].iov_len;
 
 	while (buflen) {
-		vec[i].iov_base = page_address(pagelist[i - 1]);
+		vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
 		vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
 		buflen -= vec[i].iov_len;
 		i++;
@@ -1161,8 +1162,6 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 {
 	int avail;
 	int len;
-	struct page **pagelist;
-	struct kvec head;
 	DECODE_HEAD;
 
 	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
@@ -1185,10 +1184,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 				__FILE__, __LINE__);
 		goto xdr_error;
 	}
-	head.iov_base = p;
-	head.iov_len = avail;
+	write->wr_head.iov_base = p;
+	write->wr_head.iov_len = avail;
 	WARN_ON(avail != (XDR_QUADLEN(avail) << 2));
-	pagelist = argp->pagelist;
+	write->wr_pagelist = argp->pagelist;
 
 	len = XDR_QUADLEN(write->wr_buflen) << 2;
 	if (len >= avail) {
@@ -1205,8 +1204,7 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
 	}
 	argp->p += XDR_QUADLEN(len);
-	write->wr_vlen = fill_in_write_vector(argp->rqstp->rq_vec,
-		&head, pagelist, write->wr_buflen);
+	write->wr_vlen = fill_in_write_vector(argp->rqstp->rq_vec, write);
 	WARN_ON_ONCE(write->wr_vlen > ARRAY_SIZE(argp->rqstp->rq_vec));
 
 	DECODE_TAIL;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 3c414c1..152867b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -386,6 +386,8 @@ struct nfsd4_write {
 	u32		wr_stable_how;      /* request */
 	u32		wr_buflen;          /* request */
 	int		wr_vlen;
+	struct kvec	wr_head;
+	struct page **	wr_pagelist;        /* request */
 
 	u32		wr_bytes_written;   /* response */
 	u32		wr_how_written;     /* response */
-- 
1.7.9.5

