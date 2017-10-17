Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:48728 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763275AbdJQQOh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Oct 2017 12:14:37 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 2/4] NFS: make cache_detail structure const
Date: Tue, 17 Oct 2017 18:14:24 +0200
Message-Id: <1508256866-12798-3-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it const as it is only getting passed to the function
cache_create_net having the argument as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 fs/nfs/dns_resolve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index d25f10f..477934a 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -353,7 +353,7 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name,
 	return ret;
 }
 
-static struct cache_detail nfs_dns_resolve_template = {
+static const struct cache_detail nfs_dns_resolve_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= NFS_DNS_HASHTBL_SIZE,
 	.name		= "dns_resolve",
-- 
1.9.1

