Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:62436 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaKQQXl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 11:23:41 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so181759ier.13
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 08:23:41 -0800 (PST)
Subject: [PATCH] mountstats: Fix spurious I/O errors
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 17 Nov 2014 11:23:39 -0500
Message-ID: <20141117162339.15387.88477.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When running mountstats under "watch," occassionally the output
shows "close failed in file object desctructor: sys.excepthook is
missing" and the data display is messed up. This seems to be a
common problem when Python script output is piped to another
program.

Ensure stdout/stderr is completely flushed before mountstats exits,
and add an IOError exception handler to catch these exceptions
gracefully.

Solution suggested by: http://bugs.python.org/issue11380

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 tools/mountstats/mountstats.py |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 9a6ec43..e6a456c 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -612,8 +612,12 @@ try:
         nfsstat_command()
     elif prog == 'ms-iostat':
         iostat_command()
+    sys.stdout.close()
+    sys.stderr.close()
 except KeyboardInterrupt:
     print('Caught ^C... exiting')
     sys.exit(1)
+except IOError:
+    pass
 
 sys.exit(0)

