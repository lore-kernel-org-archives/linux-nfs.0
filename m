Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440Ab1IWQ02 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:26:28 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 5/7] VFS: Ignore symlink following advice when pathwalking
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:25:41 +0100
Message-ID: <20110923162541.13574.38896.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ignore symlink advice (LOOKUP_FOLLOW) when walking the terminal component of a
path.  Base the decision entirely on LOOKUP_NO_AUTOMOUNT as this is now set
(or not) by the callers of path walk, most notably the relevant syscall
handlers.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c |   19 -------------------
 1 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index c2a2cc3..89e3dc3 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -727,25 +727,6 @@ static int follow_automount(struct path *path, unsigned flags,
 	if (!(flags & LOOKUP_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
 		return -EISDIR; /* we actually want to stop here */
 
-	/*
-	 * We don't want to mount if someone's just doing a stat and they've
-	 * set AT_SYMLINK_NOFOLLOW - unless they're stat'ing a directory and
-	 * appended a '/' to the name.
-	 */
-	if (!(flags & LOOKUP_FOLLOW)) {
-		/* We do, however, want to mount if someone wants to open or
-		 * create a file of any type under the mountpoint, wants to
-		 * traverse through the mountpoint or wants to open the mounted
-		 * directory.
-		 * Also, autofs may mark negative dentries as being automount
-		 * points.  These will need the attentions of the daemon to
-		 * instantiate them before they can be used.
-		 */
-		if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
-			     LOOKUP_OPEN | LOOKUP_CREATE)) &&
-		    path->dentry->d_inode)
-			return -EISDIR;
-	}
 	current->total_link_count++;
 	if (current->total_link_count >= 40)
 		return -ELOOP;

