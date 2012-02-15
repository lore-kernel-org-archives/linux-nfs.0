Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33952 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549Ab2BOWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:45:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] 4.0 tests: kill "Starting Call Back server stub" printk
Date: Wed, 15 Feb 2012 17:45:16 -0500
Message-Id: <1329345920-16608-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1329345920-16608-1-git-send-email-bfields@redhat.com>
References: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The printk doesn't seem especially useful, and it's just clutter if
you want to use output of the scripts somehow.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.0/nfs4lib.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 0a38ebc..c6d6781 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -191,7 +191,6 @@ class CBServer(rpc.RPCServer):
             raise "Bad name %s" % name
 
     def run(self):
-        print "Starting Call Back server stub on port %i" % self.port
         rpc.RPCServer.run(self)
 
     def handle_0(self, data, cred):
-- 
1.7.5.4

