Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39807 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051Ab0KPSzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 13:55:52 -0500
Date: Tue, 16 Nov 2010 13:55:51 -0500
To: Joe Habermann <joe.habermann@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: incorrect EXDEV error occasionally returned for rename over NFS
Message-ID: <20101116185551.GD3971@fieldses.org>
References: <AANLkTim3GyG4Skr_=0QyELJw1ySjfvhYMD2g4JKztrOx@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTim3GyG4Skr_=0QyELJw1ySjfvhYMD2g4JKztrOx@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 15, 2010 at 03:46:44PM -0600, Joe Habermann wrote:
> When running SVN checkouts over NFSv3, they occasionally fail with an
> EXDEV error:
> 
> (etc.)
> U    snfs/build/Makefile.hpux
> svn: In directory 'snfs/build'
> svn: Can't move 'snfs/build/tempfile.tmp' to
> 'snfs/build/Makefile.sol': Invalid cross-device link
> 
> I've noticed that other people have reported this problem but it remains
> unresolved.  Through some debugging, I believe I have found root cause.
> nfsd_rename() contains the following code:
> 
> 1707 /*
> 1708  * Rename a file
> 1709  * N.B. After this call _both_ ffhp and tfhp need an fh_put 1710  */
> 1711 __be32
> 1712 nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char
> *fname, int flen,
> 1713                             struct svc_fh *tfhp, char *tname, int tlen)
> 1714 {
> 1715         struct dentry   *fdentry, *tdentry, *odentry, *ndentry, *trap;
> 1716         struct inode    *fdir, *tdir;
> 1717         __be32          err;
> 1718         int             host_err;
> 1719
> 1720         err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
> 1721         if (err)
> 1722                 goto out;
> 1723         err = fh_verify(rqstp, tfhp, S_IFDIR, NFSD_MAY_CREATE);
> 1724         if (err)
> 1725                 goto out;
> 1726
> 1727         fdentry = ffhp->fh_dentry;
> 1728         fdir = fdentry->d_inode;
> 1729
> 1730         tdentry = tfhp->fh_dentry;
> 1731         tdir = tdentry->d_inode;
> 1732
> 1733         err = (rqstp->rq_vers == 2) ? nfserr_acces : nfserr_xdev;
> 1734         if (ffhp->fh_export != tfhp->fh_export)
> 1735                 goto out;
> 
> Line 1734 compares the fh_export pointers in the file handles for
> the "from" and "to" directories.  However, this is a bad check since
> it's possible these pointers differ yet refer to the same underlying
> file system.  Based on code inspection, encached export pointers are
> only valid for 30 minutes before they expire and are reinserted through
> calls made between the kernel and rpc.mountd.  So a race exists where the
> ffhp->fh_export is populated on line 1720, the export cache is updated,
> and tfhp->fh_export is set on line 1723 to a different value.
> 
> This window can be cranked wide open by putting an "msleep(10);"
> between lines 1722 and 1723 above, recompiling and reinstalling nfsd.ko
> etc., and then running SVN checkouts in a loop from an NFS client.
> Within 30 minutes, the problem is seen.

Good detective work, thanks.  Have you confirmed that applying your
change below eliminates the problem?

> I'm still very new to the NFS code, but I'm wonder whether the check
> needs to be something like this instead:
> 
> --- vfs.c.orig  2010-11-15 14:35:18.000000000 -0600
> +++ vfs.c       2010-11-15 14:43:52.000000000 -0600
> @@ -1731,7 +1731,7 @@ nfsd_rename(struct svc_rqst *rqstp, stru
>    tdir = tdentry->d_inode;
> 
>    err = (rqstp->rq_vers == 2) ? nfserr_acces : nfserr_xdev;
> -       if (ffhp->fh_export != tfhp->fh_export)
> +       if (fdir->i_sb != tdir->i_sb)
>        goto out;
> 
>    err = nfserr_perm;
> 
> Thoughts?  I think it's either that or some locking needs to be put in
> to guarantee that the file handles for the "to" and "from" directory
> always wind up with the same export pointer when they belong to the
> same file system.  I guess the other question is why there is an
> EXDEV check at the top of nfsd_rename() instead of putting it in
> vfs_rename().

The fh_verify call is also responsible for setting the identity of the
user, and that may be affected by export options like root_squash.  In
the above case if ffhp was on a root_squash export, and tfhp on a
no_root_squash export, and we get a request from uid 0, we'd end up
with an incoming uid-0 user running as root (since the fh_verify for
tfhp was performed last), and might allow renaming from a directory that
only root had write permission to.

It's a minor hole (especially since it's already easy for a client to
circumvent protections that vary from export to export in the default
no_subtree_check case).  But we should be able to do better.

I'm not sure what to suggest.

--b.

> 
> For full disclosure, I'm actually running the SLES11 SP1 kernel,
> linux-2.6.32.12-0.7, but I've looked at the latest upstream kernels and
> they appear to have the same code and I assume the same issue.
