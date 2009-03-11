From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] NFS: Fix nfs_path() to always return a '/' at the
 beginning of the path
Date: Wed, 11 Mar 2009 15:50:42 -0400
Message-ID: <189154bfc7f1671c1b161b0d7705d79a0fbbbb4e.1238525532.git.Trond.Myklebust@netapp.com>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <cover.1238525532.git.Trond.Myklebust@netapp.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/namespace.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 64a288e..63b2b19 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -65,6 +65,11 @@ char *nfs_path(const char *base,
 		dentry = dentry->d_parent;
 	}
 	spin_unlock(&dcache_lock);
+	if (*end != '/') {
+		if (--buflen < 0)
+			goto Elong;
+		*--end = '/';
+	}
 	namelen = strlen(base);
 	/* Strip off excess slashes in base string */
 	while (namelen > 0 && base[namelen - 1] == '/')
-- 
1.6.0.4

