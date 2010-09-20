Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46321 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448Ab0ITPFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 11:05:37 -0400
Date: Mon, 20 Sep 2010 11:04:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: iisaman@umich.edu
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] TESTS: fix error when rebootscript defined but not
 rebootargs
Message-ID: <20100920150413.GF4580@fieldses.org>
References: <20100920033621.GB18325@fieldses.org>
 <20100920150317.GE4580@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100920150317.GE4580@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 lib/nfs4/servertests/st_reboot.py |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/nfs4/servertests/st_reboot.py b/lib/nfs4/servertests/st_reboot.py
index f924716..4828cb8 100644
--- a/lib/nfs4/servertests/st_reboot.py
+++ b/lib/nfs4/servertests/st_reboot.py
@@ -39,8 +39,10 @@ def _waitForReboot(c):
         sys.stdin.readline()
         print "Continuing with test"
     else:
-        # Invoke the reboot script, passing it rebootargs as an argument.
-        os.system(c.opts.rebootscript + ' ' + c.opts.rebootargs)
+        args = c.opts.rebootscript
+        if c.opts.rebootargs:
+            c.opts.rebootscript += ' ' + c.opts.rebootargs
+        os.system(args)
 
         # Wait until the server is back up.
         # c.null() blocks until it gets a response,
-- 
1.7.0.4

