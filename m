From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/3] mountd: fix path comparison for v4 crossmnt
Date: Sun,  7 Mar 2010 15:07:59 -0500
Message-ID: <1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
References: <20100307200607.GA13006@fieldses.org>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58511 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742Ab0CGUGk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 15:06:40 -0500
In-Reply-To: <20100307200607.GA13006@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was obviously wrong, since path[strlen(path)] == '\0' should always
be true.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d63e10a..ff27bbf 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -619,7 +619,7 @@ static int is_subdirectory(char *subpath, char *path)
 	int l = strlen(path);
 
 	return strcmp(subpath, path) == 0
-		|| (strncmp(subpath, path, l) == 0 && path[l] == '/');
+		|| (strncmp(subpath, path, l) == 0 && subpath[l] == '/');
 }
 
 static int path_matches(nfs_export *exp, char *path)
-- 
1.6.3.3

