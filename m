Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932300AbaJUNOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Oct 2014 09:14:07 -0400
Date: Tue, 21 Oct 2014 09:14:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Message-ID: <20141021131406.GE9863@fieldses.org>
References: <20141017212446.GC3474@fieldses.org>
 <20141021103631.GB21863@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141021103631.GB21863@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 21, 2014 at 03:36:31AM -0700, Christoph Hellwig wrote:
> On Fri, Oct 17, 2014 at 05:24:46PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > We added this new estimator function but forgot to hook it up.  The
> > effect is that NFSv4.1 won't do zero-copy reads.
> > 
> > The estimate was also wrong by 8 bytes.
> 
> This would affect 4.0 and 4.2 as well, wouldn't it?

It was introduced in 4.1, so yes to 4.2, no to 4.1.

Also, this still had an arithmetic mistake. Fixed version follows.

Also my tests are failing due to an unrelated crash in 18-rc1 which I
want to track down before sending this in.

--b.

commit d1d84c9626bb3a519863b3ffc40d347166f9fb83
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Aug 21 15:04:31 2014 -0400

    nfsd4: fix response size estimation for OP_SEQUENCE
    
    We added this new estimator function but forgot to hook it up.  The
    effect is that NFSv4.1 (and greater) won't do zero-copy reads.
    
    The estimate was also wrong by 8 bytes.
    
    Fixes: ccae70a9ee41 "nfsd4: estimate sequence response size"
    Cc: stable@vger.kernel.org
    Reported-by: Chuck Lever <chucklever@gmail.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cdeb3cf..f4bd578 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1589,7 +1589,8 @@ static inline u32 nfsd4_rename_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op
 static inline u32 nfsd4_sequence_rsize(struct svc_rqst *rqstp,
 				       struct nfsd4_op *op)
 {
-	return NFS4_MAX_SESSIONID_LEN + 20;
+	return (op_encode_hdr_size
+		+ XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5) * sizeof(__be32);
 }
 
 static inline u32 nfsd4_setattr_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
@@ -1893,6 +1894,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_sequence,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_sequence_rsize,
 	},
 	[OP_DESTROY_CLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
