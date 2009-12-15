Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19171 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760470AbZLOQ0L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Dec 2009 11:26:11 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount: Retry when server can't be reached
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 15 Dec 2009 11:25:28 -0500
Message-ID: <20091215162212.29903.68998.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We want new default behavior from mount.nfs when the server refuses a
connection.  Since connection refusal can be spurious (for example,
if the server is rebooting), mount.nfs should retry.

NFS shares that are automatically mounted by /etc/fstab at boot
time may be problematic.  The new behavior can be disabled by
specifying the "retry=0" mount option, or these mounts can be changed
to background mounts by specifying the "bg" option.

A kernel code change is still required for the mount(2) system call to
return ECONNREFUSED for NFSv4 mounts.  For v2/v3, the version and
transport negotiation logic in mount.nfs should drive a retry if the
server's rpcbind can't be reached.

Note that if a v2/v3 mount request encounters an unregistered NFS
service, it will still fail immediately.  That wouldn't be too hard
to change as well, but there are many more corner cases there where
failing immediately is appropriate.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Steve-

I propose this solution for causing mount.nfs to retry when a server
refuses a TCP connection.  This has seen light testing here.

The kernel code change mentioned above for NFSv4 should be in 2.6.33.

 utils/mount/nfs.man   |    6 +++++-
 utils/mount/stropts.c |    4 ++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 93bd642..c64de5f 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -363,7 +363,11 @@ The number of minutes that the
 command retries an NFS mount operation
 in the foreground or background before giving up.
 If this option is not specified, the default value for foreground mounts
-is 2 minutes, and the default value for background mounts is 10000 minutes (80 minutes shy of one week).
+is 2 minutes, and the default value for background mounts is 10000 minutes
+(80 minutes shy of one week).
+If a value of zero is specified, the
+.BR mount (8)
+command exits immediately after the first failure.
 .TP 1.5i
 .BI sec= mode
 The RPCGSS security flavor to use for accessing files on this mount point.
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9a13509..8e7e8a5 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -520,6 +520,10 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
 				 nfs_saddr, nfs_salen, &nfs_pmap)) {
 		errno = ESPIPE;
+		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
+			errno = EOPNOTSUPP;
+		else if (rpc_createerr.cf_error.re_errno != 0)
+			errno = rpc_createerr.cf_error.re_errno;
 		return 0;
 	}
 

