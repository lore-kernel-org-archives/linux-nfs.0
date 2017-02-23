Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41722 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdBWTxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 14:53:41 -0500
Date: Thu, 23 Feb 2017 14:53:39 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFSv4: fix getacl head length estimation
Message-ID: <20170223195338.GG9417@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-3-git-send-email-bfields@redhat.com>
 <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
 <20170222223656.GG24122@parsley.fieldses.org>
 <6606b2d5-719f-9e27-6f95-eec8cebfb1a8@gmail.com>
 <20170223194321.GF9417@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170223194321.GF9417@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Bitmap and attrlen follow immediately after the op reply header.  This
was an oversight from commit bf118a342f.

Consequences of this are just minor efficiency (extra calls to
xdr_shrink_bufhead).

Fixes: bf118a342f10 "NFSv4: include bitmap in nfsv4 get acl data"
Reviewed-by: Kinglong Mee <kinglongmee@gmail.com>
Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e9255cb453e6..bb95dd2edeef 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2524,7 +2524,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
-	replen = hdr.replen + op_decode_hdr_maxsz + 1;
+	replen = hdr.replen + op_decode_hdr_maxsz;
 	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
-- 
2.9.3

