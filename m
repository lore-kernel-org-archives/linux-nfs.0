Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:47380 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763292AbdJQQOl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Oct 2017 12:14:41 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 4/4] SUNRPC: make cache_detail structures const
Date: Tue, 17 Oct 2017 18:14:26 +0200
Message-Id: <1508256866-12798-5-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make these const as they are only getting passed to the function
cache_create_net having the argument as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
 net/sunrpc/svcauth_unix.c         | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 7b1ee5a..e242cb4 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -264,7 +264,7 @@ static int rsi_parse(struct cache_detail *cd,
 	return status;
 }
 
-static struct cache_detail rsi_cache_template = {
+static const struct cache_detail rsi_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= RSI_HASHMAX,
 	.name           = "auth.rpcsec.init",
@@ -524,7 +524,7 @@ static int rsc_parse(struct cache_detail *cd,
 	return status;
 }
 
-static struct cache_detail rsc_cache_template = {
+static const struct cache_detail rsc_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= RSC_HASHMAX,
 	.name		= "auth.rpcsec.context",
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f81eaa8..740b67d 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -569,7 +569,7 @@ static int unix_gid_show(struct seq_file *m,
 	return 0;
 }
 
-static struct cache_detail unix_gid_cache_template = {
+static const struct cache_detail unix_gid_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= GID_HASHMAX,
 	.name		= "auth.unix.gid",
@@ -862,7 +862,7 @@ struct auth_ops svcauth_unix = {
 	.set_client	= svcauth_unix_set_client,
 };
 
-static struct cache_detail ip_map_cache_template = {
+static const struct cache_detail ip_map_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= IP_HASHMAX,
 	.name		= "auth.unix.ip",
-- 
1.9.1

