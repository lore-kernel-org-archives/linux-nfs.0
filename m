From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 05/24] Don't expect blocksize to always be 8
	when calculating padding
Date: Tue, 06 May 2008 17:03:56 -0400
Message-ID: <20080506210356.3770.61229.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:31300 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759390AbYEFVD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:03:56 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow blocksizes other than 8 when calculating padding

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index a0660f5..4c14b0a 100644
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

