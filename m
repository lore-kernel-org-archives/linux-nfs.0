From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 07/19] Don't expect blocksize to always be 8 when calculating
	padding
Date: Thu, 21 Feb 2008 13:44:22 -0500
Message-ID: <20080221184422.19195.9151.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:33884 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbYBUSoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:22 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 714D54504
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:22 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow blocksizes other than 8 when calculating padding

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 7a0002f..384f470 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -13,10 +13,7 @@
 static inline int
 gss_krb5_padding(int blocksize, int length)
 {
-	/* Most of the code is block-size independent but currently we
-	 * use only 8: */
-	BUG_ON(blocksize != 8);
-	return 8 - (length & 7);
+	return blocksize - (length & (blocksize - 1));
 }
 
 static inline void

