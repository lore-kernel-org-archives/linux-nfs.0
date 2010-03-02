Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386Ab0CBU4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 15:56:03 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NmZ9U-0002dK-Vj
	for linux-nfs@vger.kernel.org; Tue, 02 Mar 2010 15:57:13 -0500
Date: Tue, 2 Mar 2010 15:57:12 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] svcrpc: treat uid's as unsigned
Message-ID: <20100302205712.GB8609@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

We should consistently treat uid's as unsigned--it's confusing when
the display of uid's in the cache contents isn't consistent with their
representation in upcalls.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcauth_unix.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

We should check the gss upcalls (both kernel and nfs-utils sides) as
well at some point.--b.

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 97f0e9e..afdcb04 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -624,7 +624,7 @@ static int unix_gid_show(struct seq_file *m,
 	else
 		glen = 0;
 
-	seq_printf(m, "%d %d:", ug->uid, glen);
+	seq_printf(m, "%u %d:", ug->uid, glen);
 	for (i = 0; i < glen; i++)
 		seq_printf(m, " %d", GROUP_AT(ug->gi, i));
 	seq_printf(m, "\n");
-- 
1.6.3.3

