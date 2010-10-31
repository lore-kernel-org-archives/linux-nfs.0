Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51683 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755507Ab0JaMfe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Oct 2010 08:35:34 -0400
Date: Sun, 31 Oct 2010 08:35:31 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] locks: remove fl_copy_lock lock_manager operation
Message-ID: <20101031123531.GB4520@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101031123419.GA4491@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This one was only used for a nasty hack in nfsd, which has recently
been removed.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/locks.c
===================================================================
--- linux-2.6.orig/fs/locks.c	2010-10-31 07:10:07.649004084 -0400
+++ linux-2.6/fs/locks.c	2010-10-31 07:34:10.102255587 -0400
@@ -235,11 +235,8 @@ static void locks_copy_private(struct fi
 			fl->fl_ops->fl_copy_lock(new, fl);
 		new->fl_ops = fl->fl_ops;
 	}
-	if (fl->fl_lmops) {
-		if (fl->fl_lmops->fl_copy_lock)
-			fl->fl_lmops->fl_copy_lock(new, fl);
+	if (fl->fl_lmops)
 		new->fl_lmops = fl->fl_lmops;
-	}
 }
 
 /*
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking	2010-10-31 07:34:13.269012536 -0400
+++ linux-2.6/Documentation/filesystems/Locking	2010-10-31 07:34:20.567292713 -0400
@@ -322,7 +322,6 @@ fl_release_private:	yes	yes
 prototypes:
 	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
 	void (*fl_notify)(struct file_lock *);  /* unblock callback */
-	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *); /* break_lease callback */
 
@@ -330,7 +329,6 @@ locking rules:
 			BKL	may block
 fl_compare_owner:	yes	no
 fl_notify:		yes	no
-fl_copy_lock:		yes	no
 fl_release_private:	yes	yes
 fl_break:		yes	no
 
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2010-10-31 07:33:13.131262640 -0400
+++ linux-2.6/include/linux/fs.h	2010-10-31 07:33:25.959005833 -0400
@@ -1056,7 +1056,6 @@ struct lock_manager_operations {
 	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
 	void (*fl_notify)(struct file_lock *);	/* unblock callback */
 	int (*fl_grant)(struct file_lock *, struct file_lock *, int);
-	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *);
 	int (*fl_mylease)(struct file_lock *, struct file_lock *);
