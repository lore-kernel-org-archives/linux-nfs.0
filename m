From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH 038/100] nfsd: Allow AIX client to read dir containing
	mountpoints
Date: Fri, 08 Feb 2008 13:25:54 -0800
Message-ID: <1202505954.3688.11.camel@dyn9047022153>
References: <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-38-git-send-email-bfields@citi.umich.!edu>
	 <47ACB69D.60704@redhat.com>  <20080208210335.GI6871@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:57093 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704AbYBHVZg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 16:25:36 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m18LRStV006954
	for <linux-nfs@vger.kernel.org>; Fri, 8 Feb 2008 16:27:28 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18LPXCk253264
	for <linux-nfs@vger.kernel.org>; Fri, 8 Feb 2008 16:25:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18LPXbe009122
	for <linux-nfs@vger.kernel.org>; Fri, 8 Feb 2008 16:25:33 -0500
In-Reply-To: <20080208210335.GI6871@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-02-08 at 16:03 -0500, J. Bruce Fields wrote:
> On Fri, Feb 08, 2008 at 03:07:57PM -0500, Peter Staubach wrote:
> > J. Bruce Fields wrote:
> >> From: Frank Filz <ffilzlnx@us.ibm.com>
> >>
> >> This patch addresses a compatibility issue with a Linux NFS server and
> >> AIX NFS client.
> >>
> >> I have exported /export as fsid=0 with sec=krb5:krb5i
> >> I have mount --bind /home onto /export/home
> >> I have exported /export/home with sec=krb5i
> >>
> >> The AIX client mounts / -o sec=krb5:krb5i onto /mnt
> >>
> >> If I do an ls /mnt, the AIX client gets a permission error. Looking at
> >> the network traceIwe see a READDIR looking for attributes
> >> FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID. The response gives a
> >> NFS4ERR_WRONGSEC which the AIX client is not expecting.
> >>
> >> Since the AIX client is only asking for an attribute that is an
> >> attribute of the parent file system (pseudo root in my example), it
> >> seems reasonable that there should not be an error.
> >>
> >>   
> >
> > Can we go through this explanation one more time, a little more
> > slowly, please?  I am not following it.
> >
> > It is my understanding that FATTR4_RDATTR_ERROR simply says
> > to return a magic value to indicate that the requested attributes
> > could not be retrieved during a READDIR operation.  It is also
> > my understanding that the FATTR4_MOUNTED_ON_FILEID returns either
> > the fileid of the entry in the directory or the fileid of the
> > directory which is the root of the mount point which is mounted
> > on top of the entry in the directory.
> 
> No, it's the fileid of the directory underneath (the mounted-on
> directory), not of the directory that's mounted on top of it--that would
> be just the regular fileid.  Does that clear up the confusion?

READDIR with cross-mounts is definitely confusing. Remember READDIR is
reading some directory .../a/ that is part of file system #1. Within
that directory is a mountpoint, .../a/fs2 for a new file system (#2). A
cross mount. The client is currently using a security flavor that is
valid for file system #1 but not valid for file system #2.
Since .../a/fs2 is the root of a new file system, it probably has a
FILEID like 2 or something. However, there is .../a/fs2 which is a file
in file system #1 (perhaps with a FILEID like 356).
FATTR4_MOUNTED_ON_FILEID will return 356 instead of 2. Since the client
is only asking for the file names in .../a/ and their
FATTR4_MOUNTED_ON_FILEID, the READDIR is clearly asking for information
that does not at all depend on access to (and permission to use) file
system #2 (in fact, the exports might even deny this client access to
file system #2 no matter what security flavor it uses). Since the client
is not asking for anything that it doesn't have permission to ask for
(if file system #2 were not currently mounted, this READDIR would
respond with exactly the same results, and the security of file system
#2 would not come into play at all), there is no reason to report an
error (and not supply the attribute).

> > So, given all of this, why is the right thing to do to return
> > the fileid of the entry in the directory, even though it is
> > mounted on top of?  Why isn't the right thing to do to return
> > NFS4ERR_WRONGSEC per page 206 in rfc3530?
> >
> > Perhaps I am not following the bind mount properly?
> >
> > A little more below --
> >
> >
> >> In discussing this issue with Bruce Fields, I initially proposed
> >> ignoring the error in nfsd4_encode_dirent_fattr() if all that was being
> >> asked for was FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID, however,
> >> Bruce suggested that we avoid calling cross_mnt() if only these
> >> attributes are requested.
> >>
> >> The following patch implements bypassing cross_mnt() if only
> >> FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID are called. Since there
> >> is some complexity in the code in nfsd4_encode_fattr(), I didn't want to
> >> duplicate code (and introduce a maintenance nightmare), so I added a
> >> parameter to nfsd4_encode_fattr() that indicates whether it should
> >> ignore cross mounts and simply fill in the attribute using the passed in
> >> dentry as opposed to it's parent.
> >>
> >> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> >> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> >> ---
> >>  fs/nfsd/nfs4proc.c        |    2 +-
> >>  fs/nfsd/nfs4xdr.c         |   27 ++++++++++++++++++++++-----
> >>  include/linux/nfsd/xdr4.h |    2 +-
> >>  3 files changed, 24 insertions(+), 7 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 18ead17..c593db0 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -750,7 +750,7 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  				    cstate->current_fh.fh_export,
> >>  				    cstate->current_fh.fh_dentry, buf,
> >>  				    &count, verify->ve_bmval,
> >> -				    rqstp);
> >> +				    rqstp, 0);
> >>   	/* this means that nfsd4_encode_fattr() ran out of space */
> >>  	if (status == nfserr_resource && count == 0)
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index 25c7ae2..2d94b9b 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -1453,7 +1453,7 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
> >>  __be32
> >>  nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
> >>  		struct dentry *dentry, __be32 *buffer, int *countp, u32 *bmval,
> >> -		struct svc_rqst *rqstp)
> >> +		struct svc_rqst *rqstp, int ignore_crossmnt)
> >>  {
> >>  	u32 bmval0 = bmval[0];
> >>  	u32 bmval1 = bmval[1];
> >> @@ -1833,7 +1833,12 @@ out_acl:
> >>  	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
> >>  		if ((buflen -= 8) < 0)
> >>                  	goto out_resource;
> >> -		if (exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
> >> +                /*
> >> +                 * Get parent's attributes if not ignoring crossmount
> >> +                 * and this is the root of a cross-mounted filesystem.
> >> +                 */
> >> +                if (ignore_crossmnt == 0 &&
> >> +		    exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
> >>  			err = vfs_getattr(exp->ex_mnt->mnt_parent,
> >>  				exp->ex_mnt->mnt_mountpoint, &stat);
> >>  			if (err)
> >> @@ -1869,13 +1874,25 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
> >>  	struct svc_export *exp = cd->rd_fhp->fh_export;
> >>  	struct dentry *dentry;
> >>  	__be32 nfserr;
> >> +	int    ignore_crossmnt = 0;
> >>   	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
> >>  	if (IS_ERR(dentry))
> >>  		return nfserrno(PTR_ERR(dentry));
> >>   	exp_get(exp);
> >> -	if (d_mountpoint(dentry)) {
> >> +	/*
> >> +	 * In the case of a mountpoint, the client may be asking for
> >> +	 * attributes that are only properties of the underlying filesystem
> >> +	 * as opposed to the cross-mounted file system. In such a case,
> >> +	 * we will not follow the cross mount and will fill the attribtutes
> >> +	 * directly from the mountpoint dentry.
> >> +	 */
> >> +	if (d_mountpoint(dentry) &&
> >> +	    (cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
> >> +	    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
> >>   
> >
> > These are some odd looking tests.  What is the real intention
> > for these tests?  They don't test just for requests with just
> > RDATTR_ERROR and MOUNTED_ON_FILEID set.  They will trigger
> > whether or not either or neither is set as well.
> 
> Right.  The test is meant to fail iff someone requests an attribute
> other than those two.  (Note the different rd_bmval[] array indices.)
> 
> (Actually, I suppose we could also allow requests for lease_time.  Patch
> welcomed....)

Yep, intention here is to bypass the crossmount if the only attributes
requested are properties of file system #1 (per above discussion).

Frank Filz


