Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50282 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcFCF47 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2016 01:56:59 -0400
Date: Fri, 3 Jun 2016 06:56:55 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Message-ID: <20160603055655.GQ14480@ZenIV.linux.org.uk>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <20160603033750.GL14480@ZenIV.linux.org.uk>
 <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
 <20160603042648.GN14480@ZenIV.linux.org.uk>
 <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 03, 2016 at 12:58:10AM -0400, Oleg Drokin wrote:

> This one cures the insta-crash I was having, and I see no other ill-effects so far.

OK...  I can take it through vfs.git, but I think it'd be better off in
NFS tree.  Is everyone OK with something like the following?

make nfs_atomic_open() call d_drop() on all ->open_context() errors.

In "NFSv4: Move dentry instantiation into the NFSv4-specific atomic open code"
unconditional d_drop() after the ->open_context() had been removed.  It had
been correct for success cases (there ->open_context() itself had been doing
dcache manipulations), but not for error ones.  Only one of those (ENOENT)
got a compensatory d_drop() added in that commit, but in fact it should've
been done for all errors.  As it is, the case of O_CREAT non-exclusive open
on a hashed negative dentry racing with e.g. symlink creation from another
client ended up with ->open_context() getting an error and proceeding to
call nfs_lookup().  On a hashed dentry, which would've instantly triggered
BUG_ON() in d_materialise_unique() (or, these days, its equivalent in
d_splice_alias()).

Cc: stable@vger.kernel.org # v3.10+
Tested-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index aaf7bd0..6e3a6f4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1536,9 +1536,9 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		err = PTR_ERR(inode);
 		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 		put_nfs_open_context(ctx);
+		d_drop(dentry);
 		switch (err) {
 		case -ENOENT:
-			d_drop(dentry);
 			d_add(dentry, NULL);
 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 			break;
