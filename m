Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:38387 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbaFDVCO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:14 -0400
Received: by mail-ie0-f176.google.com with SMTP id rl12so67556iec.7
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:14 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 02/17] 4.1 server: service RECLAIM_COMPLETE operations
Date: Wed,  4 Jun 2014 17:01:50 -0400
Message-Id: <1401915726-29092-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just return ok!

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs4server.py | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 65fb9af..3607dc0 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -1809,6 +1809,9 @@ class NFS4Server(rpc.Server):
         with find_state(env, arg.deleg_stateid, allow_0=False) as state:
             state.delegreturn()
         return encode_status(NFS4_OK)
+
+    def op_reclaim_complete(self, arg, env):
+        return encode_status(NFS4_OK)
     
     def op_getdevicelist(self, arg, env): # STUB
         check_session(env)
-- 
1.8.5.2 (Apple Git-48)

