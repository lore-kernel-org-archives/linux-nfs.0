From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: Remove a redundant check for PageFsCache in
 nfs_migrate_page()
Date: Mon, 08 Feb 2010 09:59:42 -0500
Message-ID: <20100208145942.17581.12206.stgit@localhost.localdomain>
References: <20100208145942.17581.81775.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: David Howells <dhowells@redhat.com>,
	Suresh Jayaraman <sjayaraman@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588Ab0BHPCX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 10:02:23 -0500
In-Reply-To: <20100208145942.17581.81775.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>
---

 fs/nfs/write.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b54b8b..d63d964 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1598,8 +1598,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 	struct nfs_page *req;
 	int ret;
 
-	if (PageFsCache(page))
-		nfs_fscache_release_page(page, GFP_KERNEL);
+	nfs_fscache_release_page(page, GFP_KERNEL);
 
 	req = nfs_find_and_lock_request(page);
 	ret = PTR_ERR(req);

