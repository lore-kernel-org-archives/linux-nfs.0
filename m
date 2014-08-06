Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f181.google.com ([209.85.217.181]:48241 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbaHFGZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:17 -0400
Received: by mail-lb0-f181.google.com with SMTP id 10so1506271lbg.40
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:15 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 02/11] Fix header include for definition of NULL
Date: Wed,  6 Aug 2014 08:24:57 +0200
Message-Id: <1407306306-29796-3-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
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
2.0.4

