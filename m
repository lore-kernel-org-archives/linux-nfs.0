From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/17] mount command: Fix type of get_socket's timeout argument
Date: Mon, 18 Feb 2008 13:35:56 -0500
Message-ID: <20080218183556.19060.35248.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55770 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875AbYBRSf6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:58 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZuIv017890
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:57 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZuG0019336
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:56 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The type of get_socket's timeout argument should match the type of
the ultimate destination of its value, the tv_sec field in a timeval struct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index c54b312..a893a4a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -260,7 +260,7 @@ static int __nfs_gs_err_connect(const int socket, const struct sockaddr *saddr,
  * On error return, caller closes the socket.
  */
 static int connect_to(int fd, struct sockaddr *addr,
-			socklen_t addrlen, int timeout)
+			socklen_t addrlen, time_t timeout)
 {
 	int ret, saved;
 	fd_set rset, wset;
@@ -308,7 +308,7 @@ out:
  * The caller should check rpc_createerr to determine the cause of any error.
  */
 static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
-			unsigned int timeout, int resvp, int conn)
+			time_t timeout, int resvp, int conn)
 {
 	int so, type;
 	struct sockaddr_in laddr;

