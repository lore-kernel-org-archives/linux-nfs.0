Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754381AbaGOPJx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:53 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 15/15] auth_des: Converted some of the debugging syslog calls to LIBTIRPC_DEBUG() calls
Date: Tue, 15 Jul 2014 11:09:34 -0400
Message-Id: <1405436974-4161-16-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_des.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/src/auth_des.c b/src/auth_des.c
index f0c8b8c..cff777c 100644
--- a/src/auth_des.c
+++ b/src/auth_des.c
@@ -54,6 +54,8 @@
 #endif
 #include <sys/cdefs.h>
 
+#include "debug.h"
+
 #define USEC_PER_SEC		1000000
 #define RTIME_TIMEOUT		5	/* seconds to wait for sync */
 
@@ -399,7 +401,7 @@ authdes_validate(AUTH *auth, struct opaque_auth *rverf)
 	 */
 	if (bcmp((char *)&ad->ad_timestamp, (char *)&verf.adv_timestamp,
 		 sizeof(struct timeval)) != 0) {
-		syslog(LOG_DEBUG, "authdes_validate: verifier mismatch");
+		LIBTIRPC_DEBUG(1, ("authdes_validate: verifier mismatch"));
 		return (FALSE);
 	}
 
@@ -433,16 +435,15 @@ authdes_refresh(AUTH *auth, void *dummy)
 			 * Hope the clocks are synced!
 			 */
 			ad->ad_dosync = 0;
-			syslog(LOG_DEBUG,
-			    "authdes_refresh: unable to synchronize clock");
+			LIBTIRPC_DEBUG(1, ("authdes_refresh: unable to synchronize clock"));
 		 }
 	}
 	ad->ad_xkey = auth->ah_key;
 	pkey.n_bytes = (char *)(ad->ad_pkey);
 	pkey.n_len = (u_int)strlen((char *)ad->ad_pkey) + 1;
 	if (key_encryptsession_pk(ad->ad_servername, &pkey, &ad->ad_xkey) < 0) {
-		syslog(LOG_INFO,
-		    "authdes_refresh: keyserv(1m) is unable to encrypt session key");
+		LIBTIRPC_DEBUG(1,
+		    ("authdes_refresh: keyserv(1m) is unable to encrypt session key"));
 		return (FALSE);
 	}
 	cred->adc_fullname.key = ad->ad_xkey;
-- 
1.9.3

