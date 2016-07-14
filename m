Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34637 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbcGNCoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2016 22:44:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so4085932pfb.1
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 19:44:37 -0700 (PDT)
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] Gssd: Avoid compiling warning and simplify codes
Message-ID: <839f5fbe-0dea-ea36-d38f-15d0a997edbb@gmail.com>
Date: Thu, 14 Jul 2016 10:44:15 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc -D_GNU_SOURCE -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2    -g -O2 -MT gssd-krb5_util.o -MD -MP -MF .deps/gssd-krb5_util.Tpo -c -o gssd-krb5_util.o `test -f 'krb5_util.c' || echo './'`krb5_util.c
krb5_util.c: In function ‘gssd_acquire_user_cred’:
krb5_util.c:1389:4: warning: this ‘if’ clause does not guard... [-Wmisleading-indentation]
    if (get_verbosity() > 0)
    ^~
krb5_util.c:1392:5: note: ...this statement, but the latter is misleadingly indented as if it is guarded by the ‘if’
     ret = -1;

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/gssd/krb5_util.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index c1e4d2b..b64818a 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1380,17 +1380,17 @@ gssd_acquire_user_cred(gss_cred_id_t *gss_cred)
 	int ret;
 
 	ret = gssd_acquire_krb5_cred(gss_cred);
+	if (ret)
+		return ret;
 
 	/* force validation of cred to check for expiry */
-	if (ret == 0) {
-		maj_stat = gss_inquire_cred(&min_stat, *gss_cred, 
+	maj_stat = gss_inquire_cred(&min_stat, *gss_cred,
 			NULL, NULL, NULL, NULL);
-		if (maj_stat != GSS_S_COMPLETE) {
-			if (get_verbosity() > 0)
-				pgsserr("gss_inquire_cred",
-					maj_stat, min_stat, &krb5oid);
-				ret = -1;
-			}
+	if (maj_stat != GSS_S_COMPLETE) {
+		if (get_verbosity() > 0)
+			pgsserr("gss_inquire_cred",
+				maj_stat, min_stat, &krb5oid);
+		ret = -1;
 	}
 
 	return ret;
-- 
2.7.4

