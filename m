From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 038/100] nfsd: Allow AIX client to read dir containing mountpoints
Date: Mon, 28 Jan 2008 15:04:17 -0500
Message-ID: <C96D4075-614F-47B8-8788-F21589C00D06@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu> <1201303040-7779-4-git-send-email-bfields@citi.umich.edu> <1201303040-7779-5-git-send-email-bfields@citi.umich.edu> <1201303040-7779-6-git-send-email-bfields@citi.umich.edu> <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umi
 ch.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!
 1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <1201303040-7779-21-git-send-email-bfields@citi.umich.edu> <1201303040-7779-22-git-send-email-bfields@citi.umich.edu> <1201303040-7779-23-git-send-email-bfields@citi.umich.edu> <1201303040-7779-24-git-send-email-bfields@citi.umich.edu> <1201303040-7779-25-git-send-email-bfields@citi.umich.edu> <1201303040-7779-26-git-send-email-bfields@citi.umich.edu> <1201303040-7779-27-git-send-email-bfields@citi.umich.edu> <1201303040-7779-28-git-send-email-bfields@citi.umich.edu> <1201303040-7779-29-git-send-email-bfields@citi.umich.edu> <1201303040-7779-30-git-send-email-b
 fields@citi.umich.edu> <1201303040-7779-31-git-send-email-bfields@citi.umich.edu> <1201303040-7779-32-git-send-email-bfields@citi.umich.edu> <1201303040-7779-33-git-send-email-bfields@citi.!
 umich.edu> <1201303040-7779-34-git-send-email-bfields@citi.umi!
 ch.edu> <1201303040-7779-35-git-send-email-bfields@citi.umich.edu> <1201303040-7779-36-git-send-email-bfields@citi.umich.edu> <1201303040-7779-37-git-send-email-bfields@citi.umich.edu> <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org, Frank Filz <ffilzlnx@us.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:27110 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbYA1U0N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 15:26:13 -0500
In-Reply-To: <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
> From: Frank Filz <ffilzlnx@us.ibm.com>
>
> This patch addresses a compatibility issue with a Linux NFS server and
> AIX NFS client.
>
> I have exported /export as fsid=0 with sec=krb5:krb5i
> I have mount --bind /home onto /export/home
> I have exported /export/home with sec=krb5i
>
> The AIX client mounts / -o sec=krb5:krb5i onto /mnt
>
> If I do an ls /mnt, the AIX client gets a permission error. Looking at
> the network traceIwe see a READDIR looking for attributes
> FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID. The response gives a
> NFS4ERR_WRONGSEC which the AIX client is not expecting.
>
> Since the AIX client is only asking for an attribute that is an
> attribute of the parent file system (pseudo root in my example), it
> seems reasonable that there should not be an error.
>
> In discussing this issue with Bruce Fields, I initially proposed
> ignoring the error in nfsd4_encode_dirent_fattr() if all that was  
> being
> asked for was FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID,  
> however,
> Bruce suggested that we avoid calling cross_mnt() if only these
> attributes are requested.
>
> The following patch implements bypassing cross_mnt() if only
> FATTR4_RDATTR_ERROR and FATTR4_MOUNTED_ON_FILEID are called. Since  
> there
> is some complexity in the code in nfsd4_encode_fattr(), I didn't  
> want to
> duplicate code (and introduce a maintenance nightmare), so I added a
> parameter to nfsd4_encode_fattr() that indicates whether it should
> ignore cross mounts and simply fill in the attribute using the  
> passed in
> dentry as opposed to it's parent.
>
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4proc.c        |    2 +-
>  fs/nfsd/nfs4xdr.c         |   27 ++++++++++++++++++++++-----
>  include/linux/nfsd/xdr4.h |    2 +-
>  3 files changed, 24 insertions(+), 7 deletions(-)
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 18ead17..c593db0 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -750,7 +750,7 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct  
> nfsd4_compound_state *cstate,
>  				    cstate->current_fh.fh_export,
>  				    cstate->current_fh.fh_dentry, buf,
>  				    &count, verify->ve_bmval,
> -				    rqstp);
> +				    rqstp, 0);
>
>  	/* this means that nfsd4_encode_fattr() ran out of space */
>  	if (status == nfserr_resource && count == 0)
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 25c7ae2..2d94b9b 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1453,7 +1453,7 @@ static __be32 fattr_handle_absent_fs(u32  
> *bmval0, u32 *bmval1, u32 *rdattr_err)
>  __be32
>  nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  		struct dentry *dentry, __be32 *buffer, int *countp, u32 *bmval,
> -		struct svc_rqst *rqstp)
> +		struct svc_rqst *rqstp, int ignore_crossmnt)
>  {
>  	u32 bmval0 = bmval[0];
>  	u32 bmval1 = bmval[1];
> @@ -1833,7 +1833,12 @@ out_acl:
>  	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
>  		if ((buflen -= 8) < 0)
>                  	goto out_resource;
> -		if (exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
> +                /*
> +                 * Get parent's attributes if not ignoring crossmount
> +                 * and this is the root of a cross-mounted  
> filesystem.
> +                 */
> +                if (ignore_crossmnt == 0 &&
> +		    exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {

More white space damage here.

>  			err = vfs_getattr(exp->ex_mnt->mnt_parent,
>  				exp->ex_mnt->mnt_mountpoint, &stat);
>  			if (err)
> @@ -1869,13 +1874,25 @@ nfsd4_encode_dirent_fattr(struct  
> nfsd4_readdir *cd,
>  	struct svc_export *exp = cd->rd_fhp->fh_export;
>  	struct dentry *dentry;
>  	__be32 nfserr;
> +	int    ignore_crossmnt = 0;

Nit: extra blanks here.

>  	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
>  	if (IS_ERR(dentry))
>  		return nfserrno(PTR_ERR(dentry));
>
>  	exp_get(exp);
> -	if (d_mountpoint(dentry)) {
> +	/*
> +	 * In the case of a mountpoint, the client may be asking for
> +	 * attributes that are only properties of the underlying filesystem
> +	 * as opposed to the cross-mounted file system. In such a case,
> +	 * we will not follow the cross mount and will fill the attribtutes
> +	 * directly from the mountpoint dentry.
> +	 */
> +	if (d_mountpoint(dentry) &&
> +	    (cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
> +	    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
> +		ignore_crossmnt = 1;
> +	else if (d_mountpoint(dentry)) {
>  		int err;

This seems kind of awkward.  Let's invoke d_mountpoint() once instead  
of twice:

	if (d_mountpoint(dentry)) {
		if ((cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
		    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
			ignore_crossmnt = 1;
		else {
			int err;

			/*
			 * Why the heck aren't we just using nfsd_lookup??
			 * Different "."/".." handling?  Something else?
			 * At least, add a comment here to explain....
			 */
			err = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
			if (err) {
				nfserr = nfserrno(err);
				goto out_put;
			}
			nfserr = check_nfsd_access(exp, cd->rd_rqstp);
			if (nfserr)
				goto out_put;
		}
	}

> @@ -1894,7 +1911,7 @@ nfsd4_encode_dirent_fattr(struct  
> nfsd4_readdir *cd,
>
>  	}
>  	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd- 
> >rd_bmval,
> -					cd->rd_rqstp);
> +					cd->rd_rqstp, ignore_crossmnt);
>  out_put:
>  	dput(dentry);
>  	exp_put(exp);
> @@ -2048,7 +2065,7 @@ nfsd4_encode_getattr(struct nfsd4_compoundres  
> *resp, __be32 nfserr, struct nfsd4
>  	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
>  	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
>  				    resp->p, &buflen, getattr->ga_bmval,
> -				    resp->rqstp);
> +				    resp->rqstp, 0);
>  	if (!nfserr)
>  		resp->p += buflen;
>  	return nfserr;
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index b0ddfb4..27bd3e3 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -441,7 +441,7 @@ void nfsd4_encode_operation(struct  
> nfsd4_compoundres *, struct nfsd4_op *);
>  void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct  
> nfsd4_op *op);
>  __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  		       struct dentry *dentry, __be32 *buffer, int *countp,
> -		       u32 *bmval, struct svc_rqst *);
> +		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
>  extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
>  		struct nfsd4_compound_state *,
>  		struct nfsd4_setclientid *setclid);

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
