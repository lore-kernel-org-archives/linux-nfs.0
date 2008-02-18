From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/17] mount command: Add AF_INET6 support for binding to
	reserved ports
Date: Mon, 18 Feb 2008 13:36:07 -0500
Message-ID: <20080218183607.19060.27795.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56128 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbYBRSgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:08 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIa7ua018449
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:07 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIa7e9019348
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support binding AF_INET6 sockets to reserved ports in get_socket().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am |    4 ++++
 utils/mount/network.c   |   20 +++++++++++++++++++-
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 27a01de..03a02be 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -18,6 +18,10 @@ mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c parse_opt.c \
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
 		  ../../support/export/libexport.a
 
+if CONFIG_IPV6
+mount_nfs_LDADD += ../../support/misc/libmisc.a
+endif
+
 MAINTAINERCLEANFILES = Makefile.in
 
 install-exec-hook:
diff --git a/utils/mount/network.c b/utils/mount/network.c
index da0eb1a..5720a4e 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -254,6 +254,24 @@ static int __nfs_gs_err_connect(const int socket, const struct sockaddr *saddr,
 	return __nfs_gs_err_done(error);
 }
 
+#ifdef IPV6_SUPPORTED
+static int __nfs_bindresvport(const int socket, struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		return bindresvport(socket, (struct sockaddr_in *)sap);
+	case AF_INET6:
+		return bindresvport6(socket, (struct sockaddr_in6 *)sap);
+	}
+	return EAFNOSUPPORT;
+}
+#else
+static int __nfs_bindresvport(const int socket, struct sockaddr *sap)
+{
+	return bindresvport(socket, (struct sockaddr_in *)sap);
+}
+#endif
+
 /*
  * Attempt to connect a socket, but time out after "timeout" seconds.
  *
@@ -325,7 +343,7 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 	laddr.sin_port = 0;
 	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
-		if (bindresvport(so, &laddr) < 0)
+		if (__nfs_bindresvport(so, (struct sockaddr *)&laddr) < 0)
 			return __nfs_gs_err_bindresvport(so, p_prot, errno);
 	} else {
 		if (bind(so, (struct sockaddr *)&laddr, namelen) < 0)

