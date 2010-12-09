Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:44188 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab0LIQuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 11:50:04 -0500
Received: by mail-gw0-f42.google.com with SMTP id 20so2209519gwb.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Dec 2010 08:50:04 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/11] lockd: Make nrhosts an unsigned long
To: linux-nfs@vger.kernel.org
Date: Thu, 09 Dec 2010 11:50:01 -0500
Message-ID: <20101209165001.4513.66409.stgit@matisse.1015granger.net>
In-Reply-To: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
References: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 2b515e2..43d8d0c 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -40,7 +40,7 @@ static struct hlist_head	nlm_client_hosts[NLM_HOST_NRHASH];
 						(chain), h_hash)
 
 static unsigned long		next_gc;
-static int			nrhosts;
+static unsigned long		nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
@@ -669,9 +669,9 @@ nlm_shutdown_hosts(void)
 	mutex_unlock(&nlm_host_mutex);
 
 	/* complain if any hosts are left */
-	if (nrhosts) {
+	if (nrhosts != 0) {
 		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
-		dprintk("lockd: %d hosts left:\n", nrhosts);
+		dprintk("lockd: %lu hosts left:\n", nrhosts);
 		for_each_host(host, pos, chain, nlm_server_hosts) {
 			dprintk("       %s (cnt %d use %d exp %ld)\n",
 				host->h_name, atomic_read(&host->h_count),

