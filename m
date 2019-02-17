Return-Path: <SRS0=2fom=QY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A85BC43381
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 16:38:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D8652190C
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 16:38:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726371AbfBQQiM convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 17 Feb 2019 11:38:12 -0500
Received: from mout.gmx.net ([212.227.17.21]:36075 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726016AbfBQQiM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 17 Feb 2019 11:38:12 -0500
Received: from onion.lan ([62.178.200.226]) by mail.gmx.com (mrgmx102
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0MM0bQ-1gyiJ40tcC-007mzH for
 <linux-nfs@vger.kernel.org>; Sun, 17 Feb 2019 17:38:10 +0100
Date:   Sun, 17 Feb 2019 17:39:01 +0100
From:   Peter Wagner <tripolar@gmx.at>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
Message-ID: <20190217173901.33296254@onion.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
X-Provags-ID: V03:K1:JKTjH7eHaOvGbRXCLbgsPFjy977x56tGarePuJ1Yxjw7094IVHq
 j6LxnWOd0HAJCsYB8D0FJ96xaahv287cAAnjyEjqELBr4Lkb5bCjjLU28PYAHAxBVOk5fwI
 hi6pqRbDN1HAqJNvTlpdw6b0lM+9JySgk3NMxe3NcWd+g97CADaAYrblNl2Tw3C0K7inVUk
 ns8I+GQHfKwlg/A3zFCzQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:ulBNWzYNPWQ=:433w41sYHbrEuEpRn81GPB
 bivkNpXDP+zZU/BmRtH8wInhIkW9wwo2Els6v6U+S5gut+QGqrbajPJzJqccX3qUauWHlL1CD
 wZUzR2L8dftlqwf5X5lRr4iTfMYxP5xtQ/cdMbaQ5jnN54GKL7LqvEiakj6EwmmOXpMDw/K8f
 PIk6veOMemP0+wh7TfnK1mfKtb0UpvaWiP9KwAoeYhe1NrNhpElAGTqDH8KZJpXZCy1jzW4a6
 38XfGy2yJO7XAQswfjIhDozGZOxugpAKVnAgqgoiDFIOQxQ8U6xKQhLrLXCYOq9KnAX2hXm5F
 jfrc/ybycHeKr7raBJoJMxrArY+vlfwmEn8jvPmpQt0k55/2CzV9SLbzx4aaBa7czH7jJe4/7
 mNj+uTO4nOgmIYJa+Fc2F3l2VOJEg6DmHb9n4Po0arWCTVe6OBZ+ohpFAy31I+aRjZpReAY0a
 CRzEKEXzjlNmYSeikfF1SXG4B3ivJ3XEeKTf7D+94WjBWAB3IwBEUo2usfC/wiuEP3NCRxR1D
 BiYRz0qcL8ey9zJbg+oLnUjWpZ2fXRZt3Vgz1zBQblZHSmKw18kvx3VcmnUHavamTKcHbbdrX
 l9YOiUNR2aSZ4/QWQuU2Hpku3nTDg6Zn6ixFhNqYMhxoQxx3omvEVSdNXaTenNb7uH42Qr1iL
 +684AjO/zMTkytsDZ5iQM/TbglCoXNmQ9gGOWfffSYq+6BIBx8tpEscCMvOIKGm080k5GEEdG
 ghE01l1MsDYRfTacKt8IyhidgaosQnHioy65rwdIIEj2hmrbkkWPtz6XGRe4dEHyn/oIYtt2/
 AvkD25B7YH4n1J4e/WbQmtX+gpA+yL+k/Bdhw3YQd2Yn376N8InO/biJhFJ6sJCE05ODGlLa5
 j9PCKuQXdDUH9E+yJ1fh5doIROxySKezRcmewmBS6tSIQ3Ya2+KXn5Gbi1pyoYB7aaiv3cRsj
 54hWWDk8JSA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Afer the update to musl 1.1.21 freeaddrinfo is broken in some places in
the nfs-utils code because glibc seems to ignore when freeaddrinfo is
called with a NULL pointer which seems to be not defined in the spec.

See: https://www.openwall.com/lists/musl/2019/02/03/4

The free in support/export/hostname.c is removed too

See: https://www.openwall.com/lists/musl/2019/02/17/2


From 43e27735553b4c1e75964f32b2f887e84398055f Mon Sep 17 00:00:00 2001
From: Peter Wagner <tripolar@gmx.at>
Date: Sun, 17 Feb 2019 17:32:08 +0100
Subject: [PATCH] fix addrinfo usage

Signed-off-by: Peter Wagner <tripolar@gmx.at>
---
 support/export/client.c   |  3 ++-
 support/export/hostname.c |  2 +-
 utils/exportfs/exportfs.c | 12 ++++++++----
 utils/mount/stropts.c     |  3 ++-
 utils/mountd/cache.c      |  6 ++++--
 utils/statd/hostname.c    |  6 ++++--
 6 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index baf59c8..750eb7d 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -309,7 +309,8 @@ client_lookup(char *hname, int canonical)
 		init_addrlist(clp, ai);
 
 out:
-	freeaddrinfo(ai);
+	if (ai)
+		freeaddrinfo(ai);
 	return clp;
 }
 
diff --git a/support/export/hostname.c b/support/export/hostname.c
index 5c4c824..710bf61 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -354,7 +354,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
 	 */
 	if (ai != NULL) {
-		free(ai->ai_canonname);		/* just in case */
+		//free(ai->ai_canonname);		/* just in case */
 		ai->ai_canonname = strdup(buf);
 		if (ai->ai_canonname == NULL) {
 			freeaddrinfo(ai);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index cd3c979..2f8d59a 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -282,7 +282,8 @@ exportfs_parsed(char *hname, char *path, char *options, int verbose)
 	validate_export(exp);
 
 out:
-	freeaddrinfo(ai);
+	if (ai)
+		freeaddrinfo(ai);
 }
 
 static int exportfs_generic(char *arg, char *options, int verbose)
@@ -395,7 +396,8 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 	if (!success)
 		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
 
-	freeaddrinfo(ai);
+	if (ai)
+		freeaddrinfo(ai);
 }
 
 static int unexportfs_generic(char *arg, int verbose)
@@ -639,8 +641,10 @@ matchhostname(const char *hostname1, const char *hostname2)
 			}
 
 out:
-	freeaddrinfo(results1);
-	freeaddrinfo(results2);
+	if (results1)
+		freeaddrinfo(results1);
+	if (results2)
+		freeaddrinfo(results2);
 	return result;
 }
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0a25b1f..8b7a0a8 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -1268,7 +1268,8 @@ int nfsmount_string(const char *spec, const char *node, char *type,
 	} else
 		nfs_error(_("%s: internal option parsing error"), progname);
 
-	freeaddrinfo(mi.address);
+	if (mi.address)
+		freeaddrinfo(mi.address);
 	free(mi.hostname);
 	return retval;
 }
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7e8d403..8cee1c8 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -834,7 +834,8 @@ static void nfsd_fh(int f)
 out:
 	if (found_path)
 		free(found_path);
-	freeaddrinfo(ai);
+	if(ai)
+		freeaddrinfo(ai);
 	free(dom);
 	xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? found->e_path : NULL);
 }
@@ -1355,7 +1356,8 @@ static void nfsd_export(int f)
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);
 	if (dom) free(dom);
 	if (path) free(path);
-	freeaddrinfo(ai);
+	if (ai)
+		freeaddrinfo(ai);
 }
 
 
diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 8cccdb8..6556ab1 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -308,8 +308,10 @@ statd_matchhostname(const char *hostname1, const char *hostname2)
 			}
 
 out:
-	freeaddrinfo(results2);
-	freeaddrinfo(results1);
+	if (results2)
+		freeaddrinfo(results2);
+	if (results1)
+		freeaddrinfo(results1);
 
 	xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
 			hostname1, hostname2,
-- 
2.20.1

