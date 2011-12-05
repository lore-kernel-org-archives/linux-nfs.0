Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:50562 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab1LEUkd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 15:40:33 -0500
Received: by ywa9 with SMTP id 9so4688297ywa.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 12:40:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Retry mounting NFSROOT
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 05 Dec 2011 15:40:30 -0500
Message-ID: <20111205203502.1501.24764.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lukas Razik <linux@razik.name> reports that on his SPARC system,
booting with an NFS root file system stopped working after commit
56463e50 "NFS: Use super.c for NFSROOT mount option parsing."

We found that the network switch to which Lukas' client was attached
was delaying access to the LAN after the client's NIC driver reported
that its link was up.  The delay was longer than the timeouts used in
the NFS client during mounting.

NFSROOT worked for Lukas before commit 56463e50 because in those
kernels, the client's first operation was an rpcbind request to
determine which port the NFS server was listening on.  When that
request failed after a long timeout, the client simply selected the
default NFS port (2049).  By that time the switch was allowing access
to the LAN, and the mount succeeded.

Neither of these client behaviors is desirable, so reverting 56463e50
is really not a choice.  Instead, introduce a mechanism that retries
the NFSROOT mount request several times.  This is the same tactic that
normal user space NFS mounts employ to overcome server and network
delays.

Signed-off-by: Lukas Razik <linux@razik.name>
[ cel: match kernel coding style, add proper patch description ]
[ cel: add exponential back-off ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Lukas Razik <linux@razik.name>
Cc: stable@kernel.org # > 2.6.38
---

Lukas verified that his set-up works with this patch.  I have not
confirmed that the exponential back-off logic is working as designed.
Unless someone here can try this out with a non-communicative NFS
server, maybe we should drop this into linux-next for a bit.

 init/do_mounts.c |   35 +++++++++++++++++++++++++++++++----
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/init/do_mounts.c b/init/do_mounts.c
index c0851a8..ef6478f 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -360,15 +360,42 @@ out:
 }
  
 #ifdef CONFIG_ROOT_NFS
+
+#define NFSROOT_TIMEOUT_MIN	5
+#define NFSROOT_TIMEOUT_MAX	30
+#define NFSROOT_RETRY_MAX	5
+
 static int __init mount_nfs_root(void)
 {
 	char *root_dev, *root_data;
+	unsigned int timeout;
+	int try, err;
 
-	if (nfs_root_data(&root_dev, &root_data) != 0)
-		return 0;
-	if (do_mount_root(root_dev, "nfs", root_mountflags, root_data) != 0)
+	err = nfs_root_data(&root_dev, &root_data);
+	if (err != 0)
 		return 0;
-	return 1;
+
+	/*
+	 * The server or network may not be ready, so try several
+	 * times.  Stop after a few tries in case the client wants
+	 * to fall back to other boot methods.
+	 */
+	timeout = NFSROOT_TIMEOUT_MIN;
+	for (try = 1; ; try++) {
+		err = do_mount_root(root_dev, "nfs",
+					root_mountflags, root_data);
+		if (err == 0)
+			return 1;
+		if (try > NFSROOT_RETRY_MAX)
+			break;
+
+		/* Wait, in case the server refused us immediately */
+		ssleep(timeout);
+		timeout <<= 1;
+		if (timeout > NFSROOT_TIMEOUT_MAX)
+			timeout = NFSROOT_TIMEOUT_MAX;
+	}
+	return 0;
 }
 #endif
 

