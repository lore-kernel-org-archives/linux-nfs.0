Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49122 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261AbaCDTEp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 14:04:45 -0500
Date: Tue, 4 Mar 2014 14:04:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Rahtz <mrahtz@rapitasystems.com>, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: warning in ext4_journal_start_sb on filesystem freeze
Message-ID: <20140304190442.GE12805@fieldses.org>
References: <217983071.143460.1385453196946.JavaMail.zimbra@rapitasystems.com>
 <1697998867.143517.1385454051031.JavaMail.zimbra@rapitasystems.com>
 <20131126125826.GA4503@quack.suse.cz>
 <622177618.727.1393062606061.JavaMail.zimbra@rapitasystems.com>
 <20140224095525.GA20532@quack.suse.cz>
 <20140224154532.GB11992@fieldses.org>
 <20140225102126.GB1669@quack.suse.cz>
 <20140304164306.GC12805@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140304164306.GC12805@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 04, 2014 at 11:43:06AM -0500, J. Bruce Fields wrote:
> On Tue, Feb 25, 2014 at 11:21:26AM +0100, Jan Kara wrote:
> > On Mon 24-02-14 10:45:32, J. Bruce Fields wrote:
> > > On Mon, Feb 24, 2014 at 10:55:25AM +0100, Jan Kara wrote:
> > > > On Sat 22-02-14 09:50:06, Matthew Rahtz wrote:
> > > > > Thanks for your help Jan,
> > > > > 
> > > > > A few months later, we've noticed the issue is actually still there.
> > > > > Using 3.11.0-17-generic on Ubuntu 12.04, we’re seeing this in the kernel
> > > > > logs:
> > > > > 
> > > > > [29243.606215] WARNING: CPU: 0 PID: 1785 at
> > > > > /build/buildd/linux-lts-saucy-3.11.0/fs/ext4/ext4_jbd2.c:48
> > > > > ext4_journal_check_start+0x83/0x90()
> > > > > 
> > > > > Having a look at the Ubuntu source package for that version, it
> > > > > definitely does include commit 03d95eb2f2578083a3f6286262e1cb5d88a00c02,
> > > > > and the line generating the warning is still:
> > > > > 
> > > > > WARN_ON(sb->s_writers.frozen == SB_FREEZE_COMPLETE);
> > > > > 
> > > > > Are there any other obvious possibilities for what may be causing this?
> > > > > There seem to be some users of Oracle Linux experiencing similar problems
> > > > > at https://community.oracle.com/thread/2617418, which was apparently
> > > > > fixed in Oracle's kernel version '3.8.13-26.el6uek'. Any word on when
> > > > > this might be integrated into the official kernel?
> > > > > 
> > > > > Full call trace included below.
> > > >   Looking at the trace below, now the problem seems to be in the NFS server
> > > > code. NFS should get protection against the filesystem being frozen (or
> > > > remounted read-only for that matter) via mnt_want_write() before calling
> > > > into notify_change() (actually before calling fh_lock() because of lock
> > > > ordering).  Similarly to what we do e.g. in fchownat(). Bruce?
> > > 
> > > Like this?
> >   Yup, that looks right.
> 
> Ugh, actually, I didn't realize we can't do mnt_want_write recursively,
> and there's a confusing mixture of callers that do and don't already
> take it, so I'll have to do something a little more complicated.

Actually it looks like there's an easy enough way to distinguish when we
need mnt_want_write and when we don't; hopefully the following does the
job.

--b.

commit b0f5cd115e811a146a6e1a4dd1e7cb85808cca23
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Feb 24 14:59:47 2014 -0500

    nfsd: notify_change needs elevated write count
    
    Looks like this bug has been here since these write counts were
    introduced, not sure why it was just noticed now.
    
    Thanks also to Jan Kara for pointing out the problem.
    
    Reported-by: Matthew Rahtz <mrahtz@rapitasystems.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6d7be3f..eea5ad1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -404,6 +404,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	umode_t		ftype = 0;
 	__be32		err;
 	int		host_err;
+	bool		get_write_count;
 	int		size_change = 0;
 
 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
@@ -411,10 +412,18 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (iap->ia_valid & ATTR_SIZE)
 		ftype = S_IFREG;
 
+	/* Callers that do fh_verify should do the fh_want_write: */
+	get_write_count = !fhp->fh_dentry;
+
 	/* Get inode */
 	err = fh_verify(rqstp, fhp, ftype, accmode);
 	if (err)
 		goto out;
+	if (get_write_count) {
+		host_err = fh_want_write(fhp);
+		if (host_err)
+			return nfserrno(host_err);
+	}
 
 	dentry = fhp->fh_dentry;
 	inode = dentry->d_inode;
