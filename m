Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758335Ab2FAVBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:01:36 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] PYNFS rpc drop fix
Date: Tue, 29 May 2012 17:57:54 -0400
Message-Id: <1338328679-28837-2-git-send-email-andros@netapp.com>
In-Reply-To: <1338328679-28837-1-git-send-email-andros@netapp.com>
References: <1338328679-28837-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@netapp.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 rpc/rpc.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 38efcd8..3166632 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -514,7 +514,7 @@ class ConnectionHandler(object):
                         data = self.sockets[fd].recv_records(self.rsize)
                     except socket.error:
                         data = None
-                    if data:
+                    if data is not None:
                         self._event_read(data, fd)
                     else:
                         self._event_close(fd)
-- 
1.7.7.6

