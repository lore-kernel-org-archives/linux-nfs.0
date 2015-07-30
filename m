Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938AbbG3VPT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 17:15:19 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 95CBCA2C0A
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 21:15:18 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-48-41.rdu2.redhat.com [10.10.48.41])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t6ULFHr8026405
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 17:15:18 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.gssd: Only clear the retval if it has not been set
Date: Thu, 30 Jul 2015 17:15:16 -0400
Message-Id: <1438290916-12071-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In gssd_search_krb5_keytab() an error code can be
cleared by blindly setting retval to zero.

Reported-by: Jianhong Yin <jiyin@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/krb5_util.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index f1ebc0d..ecf17a2 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -772,7 +772,9 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 			    "keytab '%s'\n", k5err, kt_name);
 	}
 
-	retval = 0;
+	/* Only clear the retval if has not been set */
+	if (retval < 0)
+		retval = 0;
   out:
 	free(k5err);
 	return retval;
-- 
2.4.3

