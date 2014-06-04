Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:47059 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbaFDVCN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:13 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so6796395igb.2
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:12 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 01/17] 4.1 client: reclaim_complete after create_session
Date: Wed,  4 Jun 2014 17:01:49 -0400
Message-Id: <1401915726-29092-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send RECLAIM_COMPLETE after CREATE_SESSION. This enables backend
communication to v4.1 linux nfsd servers (i/o through MDS only).

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs4client.py | 1 +
 1 file changed, 1 insertion(+)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index e750728..0d94a42 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -367,6 +367,7 @@ class ClientRecord(object):
         self.seqid = inc_u32(csr.csr_sequence) # XXX Do we need to check this?
         sess = SessionRecord(csr, self)
         self.c.sessions[sess.sessionid] = sess
+        sess.compound([op.reclaim_complete(FALSE)])
         return sess
 
     def _cb_hook(self, prefix, opname, funct):
-- 
1.8.5.2 (Apple Git-48)

