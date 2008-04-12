From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS Client mounts hang when exported directory do not exist
Date: Fri, 11 Apr 2008 20:03:06 -0400
Message-ID: <47FFFC3A.2040708@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <fedora-kernel-list-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-kernel-list>
List-Post: <mailto:fedora-kernel-list@redhat.com>
List-Help: <mailto:fedora-kernel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=subscribe>
Sender: fedora-kernel-list-bounces@redhat.com
Errors-To: fedora-kernel-list-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes a regression that was introduced by the string based mounts. 

nfs_mount() statically returns -EACCES for every error returned
by the remote mounted. This is incorrect because -EACCES is
an non-fatal error to the mount.nfs command. This error causes
mount.nfs to retry the mount even in the case when the exported
directory does not exist. 

This patch maps the errors returned by the remote mountd into
valid errno values, exactly how it was done pre-string based 
mounts. By returning the correct errno enables mount.nfs 
to do the right thing.  

Signed-off-by: Steve Dickson <steved@redhat.com>
---
Take 2- Why reinvent the wheel, as Trond pointed out using
nfs_stat_to_errno() makes more sense and is makes things much 
similar, something I'm always a fan of... 

diff -up linux/fs/nfs/mount_clnt.c.orig linux/fs/nfs/mount_clnt.c
--- linux/fs/nfs/mount_clnt.c.orig	2008-04-09 08:32:43.000000000 -0400
+++ linux/fs/nfs/mount_clnt.c	2008-04-11 19:42:16.000000000 -0400
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_fs.h>
+#include "internal.h"
 
 #ifdef RPC_DEBUG
 # define NFSDBG_FACILITY	NFSDBG_MOUNT
@@ -98,7 +99,7 @@ out_call_err:
 
 out_mnt_err:
 	dprintk("NFS: MNT server returned result %d\n", result.status);
-	status = -EACCES;
+	status = -nfs_stat_to_errno(result.status);
 	goto out;
 }
