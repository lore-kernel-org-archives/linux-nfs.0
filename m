From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH] nfsd: Fix compatibility issue with AIX client using
	READDIR when directory contains a sub-mounted filesystem
Date: Tue, 27 Nov 2007 11:34:05 -0800
Message-ID: <1196192046.3265.30.camel@dyn9047022153>
References: <1196111951.3265.26.camel@dyn9047022153>
	 <20071126222804.GW5960@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS V4 Mailing List <nfsv4@linux-nfs.org>,
	NFS List <linux-nfs@vger.kernel.org>,
	Neil Brown <neilb@suse.de>, ffilz@us.ibm.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36839 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbXK0TcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2007 14:32:14 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lARJWDWs012420
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2007 14:32:13 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lARJWD1g127870
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2007 14:32:13 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lARJWCo9009359
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2007 14:32:13 -0500
In-Reply-To: <20071126222804.GW5960@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2007-11-26 at 22:28 +0000, J. Bruce Fields wrote:
> On Mon, Nov 26, 2007 at 01:19:11PM -0800, Frank Filz wrote:
> OK, thanks!  My only superficial complaint--I find the
> OBEY_CROSSMNT/IGNORE_CROSSMNT defines to be minor overkill.
> 
> If you want to stick with them, then you should probably use a
> comparison to IGNORE_CROSSMNT here instead of assuming which is zero:
> 
> > +                if (!ignore_crossmnt &&
> > +		    exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
> >  			err = vfs_getattr(exp->ex_mnt->mnt_parent,
> >  				exp->ex_mnt->mnt_mountpoint, &stat);
> 
> But I think it'd be simplest just to use 0 and 1 directly instead of the
> defines.

Ok, here's an updated patch removing the #defines. I did also explicitly
test ignore_crossmnt for 0 instead of implicitly testing.

This patch addresses a compatibility issue with a Linux NFS server and
AIX NFS client.

I have exported /export as fsid=0 with sec=krb5:krb5i
I have mount --bind /home onto /export/home
I have exported /export/home with sec=krb5i

The AIX client mounts / -o sec=krb5:krb5i onto /mnt

If I do an ls /mnt, the AIX client gets a permission error. Looking at
the network traceIwe see a READDIR looking for attributes
FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID. The response gives a
NFS4ERR_WRONGSEC which the AIX client is not expecting.

Since the AIX client is only asking for an attribute that is an
attribute of the parent file system (pseudo root in my example), it
seems reasonable that there should not be an error.

In discussing this issue with Bruce Fields, I initially proposed
ignoring the error in nfsd4_encode_dirent_fattr() if all that was being
asked for was FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID, however,
Bruce suggested that we avoid calling cross_mnt() if only these
attributes are requested.

The following patch implements bypassing cross_mnt() if only
FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID are called. Since there
is some complexity in the code in nfsd4_encode_fattr(), I didn't want to
duplicate code (and introduce a maintenance nightmare), so I added a
parameter to nfsd4_encode_fattr() that indicates whether it should
ignore cross mounts and simply fill in the attribute using the passed in
dentry as opposed to it's parent.

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

 fs/nfsd/nfs4proc.c        |    2 +-
 fs/nfsd/nfs4xdr.c         |   27 ++++++++++++++++++++++-----
 include/linux/nfsd/xdr4.h |    2 +-
 3 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 18ead17..c593db0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -750,7 +750,7 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				    cstate->current_fh.fh_export,
 				    cstate->current_fh.fh_dentry, buf,
 				    &count, verify->ve_bmval,
-				    rqstp);
+				    rqstp, 0);
 
 	/* this means that nfsd4_encode_fattr() ran out of space */
 	if (status == nfserr_resource && count == 0)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5733394..bbde5d6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1448,7 +1448,7 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 __be32
 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		struct dentry *dentry, __be32 *buffer, int *countp, u32 *bmval,
-		struct svc_rqst *rqstp)
+		struct svc_rqst *rqstp, int ignore_crossmnt)
 {
 	u32 bmval0 = bmval[0];
 	u32 bmval1 = bmval[1];
@@ -1828,7 +1828,12 @@ out_acl:
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
 		if ((buflen -= 8) < 0)
                 	goto out_resource;
-		if (exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
+                /*
+                 * Get parent's attributes if not ignoring crossmount
+                 * and this is the root of a cross-mounted filesystem.
+                 */
+                if (ignore_crossmnt == 0 &&
+		    exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
 			err = vfs_getattr(exp->ex_mnt->mnt_parent,
 				exp->ex_mnt->mnt_mountpoint, &stat);
 			if (err)
@@ -1864,13 +1869,25 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 	struct svc_export *exp = cd->rd_fhp->fh_export;
 	struct dentry *dentry;
 	__be32 nfserr;
+	int    ignore_crossmnt = 0;
 
 	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
 	if (IS_ERR(dentry))
 		return nfserrno(PTR_ERR(dentry));
 
 	exp_get(exp);
-	if (d_mountpoint(dentry)) {
+	/*
+	 * In the case of a mountpoint, the client may be asking for
+	 * attributes that are only properties of the underlying filesystem
+	 * as opposed to the cross-mounted file system. In such a case,
+	 * we will not follow the cross mount and will fill the attribtutes
+	 * directly from the mountpoint dentry.
+	 */
+	if (d_mountpoint(dentry) &&
+	    (cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
+	    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
+		ignore_crossmnt = 1;
+	else if (d_mountpoint(dentry)) {
 		int err;
 
 		/*
@@ -1889,7 +1906,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 
 	}
 	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
-					cd->rd_rqstp);
+					cd->rd_rqstp, ignore_crossmnt);
 out_put:
 	dput(dentry);
 	exp_put(exp);
@@ -2043,7 +2060,7 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
 	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
 				    resp->p, &buflen, getattr->ga_bmval,
-				    resp->rqstp);
+				    resp->rqstp, 0);
 	if (!nfserr)
 		resp->p += buflen;
 	return nfserr;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index b0ddfb4..27bd3e3 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -441,7 +441,7 @@ void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		       struct dentry *dentry, __be32 *buffer, int *countp,
-		       u32 *bmval, struct svc_rqst *);
+		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);


