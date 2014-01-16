Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33312 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484AbaAPSvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jan 2014 13:51:12 -0500
Date: Thu, 16 Jan 2014 13:51:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140116185107.GE16829@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140116161015.GC16829@fieldses.org>
 <1389888942.2779.34.camel@menhir>
 <20140116164411.GD16829@fieldses.org>
 <1875464309.3327883.1389891247171.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1875464309.3327883.1389891247171.JavaMail.root@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 16, 2014 at 11:54:07AM -0500, Bob Peterson wrote:
> ----- Original Message -----
> | Something like this?
> (snip)
> | @@ -779,6 +782,11 @@ static struct dentry *__gfs2_lookup(struct inode *dir,
> | struct dentry *dentry,
> |  	}
> |  
> |  	d = d_splice_alias(inode, dentry);
> | +	if (IS_ERR(d)) {
> | +		iput(inode);
> | +		gfs2_glock_dq_uninit(&gh);
> | +		return ERR_PTR(error);
> 
> ---------------------------------^
> Shouldn't that be ERR_PTR(d)?

Oops, yeah--well, actually just "d" I guess.

This is what I've got for what it's worth.

--b.

commit 6fba5295019b52a03d76c9e9570952466051a7a6
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Jan 16 11:44:53 2014 -0500

    gfs2: revert "GFS2: d_splice_alias() can't return error"
    
    0d0d110720d7960b77c03c9f2597faaff4b484ae asserts that "d_splice_alias()
    can't return error unless it was given an IS_ERR(inode)".
    
    That was true of the implementation of d_splice_alias, but this is
    really a problem with d_splice_alias: at a minimum it should be able to
    return -ELOOP in the case where inserting the given dentry would cause a
    directory loop.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index 7119504..3f44902 100644
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
+		return d;
+	}
 	if (file && S_ISREG(inode->i_mode))
 		error = finish_open(file, dentry, gfs2_open_common, opened);
 
