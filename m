From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/31] mount.nfs: Fix some nfs_error() nits in network.c
Date: Mon, 29 Jun 2009 13:38:54 -0400
Message-ID: <20090629173853.2076.85202.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54792 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964AbZF2RkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:07 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a couple of nfs_error() call sites in utils/mount/network.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ad6c146..6e0a72a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -783,8 +783,8 @@ int start_statd(void)
 				execl(START_STATD, START_STATD, NULL);
 				exit(1);
 			case -1: /* error */
-				nfs_error(_("fork failed: %s"),
-							strerror(errno));
+				nfs_error(_("%s: fork failed: %s"),
+						progname, strerror(errno));
 				break;
 			default: /* parent */
 				waitpid(pid, NULL,0);
@@ -1159,7 +1159,8 @@ int nfs_callback_address(const struct sockaddr *sap, const socklen_t salen,
 out_failed:
 	*buflen = 0;
 	if (verbose)
-		nfs_error(_("%s: failed to construct callback address"));
+		nfs_error(_("%s: failed to construct callback address"),
+				progname);
 	return 0;
 }
 

