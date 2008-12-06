From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/27] NSM: Remove !nsm check from nsm_release()
Date: Fri, 05 Dec 2008 19:03:09 -0500
Message-ID: <20081206000308.24075.73629.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49647 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717AbYLFAEt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:49 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nsm_release() function should never be called with a NULL handle
point.  If it is, that's a bug.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index f3ae631..c2f4607 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -288,8 +288,6 @@ retry:
  */
 void nsm_release(struct nsm_handle *nsm)
 {
-	if (!nsm)
-		return;
 	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
 		list_del(&nsm->sm_link);
 		spin_unlock(&nsm_lock);

