Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60066 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294Ab0KDBlc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Nov 2010 21:41:32 -0400
Date: Wed, 3 Nov 2010 21:41:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] locks: let the caller free file_lock on ->setlease
 failure
Message-ID: <20101104014128.GB22498@fieldses.org>
References: <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
 <20101031123510.GA4520@infradead.org>
 <20101103204147.GA6777@fieldses.org>
 <20101104014024.GA22498@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101104014024.GA22498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Nov 03, 2010 at 09:40:24PM -0400, J. Bruce Fields wrote:
> On Wed, Nov 03, 2010 at 04:41:48PM -0400, J. Bruce Fields wrote:
> > On Sun, Oct 31, 2010 at 08:35:10AM -0400, Christoph Hellwig wrote:
> > > Index: linux-2.6/fs/locks.c
> > > ===================================================================
> > > --- linux-2.6.orig/fs/locks.c	2010-10-31 07:10:07.649004084 -0400
> > > +++ linux-2.6/fs/locks.c	2010-10-31 07:34:10.102255587 -0400
> > > @@ -1428,8 +1425,9 @@ int generic_setlease(struct file *filp,
> > >  		goto out;
> > >  
> > >  	if (my_before != NULL) {
> > > -		*flp = *my_before;
> > >  		error = lease->fl_lmops->fl_change(my_before, arg);
> > > +		if (!error)
> > > +			*flp = *my_before;
> > 
> > Argh, missed this: we're leaking the passed-in lease in this case.
> 
> We could do something like this.

And while I was here I noticed:

--b.

>From 072be1f975c6f839661cfc4f6c45ccb944417eea Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@redhat.com>
Date: Wed, 3 Nov 2010 18:09:18 -0400
Subject: [PATCH 2/2] locks: remove dead lease error-handling code

A minor oversight from f7347ce4ee7c65415f84be915c018473e7076f31,
"fasync: re-organize fasync entry insertion to allow it under a
spinlock": this cleanup-on-error was only needed to handle -ENOMEM.  Now
that we're preallocating it's unneeded.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 61c22f7..0e62dd3 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1506,7 +1506,6 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 {
 	struct file_lock *fl, *ret;
 	struct fasync_struct *new;
-	struct inode *inode = filp->f_path.dentry->d_inode;
 	int error;
 
 	fl = lease_alloc(filp, arg);
@@ -1520,7 +1519,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	}
 	ret = fl;
 	lock_flocks();
-	error = __vfs_setlease(filp, arg, &fl);
+	error = __vfs_setlease(filp, arg, &ret);
 	if (error) {
 		unlock_flocks();
 		locks_free_lock(fl);
@@ -1538,14 +1537,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	if (!fasync_insert_entry(fd, filp, &ret->fl_fasync, new))
 		new = NULL;
 
-	if (error < 0) {
-		/* remove lease just inserted by setlease */
-		fl->fl_type = F_UNLCK | F_INPROGRESS;
-		fl->fl_break_time = jiffies - 10;
-		time_out_leases(inode);
-	} else {
-		error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
-	}
+	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
 	unlock_flocks();
 
 out_free_fasync:
-- 
1.7.1

