From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Thu, 8 May 2008 13:03:09 +1000
Message-ID: <18466.28013.258338.485948@notabene.brown>
References: <20080429174004.GA28719@janus>
	<20080430174736.GB20377@fieldses.org>
	<20080502151646.GA5515@janus>
	<20080502153439.GC7376@infradead.org>
	<20080502155617.GD18401@fieldses.org>
	<1209744293.8294.19.camel@heimdal.trondhjem.org>
	<20080502221216.GP21918@fieldses.org>
	<18462.17737.353976.999538@notabene.brown>
	<20080505174716.GA12814@fieldses.org>
	<18463.42978.531115.344884@notabene.brown>
	<20080506195041.GD13484@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:60497 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755240AbYEHDDS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2008 23:03:18 -0400
In-Reply-To: message from J. Bruce Fields on Tuesday May 6
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday May 6, bfields@fieldses.org wrote:
> On Tue, May 06, 2008 at 10:35:46AM +1000, Neil Brown wrote:
> > 
> > To fix the current bug properly, reconnect_path still needs to bypass
> > normal permission checks even when subtree_check is in effect, so it
> > can be sure of getting read permission on the parent directory.
> 
> OK, but why not just forget the subtree_check case?  It would be just
> another item on the "reasons not to use subtree_check" list.

I guess so.

> 
> If a fix for the subtree checking case were easy (or if someone else had
> the time to do a very careful job of it), then fine, but maybe we should
> just fix the easy case and leave the subtree checking as is for now.

So is this the proposed fix?  A bit ugly, but I guess it's OK.

NeilBrown

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2008-05-06 10:06:59.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2008-05-08 13:01:06.000000000 +1000
@@ -176,9 +176,24 @@ static __be32 nfsd_set_fh_dentry(struct 
 	if (IS_ERR(exp))
 		return nfserrno(PTR_ERR(exp));
 
-	error = nfsd_setuser_and_check_port(rqstp, exp);
-	if (error)
-		goto out;
+	if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
+		/* Elevate privileges so that the lack of 'r' or 'x'
+		 * permission on some parent directory will
+		 * not stop exportfs_decode_fh from being able
+		 * to reconnect a directory into the dentry cache.
+		 * The same problem can affect "SUBTREECHECK" exports,
+		 * but as nfsd_acceptable depends on correct
+		 * access control settings being in effect, we cannot
+		 * fix that case easily - so though.
+		 */
+		current->cap_effective =
+			cap_raise_nfsd_set(current->cap_effective,
+					   current->cap_permitted);
+	} else {
+		error = nfsd_setuser_and_check_port(rqstp, exp);
+		if (error)
+			goto out;
+	}
 
 	/*
 	 * Look up the dentry using the NFS file handle.
@@ -215,6 +230,14 @@ static __be32 nfsd_set_fh_dentry(struct 
 		goto out;
 	}
 
+	if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
+		error = nfsd_setuser_and_check_port(rqstp, exp);
+		if (error) {
+			dput(dentry);
+			goto out;
+		}
+	}
+
 	if (S_ISDIR(dentry->d_inode->i_mode) &&
 			(dentry->d_flags & DCACHE_DISCONNECTED)) {
 		printk("nfsd: find_fh_dentry returned a DISCONNECTED directory: %s/%s\n",
