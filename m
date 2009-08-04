From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] nfs(5): Add description of lookupcache mount option
Date: Tue, 04 Aug 2009 14:06:44 -0400
Message-ID: <20090804180644.21944.34947.stgit@matisse.1015granger.net>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56540 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933160AbZHDSHb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 14:07:31 -0400
In-Reply-To: <20090804180334.21944.64404.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See kernel commit 7973c1f1.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   96 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 13de524..87a71c6 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -422,6 +422,49 @@ NFS mount points allowed on a client, but NFS servers must be configured
 to allow clients to connect via non-privileged source ports.
 .IP
 Refer to the SECURITY CONSIDERATIONS section for important details.
+.TP 1.5i
+.BI lookupcache= mode
+Specifies how the kernel manages its cache of directory entries
+for a given mount point.
+.I mode
+can be one of
+.BR all ,
+.BR none ,
+.BR pos ,
+or
+.BR positive .
+This option is supported in kernels 2.6.28 and later.
+.IP
+The Linux NFS client caches the result of all NFS LOOKUP requests.
+If the requested directory entry exists on the server,
+the result is referred to as
+.IR positive .
+If the requested directory entry does not exist on the server,
+the result is referred to as
+.IR negative .
+.IP
+If this option is not specified, or if
+.B all
+is specified, the client assumes both types of directory cache entries
+are valid until their parent directory's cached attributes expire.
+.IP
+If
+.BR pos " or " positive
+is specified, the client assumes positive entries are valid
+until their parent directory's cached attributes expire, but
+always revalidates negative entires before an application
+can use them.
+.IP
+If
+.B none
+is specified,
+the client revalidates both types of directory cache entries
+before an application can use them.
+This permits quick detection of files that were created or removed
+by other clients, but can impact application and server performance.
+.IP
+The DATA AND METADATA COHERENCE section contains a
+detailed discussion of these trade-offs.
 .SS "Valid options for the nfs file system type"
 Use these options, along with the options in the above subsection,
 for mounting the
@@ -1017,6 +1060,59 @@ If absolute cache coherence among clients is required,
 applications should use file locking. Alternatively, applications 
 can also open their files with the O_DIRECT flag
 to disable data caching entirely.
+.SS "Directory entry caching"
+The Linux NFS client caches the result of all NFS LOOKUP requests.
+If the requested directory entry exists on the server,
+the result is referred to as a
+.IR positive " lookup result.
+If the requested directory entry does not exist on the server
+(that is, the server returned ENOENT),
+the result is referred to as
+.IR negative " lookup result.
+.P
+To detect when directory entries have been added or removed
+on the server,
+the Linux NFS client watches a directory's mtime.
+If the client detects a change in a directory's mtime,
+the client drops all cached LOOKUP results for that directory.
+Since the directory's mtime is a cached attribute, it may
+take some time before a client notices it has changed.
+See the descriptions of the
+.BR acdirmin ", " acdirmax ", and " noac
+mount options for more information about
+how long a directory's mtime is cached.
+.P
+Caching directory entries improves the performance of applications that
+do not share files with applications on other clients.
+Using cached information about directories can interfere
+with applications that run concurrently on multiple clients and
+need to detect the creation or removal of files quickly, however.
+The
+.B lookupcache
+mount option allows some tuning of directory entry caching behavior.
+.P
+Before kernel release 2.6.28,
+the Linux NFS client tracked only positive lookup results.
+This permitted applications to detect new directory entries
+created by other clients quickly while still providing some of the
+performance benefits of caching.
+If an application depends on the previous lookup caching behavior
+of the Linux NFS client, you can use
+.BR lookupcache=positive .
+.P
+If the client ignores its cache and validates every application
+lookup request with the server,
+that client can immediately detect when a new directory
+entry has been either created or removed by another client.
+You can specify this behavior using
+.BR lookupcache=none .
+The extra NFS requests needed if the client does not
+cache directory entries can exact a performance penalty.
+Disabling lookup caching
+should result in less of a performance penalty than using
+.BR noac ,
+and has no effect on how the NFS client caches the attributes of files.
+.P
 .SS "The sync mount option"
 The NFS client treats the
 .B sync

