Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55071 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753613Ab1LYSTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 Dec 2011 13:19:51 -0500
Date: Sun, 25 Dec 2011 13:19:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: file locking fix for 3.2
Message-ID: <20111225181948.GA26288@fieldses.org>
References: <20111224215012.GA23495@fieldses.org>
 <20111224225525.GR23916@ZenIV.linux.org.uk>
 <20111224235035.GA23711@fieldses.org>
 <20111225000542.GS23916@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111225000542.GS23916@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 25, 2011 at 12:05:42AM +0000, Al Viro wrote:
> On Sat, Dec 24, 2011 at 06:50:35PM -0500, J. Bruce Fields wrote:
> 
> > Then you're returning -ENOMEM in a case when we really didn't need to do
> > an allocation, but is that really a problem?  It's a rare case, and
> > opens can already fail with -ENOMEM for other reasons, and I'd rather
> > not have the extra hair.
> 
> I'm certainly OK with that variant; if the folks maintaining fs/locks.c

I've been more-or-less assuming that's me, not that I've been doing much
real maintenance to speak of.

> are happy with it, I'd suggest going for it.  Note that you don't need
> to touch locks_conflict() call at all if you bail out early on allocation
> failure and it's definitely simpler and cleaner that way.

Yep.

With no more -rc, and no chance to test anything myself till I'm back
from the holidays, my preference would be for Linus to merge the
already-posted one-liner.  Then I can queue up the below for 3.3.

--b.

commit 72acf27f6c20573d555d6b4450a7a9d41c4c9d5a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Dec 25 10:51:37 2011 -0700

    locks: simplify allocation in break_lease
    
    The code bends over backwards to avoid returning -ENOMEM in cases where
    the allocation wasn't really necessary.
    
    But there's nothing really *wrong* with returning -ENOMEM in those
    cases: break_lease callers can already return -ENOMEM for other reasons.
    So let's not take so much trouble over a rare case, and keep the code
    simpler.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/locks.c b/fs/locks.c
index 96a487a..0bd1745 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1205,6 +1205,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 
 	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
+	if (IS_ERR(new_fl))
+		return PTR_ERR(new_fl);
 
 	lock_flocks();
 
@@ -1214,19 +1216,13 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	if ((flock == NULL) || !IS_LEASE(flock))
 		goto out;
 
-	if (flock->fl_type == F_RDLCK && !want_write)
-		goto out; /* no conflict */
+	if (!locks_conflict(flock, new_fl))
+		goto out;
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next)
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
