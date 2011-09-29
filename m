Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113Ab1I2Orh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:47:37 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 05/13] FS-Cache: Check that there are no read ops when cookie
 relinquished
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:46:36 +0100
Message-ID: <20110929144636.5812.2157.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
References: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Check that the netfs isn't trying to relinquish a cookie that still has read
operations in progress upon it.  If there are, then give log a warning and BUG.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cookie.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 9905350..0666996 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -452,6 +452,14 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, int retire)
 
 		_debug("RELEASE OBJ%x", object->debug_id);
 
+		if (atomic_read(&object->n_reads)) {
+			spin_unlock(&cookie->lock);
+			printk(KERN_ERR "FS-Cache:"
+			       " Cookie '%s' still has %d outstanding reads\n",
+			       cookie->def->name, atomic_read(&object->n_reads));
+			BUG();
+		}
+
 		/* detach each cache object from the object cookie */
 		spin_lock(&object->lock);
 		hlist_del_init(&object->cookie_link);

