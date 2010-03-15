From: steved@redhat.com
Subject: [PATCH 02/22] Don't expect blocksize to always be 8 when calculating padding
Date: Mon, 15 Mar 2010 08:20:07 -0400
Message-ID: <1268655627-18712-3-git-send-email-steved@redhat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:41141 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964912Ab0CON0J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 09:26:09 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Nr9HY-00009j-IK
	for linux-nfs@vger.kernel.org; Mon, 15 Mar 2010 08:20:28 -0400
In-Reply-To: <1268655627-18712-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Allow blocksizes other than 8 when calculating padding

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
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
-- 
1.6.6.1

