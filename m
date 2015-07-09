Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33260 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbbGIN7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 09:59:33 -0400
Received: by ietj16 with SMTP id j16so3980606iet.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 06:59:32 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 9 Jul 2015 21:59:32 +0800
Message-ID: <CAHnGgyG-01Ga-U_tvVuwLvQD_d9dei57rHzGXZgtYir4U3V5tg@mail.gmail.com>
Subject: [PATCH] [patch]libtirpc: check the makefd_xprt return value
From: ditang chen <ditang.c@gmail.com>
To: steved <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprt may return NULL, so check the return value is necessary.

Signed-off-by: Ditang Chen <ditang.c@gmail.com>
---
 src/svc_vc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/src/svc_vc.c b/src/svc_vc.c
index 9824631..f864951 100644
--- a/src/svc_vc.c
+++ b/src/svc_vc.c
@@ -337,6 +337,8 @@ again:
 	 */

 	newxprt = makefd_xprt(sock, r->sendsize, r->recvsize);
+	if (!newxprt)
+		return (FALSE);

 	if (!__rpc_set_netbuf(&newxprt->xp_rtaddr, &addr, len))
 		return (FALSE);
-- 
1.9.3
