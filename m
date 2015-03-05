Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:45737 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178AbbCEQGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2015 11:06:41 -0500
Received: by igjz20 with SMTP id z20so46957068igj.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Mar 2015 08:06:41 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id mi3sm13053495igb.13.2015.03.05.08.06.39
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 08:06:39 -0800 (PST)
Subject: [PATCH] nfs(5): Update close-to-open discussion in DATA AND
 METADATA COHERENCY
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 05 Mar 2015 11:06:37 -0500
Message-ID: <20150305155511.26051.93398.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The discussion of close-to-open describes the GETATTR and data flush
behavior implemented on the Linux client, but does not describe what
happens between open() and close(). The lack of strict cache
coherency surprises users who expect single-system behavior
similar to local file systems.

An explicit description of this behavior is inserted.  Additional
clarifications are made of the surrounding text.

Text contributed by Trond, Bruce, Chuck, and Chris Perl.

Link: http://marc.info/?l=linux-nfs&m=142472673425307&w=2
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi-

TBH I'm more concerned about nfs(5) than I am about the antique NFS
FAQ. Besides, my sf.net login expired long ago, after I retired from
FAQ maintenance.

Thus I'm proposing this change to nfs(5). Then I'd like to suggest
eventually replacing the bulk of FAQ A8 with a pointer to the DATA
AND METADATA COHERENCE section of nfs(5).

Comments?

 utils/mount/nfs.man |   29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index fe4f9b1..4df8a16 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1148,9 +1148,11 @@ is expensive to achieve, especially on wide area networks.
 As such, NFS settles for weaker cache coherence that
 satisfies the requirements of most file sharing types.
 .SS "Close-to-open cache consistency"
-Typically file sharing is completely sequential.
-First client A opens a file, writes something to it, then closes it.
-Then client B opens the same file, and reads the changes.
+Typically applications share files in a sequential manner.
+First application A opens a file, writes something to it, then closes it.
+Then application B opens the same file, and reads the changes.
+This typical sharing behavior is leveraged to keep NFS operations
+from multiple clients fast.
 .P
 When an application opens a file stored on an NFS version 3 server,
 the NFS client checks that the file exists on the server
@@ -1165,14 +1167,27 @@ This also gives the NFS client an opportunity to report
 write errors to the application via the return code from
 .BR close (2).
 .P
-The behavior of checking at open time and flushing at close time
-is referred to as
+To maintain good performance, the NFS client only occasionally checks
+whether its cache remains valid between open() and close().
+.P
+The behavior of checking a file at open time and flushing at close time,
+with relaxed consistency checking in between, is referred to as
 .IR "close-to-open cache consistency" ,
 or
 .IR CTO .
-It can be disabled for an entire mount point using the
+.P
+Note that applications cannot rely on implicit cache revalidation
+while a file is held open.
+If an open file changes on the NFS server, read() on clients may return
+stale data or holes, unless the application explicitly serializes
+file changes with reads using file locking or some other technique.
+.P
+In rare cases, sending a GETATTR on every open()
+may still be too much overhead.
+Close-to-open can be relaxed further
+for an entire NFS version 3 mount point using the
 .B nocto
-mount option.
+mount option, at the cost of even weaker client cache coherence.
 .SS "Weak cache consistency"
 There are still opportunities for a client's data cache
 to contain stale data.

