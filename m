Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:51029 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751681Ab1JLHES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Oct 2011 03:04:18 -0400
Message-ID: <4E953D2E.5080103@cn.fujitsu.com>
Date: Wed, 12 Oct 2011 15:09:34 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: NFS <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs: fix bug about IPv6 address scope checking
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The result from ipv6_addr_scope() always not be a single SCOPE,
so we can't use equal to compare the result with IPV6_ADDR_SCOPE_LINKLOCAL
at nfs_sockaddr_match_ipaddr6.

This patch fixs the problem, and lets checking address before scope_id.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfs/client.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5833fbb..b4e41dd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -336,11 +336,12 @@ static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
 
-	if (ipv6_addr_scope(&sin1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
-	    sin1->sin6_scope_id != sin2->sin6_scope_id)
+	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
 		return 0;
+	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		return sin1->sin6_scope_id == sin2->sin6_scope_id;
 
-	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
+	return 1;
 }
 #else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
 static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
-- 
1.7.6



