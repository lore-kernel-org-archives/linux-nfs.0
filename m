Return-Path: linux-kernel-owner@vger.kernel.org
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 6/7] btrfs: add EXTENT_FLAG_SWAPFILE
Date: Tue,  9 Dec 2014 17:45:47 -0800
Message-Id: <f489d4ad85df4039f3a84f1a2f89735c9a1cf88d.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extents mapping a swap file should remain pinned in memory in order to
avoid doing allocations to look up an extent when we're already low on
memory. Rather than overloading EXTENT_FLAG_PINNED, add a new flag
specifically for this purpose.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/btrfs/extent_io.c         | 1 +
 fs/btrfs/extent_map.h        | 1 +
 fs/btrfs/inode.c             | 1 +
 include/trace/events/btrfs.h | 3 ++-
 4 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index bf3f424..36166d0 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -4244,6 +4244,7 @@ int try_release_extent_mapping(struct extent_map_tree *map,
 				break;
 			}
 			if (test_bit(EXTENT_FLAG_PINNED, &em->flags) ||
+			    test_bit(EXTENT_FLAG_SWAPFILE, &em->flags) ||
 			    em->start != start) {
 				write_unlock(&map->lock);
 				free_extent_map(em);
diff --git a/fs/btrfs/extent_map.h b/fs/btrfs/extent_map.h
index b2991fd..93b9548 100644
--- a/fs/btrfs/extent_map.h
+++ b/fs/btrfs/extent_map.h
@@ -16,6 +16,7 @@
 #define EXTENT_FLAG_LOGGING 4 /* Logging this extent */
 #define EXTENT_FLAG_FILLING 5 /* Filling in a preallocated extent */
 #define EXTENT_FLAG_FS_MAPPING 6 /* filesystem extent mapping type */
+#define EXTENT_FLAG_SWAPFILE 7 /* this extent maps a swap file */
 
 struct extent_map {
 	struct rb_node rb_node;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index d23362f..7c2dfb2 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -6353,6 +6353,7 @@ again:
 		else
 			goto out;
 	}
+	WARN_ON_ONCE(IS_SWAPFILE(inode));
 	em = alloc_extent_map();
 	if (!em) {
 		err = -ENOMEM;
diff --git a/include/trace/events/btrfs.h b/include/trace/events/btrfs.h
index 1faecea..5c5f9de 100644
--- a/include/trace/events/btrfs.h
+++ b/include/trace/events/btrfs.h
@@ -164,7 +164,8 @@ DEFINE_EVENT(btrfs__inode, btrfs_inode_evict,
 		{ (1 << EXTENT_FLAG_PREALLOC), 		"PREALLOC" 	},\
 		{ (1 << EXTENT_FLAG_LOGGING),	 	"LOGGING" 	},\
 		{ (1 << EXTENT_FLAG_FILLING),	 	"FILLING" 	},\
-		{ (1 << EXTENT_FLAG_FS_MAPPING),	"FS_MAPPING"	})
+		{ (1 << EXTENT_FLAG_FS_MAPPING),	"FS_MAPPING"	},\
+		{ (1 << EXTENT_FLAG_SWAPFILE),		"SWAPFILE"	})
 
 TRACE_EVENT_CONDITION(btrfs_get_extent,
 
-- 
2.1.3

