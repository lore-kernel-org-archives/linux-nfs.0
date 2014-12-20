Return-Path: linux-kernel-owner@vger.kernel.org
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 5/5] vfs: update swap_{,de}activate documentation
Date: Fri, 19 Dec 2014 19:18:29 -0800
Message-Id: <5bb833720e5f14f077e824c19d1213dd57a282c6.1419044605.git.osandov@osandov.com>
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
References: <cover.1419044605.git.osandov@osandov.com>
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
References: <cover.1419044605.git.osandov@osandov.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Parameters were added to swap_activate in the same patch series that
introduced it without updating the documentation. Additionally, the
documentation claims that non-existent address space operations
->swap_{in,out} are used for swap I/O, but now we use
->{read,write}_iter.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 Documentation/filesystems/Locking | 7 ++++---
 Documentation/filesystems/vfs.txt | 7 ++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index b30753c..e72b4c3 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -205,7 +205,8 @@ prototypes:
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
-	int (*swap_activate)(struct file *);
+	int (*swap_activate)(struct swap_info_struct *, struct file *,
+			     sector_t *);
 	int (*swap_deactivate)(struct file *);
 
 locking rules:
@@ -230,8 +231,8 @@ migratepage:		yes (both)
 launder_page:		yes
 is_partially_uptodate:	yes
 error_remove_page:	yes
-swap_activate:		no
-swap_deactivate:	no
+swap_activate:					yes
+swap_deactivate:				no
 
 	->write_begin(), ->write_end(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 43ce050..9c793a7 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -600,8 +600,9 @@ struct address_space_operations {
 					unsigned long);
 	void (*is_dirty_writeback) (struct page *, bool *, bool *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
-	int (*swap_activate)(struct file *);
-	int (*swap_deactivate)(struct file *);
+	int (*swap_activate)(struct swap_info_struct *, struct file *,
+			     sector_t *);
+	void (*swap_deactivate)(struct file *);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -788,7 +789,7 @@ struct address_space_operations {
 	memory. A return value of zero indicates success,
 	in which case this file can be used to back swapspace. The
 	swapspace operations will be proxied to this address space's
-	->swap_{out,in} methods.
+	->{read,write}_iter methods with O_DIRECT.
 
   swap_deactivate: Called during swapoff on files where swap_activate
 	was successful.
-- 
2.2.1

