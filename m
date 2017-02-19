Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35984 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751264AbdBSCI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 18 Feb 2017 21:08:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/6] NFSv4: fix getacl head length estimation
Date: Sat, 18 Feb 2017 21:07:45 -0500
Message-Id: <1487470070-32358-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1487470070-32358-1-git-send-email-bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Bitmap and attrlen follow immediately after the op reply header, so I'm
not sure what this extra "+1" was for.

Consequences of this are just minor efficiency (extra calls to
xdr_shrink_bufhead).

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

