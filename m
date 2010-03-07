From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/3] mountd: trivial: name parameters for clarity
Date: Sun,  7 Mar 2010 15:08:00 -0500
Message-ID: <1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
References: <20100307200607.GA13006@fieldses.org>
 <1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58513 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754796Ab0CGUGk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 15:06:40 -0500
In-Reply-To: <1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Part of the reason for the previous bug was confusion between "subpath"
and "path"; which is the shorter path, and which the longer?

"child" and "parent" seem less ambiguous.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/mountd/cache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ff27bbf..7dec468 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -614,12 +614,12 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 	return qword_eol(f);
 }
 
-static int is_subdirectory(char *subpath, char *path)
+static int is_subdirectory(char *child, char *parent)
 {
-	int l = strlen(path);
+	int l = strlen(parent);
 
-	return strcmp(subpath, path) == 0
-		|| (strncmp(subpath, path, l) == 0 && subpath[l] == '/');
+	return strcmp(child, parent) == 0
+		|| (strncmp(child, parent, l) == 0 && child[l] == '/');
 }
 
 static int path_matches(nfs_export *exp, char *path)
-- 
1.6.3.3

