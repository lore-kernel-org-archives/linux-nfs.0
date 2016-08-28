Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:24127 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752619AbcH1Uyq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 16:54:46 -0400
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: kernel-janitors@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: constify reply_cache_stats_operations structure
Date: Sun, 28 Aug 2016 22:36:55 +0200
Message-Id: <1472416615-24079-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

reply_cache_stats_operations, of type struct file_operations, is never
modified, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 fs/nfsd/nfsctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 65ad016..3bc9693 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -217,7 +217,7 @@ static const struct file_operations pool_stats_operations = {
 	.release	= nfsd_pool_stats_release,
 };
 
-static struct file_operations reply_cache_stats_operations = {
+static const struct file_operations reply_cache_stats_operations = {
 	.open		= nfsd_reply_cache_stats_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,

