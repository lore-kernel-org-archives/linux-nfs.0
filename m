Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:60182 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbaFWQ6G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:58:06 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 23 Jun 2014 10:58:05 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E165C3E4004C
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 10:58:02 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5NGuwoq51511484
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 18:56:58 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5NGw210014451
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 10:58:02 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: [PATCH 1/2] Check for None to avoid python exception.
Date: Mon, 23 Jun 2014 11:57:41 -0500
Message-Id: <1403542662-8450-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 nfs4.0/servertests/st_delegation.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index 4965f5a..4da3a7a 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -35,7 +35,7 @@ def _recall(c, op, cbid):
         print "CALLBACK error in _recall:", e
         res = None
     _lock.release()
-    if res.status != NFS4_OK:
+    if res is not None and res.status != NFS4_OK:
         t_error = _handle_error(c, res, ops)
         t = threading.Thread(target=t_error.run)
         t.setDaemon(1)
-- 
1.8.3.1

