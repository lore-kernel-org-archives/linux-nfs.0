Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38628 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbcGXUVx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Jul 2016 16:21:53 -0400
Date: Sun, 24 Jul 2016 16:21:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Oleg Drokin <green@linuxhacker.ru>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/7] nfsd: remove redundant i_lookup check
Message-ID: <20160724202150.GA25100@fieldses.org>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
 <1469209736-6490-4-git-send-email-bfields@redhat.com>
 <20160724002152.GN2356@ZenIV.linux.org.uk>
 <20160724121014.GA20985@fieldses.org>
 <20160724142306.GO2356@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160724142306.GO2356@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 24, 2016 at 03:23:07PM +0100, Al Viro wrote:
> On Sun, Jul 24, 2016 at 08:10:14AM -0400, J. Bruce Fields wrote:
> > On Sun, Jul 24, 2016 at 01:22:06AM +0100, Al Viro wrote:
> > > On Fri, Jul 22, 2016 at 01:48:52PM -0400, J. Bruce Fields wrote:
> > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > 
> > > > I'm not sure why this was added.  It doesn't seem necessary, and no
> > > > other caller does this.
> > > 
> > > lookup_one_len() will explode if you call it for non-directory (==
> > > !d_can_lookup(), i.e. something without ->lookup()).  So unless the callers
> > > do guarantee that check being true, it *is* needed.
> > 
> > Both callers call fh_verify(.,.,S_IFDIR,.), so at this point we know
> > that i_mode & S_IFMT == S_IFDIR.  Is there some odd case where that's
> > insufficient?  If so, I think there may be bugs elsewhere in nfsd.  If
> > not, I'll add a note to the changelog.
> 
> First of all, such objects do exist; they probably won't be encountered by
> nfsd and all instances I can think of are not writable, but...
> 
> > Thanks for reminding me to check this, I hadn't thought of that as an
> > "is this a directory" check, it makes more sense now.
> 
> I'd have turned that into d_can_lookup(fhp->fh_dentry), actually.

So would such a check mainly just protect developers from themselves if
they try to make a weird filesystems exportable?

If we need to catch this I'd rather do it in fh_verify, which would
cover some other operations, too.  Maybe like the below.  We could be
nicer and WARN()/error out instead of BUG.  But it's unclear to me
whether this case is worth checking for at all.

--b.

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 27250e279c37..372747a00214 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -59,14 +59,17 @@ static int nfsd_acceptable(void *expv, struct dentry *dentry)
  * the write call).
  */
 static inline __be32
-nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, umode_t requested)
+nfsd_mode_check(struct svc_rqst *rqstp, struct dentry *dentry,
+		umode_t requested)
 {
-	mode &= S_IFMT;
+	umode_t mode = d_inode(dentry)->i_mode & S_IFMT;
 
 	if (requested == 0) /* the caller doesn't care */
 		return nfs_ok;
-	if (mode == requested)
+	if (mode == requested) {
+		BUG_ON(mode == S_IFDIR && !d_can_lookup(dentry));
 		return nfs_ok;
+	}
 	/*
 	 * v4 has an error more specific than err_notdir which we should
 	 * return in preference to err_notdir:
@@ -340,7 +343,7 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type, int access)
 	if (error)
 		goto out;
 
-	error = nfsd_mode_check(rqstp, d_inode(dentry)->i_mode, type);
+	error = nfsd_mode_check(rqstp, dentry, type);
 	if (error)
 		goto out;
 
