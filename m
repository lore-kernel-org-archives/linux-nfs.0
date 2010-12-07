Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53645 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270Ab0LGAJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Dec 2010 19:09:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd: fix offset printk's in nfsd3 read/write
Date: Mon,  6 Dec 2010 19:09:26 -0500
Message-Id: <1291680566-13980-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1291680566-13980-1-git-send-email-bfields@redhat.com>
References: <1291680566-13980-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Thanks to dysbr01@ca.com for noticing that the debugging printk in
the v3 write procedure can print >2GB offsets as negative numbers:
	https://bugzilla.kernel.org/show_bug.cgi?id=23342

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs3proc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 5b7e302..2247fc9 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -151,10 +151,10 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
 	__be32	nfserr;
 	u32	max_blocksize = svc_max_payload(rqstp);
 
-	dprintk("nfsd: READ(3) %s %lu bytes at %lu\n",
+	dprintk("nfsd: READ(3) %s %lu bytes at %Lu\n",
 				SVCFH_fmt(&argp->fh),
 				(unsigned long) argp->count,
-				(unsigned long) argp->offset);
+				(unsigned long long) argp->offset);
 
 	/* Obtain buffer pointer for payload.
 	 * 1 (status) + 22 (post_op_attr) + 1 (count) + 1 (eof)
@@ -191,10 +191,10 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
 	__be32	nfserr;
 	unsigned long cnt = argp->len;
 
-	dprintk("nfsd: WRITE(3)    %s %d bytes at %ld%s\n",
+	dprintk("nfsd: WRITE(3)    %s %d bytes at %Lu%s\n",
 				SVCFH_fmt(&argp->fh),
 				argp->len,
-				(unsigned long) argp->offset,
+				(unsigned long long) argp->offset,
 				argp->stable? " stable" : "");
 
 	fh_copy(&resp->fh, &argp->fh);
-- 
1.7.1

