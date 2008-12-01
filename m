From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] mount command: Use nfs_error() instead of perror()
Date: Mon, 01 Dec 2008 13:48:45 -0500
Message-ID: <20081201184845.10436.17966.stgit@ingres.1015granger.net>
References: <20081201183616.10436.71066.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: steved@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:37243 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbYLASt0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:49:26 -0500
In-Reply-To: <20081201183616.10436.71066.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So we can ensure that error output is directed appropriately, use
nfs_error() instead of perror() in start_statd().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 0ba7bdb..2231210 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -710,7 +710,8 @@ int start_statd(void)
 				execl(START_STATD, START_STATD, NULL);
 				exit(1);
 			case -1: /* error */
-				perror("Fork failed");
+				nfs_error(_("fork failed: %s"),
+							strerror(errno));
 				break;
 			default: /* parent */
 				waitpid(pid, NULL,0);

