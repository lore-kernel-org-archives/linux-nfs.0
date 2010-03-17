From: steved@redhat.com
Subject: [PATCH 03/23] gss_krb5: Don't expect blocksize to always be 8 when calculating padding
Date: Wed, 17 Mar 2010 13:02:48 -0400
Message-ID: <1268845388-9516-4-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:55125 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753146Ab0CQRDL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:03:11 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweD-0003fC-Kc
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:09 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 8bc3701..27d744c 100644
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
+	return blocksize - (length % blocksize);
 }
 
 static inline void
-- 
1.6.6.1

