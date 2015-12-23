Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbbLWQWs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Dec 2015 11:22:48 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 966FA13593
	for <linux-nfs@vger.kernel.org>; Wed, 23 Dec 2015 16:22:48 +0000 (UTC)
Message-ID: <567ACA53.9010807@redhat.com>
Date: Wed, 23 Dec 2015 21:52:43 +0530
From: Rinku Kothiya <rkothiya@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
CC: Mohit Agrawal <moagrawa@redhat.com>
Subject: [nfs-utils PATCH] Set right error after getaddrinfo fails bz 1287468
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rinku Kothiya <rkothiya@redhat.com>

Signed-off-by: Rinku Kothiya <rkothiya@redhat.com>
Signed-off-by: Mohit Agrawal <moagrawa@redhat.com>
---

diff -up nfs-utils-1.3.0/support/nfs/hostname.c.orig 
nfs-utils-1.3.0/support/nfs/hostname.c
--- nfs-utils-1.3.0/support/export/hostname.c.orig      2015-12-08 
15:24:36.705047453 +0530
+++ nfs-utils-1.3.0/support/export/hostname.c   2015-12-08 
15:25:46.614047453 +0530
@@ -179,11 +179,11 @@
         case 0:
                 return ai;
         case EAI_SYSTEM:
-               xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
+               xlog(L_WARNING, "%s: failed to resolve %s: (%d) %m",
                                 __func__, hostname, errno);
                 break;
         default:
-               xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+               xlog(L_WARNING, "%s: failed to resolve %s: %s",
                                 __func__, hostname, gai_strerror(error));
                 break;
         }
diff -up nfs-utils-1.3.0/support/nfs/client.c.orig 
nfs-utils-1.3.0/support/nfs/client.c
--- nfs-utils-1.3.0/support/export/client.c.orig        2015-12-08 
17:08:45.469047453 +0530
+++ nfs-utils-1.3.0/support/export/client.c     2015-12-08 
17:09:01.159047453 +0530
@@ -277,7 +277,7 @@
         if (htype == MCL_FQDN && !canonical) {
                 ai = host_addrinfo(hname);
                 if (!ai) {
-                       xlog(L_ERROR, "Failed to resolve %s", hname);
+                       xlog(L_WARNING, "Failed to resolve %s", hname);
                         goto out;
                 }
                 hname = ai->ai_canonname;

-- 
Thanks and Regards
Rinku Kothiya

