Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35541 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237Ab2KZOkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/8] nfsd4: delay filling in write iovec array till after xdr decoding
Date: Mon, 26 Nov 2012 09:39:57 -0500
Message-Id: <1353940799-11763-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Our server rejects compounds containing more than one write operation.
It's unclear whether this is really permitted by the spec; with 4.0,
it's possibly OK, with 4.1 (which has clearer limits on compound
parameters), it's probably not OK.  No client that we're aware of has
ever done this, but in theory it could be useful.

The source of the limitation: we need an array of iovecs to pass to the
write operation.  In the worst case that array of iovecs could have
hundreds of elements (the maximum rwsize divided by the page size), so
it's too big to put on the stack, or in each compound op.  So we instead
keep a single such array in the compound argument.

We fill in that array at the time we decode the xdr operation.

But we decode every op in the compound before executing any of them.  So
once we've used that array we can't decode another write.

If we instead delay filling in that array till the time we actually
perform the write, we can reuse it.

Another option might be to switch to decoding compound ops one at a
time.  I considered doing that, but it has a number of other side
effects, and I'd rather fix just this one problem for now.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/nfs/nfs41-server.txt |    4 ++--
 fs/nfsd/nfs4proc.c                             |   24 +++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c                              |   20 --------------------
 fs/nfsd/xdr4.h                                 |    1 -
 4 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfs41-server.txt b/Documentation/filesystems/nfs/nfs41-server.txt
index 392ef63..01c2db7 100644
--- a/Documentation/filesystems/nfs/nfs41-server.txt
+++ b/Documentation/filesystems/nfs/nfs41-server.txt
@@ -190,7 +190,7 @@ Nonstandard compound limitations:
   ca_maxrequestsize request and a ca_maxresponsesize reply, so we may
   fail to live up to the promise we made in CREATE_SESSION fore channel
   negotiation.
-* No more than one IO operation (read, write, readdir) allowed per
-  compound.
+* No more than one read-like operation allowed per compound; encoding
+  replies that cross page boundaries (except for read data) not handled.
 
 See also http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues.
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1d2396b..87d24e5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -881,6 +881,24 @@ out:
 	return status;
 }
 
+static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
+{
+        int i = 1;
+        int buflen = write->wr_buflen;
+
+        vec[0].iov_base = write->wr_head.iov_base;
+        vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len);
+        buflen -= vec[0].iov_len;
+
+        while (buflen) {
+                vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
+                vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
+                buflen -= vec[i].iov_len;
+                i++;
+        }
+        return i;
+}
+
 static __be32
 nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_write *write)
@@ -889,6 +907,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file *filp = NULL;
 	__be32 status = nfs_ok;
 	unsigned long cnt;
+	int nvecs;
 
 	/* no need to check permission - this will be done in nfsd_write() */
 
@@ -911,8 +930,11 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	write->wr_how_written = write->wr_stable_how;
 	gen_boot_verifier(&write->wr_verifier);
 
+	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
+	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
+
 	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
-			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
+			     write->wr_offset, rqstp->rq_vec, nvecs,
 			     &cnt, &write->wr_how_written);
 	if (filp)
 		fput(filp);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index cb9f9017..09204f5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1139,24 +1139,6 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
 	DECODE_TAIL;
 }
 
-static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
-{
-	int i = 1;
-	int buflen = write->wr_buflen;
-
-	vec[0].iov_base = write->wr_head.iov_base;
-	vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len);
-	buflen -= vec[0].iov_len;
-
-	while (buflen) {
-		vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
-		vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
-		buflen -= vec[i].iov_len;
-		i++;
-	}
-	return i;
-}
-
 static __be32
 nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 {
@@ -1204,8 +1186,6 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
 	}
 	argp->p += XDR_QUADLEN(len);
-	write->wr_vlen = fill_in_write_vector(argp->rqstp->rq_vec, write);
-	WARN_ON_ONCE(write->wr_vlen > ARRAY_SIZE(argp->rqstp->rq_vec));
 
 	DECODE_TAIL;
 }
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 152867b..331f8a3 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -385,7 +385,6 @@ struct nfsd4_write {
 	u64		wr_offset;          /* request */
 	u32		wr_stable_how;      /* request */
 	u32		wr_buflen;          /* request */
-	int		wr_vlen;
 	struct kvec	wr_head;
 	struct page **	wr_pagelist;        /* request */
 
-- 
1.7.9.5

