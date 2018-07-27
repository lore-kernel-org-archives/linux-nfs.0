Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:52708 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730395AbeG0Qla (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 12:41:30 -0400
Subject: [PATCH v1 3/4] NFSD: Refactor the generic write vector fill helper
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Jul 2018 11:19:05 -0400
Message-ID: <20180727151905.21878.62693.stgit@klimt.1015granger.net>
In-Reply-To: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fill_in_write_vector() is nearly the same logic as
svc_fill_write_vector(), but there are a few differences so that
the former can handle multiple WRITE payloads in a single COMPOUND.

svc_fill_write_vector() can be adjusted so that it can be used in
the NFSv4 WRITE code path too. Instead of assuming the pages are
coming from rq_args.pages, have the caller pass in the page list.

The immediate benefit is a reduction of code duplication. It also
prevents the NFSv4 WRITE decoder from passing an empty vector
element when the transport has provided the payload in the xdr_buf's
page array.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3proc.c         |    3 ++-
 fs/nfsd/nfs4proc.c         |   23 ++++-------------------
 fs/nfsd/nfsproc.c          |    3 ++-
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |   11 ++++-------
 5 files changed, 13 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 6259a4b..8d1c2d1a 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -202,7 +202,8 @@
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->committed = argp->stable;
-	nvecs = svc_fill_write_vector(rqstp, &argp->first, cnt);
+	nvecs = svc_fill_write_vector(rqstp, rqstp->rq_arg.pages,
+				      &argp->first, cnt);
 	if (!nvecs)
 		RETURN_STATUS(nfserr_io);
 	nfserr = nfsd_write(rqstp, &resp->fh, argp->offset,
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5d99e88..1d1080c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -982,24 +982,6 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	return status;
 }
 
-static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
-{
-        int i = 1;
-        int buflen = write->wr_buflen;
-
-        vec[0].iov_base = write->wr_head.iov_base;
-        vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len);
-        buflen -= vec[0].iov_len;
-
-        while (buflen) {
-                vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
-                vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
-                buflen -= vec[i].iov_len;
-                i++;
-        }
-        return i;
-}
-
 static __be32
 nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    union nfsd4_op_u *u)
@@ -1027,7 +1009,10 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	write->wr_how_written = write->wr_stable_how;
 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
 
-	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
+	nvecs = svc_fill_write_vector(rqstp, write->wr_pagelist,
+				      &write->wr_head, write->wr_buflen);
+	if (!nvecs)
+		return nfserr_io;
 	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
 
 	status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index f107f9f..a6faee5 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -218,7 +218,8 @@
 		SVCFH_fmt(&argp->fh),
 		argp->len, argp->offset);
 
-	nvecs = svc_fill_write_vector(rqstp, &argp->first, cnt);
+	nvecs = svc_fill_write_vector(rqstp, rqstp->rq_arg.pages,
+				      &argp->first, cnt);
 	if (!nvecs)
 		return nfserr_io;
 	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 574368e..43f88bd 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -496,6 +496,7 @@ int		   svc_register(const struct svc_serv *, struct net *, const int,
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
+					 struct page **pages,
 					 struct kvec *first, size_t total);
 char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
 					     struct kvec *first, size_t total);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 30a4226..2194ed5 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1537,16 +1537,16 @@ u32 svc_max_payload(const struct svc_rqst *rqstp)
 /**
  * svc_fill_write_vector - Construct data argument for VFS write call
  * @rqstp: svc_rqst to operate on
+ * @pages: list of pages containing data payload
  * @first: buffer containing first section of write payload
  * @total: total number of bytes of write payload
  *
- * Returns the number of elements populated in the data argument array.
+ * Fills in rqstp::rq_vec, and returns the number of elements.
  */
-unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct kvec *first,
-				   size_t total)
+unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct page **pages,
+				   struct kvec *first, size_t total)
 {
 	struct kvec *vec = rqstp->rq_vec;
-	struct page **pages;
 	unsigned int i;
 
 	/* Some types of transport can present the write payload
@@ -1560,14 +1560,11 @@ unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct kvec *first,
 		++i;
 	}
 
-	WARN_ON_ONCE(rqstp->rq_arg.page_base != 0);
-	pages = rqstp->rq_arg.pages;
 	while (total) {
 		vec[i].iov_base = page_address(*pages);
 		vec[i].iov_len = min_t(size_t, total, PAGE_SIZE);
 		total -= vec[i].iov_len;
 		++i;
-
 		++pages;
 	}
 

