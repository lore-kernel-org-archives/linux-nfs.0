Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:57483 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbaFENzu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:50 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so2925560igd.5
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:49 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 01/16] dataserver: reclaim_complete after create_session
Date: Thu,  5 Jun 2014 09:55:29 -0400
Message-Id: <1401976544-36374-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send RECLAIM_COMPLETE after CREATE_SESSION. This enables backend
communication to v4.1 linux nfsd servers (i/o through MDS only).

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 1 +
 1 file changed, 1 insertion(+)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index 65e4f55..ade55e1 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -54,6 +54,7 @@ class DataServer(object):
         # as wide as the client/MDS channel (at least for linux client)
         fore_attrs = channel_attrs4(0, 16384, 16384, 2868, 8, 8, [])
         self.sess = c.create_session(fore_attrs=fore_attrs)
+        sess.compound([op.reclaim_complete(FALSE)])
         self.make_root()
 
     def disconnect(self):
-- 
1.8.5.2 (Apple Git-48)

