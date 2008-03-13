From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: fix encode_fsinfo_maxsz
Date: Thu, 13 Mar 2008 15:26:30 +0200
Message-ID: <1205414790-1710-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bzq-219-195-70.pop.bezeqint.net ([62.219.195.70]:51867 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbYCMN1R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2008 09:27:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

The previous value was not taking into account space for bitmap array size.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 51dd380..0277821 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -110,7 +110,7 @@ static int nfs4_stat_to_errno(int);
 #define decode_savefh_maxsz     (op_decode_hdr_maxsz)
 #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
 #define decode_restorefh_maxsz  (op_decode_hdr_maxsz)
-#define encode_fsinfo_maxsz	(op_encode_hdr_maxsz + 2)
+#define encode_fsinfo_maxsz	(encode_getattr_maxsz)
 #define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 11)
 #define encode_renew_maxsz	(op_encode_hdr_maxsz + 3)
 #define decode_renew_maxsz	(op_decode_hdr_maxsz)
-- 
1.5.3.3

