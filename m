Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:45769 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbaKWRnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Nov 2014 12:43:37 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so10453709wgg.8
        for <linux-nfs@vger.kernel.org>; Sun, 23 Nov 2014 09:43:36 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Steve Dickson <steved@redhat.com>
Subject: [PATCH libtirpc v2] pkg-config: needs pthread as private library
Date: Sun, 23 Nov 2014 18:43:29 +0100
Message-Id: <1416764609-1822-1-git-send-email-yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

libtirpc needs pthreads. This is automatically pulled in when linking
with the shared library, thanks to the DT_NEEDED ELF tags.

But for a static library, there is no such mechanism to identify
required libraries.

Thus, add -lpthread to the private libraries in the pkg-config file.

Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Steve Dickson <steved@redhat.com>

---
Changes v1 -> v2:
  - posted publicly in appropriate locations  (thanks Steve)
---
 libtirpc.pc.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/libtirpc.pc.in b/libtirpc.pc.in
index ec4cf75..38034c5 100644
--- a/libtirpc.pc.in
+++ b/libtirpc.pc.in
@@ -8,4 +8,5 @@ Description: Transport Independent RPC Library
 Requires:
 Version: @PACKAGE_VERSION@
 Libs: -L@libdir@ -ltirpc
+Libs.private: -lpthread
 Cflags: -I@includedir@/tirpc
-- 
1.9.1

