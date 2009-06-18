From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] NFS: Fix nfs_path() to always return a '/' at the
 beginning of the path
Date: Thu, 18 Jun 2009 12:25:01 -0700
Message-ID: <20090618192501.19433.174.stgit@heimdal.trondhjem.org>
References: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/namespace.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index f01caec..40c7667 100644
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

