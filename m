Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:46676 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752283AbdLEOFm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 09:05:42 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH 3/3 v3] kernel: set_groups doesn't call groups_sort anymore.
Date: Tue,  5 Dec 2017 12:05:12 -0200
Message-Id: <20171205140512.13349-4-thiago.becker@gmail.com>
In-Reply-To: <20171205140512.13349-1-thiago.becker@gmail.com>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171205140512.13349-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the group_info is cached (e.g. sunrpc) there's the possibility
that threads calling set_groups will attempt to do so simultaneously.

Moving the responsibility of sorting to the caller of set_groups, or
in the case of nfsd, to the point where it is received from rpc.mountd
avoids this issue.

Moving it to the caller has the added benifit of a slight improvement on
the nfsd performance.

Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
---
 kernel/groups.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/groups.c b/kernel/groups.c
index 17073a9..8620ad3 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -124,7 +124,6 @@ int groups_search(const struct group_info *group_info, kgid_t grp)
 void set_groups(struct cred *new, struct group_info *group_info)
 {
 	put_group_info(new->group_info);
-	groups_sort(group_info);
 	get_group_info(group_info);
 	new->group_info = group_info;
 }
-- 
2.9.5

