From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 28/30] NFS: Client mounts hang when exported directory do
	not exist
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221954.20945.86207.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Steve Dickson <steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbYJGWcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:48 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <SteveD@redhat.com>

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
[Trond.Myklebust@netapp.com: nfs_stat_to_errno() now correctly returns
 negative errors, so remove the sign change.]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/mount_clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 779d2eb..086a683 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
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
+	status = nfs_stat_to_errno(result.status);
 	goto out;
 }
 

