Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:4875 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505AbcANVe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2016 16:34:28 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] [nfs-utils] handle EINTR during connection establishment
Date: Thu, 14 Jan 2016 16:34:25 -0500
Message-ID: <1452807265-36920-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

both connect() and select() can receive EINTR signals that we need to
recover from.

In Unix Network Programming, volume 1, section 5.9, W. Richard Stevens
states:

What we are doing […] is restarting the interrupted system call ourself.
This is fine for accept, along with the functions such as read, write,
select and open. But there is one function that we cannot restart ourself:
connect. If this function returns EINTR, we cannot call it again, as doing
so will return an immediate error. When connect is interrupted by a caught
signal and is not automatically restarted, we must call select to wait for
the connection to complete,

Thus for connect() treat both EINPROGRESS and EINTR the same -- call
select().

For select(), it should be re-tried again upon receiving EINTR.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 support/nfs/rpc_socket.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index c14efe8..edd43cc 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -215,7 +215,7 @@ static int nfs_connect_nb(const int fd, const struct sockaddr *sap,
 	 * use it later.
 	 */
 	ret = connect(fd, sap, salen);
-	if (ret < 0 && errno != EINPROGRESS) {
+	if (ret < 0 && errno != EINPROGRESS && errno != EINTR) {
 		ret = -1;
 		goto done;
 	}
@@ -227,10 +227,16 @@ static int nfs_connect_nb(const int fd, const struct sockaddr *sap,
 	FD_ZERO(&rset);
 	FD_SET(fd, &rset);
 
-	ret = select(fd + 1, NULL, &rset, NULL, timeout);
-	if (ret <= 0) {
-		if (ret == 0)
-			errno = ETIMEDOUT;
+	while ((ret = select(fd + 1, NULL, &rset, NULL, timeout)) < 0) {
+		if (errno != EINTR) {
+			ret = -1;
+			goto done;
+		} else {
+			continue;
+		}
+	}
+	if (ret == 0) {
+		errno = ETIMEDOUT;
 		ret = -1;
 		goto done;
 	}
-- 
1.7.1

