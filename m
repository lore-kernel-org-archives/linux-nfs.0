From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/22] gss_krb5: Don't expect blocksize to always be 8 when calculating padding
Date: Wed, 14 Apr 2010 13:36:39 -0400
Message-ID: <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756543Ab0DNRhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:17 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawJx021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:00 -0700 (PDT)
In-Reply-To: <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 496281f..5d6c3b1 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -12,10 +12,7 @@
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

