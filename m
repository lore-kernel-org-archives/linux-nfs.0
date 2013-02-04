Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:42670 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754266Ab3BDLCI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 06:02:08 -0500
Subject: [PATCH v2 6/6] SUNRPC: move cache_detail->cache_request callback call
	to cache_read()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 04 Feb 2013 14:03:03 +0300
Message-ID: <20130204110303.11633.95912.stgit@localhost.localdomain>
In-Reply-To: <20130204105728.11633.53621.stgit@localhost.localdomain>
References: <20130204105728.11633.53621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The reason to move cache_request() callback call from
sunrpc_cache_pipe_upcall() to cache_read() is that this garantees, that cache
access will be done userspace process context (only userspace process have
proper root context).
This is required for NFSd support in container: svc_export_request() (which is
cache_request callback) calls d_path(), which, in turn, traverse dentry up to
current->fs->root. Kernel threads always have global root, while container
have be in "root jail" - i.e. have it's own nested root.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/cache.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8ffec5a..5502471 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -750,6 +750,18 @@ struct cache_reader {
 	int			offset;	/* if non-0, we have a refcnt on next request */
 };
 
+static int cache_request(struct cache_detail *detail,
+			       struct cache_request *crq)
+{
+	char *bp = crq->buf;
+	int len = PAGE_SIZE;
+
+	detail->cache_request(detail, crq->item, &bp, &len);
+	if (len < 0)
+		return -EAGAIN;
+	return PAGE_SIZE - len;
+}
+
 static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
 			  loff_t *ppos, struct cache_detail *cd)
 {
@@ -784,6 +796,13 @@ static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
 		rq->readers++;
 	spin_unlock(&queue_lock);
 
+	if (rq->len == 0) {
+		err = cache_request(cd, rq);
+		if (err < 0)
+			goto out;
+		rq->len = err;
+	}
+
 	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
 		err = -EAGAIN;
 		spin_lock(&queue_lock);
@@ -1145,8 +1164,6 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 
 	char *buf;
 	struct cache_request *crq;
-	char *bp;
-	int len;
 
 	if (!detail->cache_request)
 		return -EINVAL;
@@ -1166,19 +1183,10 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 		return -EAGAIN;
 	}
 
-	bp = buf; len = PAGE_SIZE;
-
-	detail->cache_request(detail, h, &bp, &len);
-
-	if (len < 0) {
-		kfree(buf);
-		kfree(crq);
-		return -EAGAIN;
-	}
 	crq->q.reader = 0;
 	crq->item = cache_get(h);
 	crq->buf = buf;
-	crq->len = PAGE_SIZE - len;
+	crq->len = 0;
 	crq->readers = 0;
 	spin_lock(&queue_lock);
 	list_add_tail(&crq->q.list, &detail->queue);

