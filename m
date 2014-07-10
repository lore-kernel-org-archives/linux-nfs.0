Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:49024 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaGJPxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 11:53:37 -0400
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <srimalik@in.ibm.com>;
	Thu, 10 Jul 2014 21:23:34 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BD23BE004B
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 21:24:58 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6AFt3tY5505438
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 21:25:03 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6AFrUhQ022893
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 21:23:30 +0530
From: Srikrishan Malik <srimalik@in.ibm.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Srikrishan Malik <srimalik@in.ibm.com>
Subject: [PATCH] Use original reserved port setting for reconnect.
Date: Thu, 10 Jul 2014 21:22:06 +0530
Message-Id: <1405007526-2234-1-git-send-email-srimalik@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Srikrishan Malik <srimalik@in.ibm.com>
---
Reconnect ignores the "--secure" arg after connection reset.                  
If the export is secure then OPs after reconnect fail with NFS4ERR_ACCESS.
 nfs4.0/lib/rpc/rpc.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 8b39df4..5ef2e3e 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -305,7 +305,8 @@ class RPCClient(object):
         self.lock.acquire()
         self._socket[t].close()
         out = self._socket[t] = socket.socket(self.af, socket.SOCK_STREAM)
-        # out.bind
+        if self.uselowport:
+            self.bindsocket(out)
         out.connect((self.remotehost, self.remoteport))
         out.settimeout(self.timeout)
         self.lock.release()
-- 
1.7.1

