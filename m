Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51854 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932824AbdIYNVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 09:21:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd: increase DRC cache limit
Date: Mon, 25 Sep 2017 09:21:43 -0400
Message-Id: <1506345704-9486-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1506345704-9486-1-git-send-email-bfields@redhat.com>
References: <1506345704-9486-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

An NFSv4.1+ client negotiates the size of its duplicate reply cache size
in the initial CREATE_SESSION request.  The server preallocates the
memory for the duplicate reply cache to ensure that we'll never fail to
record the response to a nonidempotent operation.

To prevent a few CREATE_SESSIONs from consuming all of memory we set an
upper limit based on nr_free_buffer_pages().  1/2^10 has been too
limiting in practice; 1/2^7 is still less than one percent.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 7e3af3ef0917..6bbc717f40f2 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -446,7 +446,7 @@ void nfsd_reset_versions(void)
  */
 static void set_max_drc(void)
 {
-	#define NFSD_DRC_SIZE_SHIFT	10
+	#define NFSD_DRC_SIZE_SHIFT	7
 	nfsd_drc_max_mem = (nr_free_buffer_pages()
 					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
 	nfsd_drc_mem_used = 0;
-- 
2.13.5

