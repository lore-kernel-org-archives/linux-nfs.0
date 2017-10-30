Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40795 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751837AbdJ3NsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 09:48:04 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] nlm_shutdown_hosts_net() cleanup
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <1d1a25d8-a34b-5175-bb6a-9549041c11f4@virtuozzo.com>
Date: Mon, 30 Oct 2017 16:47:58 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nlm_complain_hosts() walk through nlm_server_hosts hlist that should be
protected by nlm_host_mutex.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/host.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index d716c99..089c1d7 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -617,9 +617,8 @@ nlm_shutdown_hosts_net(struct net *net)
 
 	/* Then, perform a garbage collection pass */
 	nlm_gc_hosts(net);
-	mutex_unlock(&nlm_host_mutex);
-
 	nlm_complain_hosts(net);
+	mutex_unlock(&nlm_host_mutex);
 }
 
 /*
-- 
2.7.4

