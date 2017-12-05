Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:41247 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752974AbdLEOFg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 09:05:36 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH 1/3 v3] kernel: make groups_sort globally visible
Date: Tue,  5 Dec 2017 12:05:10 -0200
Message-Id: <20171205140512.13349-2-thiago.becker@gmail.com>
In-Reply-To: <20171205140512.13349-1-thiago.becker@gmail.com>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171205140512.13349-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to move group_info sorting to the caller,
make group_sort globally visible.

Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
---
 include/linux/cred.h | 1 +
 kernel/groups.c      | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 099058e..6312865 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -83,6 +83,7 @@ extern int set_current_groups(struct group_info *);
 extern void set_groups(struct cred *, struct group_info *);
 extern int groups_search(const struct group_info *, kgid_t);
 extern bool may_setgroups(void);
+extern void groups_sort(struct group_info *);
 
 /*
  * The security context of a task
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
-- 
2.9.5

