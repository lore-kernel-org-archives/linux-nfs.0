From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/27] NSM: Remove NULL pointer check from nsm_find()
Date: Fri, 05 Dec 2008 19:03:01 -0500
Message-ID: <20081206000300.24075.43859.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49552 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbYLFAE1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:27 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nsm_find() function should never be called with a NULL IP address
pointer.  If it is, that's a bug.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 8628d31..f3ae631 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -225,9 +225,6 @@ struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
 	struct nsm_handle *nsm = NULL;
 	struct nsm_handle *pos;
 
-	if (!sap)
-		return NULL;
-
 	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
 		if (printk_ratelimit()) {
 			printk(KERN_WARNING "Invalid hostname \"%.*s\" "

