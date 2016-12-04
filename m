Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay110.isp.belgacom.be ([195.238.20.137]:12563 "EHLO
        mailrelay110.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750867AbcLDMpb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2016 07:45:31 -0500
From: Fabian Frederick <fabf@skynet.be>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        fabf@skynet.be
Subject: [PATCH 1/1 linux-next] sunrpc: use DEFINE_SPINLOCK()
Date: Sun,  4 Dec 2016 13:45:28 +0100
Message-Id: <1480855528-19620-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/sunrpc/svcauth.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
index 69841db..e112da8 100644
--- a/net/sunrpc/svcauth.c
+++ b/net/sunrpc/svcauth.c
@@ -124,8 +124,7 @@ EXPORT_SYMBOL_GPL(svc_auth_unregister);
 #define	DN_HASHMAX	(1<<DN_HASHBITS)
 
 static struct hlist_head	auth_domain_table[DN_HASHMAX];
-static spinlock_t	auth_domain_lock =
-	__SPIN_LOCK_UNLOCKED(auth_domain_lock);
+static DEFINE_SPINLOCK(auth_domain_lock);
 
 void auth_domain_put(struct auth_domain *dom)
 {
-- 
2.7.4

