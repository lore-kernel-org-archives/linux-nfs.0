Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:54905 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763251AbdJQQOj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Oct 2017 12:14:39 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 3/4] NFSD: make cache_detail structures const
Date: Tue, 17 Oct 2017 18:14:25 +0200
Message-Id: <1508256866-12798-4-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make these const as they are only getting passed to the function
cache_create_net having the argument as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 fs/nfsd/export.c    | 4 ++--
 fs/nfsd/nfs4idmap.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 3bc08c3..06bb39c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -231,7 +231,7 @@ static struct cache_head *expkey_alloc(void)
 		return NULL;
 }
 
-static struct cache_detail svc_expkey_cache_template = {
+static const struct cache_detail svc_expkey_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPKEY_HASHMAX,
 	.name		= "nfsd.fh",
@@ -747,7 +747,7 @@ static struct cache_head *svc_export_alloc(void)
 		return NULL;
 }
 
-static struct cache_detail svc_export_cache_template = {
+static const struct cache_detail svc_export_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPORT_HASHMAX,
 	.name		= "nfsd.export",
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 6b9b6cc..a5bb765 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -178,7 +178,7 @@ struct ent {
 static struct ent *idtoname_update(struct cache_detail *, struct ent *,
 				   struct ent *);
 
-static struct cache_detail idtoname_cache_template = {
+static const struct cache_detail idtoname_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= ENT_HASHMAX,
 	.name		= "nfs4.idtoname",
@@ -341,7 +341,7 @@ static struct ent *nametoid_update(struct cache_detail *, struct ent *,
 				   struct ent *);
 static int         nametoid_parse(struct cache_detail *, char *, int);
 
-static struct cache_detail nametoid_cache_template = {
+static const struct cache_detail nametoid_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= ENT_HASHMAX,
 	.name		= "nfs4.nametoid",
-- 
1.9.1

