Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15958 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053Ab3KOQiH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Nov 2013 11:38:07 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
Date: Fri, 15 Nov 2013 11:38:01 -0500
Message-ID: <1384533481-2254-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

decode_bitmap will only decode up to three bitmaps.  If the xdr buffer
has more than three bitmaps, return -EIO here instead of bailing out in
a later xdr decode.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

This is related to my "NFSv4: fix getacl ERANGE for some ACL buffer sizes"
patch - I noticed that even though we'll only ever parse 3 bitmaps, we don't
error out correctly if more are sent.

This condition is probably never hit, but if it ever is, it'd be nice to
have the code error out where the problem actually occurred.

 fs/nfs/nfs4xdr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5be2868..3866a69 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3146,6 +3146,9 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 		goto out_overflow;
 	bmlen = be32_to_cpup(p);
 
+	if (unlikely(bmlen > 3))
+		goto out_overflow;
+
 	bitmap[0] = bitmap[1] = bitmap[2] = 0;
 	p = xdr_inline_decode(xdr, (bmlen << 2));
 	if (unlikely(!p))
-- 
1.8.3.1 (Apple Git-46)

