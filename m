Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33354 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778Ab0ICQPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 12:15:14 -0400
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [nfs] nfs:  Fix nfs_sockaddr_match_ipaddr6
Date: Fri,  3 Sep 2010 09:15:11 -0700
Message-Id: <1283530511-20658-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A typo caused this method not not actually compare the
two addresses passed in.  It returned true in almost all
cases instead.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 4e7df2a... e734072... M	fs/nfs/client.c
 fs/nfs/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e7df2a..e734072 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -275,7 +275,7 @@ static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
 	    sin1->sin6_scope_id != sin2->sin6_scope_id)
 		return 0;
 
-	return ipv6_addr_equal(&sin1->sin6_addr, &sin1->sin6_addr);
+	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
 }
 #else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
 static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
-- 
1.6.2.5

