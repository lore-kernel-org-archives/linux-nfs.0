Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.kapsi.fi ([217.30.184.167]:49270 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179AbbBPXHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Feb 2015 18:07:11 -0500
From: Mikko Rapeli <mikko.rapeli@iki.fi>
To: linux-kernel@vger.kernel.org
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org
Subject: [PATCH 18/45] cld.h: include stdint.h in userspace
Date: Tue, 17 Feb 2015 00:05:21 +0100
Message-Id: <1424127948-22484-19-git-send-email-mikko.rapeli@iki.fi>
In-Reply-To: <1424127948-22484-1-git-send-email-mikko.rapeli@iki.fi>
References: <1424127948-22484-1-git-send-email-mikko.rapeli@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes compilation error:

linux/nfsd/cld.h:40:2: error: unknown type name ‘uint16_t’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/nfsd/cld.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cld.h
index f14a9ab..9f60f9c 100644
--- a/include/uapi/linux/nfsd/cld.h
+++ b/include/uapi/linux/nfsd/cld.h
@@ -22,6 +22,12 @@
 #ifndef _NFSD_CLD_H
 #define _NFSD_CLD_H
 
+#ifdef __KERNEL__
+#include <linux/types.h>
+#else
+#include <stdint.h>
+#endif
+
 /* latest upcall version available */
 #define CLD_UPCALL_VERSION 1
 
-- 
2.1.4

