Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43928 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757715Ab0LNPGf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:06:35 -0500
Received: by yxt3 with SMTP id 3so385481yxt.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:06:34 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/11] lockd: Make nrhosts an unsigned long
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:06:32 -0500
Message-ID: <20101214150632.2736.85687.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
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
index 87fbde1..77ec21a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -40,7 +40,7 @@ static struct hlist_head	nlm_client_hosts[NLM_HOST_NRHASH];
 						(chain), h_hash)
 
 static unsigned long		next_gc;
-static int			nrhosts;
+static unsigned long		nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
@@ -673,9 +673,9 @@ nlm_shutdown_hosts(void)
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

