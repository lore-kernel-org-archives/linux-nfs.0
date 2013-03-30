Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247Ab3C3Vub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Mar 2013 17:50:31 -0400
Message-ID: <51575E1D.7000605@RedHat.com>
Date: Sat, 30 Mar 2013 17:50:21 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com> <1364478845-29796-14-git-send-email-SteveD@redhat.com> <20130328185845.GI7080@fieldses.org>
In-Reply-To: <20130328185845.GI7080@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 28/03/13 14:58, J. Bruce Fields wrote:
> On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> This patch adds the ability to encode and decode file labels on the server for
>> the purpose of sending them to the client and also to process label change
>> requests from the client.
>>
>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>  fs/nfsd/nfs4proc.c |  41 +++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c  | 116 ++++++++++++++++++++++++++++++++++++++++++++++++++---
>>  fs/nfsd/nfsd.h     |   6 ++-
>>  fs/nfsd/vfs.c      |  29 ++++++++++++++
>>  fs/nfsd/vfs.h      |   2 +
>>  fs/nfsd/xdr4.h     |   3 ++
>>  6 files changed, 191 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index ae73175..bb17589 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -42,6 +42,36 @@
>>  #include "current_stateid.h"
>>  #include "netns.h"
>>  
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +#include <linux/security.h>
>> +
>> +static inline void
>> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct nfs4_label *label, u32 *bmval)
>> +{
>> +	struct inode *inode = resfh->fh_dentry->d_inode;
>> +	int status;
>> +
>> +	mutex_lock(&inode->i_mutex);
>> +	status = security_inode_setsecctx(resfh->fh_dentry,
>> +		label->label, label->len);
>> +	mutex_unlock(&inode->i_mutex);
>> +
>> +	if (status)
>> +		/*
>> +		 * We should probably fail the whole open at this point,
>> +		 * but we've already created or opened the file, so it's 
>> +		 * too late; So this seems the least of evils:
>> +		 */
>> +		bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
>> +		
>> +	return;
>> +}
>> +#else 
>> +static inline void 
>> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct nfs4_label *label, u32 *bmval)
>> +{ }
>> +#endif
>> +
>>  #define NFSDDBG_FACILITY		NFSDDBG_PROC
>>  
>>  static u32 nfsd_attrmask[] = {
>> @@ -230,6 +260,9 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
>>  					(u32 *)open->op_verf.data,
>>  					&open->op_truncate, &open->op_created);
>>  
>> +		if (!status && open->op_label != NULL) 
>> +			nfsd4_security_inode_setsecctx(resfh, open->op_label, open->op_bmval);
>> +
>>  		/*
>>  		 * Following rfc 3530 14.2.16, use the returned bitmask
>>  		 * to indicate which attributes we used to store the
>> @@ -599,6 +632,9 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	if (status)
>>  		goto out;
>>  
>> +	if (create->cr_label != NULL)
>> +		nfsd4_security_inode_setsecctx(&resfh, create->cr_label, create->cr_bmval);
>> +
>>  	if (create->cr_acl != NULL)
>>  		do_set_nfs4_acl(rqstp, &resfh, create->cr_acl,
>>  				create->cr_bmval);
>> @@ -888,6 +924,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  					    setattr->sa_acl);
>>  	if (status)
>>  		goto out;
>> +	if (setattr->sa_label != NULL)
>> +		status = nfsd4_set_nfs4_label(rqstp, &cstate->current_fh,
>> +				setattr->sa_label);
>> +	if (status)
>> +		goto out;
>>  	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
>>  				0, (time_t)0);
>>  out:
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 0116886..52e219c 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -55,6 +55,11 @@
>>  #include "cache.h"
>>  #include "netns.h"
>>  
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +#include <linux/security.h>
>> +#endif
>> +
>> +
>>  #define NFSDDBG_FACILITY		NFSDDBG_XDR
>>  
>>  /*
>> @@ -79,6 +84,24 @@ check_filename(char *str, int len)
>>  			return nfserr_badname;
>>  	return 0;
>>  } 
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +static struct nfs4_label *nfsd4_label_alloc(u32 len)
>> +{
>> +	struct nfs4_label *label = NULL;
>> +
>> +	if (len > NFS4_MAXLABELLEN)
>> +		return ERR_PTR(-ENAMETOOLONG);
> 
> This is returned as NFS4ERR_NAMETOOLONG.
> 
> The 4.2 spec should note this case, if it's the right error.  rfc 5661
> says that error's only for filenames, and doesn't allow it for setattr
> (which doesn't take a filename).
The 4.2 spec (draft-ietf-nfsv4-minorversion2-19.txt) defines two Labeled 
NFS errors:
NFS4ERR_BADLABEL  (Error Code 10093)
NFS4ERR_WRONG_LFS (Error Code 10092)

and we currently don't define either one of them... So I guess that
will have to change... 

So what should NFS4ERR_BADLABEL map to in nfserrno()?

> 
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
>> +		uint32_t pi;
>> +		uint32_t lfs;
>> +
>> +		READ_BUF(4);
>> +		len += 4;
>> +		READ32(lfs);
>> +		READ_BUF(4);
>> +		len += 4;
>> +		READ32(pi);
>> +		READ_BUF(4);
>> +		len += 4;
>> +		READ32(dummy32);
>> +		READ_BUF(dummy32);
>> +		len += (XDR_QUADLEN(dummy32) << 2);
>> +		READMEM(buf, dummy32);
>> +
>> +		*label = nfsd4_label_alloc(dummy32);
>> +		if (*label == NULL) {
> 
> Careful!  That should be IS_ERR(*label).
> 
>> +			host_err = PTR_ERR(label);
> 
> And that should be *label.
Gotta it... 

> 
>>  static __be32
>> @@ -1988,6 +2044,50 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
>>  			      FATTR4_WORD0_RDATTR_ERROR)
>>  #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
>>  
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +static inline __be32
>> +nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
>> +{
>> +	void *context;
>> +	int err;
>> +	int len;
>> +	uint32_t pi = 0;
>> +	uint32_t lfs = 0;
>> +	__be32 *p = *pp;
>> +
>> +	err = 0;
>> +	(void)security_inode_getsecctx(dentry->d_inode, &context, &len);
>> +	if (len < 0)
>> +		return nfserrno(len);
>> +
>> +	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4)) {
>> +		err = nfserr_resource;
>> +		goto out;
>> +	}
>> +
>> +	/* XXX: A call to the translation code should be placed here
>> +	 * for now send 0  until we have that to indicate the null
>> +	 * translation */ 
> 
> Could we better a better comment here?
Changed to:
/*
 * For now we use a 0 here to indicate the null translation; in
 * the future we may place a call to translation code here.
 */
> 
>> +
>> +	if ((*buflen -= 4) < 0)
> 
> Looks like that should be 8.
Right...

> 
>> +		return nfserr_resource;
>> +
>> +	WRITE32(lfs);	
>> +	WRITE32(pi);
>> +	p = xdr_encode_opaque(p, context, len);
>> +	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
>> +
>> +	*pp = p;
>> +out:
>> +	security_release_secctx(context, len);
>> +	return err;
>> +}
> 
> ...
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> +		struct nfs4_label *label)
>> +{
>> +	__be32 error;
>> +	int host_error;
>> +	struct dentry *dentry;
>> +
>> +	/* XXX: should we have a MAY_SSECCTX? */
> 
> Again: could we get an answer to this question?
Gone... just a bad dream! ;-) 

Thank you the cycles! 

steved.
