Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:60448 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbaAPRJS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 12:09:18 -0500
Received: by mail-ig0-f178.google.com with SMTP id uq10so8109302igb.5
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 09:09:17 -0800 (PST)
Received: from seurat.1015granger.net (c-68-40-85-241.hsd1.mi.comcast.net. [68.40.85.241])
        by mx.google.com with ESMTPSA id f5sm12853811igc.4.2014.01.16.09.09.16
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jan 2014 09:09:16 -0800 (PST)
Subject: [PATCH] nfs(5): Clarify DATA AND METADATA COHERENCE section
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 16 Jan 2014 12:09:15 -0500
Message-ID: <20140116170841.1489.82372.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
How about something like this?

 utils/mount/nfs.man |   28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2250963..99c9fc3 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1161,24 +1161,32 @@ perfect cache coherence among their clients.
 Perfect cache coherence among disparate NFS clients
 is expensive to achieve, especially on wide area networks.
 As such, NFS settles for weaker cache coherence that
-satisfies the requirements of most file sharing types. Normally,
-file sharing is completely sequential:
-first client A opens a file, writes something to it, then closes it;
-then client B opens the same file, and reads the changes.
-.DT
+satisfies the requirements of most file sharing types.
 .SS "Close-to-open cache consistency"
-When an application opens a file stored on an NFS server,
-the NFS client checks that it still exists on the server
+Typically file sharing is completely sequential.
+First client A opens a file, writes something to it, then closes it.
+Then client B opens the same file, and reads the changes.
+.P
+When an application opens a file stored on an NFS version 3 server,
+the NFS client checks that the file exists on the server
 and is permitted to the opener by sending a GETATTR or ACCESS request.
+The NFS client sends these requests
+independent of the freshness of the file's attribute cache.
+.P
 When the application closes the file,
 the NFS client writes back any pending changes
 to the file so that the next opener can view the changes.
 This also gives the NFS client an opportunity to report
-any server write errors to the application
-via the return code from
+write errors to the application via the return code from
 .BR close (2).
+.P
 The behavior of checking at open time and flushing at close time
-is referred to as close-to-open cache consistency.
+is referred to as
+.IR "close-to-open cache consistency" ,
+or CTO.
+It can be disabled for an entire mount point using the
+.B nocto
+mount option.
 .SS "Weak cache consistency"
 There are still opportunities for a client's data cache
 to contain stale data.

