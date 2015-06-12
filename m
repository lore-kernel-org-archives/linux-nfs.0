Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay108.isp.belgacom.be ([195.238.20.135]:1917 "EHLO
	mailrelay108.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755245AbbFLQ7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 12:59:01 -0400
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, Fabian Frederick <fabf@skynet.be>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/1 linux-next] nfsd: use swap() in sort_pacl_range()
Date: Fri, 12 Jun 2015 18:58:57 +0200
Message-Id: <1434128337-10366-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use kernel.h macro definition.

Thanks to Julia Lawall for Coccinelle scripting support.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfsd/nfs4acl.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 7e10e2a..eb5accf 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -372,7 +372,6 @@ pace_gt(struct posix_acl_entry *pace1, struct posix_acl_entry *pace2)
 static void
 sort_pacl_range(struct posix_acl *pacl, int start, int end) {
 	int sorted = 0, i;
-	struct posix_acl_entry tmp;
 
 	/* We just do a bubble sort; easy to do in place, and we're not
 	 * expecting acl's to be long enough to justify anything more. */
@@ -382,9 +381,8 @@ sort_pacl_range(struct posix_acl *pacl, int start, int end) {
 			if (pace_gt(&pacl->a_entries[i],
 				    &pacl->a_entries[i+1])) {
 				sorted = 0;
-				tmp = pacl->a_entries[i];
-				pacl->a_entries[i] = pacl->a_entries[i+1];
-				pacl->a_entries[i+1] = tmp;
+				swap(pacl->a_entries[i],
+				     pacl->a_entries[i + 1]);
 			}
 		}
 	}
-- 
2.4.2

