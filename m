From: David Howells <dhowells@redhat.com>
Subject: [PATCH 16/18] xstat: Remove the automount through follow_link()
	kludge code from pathwalk [ver #6]
Date: Thu, 15 Jul 2010 03:17:28 +0100
Message-ID: <20100715021728.5544.68615.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the automount through follow_link() kludge code from pathwalk in favour
of using d_automount().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c |   17 +++--------------
 1 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index fcec3c6..86068a2 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -845,17 +845,6 @@ fail:
 }
 
 /*
- * This is a temporary kludge to deal with "automount" symlinks; proper
- * solution is to trigger them on follow_mount(), so that do_lookup()
- * would DTRT.  To be killed before 2.6.34-final.
- */
-static inline int follow_on_final(struct inode *inode, unsigned lookup_flags)
-{
-	return inode && unlikely(inode->i_op->follow_link) &&
-		((lookup_flags & LOOKUP_FOLLOW) || S_ISDIR(inode->i_mode));
-}
-
-/*
  * Name resolution.
  * This is the basic name resolution function, turning a pathname into
  * the final dentry. We expect 'base' to be positive and a directory.
@@ -975,7 +964,8 @@ last_component:
 		if (err)
 			break;
 		inode = next.dentry->d_inode;
-		if (follow_on_final(inode, lookup_flags)) {
+		if (inode && unlikely(inode->i_op->follow_link) &&
+		    (lookup_flags & LOOKUP_FOLLOW)) {
 			err = do_follow_link(&next, nd);
 			if (err)
 				goto return_err;
@@ -1888,8 +1878,7 @@ reval:
 		struct inode *inode = path.dentry->d_inode;
 		void *cookie;
 		error = -ELOOP;
-		/* S_ISDIR part is a temporary automount kludge */
-		if (!(nd.flags & LOOKUP_FOLLOW) && !S_ISDIR(inode->i_mode))
+		if (!(nd.flags & LOOKUP_FOLLOW))
 			goto exit_dput;
 		if (count++ == 32)
 			goto exit_dput;

