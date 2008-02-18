From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/17] NFS: Fix error handling in get_client_address()
Date: Mon, 18 Feb 2008 13:36:17 -0500
Message-ID: <20080218183617.19060.849.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56438 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbYBRSgT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:19 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIaH6i018887
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:17 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIaHY6019360
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_error() reports the wrong error message because close(2) tromps on
the errno set by getsockname(2).  Also, the existing logic returned
error status only if verbose was set.

As an added bonus, clarify the error message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ee8aa28..9f8d1d4 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -883,12 +883,10 @@ int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
 		return 0;
 
 	err = getsockname(socket, caddr, &len);
-	close(socket);
-
-	if (err && verbose) {
-		nfs_error(_("%s: getsockname failed: %s"),
+	if (err && verbose)
+		nfs_error(_("%s: error acquiring client's local address: %s"),
 				progname, strerror(errno));
-		return 0;
-	}
-	return 1;
+
+	close(socket);
+	return err ? 0 : 1;
 }

