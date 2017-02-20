Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38642 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751660AbdBTU1d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Feb 2017 15:27:33 -0500
Date: Mon, 20 Feb 2017 15:27:31 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] NFSv4: fix getacl head length estimation
Message-ID: <20170220202731.GA20882@fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-2-git-send-email-bfields@redhat.com>
 <81d554b6-7b8d-51e8-c7ad-b23acd70f717@gmail.com>
 <20170220155019.GA12335@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170220155019.GA12335@parsley.fieldses.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Bitmap and attrlen follow immediately after the op reply header.  This
was an oversight from commit bf118a342f.

Consequences of this are just minor efficiency (extra calls to
xdr_shrink_bufhead).

Fixes: bf118a342f10 "NFSv4: include bitmap in nfsv4 get acl data"
Reviewed-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

On Mon, Feb 20, 2017 at 10:50:19AM -0500, J. Bruce Fields wrote:
> Thanks for the history, and the review.  I've added a "Fixes:
> bf118a342f10" line.


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

