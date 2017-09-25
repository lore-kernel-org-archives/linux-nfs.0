Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51856 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932107AbdIYNVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 09:21:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: give out fewer session slots as limit approaches
Date: Mon, 25 Sep 2017 09:21:44 -0400
Message-Id: <1506345704-9486-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1506345704-9486-1-git-send-email-bfields@redhat.com>
References: <1506345704-9486-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Instead of granting client's full requests until we hit our DRC size
limit and then failing CREATE_SESSIONs (and hence mounts) completely,
start granting clients smaller slot tables as we approach the limit.

The factor chosen here is pretty much arbitrary.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 28e5bded6a4b..2fe930e92545 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1472,6 +1472,11 @@ static u32 nfsd4_get_drc_mem(struct nfsd4_channel_attrs *ca)
 	spin_lock(&nfsd_drc_lock);
 	avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
 		    nfsd_drc_max_mem - nfsd_drc_mem_used);
+	/*
+	 * Never use more than a third of the remaining memory,
+	 * unless it's the only way to give this client a slot:
+	 */
+	avail = clamp_t(int, avail, slotsize, avail/3);
 	num = min_t(int, num, avail / slotsize);
 	nfsd_drc_mem_used += num * slotsize;
 	spin_unlock(&nfsd_drc_lock);
-- 
2.13.5

