Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:20 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 06/14] mount: generate AF_VSOCK clientaddr
Date: Wed, 13 Sep 2017 11:26:42 +0100
Message-Id: <20170913102650.10377-7-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mount(8) command should automatically determine the NFS backchannel
address details so the user does not have to specify them on the
command-line.  Use the AF_VSOCK ioctl for determining the local CID.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 7b0bc97..1f9ad02 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -35,6 +35,7 @@
 #include <time.h>
 #include <grp.h>
 
+#include <sys/ioctl.h>
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/wait.h>
@@ -1129,6 +1130,34 @@ static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
 	int sock, result = 0;
 	int val;
 
+	if (sap->sa_family == AF_VSOCK) {
+		struct sockaddr_vm *svm = (struct sockaddr_vm *)buf;
+		unsigned int cid;
+		int fd;
+
+		if (*buflen < sizeof(struct sockaddr_vm)) {
+			errno = EINVAL;
+			return 0;
+		}
+
+		fd = open("/dev/vsock", O_RDONLY);
+		if (fd < 0)
+			return 0;
+
+		if (ioctl(fd, IOCTL_VM_SOCKETS_GET_LOCAL_CID, &cid) < 0) {
+			close(fd);
+			return 0;
+		}
+
+		memset(svm, 0, sizeof(*svm));
+		svm->svm_family = AF_VSOCK;
+		svm->svm_cid = cid;
+
+		*buflen = sizeof(*svm);
+		close(fd);
+		return 1;
+	}
+
 	sock = socket(sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
 	if (sock < 0)
 		return 0;
-- 
2.13.5

