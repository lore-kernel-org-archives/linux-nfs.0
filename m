Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:52660 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbaFENzw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:52 -0400
Received: by mail-ig0-f174.google.com with SMTP id h3so7571491igd.7
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:51 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 03/16] 4.1 server: avoid traceback in DS disconnect()
Date: Thu,  5 Jun 2014 09:55:31 -0400
Message-Id: <1401976544-36374-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Session objects have no destroy method.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index aca07ee..435ddd2 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -59,7 +59,7 @@ class DataServer(object):
         self.make_root()
 
     def disconnect(self):
-        self.sess.destroy()
+        pass
 
     def execute(self, ops, exceptions=[], delay=5, maxretries=3):
         """ execute the NFS call
-- 
1.8.5.2 (Apple Git-48)

