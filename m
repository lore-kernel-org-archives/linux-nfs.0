Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61573 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab1LZSiX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Dec 2011 13:38:23 -0500
Date: Mon, 26 Dec 2011 10:37:56 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: file locking fix for 3.2
In-Reply-To: <20111225181948.GA26288@fieldses.org>
Message-ID: <alpine.LFD.2.02.1112261035240.27600@i5.linux-foundation.org>
References: <20111224215012.GA23495@fieldses.org> <20111224225525.GR23916@ZenIV.linux.org.uk> <20111224235035.GA23711@fieldses.org> <20111225000542.GS23916@ZenIV.linux.org.uk> <20111225181948.GA26288@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I'm committing the appended version instead. It removes all the games with 
IS_ERR(), and just does the checking at the allocation point, the way the 
other lease_alloc() user does too.

Holler if you see something odd in there..

                   Linus
---
commit 6d4b9e38d3980826abccfbd90e95bf4bd41b8dd2
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Mon Dec 26 10:25:26 2011 -0800

    vfs: fix handling of lock allocation failure in lease-break case
    
    Bruce Fields notes that commit 778fc546f749 ("locks: fix tracking of
    inprogress lease breaks") introduced a possible error pointer
    dereference on failure to allocate memory.  locks_conflict() will
    dereference the passed-in new lease lock structure that may be an error pointer.
    
    This means an open (without O_NONBLOCK set) on a file with a lease
    applied (generally only done when Samba or nfsd (with v4) is running)
    could crash if a kmalloc() fails.
    
    So instead of playing games with IS_ERROR() all over the place, just
    check the allocation failure early.  That makes the code more
    straightforward, and avoids this possible bad pointer dereference.
    
    Based-on-patch-by: J. Bruce Fields <bfields@redhat.com>
    Cc: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 fs/locks.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 3b0d05dcd7c1..637694bf3a03 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1205,6 +1205,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
+	if (IS_ERR(new_fl))
+		return PTR_ERR(new_fl);
 
 	lock_flocks();
 
@@ -1221,12 +1223,6 @@ int __break_lease(struct inode *inode, unsigned int mode)
 		if (fl->fl_owner == current->files)
 			i_have_this_lease = 1;
 
-	if (IS_ERR(new_fl) && !i_have_this_lease
-			&& ((mode & O_NONBLOCK) == 0)) {
-		error = PTR_ERR(new_fl);
-		goto out;
-	}
-
 	break_time = 0;
 	if (lease_break_time > 0) {
 		break_time = jiffies + lease_break_time * HZ;
@@ -1284,8 +1280,7 @@ restart:
 
 out:
 	unlock_flocks();
-	if (!IS_ERR(new_fl))
-		locks_free_lock(new_fl);
+	locks_free_lock(new_fl);
 	return error;
 }
 
