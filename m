Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59644 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S977232AbdDXVUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 17:20:31 -0400
Date: Mon, 24 Apr 2017 17:20:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170424212031.GB1585@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <20170420161935.GB4782@fieldses.org>
 <20170421211253.GE19775@fieldses.org>
 <87vapurci7.fsf@notabene.neil.brown.name>
 <20170424140642.GB30046@fieldses.org>
 <20170424211920.GA1585@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170424211920.GA1585@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And, another problem spotted by the Synposys folks.

I'll give these some more testing and hope to send a pull request in
another day or two.

--b.

commit a0aa2db91590
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Apr 21 15:26:30 2017 -0400

    nfsd: stricter decoding of write-like NFSv2/v3 ops
    
    The NFSv2/v3 code does not systematically check whether we decode past
    the end of the buffer.  This generally appears to be harmless, but there
    are a few places where we do arithmetic on the pointers involved and
    don't account for the possibility that a length could be negative.  Add
    checks to catch these.
    
    Reported-by: Tuomas Haanpää <thaan@synopsys.com>
    Reported-by: Ari Kauppi <ari@synopsys.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index dba2ff8eaa68..41cc47bf9d00 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -358,6 +358,7 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 {
 	unsigned int len, v, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
+	struct kvec *head = rqstp->rq_arg.head;
 
 	p = decode_fh(p, &args->fh);
 	if (!p)
@@ -367,6 +368,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	args->count = ntohl(*p++);
 	args->stable = ntohl(*p++);
 	len = args->len = ntohl(*p++);
+	if ((void *)p > head->iov_base + head->iov_len)
+		return 0;
 	/*
 	 * The count must equal the amount of data passed.
 	 */
@@ -466,11 +469,15 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 	len = ntohl(*p++);
 	if (len == 0 || len > NFS3_MAXPATHLEN || len >= PAGE_SIZE)
 		return 0;
+	if (!*(rqstp->rq_next_page))
+		return 0;
 	args->tname = new = page_address(*(rqstp->rq_next_page++));
 	args->tlen = len;
 	/* first copy and check from the first page */
 	old = (char*)p;
 	vec = &rqstp->rq_arg.head[0];
+	if ((void *)old > vec->iov_base + vec->iov_len)
+		return 0;
 	avail = vec->iov_len - (old - (char*)vec->iov_base);
 	while (len && avail && *old) {
 		*new++ = *old++;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 41b468a6a90f..7a0eed7c619d 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -301,6 +301,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 * bytes.
 	 */
 	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
+	if (hdr > rqstp->rq_arg.head[0].iov_len)
+		return 0;
 	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
 		- hdr;
 
