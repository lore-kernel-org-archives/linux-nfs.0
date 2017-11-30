Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:44863 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752804AbdK3NGy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Nov 2017 08:06:54 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of set_groups.
Date: Thu, 30 Nov 2017 11:04:56 -0200
Message-Id: <20171130130457.11429-3-thiago.becker@gmail.com>
In-Reply-To: <20171130130457.11429-1-thiago.becker@gmail.com>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The responsibility for calling groups_sort is now on the caller
of set_groups.

Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
---
 kernel/groups.c           | 1 +
 kernel/uid16.c            | 1 +
 net/sunrpc/svcauth_unix.c | 7 +++++++
 3 files changed, 9 insertions(+)

diff --git a/kernel/groups.c b/kernel/groups.c
index 4c9c9ed..17073a9 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -208,6 +208,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 		return retval;
 	}
 
+	groups_sort(group_info);
 	retval = set_current_groups(group_info);
 	put_group_info(group_info);
 
diff --git a/kernel/uid16.c b/kernel/uid16.c
index ce74a49..ef1da2a 100644
--- a/kernel/uid16.c
+++ b/kernel/uid16.c
@@ -192,6 +192,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid_t __user *, grouplist)
 		return retval;
 	}
 
+	groups_sort(group_info);
 	retval = set_current_groups(group_info);
 	put_group_info(group_info);
 
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

