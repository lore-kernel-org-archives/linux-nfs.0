Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35356 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbcFDA4O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2016 20:56:14 -0400
Date: Sat, 4 Jun 2016 01:56:11 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, linux-nfs@vger.kernel.org
Subject: Re: Dcache oops
Message-ID: <20160604005611.GA14480@ZenIV.linux.org.uk>
References: <74306F63-DBDF-4DED-85D2-5C3FB21B8A1E@linuxhacker.ru>
 <20160603182203.GR14480@ZenIV.linux.org.uk>
 <4285E00F-7228-485C-AD32-97552ED746F2@linuxhacker.ru>
 <20160603200759.GS14480@ZenIV.linux.org.uk>
 <CA+55aFznPit97evuwZHdCG55=N0QbkFSST2ydKxvExQTR-YXTg@mail.gmail.com>
 <20160603212652.GT14480@ZenIV.linux.org.uk>
 <CA+55aFyYkbXqoJ3PqfrnxWDEXJM_BH6Q_OdKf+UVJYEUF4gdQA@mail.gmail.com>
 <20160603222355.GW14480@ZenIV.linux.org.uk>
 <20160603223700.GY14480@ZenIV.linux.org.uk>
 <DA67EEEA-D769-4D0F-9C20-6145F2B0808F@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DA67EEEA-D769-4D0F-9C20-6145F2B0808F@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 03, 2016 at 07:58:37PM -0400, Oleg Drokin wrote:

> > EOPENSTALE, that is...  Oleg, could you check if the following works?
> 
> Yes, this one lasted for an hour with no crashing, so it must be good.
> Thanks.
> (note, I am not equipped to verify correctness of NFS operations, though).

I suspect that Jeff Layton might have relevant regression tests.  Incidentally,
we really need a consolidated regression testsuite, including the tests you'd
been running.  Right now there's some stuff in xfstests, LTP and cthon; if
anything, this mess shows just why we need all of that and then some in
a single place.  Lustre stuff has caught a 3 years old NFS bug (missing
d_drop() in nfs_atomic_open()) and a year-old bug in handling of EOPENSTALE
retries on the last component of a trailing non-embedded symlink.  Neither
is hard to trigger; it's just that relevant tests hadn't been run on NFS,
period.

Jeff, could you verify that the following does not cause regressions in
stale fhandles treatment?  I want to rip the damn retry logics out of
do_last() and if the staleness had only been discovered inside of
nfs4_file_open() just have the upper-level logics handle it by doing
a normal LOOKUP_REVAL pass from scratch.  To hell with trying to be clever;
a few roundtrips it saves us in some cases is not worth the complexity and
potential for bugs.  I'm fairly sure that the time spent debugging this
particular turd exceeds the total amount of time it has ever saved,
and do_last() is in dire need of simplification.  All talk about "enough eyes"
isn't worth much when the readers of code in question feel like ripping their
eyes out...

diff --git a/fs/namei.c b/fs/namei.c
index 4c4f95a..3d9511e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3166,9 +3166,7 @@ static int do_last(struct nameidata *nd,
 	int acc_mode = op->acc_mode;
 	unsigned seq;
 	struct inode *inode;
-	struct path save_parent = { .dentry = NULL, .mnt = NULL };
 	struct path path;
-	bool retried = false;
 	int error;
 
 	nd->flags &= ~LOOKUP_PARENT;
@@ -3211,7 +3209,6 @@ static int do_last(struct nameidata *nd,
 			return -EISDIR;
 	}
 
-retry_lookup:
 	if (open_flag & (O_CREAT | O_TRUNC | O_WRONLY | O_RDWR)) {
 		error = mnt_want_write(nd->path.mnt);
 		if (!error)
@@ -3292,23 +3289,14 @@ finish_lookup:
 	if (unlikely(error))
 		return error;
 
-	if ((nd->flags & LOOKUP_RCU) || nd->path.mnt != path.mnt) {
-		path_to_nameidata(&path, nd);
-	} else {
-		save_parent.dentry = nd->path.dentry;
-		save_parent.mnt = mntget(path.mnt);
-		nd->path.dentry = path.dentry;
-
-	}
+	path_to_nameidata(&path, nd);
 	nd->inode = inode;
 	nd->seq = seq;
 	/* Why this, you ask?  _Now_ we might have grown LOOKUP_JUMPED... */
 finish_open:
 	error = complete_walk(nd);
-	if (error) {
-		path_put(&save_parent);
+	if (error)
 		return error;
-	}
 	audit_inode(nd->name, nd->path.dentry, 0);
 	error = -EISDIR;
 	if ((open_flag & O_CREAT) && d_is_dir(nd->path.dentry))
@@ -3331,13 +3319,9 @@ finish_open_created:
 		goto out;
 	BUG_ON(*opened & FILE_OPENED); /* once it's opened, it's opened */
 	error = vfs_open(&nd->path, file, current_cred());
-	if (!error) {
-		*opened |= FILE_OPENED;
-	} else {
-		if (error == -EOPENSTALE)
-			goto stale_open;
+	if (error)
 		goto out;
-	}
+	*opened |= FILE_OPENED;
 opened:
 	error = open_check_o_direct(file);
 	if (!error)
@@ -3353,26 +3337,7 @@ out:
 	}
 	if (got_write)
 		mnt_drop_write(nd->path.mnt);
-	path_put(&save_parent);
 	return error;
-
-stale_open:
-	/* If no saved parent or already retried then can't retry */
-	if (!save_parent.dentry || retried)
-		goto out;
-
-	BUG_ON(save_parent.dentry != dir);
-	path_put(&nd->path);
-	nd->path = save_parent;
-	nd->inode = dir->d_inode;
-	save_parent.mnt = NULL;
-	save_parent.dentry = NULL;
-	if (got_write) {
-		mnt_drop_write(nd->path.mnt);
-		got_write = false;
-	}
-	retried = true;
-	goto retry_lookup;
 }
 
 static int do_tmpfile(struct nameidata *nd, unsigned flags,

