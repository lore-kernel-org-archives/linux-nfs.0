Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756936Ab2BHVRb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:17:31 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/17] CacheFiles: Make some debugging statements conditional
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:17:21 +0000
Message-ID: <20120208211721.15607.89229.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Downgrade some debugging statements to not unconditionally print stuff, but
rather be conditional on the appropriate module parameter setting.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/rdwr.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 26a6f52..885f1b2 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -77,25 +77,25 @@ static int cachefiles_read_reissue(struct cachefiles_object *object,
 	struct page *backpage = monitor->back_page, *backpage2;
 	int ret;
 
-	kenter("{ino=%lx},{%lx,%lx}",
+	_enter("{ino=%lx},{%lx,%lx}",
 	       object->backer->d_inode->i_ino,
 	       backpage->index, backpage->flags);
 
 	/* skip if the page was truncated away completely */
 	if (backpage->mapping != bmapping) {
-		kleave(" = -ENODATA [mapping]");
+		_leave(" = -ENODATA [mapping]");
 		return -ENODATA;
 	}
 
 	backpage2 = find_get_page(bmapping, backpage->index);
 	if (!backpage2) {
-		kleave(" = -ENODATA [gone]");
+		_leave(" = -ENODATA [gone]");
 		return -ENODATA;
 	}
 
 	if (backpage != backpage2) {
 		put_page(backpage2);
-		kleave(" = -ENODATA [different]");
+		_leave(" = -ENODATA [different]");
 		return -ENODATA;
 	}
 
@@ -114,7 +114,7 @@ static int cachefiles_read_reissue(struct cachefiles_object *object,
 		if (PageUptodate(backpage))
 			goto unlock_discard;
 
-		kdebug("reissue read");
+		_debug("reissue read");
 		ret = bmapping->a_ops->readpage(NULL, backpage);
 		if (ret < 0)
 			goto unlock_discard;
@@ -129,7 +129,7 @@ static int cachefiles_read_reissue(struct cachefiles_object *object,
 	}
 
 	/* it'll reappear on the todo list */
-	kleave(" = -EINPROGRESS");
+	_leave(" = -EINPROGRESS");
 	return -EINPROGRESS;
 
 unlock_discard:
@@ -137,7 +137,7 @@ unlock_discard:
 	spin_lock_irq(&object->work_lock);
 	list_del(&monitor->op_link);
 	spin_unlock_irq(&object->work_lock);
-	kleave(" = %d", ret);
+	_leave(" = %d", ret);
 	return ret;
 }
 

