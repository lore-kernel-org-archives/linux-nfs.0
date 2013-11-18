Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f171.google.com ([209.85.161.171]:64207 "EHLO
	mail-gg0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab3KRPnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 10:43:08 -0500
Received: by mail-gg0-f171.google.com with SMTP id j1so379210ggn.16
        for <linux-nfs@vger.kernel.org>; Mon, 18 Nov 2013 07:43:07 -0800 (PST)
Subject: [PATCH] nfs(5): Treatment of *atime mount options
To: steved@redhat.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@netapp.com
Date: Mon, 18 Nov 2013 10:36:45 -0500
Message-ID: <20131118153645.912.68903.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was reminded recently that NFS treats file atime time stamps
differently than other filesystems.  It also ignores the generic
*atime mount options because it cannot support the atime semantics
of local filesystems.

We should document that somewhere.  nfs(5) seems like a logical
place for it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/nfs.man |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 67031b5..2250963 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1227,6 +1227,65 @@ If absolute cache coherence among clients is required,
 applications should use file locking. Alternatively, applications
 can also open their files with the O_DIRECT flag
 to disable data caching entirely.
+.SS "File timestamp maintainence"
+NFS servers are responsible for managing file and directory timestamps
+.RB ( atime ,
+.BR ctime ", and"
+.BR mtime ).
+When a file is accessed or updated on an NFS server,
+the file's timestamps are updated just like they would be on a filesystem
+local to an application.
+.P
+NFS clients cache file attributes, including timestamps.
+A file's timestamps are updated on NFS clients when its attributes
+are retrieved from the NFS server.
+Thus there may be some delay before timestamp updates
+on an NFS server appear to applications on NFS clients.
+.P
+To comply with the POSIX filesystem standard, the Linux NFS client
+relies on NFS servers to keep a file's
+.B mtime
+and
+.B ctime
+timestamps properly up to date.
+It does this by flushing local data changes to the server
+before reporting
+.B mtime
+to applications via system calls such as
+.BR stat (2).
+.P
+The Linux client handles
+.B atime
+updates more loosely, however.
+NFS clients maintain good performance by caching data,
+but that means that application reads, which normally update
+.BR atime ,
+are not reflected to the server where a file's
+.B atime
+is actually maintained.
+.P
+Because of this caching behavior,
+the Linux NFS client does not support generic atime-related mount options.
+See
+.BR mount (8)
+for details on these options.
+.P
+In particular, the
+.BR atime / noatime ,
+.BR diratime / nodiratime ,
+.BR relatime / norelatime ,
+and
+.BR strictatime / nostrictatime
+mount options have no effect on NFS mounts.
+.P
+.I /proc/mounts
+may report that the
+.B relatime
+mount option is set on NFS mounts, but in fact the
+.B atime
+semantics are always as described here, and are not like
+.B relatime
+semantics.
 .SS "Directory entry caching"
 The Linux NFS client caches the result of all NFS LOOKUP requests.
 If the requested directory entry exists on the server,

