Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40013 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab2LKNLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 08:11:42 -0500
Received: by mail-gg0-f174.google.com with SMTP id k2so711147ggd.19
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2012 05:11:42 -0800 (PST)
Date: Tue, 11 Dec 2012 08:11:35 -0500
From: Jeff Layton <jlayton@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Pavel Shilovsky <piastry@etersoft.ru>,
        Christoph Hellwig <hch@infradead.org>, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        wine-devel@winehq.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121211081135.136ee0d0@tlielax.poochiereds.net>
In-Reply-To: <20121210164116.GC13327@fieldses.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
	<20121207161602.GA17710@infradead.org>
	<495d17310e0a687d446afc86def0f058@office.etersoft.ru>
	<20121210164116.GC13327@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Dec 2012 11:41:16 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Dec 08, 2012 at 12:43:14AM +0400, Pavel Shilovsky wrote:
> > The problem is the possibility of denial-of-service attacks here. We
> > can try to prevent them by:
> > 1) specifying an extra security bit on the file that indicates that
> > share flags are accepted (like we have for mandatory locks now) and
> > setting it for neccessary files only, or
> > 2) adding a special mount option (but it it probably makes sense if
> > we decided to add this support for CIFS and NFS only).
> 
> In the case of knfsd and samba exporting a common filesystem, you'd also
> want to be able to enforce it on the exported filesystem.
> 

Sorry for chiming in late on this, but I've been looking at this
problem from the other end as well, from the POV of a fileserver. For
there, you absolutely do want to have some mechanism for enforcing this
on local filesystems. 

Currently, file servers generally enforce share reservations
internally. The upshot is that they're not aware when other tasks
outside the server modify a file. This is also problematic too in many
common fileserving situations -- when exporting files via both NFS and
SMB, for instance.

One thing that's important to note is that there is already some
support for this in the kernel. The LOCK_MAND flag and its associates
are intended for just this purpose. Samba even already calls into the
kernel to set LOCK_MAND locks, but the kernel just passes them through
to the fs. Rumor has it that GPFS does something with these flags, but
I can't confirm that.

Of course, LOCK_MAND is racy since you can't set it on open(), but it
might be nice to use that as a starting point for trying to add this
support.

At the very least, if we're going to do this, we need to consider what
to do with the LOCK_MAND interfaces. As a starting point for
discussion, here's a patch that I was playing with a few months ago. I
haven't had much time to really spend on this project, but it may be
worthwhile to consider. It works, but I'm not sure about the
semantics...

-----------------------------[snip]--------------------------------

locks: add enforcement of LOCK_MAND locks

The LOCK_MAND lock mechanism is currently a no-op for any in-tree
filesystem. The flags are passed to f_ops->flock, but the standard
flock routines basically ignore them.

Change this by adding enforcement against other LOCK_MAND locks. Also,
assume that LOCK_MAND also implies LOCK_NB.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c | 45 ++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 814c51d..736e38b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -625,6 +625,43 @@ static int posix_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
 	return (locks_conflict(caller_fl, sys_fl));
 }
 
+/*
+ * locks_mand_conflict - Determine if there's a share reservation conflict
+ * @caller_fl: lock we're attempting to acquire
+ * @sys_fl: lock already present on system that we're checking against
+ *
+ * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
+ * tell us whether the reservation allows other readers and writers.
+ *
+ * We only check against other LOCK_MAND locks, so applications that want to
+ * use share mode locking will only conflict against one another. "normal"
+ * applications that open files won't be affected by and won't themselves
+ * affect the share reservations.
+ */
+static int locks_mand_conflict(struct file_lock *caller_fl,
+				struct file_lock *sys_fl)
+{
+	unsigned char caller_type = caller_fl->fl_type;
+	unsigned char sys_type = sys_fl->fl_type;
+	fmode_t	caller_fmode = caller_fl->fl_file->f_mode;
+	fmode_t sys_fmode = sys_fl->fl_file->f_mode;
+
+	/* they can only conflict if they're both LOCK_MAND */
+	if (!(caller_type & LOCK_MAND) || !(sys_type & LOCK_MAND))
+		return 0;
+
+	if (!(caller_type & LOCK_READ) && (sys_fmode & FMODE_READ))
+		return 1;
+	if (!(caller_type & LOCK_WRITE) && (sys_fmode & FMODE_WRITE))
+		return 1;
+	if (!(sys_type & LOCK_READ) && (caller_fmode & FMODE_READ))
+		return 1;
+	if (!(sys_type & LOCK_WRITE) && (caller_fmode & FMODE_WRITE))
+		return 1;
+
+	return 0;
+}
+
 /* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
  * checking before calling the locks_conflict().
  */
@@ -633,9 +670,11 @@ static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
 	/* FLOCK locks referring to the same filp do not conflict with
 	 * each other.
 	 */
-	if (!IS_FLOCK(sys_fl) || (caller_fl->fl_file == sys_fl->fl_file))
-		return (0);
+	if (!IS_FLOCK(sys_fl))
+		return 0;
 	if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
+		return locks_mand_conflict(caller_fl, sys_fl);
+	if (caller_fl->fl_file == sys_fl->fl_file)
 		return 0;
 
 	return (locks_conflict(caller_fl, sys_fl));
@@ -1646,7 +1685,7 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 	if (!filp)
 		goto out;
 
-	can_sleep = !(cmd & LOCK_NB);
+	can_sleep = !(cmd & (LOCK_NB|LOCK_MAND));
 	cmd &= ~LOCK_NB;
 	unlock = (cmd == LOCK_UN);
 
-- 
1.7.11.7

