From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Sat, 12 Apr 2008 20:08:30 -0400
Message-ID: <20080413000830.GF31789@fieldses.org>
References: <E1JjcgO-0004q2-VJ@pomaz-ex.szeredi.hu> <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org> <20080410215410.GF22324@fieldses.org> <E1JkOff-0000pS-A7@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, eshel@almaden.ibm.com, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JkOff-0000pS-A7@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:12:23PM +0200, Miklos Szeredi wrote:
> > > OK. So the correct fix here should really be applied to fcntl_setlk().
> > > There is absolutely no reason why we should be looping at all if the
> > > filesystem has a ->lock() method.
> > > 
> > > In fact, this looping behaviour was introduced recently in commit
> > > 7723ec9777d9832849b76475b1a21a2872a40d20.
> > 
> > Apologies, that was indeed a behavioral change introduced in a commit
> > that claimed just to be shuffling code around.
> 
> Yeah, that patch looks totally wrong.  It's not generally a good idea
> to do a loop where the exit condition depends on something you don't
> control.  And error values from filesystem methods are typically like
> that.  For example with fuse, the error code could come from an
> unprivileged userspace process.
> 
> I didn't realize this aspect of the bug previously, because I
> concentrated on the lockd inconsistency.

So, does this patch on its own fix the problem you saw?

Any extra eyes welcome....

--b.

commit e56100676b9ea3b2d5f3e937c3ce8a5149cffb84
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sat Apr 12 18:12:15 2008 -0400

    locks: fix possible infinite loop in fcntl(F_SETLKW) over nfs
    
    Miklos Szeredi found the bug:
    
    	"Basically what happens is that on the server nlm_fopen() calls
    	nfsd_open() which returns -EACCES, to which nlm_fopen() returns
    	NLM_LCK_DENIED.
    
    	"On the client this will turn into a -EAGAIN (nlm_stat_to_errno()),
    	which in will cause fcntl_setlk() to retry forever."
    
    So, for example, opening a file on an nfs filesystem, changing
    permissions to forbid further access, then trying to lock the file,
    could result in an infinite loop.
    
    And Trond Myklebust identified the culprit, from Marc Eshel and I:
    
    	7723ec9777d9832849b76475b1a21a2872a40d20 "locks: factor out
    	generic/filesystem switch from setlock code"
    
    That commit claimed to just be reshuffling code, but actually introduced
    a behavioral change by calling the lock method repeatedly as long as it
    returned -EAGAIN.
    
    We assumed this would be safe, since we assumed a lock of type SETLKW
    would only return with either success or an error other than -EAGAIN.
    However, nfs does can in fact return -EAGAIN in this situation, and
    independently of whether that behavior is correct or not, we don't
    actually need this change, and it seems far safer not to depend on such
    assumptions about the filesystem's ->lock method.
    
    Therefore, revert the problematic part of the original commit.  This
    leaves vfs_lock_file() and its other callers unchanged, while returning
    fcntl_setlk and fcntl_setlk64 to their former behavior.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: Miklos Szeredi <mszeredi@suse.cz>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: Marc Eshel <eshel@almaden.ibm.com>

diff --git a/fs/locks.c b/fs/locks.c
index d83fab1..43c0af2 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1801,17 +1801,21 @@ again:
 	if (error)
 		goto out;
 
-	for (;;) {
-		error = vfs_lock_file(filp, cmd, file_lock, NULL);
-		if (error != -EAGAIN || cmd == F_SETLK)
-			break;
-		error = wait_event_interruptible(file_lock->fl_wait,
-				!file_lock->fl_next);
-		if (!error)
-			continue;
+	if (filp->f_op && filp->f_op->lock != NULL)
+		error = filp->f_op->lock(filp, cmd, file_lock);
+	else {
+		for (;;) {
+			error = posix_lock_file(filp, file_lock, NULL);
+			if (error != -EAGAIN || cmd == F_SETLK)
+				break;
+			error = wait_event_interruptible(file_lock->fl_wait,
+					!file_lock->fl_next);
+			if (!error)
+				continue;
 
-		locks_delete_block(file_lock);
-		break;
+			locks_delete_block(file_lock);
+			break;
+		}
 	}
 
 	/*
@@ -1925,17 +1929,21 @@ again:
 	if (error)
 		goto out;
 
-	for (;;) {
-		error = vfs_lock_file(filp, cmd, file_lock, NULL);
-		if (error != -EAGAIN || cmd == F_SETLK64)
-			break;
-		error = wait_event_interruptible(file_lock->fl_wait,
-				!file_lock->fl_next);
-		if (!error)
-			continue;
+	if (filp->f_op && filp->f_op->lock != NULL)
+		error = filp->f_op->lock(filp, cmd, file_lock);
+	else {
+		for (;;) {
+			error = posix_lock_file(filp, file_lock, NULL);
+			if (error != -EAGAIN || cmd == F_SETLK64)
+				break;
+			error = wait_event_interruptible(file_lock->fl_wait,
+					!file_lock->fl_next);
+			if (!error)
+				continue;
 
-		locks_delete_block(file_lock);
-		break;
+			locks_delete_block(file_lock);
+			break;
+		}
 	}
 
 	/*
