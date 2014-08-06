Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:52610 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbaHFTDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 15:03:20 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so2911491qac.19
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 12:03:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Anna.Schumaker@netapp.com
Subject: [PATCH] nfsd: mark CONFIG_NFSD_FAULT_INJECTION as deprecated
Date: Wed,  6 Aug 2014 15:02:51 -0400
Message-Id: <1407351771-11435-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fault injection code is shaky at best. If you have a lot of stateful
objects, then you can end up overflowing the client's refcount. The code
is not widely used and is starting to become a maintenance burden mark
it DEPRECATED and document that we'll remove it in v3.19.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/Kconfig | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index f994e750e0d1..aad734c0b48a 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -98,11 +98,14 @@ config NFSD_V4_SECURITY_LABEL
 	For now we recommend "Y" only for developers and testers.
 
 config NFSD_FAULT_INJECTION
-	bool "NFS server manual fault injection"
+	bool "NFS server manual fault injection (DEPRECATED)"
 	depends on NFSD_V4 && DEBUG_KERNEL
 	help
 	  This option enables support for manually injecting faults
 	  into the NFS server.  This is intended to be used for
 	  testing error recovery on the NFS client.
 
+	  This feature should not be enabled on production systems
+	  and will be removed in v3.19.
+
 	  If unsure, say N.
-- 
1.9.3

