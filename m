Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:56376 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaFDVCR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:17 -0400
Received: by mail-ig0-f182.google.com with SMTP id a13so1548763igq.9
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:17 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 04/17] 4.1 server: avoid traceback in DS disconnect()
Date: Wed,  4 Jun 2014 17:01:52 -0400
Message-Id: <1401915726-29092-5-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Session objects have no destroy method.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index b8dd903..175dd95 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -58,7 +58,7 @@ class DataServer(object):
         self.make_root()
 
     def disconnect(self):
-        self.sess.destroy()
+        pass
 
     def execute(self, ops, exceptions=[], delay=5, maxretries=3):
         """ execute the NFS call
-- 
1.8.5.2 (Apple Git-48)

