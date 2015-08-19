Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:33468 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887AbbHSUI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2015 16:08:26 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH] rpc.gssd: Replace exit(0) by return in process_krb5_upcall
Date: Wed, 19 Aug 2015 15:58:20 -0400
Message-ID: <1440014300-1502-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

exit(0) silenty reaps the gssd_k5_kt_princ struct, the in-memory
rpc.gssd cache which means that rpc.gssd will get a new TGT and TGS for
each upcall, ignoring a valid TGT in the kerberos credential cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 03afc8b..3fc7bba 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -684,7 +684,7 @@ out:
 		AUTH_DESTROY(auth);
 	if (rpc_clnt)
 		clnt_destroy(rpc_clnt);
-	exit(0);
+	return;
 
 out_return_error:
 	do_error_downcall(fd, uid, downcall_err);
-- 
1.9.3 (Apple Git-50)

