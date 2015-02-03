Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:37271 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbbBCWsm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Feb 2015 17:48:42 -0500
Received: by mail-ie0-f182.google.com with SMTP id ar1so28996060iec.13
        for <linux-nfs@vger.kernel.org>; Tue, 03 Feb 2015 14:48:41 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: anna.schumaker@netapp.com
Subject: [PATCH] NFS: Add Anna Schumaker as co-maintainer for the NFS client
Date: Tue,  3 Feb 2015 17:48:39 -0500
Message-Id: <1423003719-93920-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anna has essentially been performing the duties of co-maintainer for
the past several years. In recognition of those efforts, I'd like to
add her to the maintainers file.

Cc: Anna Schumaker <anna.schumaker@netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2fa385321245..b30d937c3ec8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6682,6 +6682,7 @@ F:	Documentation/devicetree/bindings/net/nfc/
 
 NFS, SUNRPC, AND LOCKD CLIENTS
 M:	Trond Myklebust <trond.myklebust@primarydata.com>
+M:	Anna Schumaker <anna.schumaker@netapp.com>
 L:	linux-nfs@vger.kernel.org
 W:	http://client.linux-nfs.org
 T:	git git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
-- 
2.1.0

