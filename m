Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33950 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab2BOWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:45:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] 4.0 tests: remove 1-second wait on client creation
Date: Wed, 15 Feb 2012 17:45:17 -0500
Message-Id: <1329345920-16608-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1329345920-16608-1-git-send-email-bfields@redhat.com>
References: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I can't figure out why this wait is necessary, and it slows things down.
(Noticed while trying to write a race-condition reproducer requiring
more precise timing.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.0/nfs4lib.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index c6d6781..7185057 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -293,7 +293,6 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         self.cb_control = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
         while 1:
             try:
-                time.sleep(1)
                 self.cb_control.connect(('127.0.0.1', self.cb_server.port))
                 break
             except socket.error:
-- 
1.7.5.4

