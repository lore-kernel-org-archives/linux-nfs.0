Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932489AbbDUUWS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 16:22:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 3/3] nfsd4: fix READ permission checking
Date: Tue, 21 Apr 2015 16:22:15 -0400
Message-Id: <1429647735-15512-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1429647735-15512-1-git-send-email-bfields@redhat.com>
References: <1429647735-15512-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the case we already have a struct file (derived from a stateid), we
still need to do permission-checking; otherwise an unauthorized user
could gain access to a file by sniffing or guessing somebody else's
stateid.

Cc: stable@vger.kernel.org
Fixes: dc97618ddda9 "nfsd4: separate splice and readv cases"
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index cea6c529434f..a45032ce7b80 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3422,6 +3422,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	unsigned long maxcount;
 	struct xdr_stream *xdr = &resp->xdr;
 	struct file *file = read->rd_filp;
+	struct svc_fh *fhp = read->rd_fhp;
 	int starting_len = xdr->buf->len;
 	struct raparms *ra;
 	__be32 *p;
@@ -3445,12 +3446,15 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
 
-	if (!read->rd_filp) {
+	if (read->rd_filp)
+		err = nfsd_permission(resp->rqstp, fhp->fh_export,
+				fhp->fh_dentry,
+				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
+	else
 		err = nfsd_get_tmp_read_open(resp->rqstp, read->rd_fhp,
 						&file, &ra);
-		if (err)
-			goto err_truncate;
-	}
+	if (err)
+		goto err_truncate;
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
 		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
-- 
1.9.3

