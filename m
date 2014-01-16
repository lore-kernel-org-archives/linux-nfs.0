Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52823 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970AbaAPQoP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jan 2014 11:44:15 -0500
Date: Thu, 16 Jan 2014 11:44:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140116164411.GD16829@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140116161015.GC16829@fieldses.org>
 <1389888942.2779.34.camel@menhir>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1389888942.2779.34.camel@menhir>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 16, 2014 at 04:15:42PM +0000, Steven Whitehouse wrote:
> Hi,
> 
> On Thu, 2014-01-16 at 11:10 -0500, J. Bruce Fields wrote:
> > On Wed, Jan 15, 2014 at 10:17:49AM -0500, bfields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > d_splice_alias can create duplicate directory aliases (in the !new
> > > case), or (in the new case) d_move without holding appropriate locks.
> > > 
> > > d_materialise_unique deals with both of these problems.  (The latter
> > > seems to be dealt by trylocks (see __d_unalias), which look like they
> > > could cause spurious lookup failures--but that's at least better than
> > > corrupting the dcache.)
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/dcache.c |   25 +------------------------
> > >  1 file changed, 1 insertion(+), 24 deletions(-)
> > > 
> > > Only lightly tested....  If this is right, then we can also just ditch
> > > d_splice_alias completely, and clean up the various d_find_alias's.
> > > 
> > > I think the only reason we have both d_splice_alias and
> > > d_materialise_unique is that the former was written for exportable
> > > filesystems and the latter for distributed filesystems.
> > > 
> > > But we have at least one exportable filesystem (fuse) using
> > > d_materialise_unique.  And I doubt d_splice_alias was ever completely
> > > correct even for on-disk filesystems.
> > > 
> > > Am I missing some subtlety?
> > 
> > Hm, I just noticed:
> > 
> >     commit 0d0d110720d7960b77c03c9f2597faaff4b484ae
> >     Author: Miklos Szeredi <mszeredi@suse.cz>
> >     Date:   Mon Sep 16 14:52:00 2013 +0200
> > 
> >     GFS2: d_splice_alias() can't return error
> >     
> >     unless it was given an IS_ERR(inode), which isn't the case here.  So clean
> >     up the unnecessary error handling in gfs2_create_inode().
> >     
> >     This paves the way for real fixes (hence the stable Cc).
> >     
> >     Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> >     Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
> >     Cc: stable@vger.kernel.org
> > 
> > While the statement is true for the current implementation of
> > d_splice_alias, I don't think it's actually true for any correct
> > implementation of d_splice_alias, which must be able to return at least
> > -ELOOP in the directory case.  Does gfs2 need fixing?
> > 
> > --b.
> 
> Yes, in that case, probably in two places,

Something like this?

(Except: is the inode cleanup right in the first chunk?  And in the
second chunk the cleanup could maybe be organized better even if I got
it right....)

--b.

diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index 7119504..19e0924 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -585,6 +585,9 @@ static int gfs2_create_inode(struct inode *dir, struct dentry *dentry,
 	error = PTR_ERR(inode);
 	if (!IS_ERR(inode)) {
 		d = d_splice_alias(inode, dentry);
+		error = PTR_ERR(d);
+		if (IS_ERR(d))
+			goto fail_gunlock;
 		error = 0;
 		if (file) {
 			if (S_ISREG(inode->i_mode)) {
@@ -779,6 +782,11 @@ static struct dentry *__gfs2_lookup(struct inode *dir, struct dentry *dentry,
 	}
 
 	d = d_splice_alias(inode, dentry);
+	if (IS_ERR(d)) {
+		iput(inode);
+		gfs2_glock_dq_uninit(&gh);
+		return ERR_PTR(error);
+	}
 	if (file && S_ISREG(inode->i_mode))
 		error = finish_open(file, dentry, gfs2_open_common, opened);
 
