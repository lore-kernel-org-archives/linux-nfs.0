Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60061 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294Ab0KDBkf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Nov 2010 21:40:35 -0400
Date: Wed, 3 Nov 2010 21:40:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] locks: let the caller free file_lock on ->setlease
 failure
Message-ID: <20101104014024.GA22498@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
 <20101031123510.GA4520@infradead.org>
 <20101103204147.GA6777@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101103204147.GA6777@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Nov 03, 2010 at 04:41:48PM -0400, J. Bruce Fields wrote:
> On Sun, Oct 31, 2010 at 08:35:10AM -0400, Christoph Hellwig wrote:
> > Index: linux-2.6/fs/locks.c
> > ===================================================================
> > --- linux-2.6.orig/fs/locks.c	2010-10-31 07:10:07.649004084 -0400
> > +++ linux-2.6/fs/locks.c	2010-10-31 07:34:10.102255587 -0400
> > @@ -1428,8 +1425,9 @@ int generic_setlease(struct file *filp,
> >  		goto out;
> >  
> >  	if (my_before != NULL) {
> > -		*flp = *my_before;
> >  		error = lease->fl_lmops->fl_change(my_before, arg);
> > +		if (!error)
> > +			*flp = *my_before;
> 
> Argh, missed this: we're leaking the passed-in lease in this case.

We could do something like this.

The irritating thing is that the only lease user I understand is the
nfsd code, and it doesn't want this lease-merging behavior; the only
reason that fl_change is there is so it can just turn this case into an
error every time.

And I have no idea what the requirements are of any other users: do
leases behave like this on purpose, or was it just an arbitrary choice,
and does anyone depend on it now?

In the end maybe it would be better just to leave leases as they are and
define a new lock type for nfsd.

We'd probably have to do that eventually anyway, and it'd save me trying
to guess what the lease semantics are supposed to be....

--b.

>From f5c6d51ae638af213d8bda31504f4b2287b8a801 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@redhat.com>
Date: Wed, 3 Nov 2010 16:49:44 -0400
Subject: [PATCH 1/2] locks: fix leak on merging leases

We must also free the passed-in lease in the case it wasn't used because
an existing lease was upgrade/downgraded or already existed.

Note the nfsd caller doesn't care because it's fl_change callback
returns an error in those cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 65765cb..61c22f7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1504,7 +1504,7 @@ static int do_fcntl_delete_lease(struct file *filp)
 
 static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 {
-	struct file_lock *fl;
+	struct file_lock *fl, *ret;
 	struct fasync_struct *new;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	int error;
@@ -1518,6 +1518,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 		locks_free_lock(fl);
 		return -ENOMEM;
 	}
+	ret = fl;
 	lock_flocks();
 	error = __vfs_setlease(filp, arg, &fl);
 	if (error) {
@@ -1525,6 +1526,8 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 		locks_free_lock(fl);
 		goto out_free_fasync;
 	}
+	if (ret != fl)
+		locks_free_lock(fl);
 
 	/*
 	 * fasync_insert_entry() returns the old entry if any.
@@ -1532,7 +1535,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	 * inserted it into the fasync list. Clear new so that
 	 * we don't release it here.
 	 */
-	if (!fasync_insert_entry(fd, filp, &fl->fl_fasync, new))
+	if (!fasync_insert_entry(fd, filp, &ret->fl_fasync, new))
 		new = NULL;
 
 	if (error < 0) {
-- 
1.7.1

