Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f48.google.com ([209.85.215.48]:38563 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaG3LXb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:31 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so757839lab.21
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:29 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 02/11] Fix header include for definition of NULL
Date: Wed, 30 Jul 2014 13:23:10 +0200
Message-Id: <1406719399-1735-3-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NULL is defined in stdlib.h so we need to include that.

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 support/include/sockaddr.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index a1c30f9..446b537 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -27,6 +27,7 @@
 #ifdef HAVE_LIBIO_H
 #include <libio.h>
 #endif
+#include <stdlib.h>
 #include <stdbool.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
-- 
2.0.3

