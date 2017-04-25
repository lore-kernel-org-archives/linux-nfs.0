Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33026 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1949789AbdDYUkR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Apr 2017 16:40:17 -0400
Date: Tue, 25 Apr 2017 16:40:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170425204016.GA15279@fieldses.org>
References: <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <20170420161935.GB4782@fieldses.org>
 <20170421211253.GE19775@fieldses.org>
 <87vapurci7.fsf@notabene.neil.brown.name>
 <20170424140642.GB30046@fieldses.org>
 <20170424211920.GA1585@fieldses.org>
 <20170424212031.GB1585@fieldses.org>
 <87o9vlp48j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87o9vlp48j.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > +	if (!*(rqstp->rq_next_page))
> > +		return 0;
> 
> Why the extra parentheses?  "->" is at the highest precedence level for C.

I've been doing this stuff enough years, you'd think I'd have bothered
to memorize the C operator precedence table by now.

Anyway, this change is actually unrelated and not entirely necessary;
dropped.

> i.e. either keep it simple (like the v2 code) or make it tidy (with head
> and tail), but not half-and-half??

What the heck, let's go all out.

You only live once!

--b.

commit db44bac41bbf
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Apr 25 16:21:34 2017 -0400

    nfsd4: minor NFSv2/v3 write decoding cleanup
    
    Use a couple shortcuts that will simplify a following bugfix.
    
    Cc: stable@vger.kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index dba2ff8eaa68..d18cfddbe115 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -358,6 +358,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 {
 	unsigned int len, v, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
+	struct kvec *head = rqstp->rq_arg.head;
+	struct kvec *tail = rqstp->rq_arg.tail;
 
 	p = decode_fh(p, &args->fh);
 	if (!p)
@@ -377,9 +379,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 * Check to make sure that we got the right number of
 	 * bytes.
 	 */
-	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
-	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
-		+ rqstp->rq_arg.tail[0].iov_len - hdr;
+	hdr = (void*)p - head->iov_base;
+	dlen = head->iov_len + rqstp->rq_arg.page_len + tail->iov_len - hdr;
 	/*
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
@@ -396,7 +397,7 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 		len = args->len = max_blocksize;
 	}
 	rqstp->rq_vec[0].iov_base = (void*)p;
-	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
+	rqstp->rq_vec[0].iov_len = head->iov_len - hdr;
 	v = 0;
 	while (len > rqstp->rq_vec[v].iov_len) {
 		len -= rqstp->rq_vec[v].iov_len;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 41b468a6a90f..59bd88a23a3d 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -280,6 +280,7 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_writeargs *args)
 {
 	unsigned int len, hdr, dlen;
+	struct kvec *head = rqstp->rq_arg.head;
 	int v;
 
 	p = decode_fh(p, &args->fh);
@@ -300,9 +301,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 * Check to make sure that we got the right number of
 	 * bytes.
 	 */
-	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
-	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
-		- hdr;
+	hdr = (void*)p - head->iov_base;
+	dlen = head->iov_len + rqstp->rq_arg.page_len - hdr;
 
 	/*
 	 * Round the length of the data which was specified up to
@@ -316,7 +316,7 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 		return 0;
 
 	rqstp->rq_vec[0].iov_base = (void*)p;
-	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
+	rqstp->rq_vec[0].iov_len = head->iov_len - hdr;
 	v = 0;
 	while (len > rqstp->rq_vec[v].iov_len) {
 		len -= rqstp->rq_vec[v].iov_len;
commit 13bf9fbff0e5
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
    Reviewed-by: NeilBrown <neilb@suse.com>
    Cc: stable@vger.kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index d18cfddbe115..452334694a5d 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -369,6 +369,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	args->count = ntohl(*p++);
 	args->stable = ntohl(*p++);
 	len = args->len = ntohl(*p++);
+	if ((void *)p > head->iov_base + head->iov_len)
+		return 0;
 	/*
 	 * The count must equal the amount of data passed.
 	 */
@@ -472,6 +474,8 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 	/* first copy and check from the first page */
 	old = (char*)p;
 	vec = &rqstp->rq_arg.head[0];
+	if ((void *)old > vec->iov_base + vec->iov_len)
+		return 0;
 	avail = vec->iov_len - (old - (char*)vec->iov_base);
 	while (len && avail && *old) {
 		*new++ = *old++;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 59bd88a23a3d..de07ff625777 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -302,6 +302,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 * bytes.
 	 */
 	hdr = (void*)p - head->iov_base;
+	if (hdr > head->iov_len)
+		return 0;
 	dlen = head->iov_len + rqstp->rq_arg.page_len - hdr;
 
 	/*

