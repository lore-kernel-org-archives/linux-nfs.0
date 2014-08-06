Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f171.google.com ([209.85.217.171]:63599 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaHFGZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:23 -0400
Received: by mail-lb0-f171.google.com with SMTP id l4so1558065lbv.30
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:21 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 10/11] exportfs: fix test of NULL pointer in host_pton()
Date: Wed,  6 Aug 2014 08:25:05 +0200
Message-Id: <1407306306-29796-11-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

should fix https://bugzilla.redhat.com/show_bug.cgi?id=1083018

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 support/export/hostname.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index ad595d1..d9153e1 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -115,6 +115,11 @@ host_pton(const char *paddr)
 	 * have a real AF_INET presentation address, before invoking
 	 * getaddrinfo(3) to generate the full addrinfo list.
 	 */
+	if (paddr == NULL) {
+		xlog(D_GENERAL, "%s: passed a NULL presentation address",
+			__func__);
+		return NULL;
+	}
 	inet4 = 1;
 	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0)
 		inet4 = 0;
@@ -123,15 +128,12 @@ host_pton(const char *paddr)
 	switch (error) {
 	case 0:
 		if (!inet4 && ai->ai_addr->sa_family == AF_INET) {
+			xlog(D_GENERAL, "%s: failed to convert %s",
+					__func__, paddr);
 			freeaddrinfo(ai);
 			break;
 		}
 		return ai;
-	case EAI_NONAME:
-		if (paddr == NULL)
-			xlog(D_GENERAL, "%s: passed a NULL presentation address",
-				__func__);
-		break;
 	case EAI_SYSTEM:
 		xlog(D_GENERAL, "%s: failed to convert %s: (%d) %m",
 				__func__, paddr, errno);
-- 
2.0.4

