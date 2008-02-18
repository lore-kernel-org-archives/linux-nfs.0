From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/17] mount command:  rename connect_to helper
Date: Mon, 18 Feb 2008 13:36:01 -0500
Message-ID: <20080218183601.19060.44841.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55969 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbYBRSgF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:05 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIa2Hg018176
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:03 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIa1K6019342
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:02 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rename connect_to().

The get_socket() function uses a helper called connect_to() that wraps the
connect(2) system call with logic that establishes a connection timeout.  The
name "connect_to()" is confusing though, as it suggests we are invoking
some other system interface rather than a locally defined function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index a893a4a..da0eb1a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -257,10 +257,13 @@ static int __nfs_gs_err_connect(const int socket, const struct sockaddr *saddr,
 /*
  * Attempt to connect a socket, but time out after "timeout" seconds.
  *
- * On error return, caller closes the socket.
+ * Returns zero if successful, or -1 if an error occurred.
+ * On error return, caller must close the socket.
  */
-static int connect_to(int fd, struct sockaddr *addr,
-			socklen_t addrlen, time_t timeout)
+static int __nfs_gs_connect_with_timeout(const int fd,
+						const struct sockaddr *addr,
+						const socklen_t addrlen,
+						const time_t timeout)
 {
 	int ret, saved;
 	fd_set rset, wset;
@@ -329,8 +332,8 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 			return __nfs_gs_err_bind(so, p_prot, errno);
 	}
 	if (type == SOCK_STREAM || conn) {
-		if (connect_to(so, (struct sockaddr *)saddr, namelen,
-								timeout) < 0)
+		if (__nfs_gs_connect_with_timeout(so, (struct sockaddr *)saddr,
+							namelen, timeout) < 0)
 			return __nfs_gs_err_connect(so, (struct sockaddr *)saddr,
 							errno);
 	}

