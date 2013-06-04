Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab3FDNVw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 09:21:52 -0400
Date: Tue, 4 Jun 2013 09:21:49 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 1/1] NFS: Allow nfs_updatepage to extend a write to
 cover a full page when we have a lock that covers the entire file
Message-ID: <20130604132149.GL55330@tonberry.usersys.redhat.com>
References: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
 <1369346021-20041-2-git-send-email-smayhew@redhat.com>
 <20130523182450.18adbcd8@tlielax.poochiereds.net>
 <1369348209.8861.12.camel@leira.trondhjem.org>
 <20130524072403.6b814585@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="+sHJum3is6Tsg7/J"
In-Reply-To: <20130524072403.6b814585@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--+sHJum3is6Tsg7/J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, 24 May 2013, Jeff Layton wrote:

> On Thu, 23 May 2013 22:30:10 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2013-05-23 at 18:24 -0400, Jeff Layton wrote:
> > > On Thu, 23 May 2013 17:53:41 -0400
> > > Scott Mayhew <smayhew@redhat.com> wrote:
> > > 
> > > > Currently nfs_updatepage allows a write to be extended to cover a full
> > > > page only if we don't have a byte range lock on the file... but if we've
> > > > got the whole file locked, then we should be allowed to extend the
> > > > write.
> > > > 
> > > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > > ---
> > > >  fs/nfs/write.c | 7 +++++--
> > > >  1 file changed, 5 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > > index a2c7c28..f35fb4f 100644
> > > > --- a/fs/nfs/write.c
> > > > +++ b/fs/nfs/write.c
> > > > @@ -908,13 +908,16 @@ int nfs_updatepage(struct file *file, struct page *page,
> > > >  		file->f_path.dentry->d_name.name, count,
> > > >  		(long long)(page_file_offset(page) + offset));
> > > >  
> > > > -	/* If we're not using byte range locks, and we know the page
> > > > +	/* If we're not using byte range locks (or if the range of the
> > > > +	 * lock covers the entire file), and we know the page
> > > >  	 * is up to date, it may be more efficient to extend the write
> > > >  	 * to cover the entire page in order to avoid fragmentation
> > > >  	 * inefficiencies.
> > > >  	 */
> > > >  	if (nfs_write_pageuptodate(page, inode) &&
> > > > -			inode->i_flock == NULL &&
> > > > +			(inode->i_flock == NULL ||
> > > > +			(inode->i_flock->fl_start == 0 &&
> > > > +			inode->i_flock->fl_end == OFFSET_MAX)) &&
> > > >  			!(file->f_flags & O_DSYNC)) {
> > > >  		count = max(count + offset, nfs_page_length(page));
> > > >  		offset = 0;
> > > 
> > > Sounds like a reasonable proposition, but I think you might need to do
> > > more vetting of the locks...
> > > 
> > > For instance, does it make sense to do this if it's a F_RDLCK? Also,
> > > you're only looking at the first lock in the i_flock list. Might it
> > > make more sense to walk the list and see whether the page might be
> > > entirely covered by a lock that doesn't extend over the whole file?
> > > 
> > 
> > I'm guessing that the answer is to both these questions are "no":
> > - Anybody who is writing while holding a F_RDLCK is likely doing
> > something wrong.
> 
> Right, so I think we ought to be conservative here and not extend the
> write if this is an F_RDLCK.
> 
> > - Walking the lock list on every write can quickly get painful if we
> > have lots of small locks.
> > 
> 
> True, but it's probably still preferable to do that than to do a bunch
> of small I/Os to the server. But, that's an optimization that can be
> done later. Hardly anyone does real byte-range locking so I'm fine with
> this approach for now.
> 
> > However it may make a lot of sense to look at whether or not we hold a
> > NFSv4 write delegation.
> > 
> 
> Yes, that would be a good thing too. Having a helper function like you
> suggested should make it easier to encapsulate that logic sanely.
> 
Here's an updated patch that moves the logic to a helper function,
checks to see if we have a write delegation, and checks the lock type.

-Scott

--+sHJum3is6Tsg7/J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="0001-NFS-Allow-nfs_updatepage-to-extend-a-write-under-add.patch"

>From 3938f17ef84f5c4889fd7f827109f89c932df569 Mon Sep 17 00:00:00 2001
From: Scott Mayhew <smayhew@redhat.com>
Date: Wed, 22 May 2013 17:03:17 -0400
Subject: [PATCH RFC] NFS: Allow nfs_updatepage to extend a write under
 additional circumstances

Currently nfs_updatepage allows a write to be extended to cover a full
page only if we don't have a byte range lock lock on the file... but if
we have a write delegation on the file or if we have the whole file
locked for writing then we should be allowed to extend the write as
well.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/write.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a2c7c28..c8a1bcc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -888,6 +888,28 @@ out:
 	return PageUptodate(page) != 0;
 }
 
+/* If we know the page is up to date, and we're not using byte range locks (or
+ * if we have the whole file locked for writing), it may be more efficient to
+ * extend the write to cover the entire page in order to avoid fragmentation
+ * inefficiencies.
+ *
+ * If the file is opened for synchronous writes or if we have a write delegation
+ * from the server then we can just skip the rest of the checks.
+ */
+static int nfs_can_extend_write(struct file *file, struct page *page, struct inode *inode)
+{
+	if (file->f_flags & O_DSYNC)
+		return 0;
+	if (nfs_have_delegation(inode, FMODE_WRITE))
+		return 1;
+	if (nfs_write_pageuptodate(page, inode) && (inode->i_flock == NULL ||
+			(inode->i_flock->fl_start == 0 &&
+			inode->i_flock->fl_end == OFFSET_MAX &&
+			inode->i_flock->fl_type != F_RDLCK)))
+		return 1;
+	return 0;
+}
+
 /*
  * Update and possibly write a cached page of an NFS file.
  *
@@ -908,14 +930,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		file->f_path.dentry->d_name.name, count,
 		(long long)(page_file_offset(page) + offset));
 
-	/* If we're not using byte range locks, and we know the page
-	 * is up to date, it may be more efficient to extend the write
-	 * to cover the entire page in order to avoid fragmentation
-	 * inefficiencies.
-	 */
-	if (nfs_write_pageuptodate(page, inode) &&
-			inode->i_flock == NULL &&
-			!(file->f_flags & O_DSYNC)) {
+	if (nfs_can_extend_write(file, page, inode)) {
 		count = max(count + offset, nfs_page_length(page));
 		offset = 0;
 	}
-- 
1.7.11.7


--+sHJum3is6Tsg7/J--
