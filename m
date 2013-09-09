Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab3IIRRg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Sep 2013 13:17:36 -0400
Message-ID: <1378747050.4117.122.camel@serendib>
Subject: [PATCH] nfsiostat: periodically flush stdout
From: Harshula Jayasuriya <harshula@redhat.com>
To: Steve Dickson <SteveD@redhat.com>, Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 10 Sep 2013 03:17:30 +1000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* In a shell script, when nfsiostat is run in the background with
  stdout redirected to a file, flush stdout periodically to ensure
  that we do not lose the buffered output if the nfsiostat process 
  is killed.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
---
 tools/nfs-iostat/nfs-iostat.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index c035537..155581c 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -413,6 +413,8 @@ class DeviceData:
             self.__print_rpc_op_stats('WRITE', sample_time)
             self.__print_page_stats(sample_time)
 
+        sys.stdout.flush()
+
 #
 # Functions
 #
-- 
1.8.3.1

