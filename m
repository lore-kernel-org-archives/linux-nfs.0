Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab0LGWQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Dec 2010 17:16:54 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] NFS: nfs_readdir_search_for_cookie() don't mark as eof if cookie not found
Date: Tue,  7 Dec 2010 17:16:47 -0500
Message-Id: <1291760208-11251-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If we're searching for a specific cookie, and it isn't found in the page
cache, we should try an uncached_readdir(). To do so, we return EBADCOOKIE,
but we don't set desc->eof.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d529e0e..ad2fde2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -316,8 +316,9 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 		}
 	}
 	if (i == array->eof_index) {
-		desc->eof = 1;
 		status = -EBADCOOKIE;
+		if (*desc->dir_cookie == array->last_cookie)
+			desc->eof = 1;
 	}
 out:
 	return status;
-- 
1.7.3.2

