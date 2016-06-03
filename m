Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49296 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbcFCE0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2016 00:26:52 -0400
Date: Fri, 3 Jun 2016 05:26:48 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Message-ID: <20160603042648.GN14480@ZenIV.linux.org.uk>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <20160603033750.GL14480@ZenIV.linux.org.uk>
 <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 02, 2016 at 11:43:59PM -0400, Oleg Drokin wrote:

> > Which of the call sites had that been and how does one reproduce that fun?
> > If you feel that posting a reproducer in the open is a bad idea, just send
> > it off-list...
> 
> This is fs/nfs/dir.c::nfs_lookup() right after no_entry label.

Bloody hell...  Was that sucker hashed on the entry into nfs_lookup()?
If we get that with call as a method, we are really fucked.

<greps>

Ho-hum...  One of the goto no_open; in nfs_atomic_open()?  That would
mean a stale negative dentry in dcache that has escaped revalidation...
Wait a minute, didn't nfs ->d_revalidate() skip everything in some
cases, leaving it to ->atomic_open()?

Looks like the right thing to do would be to do d_drop() at no_open:,
just before we call nfs_lookup().  If not earlier, actually...  How
about the following?

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
