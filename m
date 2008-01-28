From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 038/100] nfsd: Allow AIX client to read dir containing
	mountpoints
Date: Mon, 28 Jan 2008 15:54:37 -0500
Message-ID: <20080128205437.GJ16785@fieldses.org>
References: <1201303040-7779-30-git-send-email-bfields@citi.umich.edu> <1201303040-7779-31-git-send-email-bfields@citi.umich.edu> <1201303040-7779-32-git-send-email-bfields@citi.umich.edu> <1201303040-7779-33-git-send-email-bfields@citi.!umich.edu> <1201303040-7779-34-git-send-email-bfields@citi.umi!ch.edu> <1201303040-7779-35-git-send-email-bfields@citi.umich.edu> <1201303040-7779-36-git-send-email-bfields@citi.umich.edu> <1201303040-7779-37-git-send-email-bfields@citi.umich.edu> <1201303040-7779-38-git-send-email-bfields@citi.umich.edu> <C96D4075-614F-47B8-8788-F21589C00D06@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Frank Filz <ffilzlnx@us.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51919 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900AbYA1Uyk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 15:54:40 -0500
In-Reply-To: <C96D4075-614F-47B8-8788-F21589C00D06@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 03:04:17PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> @@ -1833,7 +1833,12 @@ out_acl:
>>  	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
>>  		if ((buflen -= 8) < 0)
>>                  	goto out_resource;
>> -		if (exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
>> +                /*
>> +                 * Get parent's attributes if not ignoring crossmount
>> +                 * and this is the root of a cross-mounted  
>> filesystem.
>> +                 */
>> +                if (ignore_crossmnt == 0 &&
>> +		    exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
>
> More white space damage here.

Whoops, fixed; thanks.

>
>>  			err = vfs_getattr(exp->ex_mnt->mnt_parent,
>>  				exp->ex_mnt->mnt_mountpoint, &stat);
>>  			if (err)
>> @@ -1869,13 +1874,25 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir 
>> *cd,
>>  	struct svc_export *exp = cd->rd_fhp->fh_export;
>>  	struct dentry *dentry;
>>  	__be32 nfserr;
>> +	int    ignore_crossmnt = 0;
>
> Nit: extra blanks here.

OK, fixed.

>
>>  	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
>>  	if (IS_ERR(dentry))
>>  		return nfserrno(PTR_ERR(dentry));
>>
>>  	exp_get(exp);
>> -	if (d_mountpoint(dentry)) {
>> +	/*
>> +	 * In the case of a mountpoint, the client may be asking for
>> +	 * attributes that are only properties of the underlying filesystem
>> +	 * as opposed to the cross-mounted file system. In such a case,
>> +	 * we will not follow the cross mount and will fill the attribtutes
>> +	 * directly from the mountpoint dentry.
>> +	 */
>> +	if (d_mountpoint(dentry) &&
>> +	    (cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
>> +	    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
>> +		ignore_crossmnt = 1;
>> +	else if (d_mountpoint(dentry)) {
>>  		int err;
>
> This seems kind of awkward.  Let's invoke d_mountpoint() once instead of 
> twice:

Yeah, OK.  I'd rather take that as a followup patch.  And I wonder if
the mountpoint case could be hidden in a separate function?  It'd be
nice to just have something like

	if (d_mountpoint(dentry))
		err = handle_mountpoint(cd->rd_rqstp, &dentry, &exp);

(or whatever).

--b.

>
> 	if (d_mountpoint(dentry)) {
> 		if ((cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
> 		    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
> 			ignore_crossmnt = 1;
> 		else {
> 			int err;
>
> 			/*
> 			 * Why the heck aren't we just using nfsd_lookup??
> 			 * Different "."/".." handling?  Something else?
> 			 * At least, add a comment here to explain....
> 			 */
> 			err = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
> 			if (err) {
> 				nfserr = nfserrno(err);
> 				goto out_put;
> 			}
> 			nfserr = check_nfsd_access(exp, cd->rd_rqstp);
> 			if (nfserr)
> 				goto out_put;
> 		}
> 	}
>
>> @@ -1894,7 +1911,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir 
>> *cd,
>>
>>  	}
>>  	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd- 
>> >rd_bmval,
>> -					cd->rd_rqstp);
>> +					cd->rd_rqstp, ignore_crossmnt);
>>  out_put:
>>  	dput(dentry);
>>  	exp_put(exp);
>> @@ -2048,7 +2065,7 @@ nfsd4_encode_getattr(struct nfsd4_compoundres  
>> *resp, __be32 nfserr, struct nfsd4
>>  	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
>>  	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
>>  				    resp->p, &buflen, getattr->ga_bmval,
>> -				    resp->rqstp);
>> +				    resp->rqstp, 0);
>>  	if (!nfserr)
>>  		resp->p += buflen;
>>  	return nfserr;
>> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
>> index b0ddfb4..27bd3e3 100644
>> --- a/include/linux/nfsd/xdr4.h
>> +++ b/include/linux/nfsd/xdr4.h
>> @@ -441,7 +441,7 @@ void nfsd4_encode_operation(struct  
>> nfsd4_compoundres *, struct nfsd4_op *);
>>  void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct  
>> nfsd4_op *op);
>>  __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>>  		       struct dentry *dentry, __be32 *buffer, int *countp,
>> -		       u32 *bmval, struct svc_rqst *);
>> +		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
>>  extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
>>  		struct nfsd4_compound_state *,
>>  		struct nfsd4_setclientid *setclid);
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
