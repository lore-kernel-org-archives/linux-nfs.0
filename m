Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:41718 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdK0TZU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Nov 2017 14:25:20 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH] sunrpc: sort groups on unix_gid_parse
Date: Mon, 27 Nov 2017 17:25:08 -0200
Message-Id: <20171127192508.12751-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cases were mountd is managing the group membership for nfsd,
if a user has several groups, multiple nfsd threads may call
sort_groups for the same freshly created unix_gid_cache entry
simultaneously, causing entries to be overwritten and the cache
entry to get corrupted. This eventually leads to the server
replying to the client with a bogus EPERM error if the group
overwritten is the group that would allow access.

This is a very hard bug to analyze, as a very slight change in
timing leads to proper sorting behavior. It was first noticed
and reproduced in kernel 3.10.0, which uses shell sort to sort
groups. Nothing indicates that heapsort, which is used
upstream, is thread safe.

This patch solves this issue by sorting the cache entry before
inserting it into the cache, and thus next entries will not
have to sort it again, avoiding the issue altogether.

Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
---
 kernel/groups.c           | 4 +++-
 net/sunrpc/svcauth_unix.c | 7 +++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/kernel/groups.c b/kernel/groups.c
index e357bc8..4c9c9ed 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -86,11 +86,13 @@ static int gid_cmp(const void *_a, const void *_b)
 	return gid_gt(a, b) - gid_lt(a, b);
 }
 
-static void groups_sort(struct group_info *group_info)
+void groups_sort(struct group_info *group_info)
 {
 	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
 	     gid_cmp, NULL);
 }
+EXPORT_SYMBOL(groups_sort);
+
 
 /* a simple bsearch */
 int groups_search(const struct group_info *group_info, kgid_t grp)
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f81eaa8..91e3d34 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -20,6 +20,7 @@
 
 
 #include "netns.h"
+void groups_sort(struct group_info *group_info);
 
 /*
  * AUTHUNIX and AUTHNULL credentials are both handled here.
@@ -520,6 +521,12 @@ static int unix_gid_parse(struct cache_detail *cd,
 		ug.gi->gid[i] = kgid;
 	}
 
+	/* Sort the groups before inserting this entry
+	 * into the cache to avoid future corrutpions
+	 * by multiple simultaneous attempts to sort this
+	 * entry.
+	 */
+	groups_sort(ug.gi);
 	ugp = unix_gid_lookup(cd, uid);
 	if (ugp) {
 		struct cache_head *ch;
-- 
2.9.5

