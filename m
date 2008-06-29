From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Sun, 29 Jun 2008 15:27:34 -0400
Message-ID: <20080629192734.GA4427@fieldses.org>
References: <20080502155617.GD18401@fieldses.org> <1209744293.8294.19.camel@heimdal.trondhjem.org> <20080502221216.GP21918@fieldses.org> <18462.17737.353976.999538@notabene.brown> <20080505174716.GA12814@fieldses.org> <18463.42978.531115.344884@notabene.brown> <20080506195041.GD13484@fieldses.org> <18466.28013.258338.485948@notabene.brown> <20080509043425.GD21408@fieldses.org> <20080509101134.GA665@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbYF2T1s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Jun 2008 15:27:48 -0400
In-Reply-To: <20080509101134.GA665@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 09, 2008 at 12:11:34PM +0200, Frank van Maarseveen wrote:
> On Fri, May 09, 2008 at 12:34:25AM -0400, J. Bruce Fields wrote:
> > On Thu, May 08, 2008 at 01:03:09PM +1000, Neil Brown wrote:
> > > On Tuesday May 6, bfields@fieldses.org wrote:
> > > > On Tue, May 06, 2008 at 10:35:46AM +1000, Neil Brown wrote:
> > > > > 
> > > > > To fix the current bug properly, reconnect_path still needs to bypass
> > > > > normal permission checks even when subtree_check is in effect, so it
> > > > > can be sure of getting read permission on the parent directory.
> > > > 
> > > > OK, but why not just forget the subtree_check case?  It would be just
> > > > another item on the "reasons not to use subtree_check" list.
> > > 
> > > I guess so.
> > > 
> > > > 
> > > > If a fix for the subtree checking case were easy (or if someone else had
> > > > the time to do a very careful job of it), then fine, but maybe we should
> > > > just fix the easy case and leave the subtree checking as is for now.
> > > 
> > > So is this the proposed fix?  A bit ugly, but I guess it's OK.
> > 
> > Something like that, yep.  (Frank, can you confirm that this does the
> > job for you?)
> 
> It didn't apply on 2.6.25.1 due to indentation and context but it was
> trivial to do that by hand. It survived my little testprogram so yes
> it works.

I've applied this for 2.6.27, by the way.

--b.

commit 7547bdf6b3e7633a9b69b7bc270a3f0eecf7a2fd
Author: Neil Brown <neilb@suse.de>
Date:   Thu May 8 13:03:09 2008 +1000

    exportfs: fix incorrect EACCES in reconnect_path()
    
    nfsd: fix spurious EACCESS in reconnect_path()
    
    Thanks to Frank Van Maarseveen for the original problem report: "A
    privileged process on an NFS client which drops privileges after using
    them to change the current working directory, will experience incorrect
    EACCES after an NFS server reboot. This problem can also occur after
    memory pressure on the server, particularly when the client side is
    quiet for some time."
    
    This occurs because the filehandle points to a directory whose parents
    are no longer in the dentry cache, and we're attempting to reconnect the
    directory to its parents without adequate permissions to perform lookups
    in the parent directories.
    
    We can therefore fix the problem by acquiring the necessary capabilities
    before attempting the reconnection.  We do this only in the
    no_subtree_check case, since the documented behavior of the
    subtree_check export option requires the server to check that the user
    has lookup permissions on all parents.
    
    The subtree_check case still has a problem, since reconnect_path()
    unnecessarily requires both read and lookup permissions on all parent
    directories.  However, a fix in that case would be more delicate, and
    use of subtree_check is already discouraged for other reasons.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Cc: Frank van Maarseveen <frankvm@frankvm.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index c7b0fda..f45451e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -176,9 +176,24 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
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
+		 * fix that case easily.
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
@@ -215,6 +230,14 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
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
