Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757023Ab2BHVRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:17:21 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 03/17] FS-Cache: Check that there are no read ops when cookie
 relinquished
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:17:11 +0000
Message-ID: <20120208211711.15607.46274.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

