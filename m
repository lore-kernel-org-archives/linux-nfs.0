Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11947 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759795Ab2EVQKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 12:10:21 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] NFSv4.1 do not release page on commit mismatch
Date: Tue, 22 May 2012 08:09:29 -0400
Message-Id: <1337688569-1515-5-git-send-email-andros@netapp.com>
In-Reply-To: <1337688569-1515-1-git-send-email-andros@netapp.com>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/write.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e6fe3d6..c7295de 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1555,6 +1555,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		/* We have a mismatch. Write the page again */
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
+		nfs_unlock_request(req);
+		continue;
 	next:
 		nfs_unlock_and_release_request(req);
 	}
-- 
1.7.7.6

