Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:63246 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751684AbdHQOdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Aug 2017 10:33:43 -0400
Subject: [PATCH 1/2] lockd: Delete an error message for a failed memory
 allocation in reclaimer()
From: SF Markus Elfring <elfring@users.sourceforge.net>
To: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Christoph Hellwig <hch@lst.de>,
        Colin Ian King <colin.king@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
References: <e53b2d3a-239a-268c-5674-3c50b02c966f@users.sourceforge.net>
Message-ID: <350de6ea-41ff-1b86-ff50-26c677447f00@users.sourceforge.net>
Date: Thu, 17 Aug 2017 16:33:35 +0200
MIME-Version: 1.0
In-Reply-To: <e53b2d3a-239a-268c-5674-3c50b02c966f@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 16 Aug 2017 22:35:24 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 fs/lockd/clntlock.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 27d577dbe51a..96c1d14c18f1 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -235,12 +235,8 @@ reclaimer(void *ptr)
 	struct net *net = host->net;
 
 	req = kmalloc(sizeof(*req), GFP_KERNEL);
-	if (!req) {
-		printk(KERN_ERR "lockd: reclaimer unable to alloc memory."
-				" Locks for %s won't be reclaimed!\n",
-				host->h_name);
+	if (!req)
 		return 0;
-	}
 
 	allow_signal(SIGKILL);
 
-- 
2.14.0

