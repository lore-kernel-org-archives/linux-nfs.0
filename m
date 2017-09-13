Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:38 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 13/14] nfsd: add --vsock (-v) option to nfsd
Date: Wed, 13 Sep 2017 11:26:49 +0100
Message-Id: <20170913102650.10377-14-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following command-line serves NFSv4.1 over AF_VSOCK:

  nfsd -TU -N3 -V4.1 -v 2049

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/nfsd/nfssvc.h |  1 +
 utils/nfsd/nfsd.c   | 18 +++++++++++++---
 utils/nfsd/nfssvc.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsd/nfsd.man |  4 ++++
 4 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 39ebf37..1d251ca 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -26,6 +26,7 @@ int	nfssvc_set_sockets(const unsigned int protobits,
 			   const char *host, const char *port);
 void	nfssvc_set_time(const char *type, const int seconds);
 int	nfssvc_set_rdmaport(const char *port);
+int	nfssvc_set_vsock(const char *port);
 void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigned int minorvers4set);
 int	nfssvc_threads(int nrservs);
 void	nfssvc_get_minormask(unsigned int *mask);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index f973203..7f527db 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -53,6 +53,7 @@ static struct option longopts[] =
 	{ "rdma", 2, 0, 'R' },
 	{ "grace-time", 1, 0, 'G'},
 	{ "lease-time", 1, 0, 'L'},
+	{ "vsock", 1, 0, 'v' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -61,6 +62,7 @@ main(int argc, char **argv)
 {
 	int	count = NFSD_NPROC, c, i, error = 0, portnum, fd, found_one;
 	char *p, *progname, *port, *rdma_port = NULL;
+	char *vsock_port = NULL;
 	char **haddr = NULL;
 	int hcounter = 0;
 	struct conf_list *hosts;
@@ -145,7 +147,7 @@ main(int argc, char **argv)
 		}
 	}
 
-	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:stTituUrG:L:", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:stTituUrG:L:v:", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'd':
 			xlog_config(D_ALL, 1);
@@ -180,7 +182,9 @@ main(int argc, char **argv)
 			else
 				rdma_port = "nfsrdma";
 			break;
-
+		case 'v': /* --vsock */
+			vsock_port = optarg;
+			break;
 		case 'N':
 			switch((c = strtol(optarg, &p, 0))) {
 			case 4:
@@ -309,7 +313,8 @@ main(int argc, char **argv)
 	}
 
 	if (NFSCTL_VERISSET(versbits, 4) &&
-	    !NFSCTL_TCPISSET(protobits)) {
+	    !NFSCTL_TCPISSET(protobits) &&
+	    !vsock_port) {
 		xlog(L_ERROR, "version 4 requires the TCP protocol");
 		exit(1);
 	}
@@ -353,6 +358,13 @@ main(int argc, char **argv)
 		if (!error)
 			socket_up = 1;
 	}
+
+	if (vsock_port) {
+		error = nfssvc_set_vsock(vsock_port);
+		if (!error)
+			socket_up = 1;
+	}
+
 set_threads:
 	/* don't start any threads if unable to hand off any sockets */
 	if (!socket_up) {
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index e8609c1..2fbdb48 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -22,6 +22,7 @@
 #include <stdlib.h>
 #include <string.h>
 
+#include "vsock.h"
 #include "nfslib.h"
 #include "xlog.h"
 #include "nfssvc.h"
@@ -304,6 +305,67 @@ nfssvc_set_rdmaport(const char *port)
 	return ret;
 }
 
+int
+nfssvc_set_vsock(const char *port)
+{
+	struct sockaddr_vm svm;
+	int nport;
+	char buf[20];
+	int rc = 1;
+	int sockfd = -1;
+	int fd = -1;
+	char *ep;
+
+	nport = strtol(port, &ep, 10);
+	if (!*port || *ep) {
+		xlog(L_ERROR, "unable to interpret port name %s",
+		     port);
+		goto out;
+	}
+
+	sockfd = socket(AF_VSOCK, SOCK_STREAM, 0);
+	if (sockfd < 0) {
+		xlog(L_ERROR, "unable to create AF_VSOCK socket: "
+			      "errno %d (%m)", errno);
+		goto out;
+	}
+
+	svm.svm_family = AF_VSOCK;
+	svm.svm_port = nport;
+	svm.svm_cid = VMADDR_CID_ANY;
+
+	if (bind(sockfd, (struct sockaddr*)&svm, sizeof(svm))) {
+		xlog(L_ERROR, "unable to bind AF_VSOCK socket: "
+			      "errno %d (%m)", errno);
+		goto out;
+	}
+
+	if (listen(sockfd, 64)) {
+		xlog(L_ERROR, "unable to create listening socket: "
+			      "errno %d (%m)", errno);
+		goto out;
+	}
+
+	fd = open(NFSD_PORTS_FILE, O_WRONLY);
+	if (fd < 0) {
+		xlog(L_ERROR, "couldn't open ports file: errno "
+		     "%d (%m)", errno);
+		goto out;
+	}
+	snprintf(buf, sizeof(buf), "%d\n", sockfd);
+	if (write(fd, buf, strlen(buf)) != (ssize_t)strlen(buf)) {
+		xlog(L_ERROR, "unable to request vsock services: %m");
+		goto out;
+	}
+	rc = 0;
+out:
+	if (fd != -1)
+		close(fd);
+	if (sockfd != -1)
+		close(sockfd);
+	return rc;
+}
+
 void
 nfssvc_set_time(const char *type, const int seconds)
 {
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index d83ef86..058a252 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -52,6 +52,10 @@ Listen for RDMA requests on an alternate port - may be a number or a
 name listed in
 .BR /etc/services .
 .TP
+.BI \-\-vsock= port
+Listen for vsock requests on a given port number.
+Requires NFS version 4.0 or later.
+.TP
 .B \-N " or " \-\-no-nfs-version vers
 This option can be used to request that 
 .B rpc.nfsd
-- 
2.13.5

