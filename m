Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f44.google.com ([209.85.215.44]:51266 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaG3LXj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:39 -0400
Received: by mail-la0-f44.google.com with SMTP id e16so780501lan.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:37 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 11/11] exportfs: only do glibc specific hackery on glibc
Date: Wed, 30 Jul 2014 13:23:19 +0200
Message-Id: <1406719399-1735-12-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should not depend on the libc do free(3) on ai_canonname as that is
completely up to implementation and known o break things on uclibc and
musl libc.

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 support/export/hostname.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index d9153e1..30584b4 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -382,6 +382,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 
 	ai = host_pton(buf);
 
+#if !definded(__UCLIBC__) && defined(__GLIBC__)
 	/*
 	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
 	 */
@@ -392,7 +393,9 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 			ai = NULL;
 		}
 	}
+#endif
 
 	return ai;
 }
+
 #endif	/* !HAVE_GETNAMEINFO */
-- 
2.0.3

