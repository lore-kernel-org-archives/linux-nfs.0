Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab3BPUpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 15:45:07 -0500
Message-ID: <511FEFCB.2090002@RedHat.com>
Date: Sat, 16 Feb 2013 15:44:59 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 14/15] NFSD: Server implementation of MAC Labeling
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com> <1360327163-20360-15-git-send-email-SteveD@redhat.com> <20130212225425.GM10267@fieldses.org>
In-Reply-To: <20130212225425.GM10267@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/02/13 17:54, J. Bruce Fields wrote:
> On Fri, Feb 08, 2013 at 07:39:22AM -0500, Steve Dickson wrote:
>> @@ -242,7 +247,8 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
>>  
>>  static __be32
>>  nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>> -		   struct iattr *iattr, struct nfs4_acl **acl)
>> +		   struct iattr *iattr, struct nfs4_acl **acl,
>> +		   struct nfs4_label **label)
>>  {
>>  	int expected_len, len = 0;
>>  	u32 dummy32;
>> @@ -386,6 +392,50 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>>  			goto xdr_error;
>>  		}
>>  	}
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
>> +		if (dummy32 > NFS4_MAXLABELLEN)
>> +			return nfserr_resource;
>> +
>> +		*label = kzalloc(sizeof(struct nfs4_label), GFP_KERNEL);
> 
> So we don't want to allocate these the same way we did on the client?
These allocations are slightly different.. One is for incoming labels
and the other is for out going... 

> 
>> +		if (*label == NULL) {
>> +			host_err = -ENOMEM;
>> +			goto out_nfserr;
>> +		}
>> +
>> +		(*label)->label = kmalloc(dummy32 + 1, GFP_KERNEL);
>> +		if ((*label)->label == NULL) {
>> +			host_err = -ENOMEM;
>> +			kfree(*label);
>> +			goto out_nfserr;
>> +		}
>> +
>> +		(*label)->len = dummy32;
>> +		memcpy((*label)->label, buf, dummy32);
>> +		((char *)(*label)->label)[dummy32] = '\0';
>> +		(*label)->pi = pi;
>> +		(*label)->lfs = lfs;
>> +
>> +		defer_free(argp, kfree, (*label)->label);
>> +		defer_free(argp, kfree, *label);
> 
> Hm: looking at defer_free and nfsd4_release_compoundargs: looks like
> argp->to_free is effectively a stack, so these will get freed in the
> reverse order: *label first, then (*label)->label.  That's trouble.
> 
> So, I think we want the order of those two defer_free()'s reversed.
> 
> Or we could just allocate the whole things as one chunk as on the client
> and not have to worry about this kind of thing.  I think I'd prefer that
> to trying to keep the allocation as small as possible.  We're only using
> this memory temporarily so it's not as though we need to have tons of
> struct nfs4_labels allocated at the same time anyway.
I reworked this in the upcoming release to be more chunky... ;-)

>> +
>>  static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
>>  {
>>  	/* As per referral draft:  */
>> @@ -2111,6 +2205,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>>  
>>  		if (!aclsupport)
>>  			word0 &= ~FATTR4_WORD0_ACL;
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +		if (word2)
>> +			word2 |= FATTR4_WORD2_SECURITY_LABEL;
>> +#endif
> 
> Please just fix the definition of NFSD4_1_SUPPORTED_ATTRS_WORD2.  (The
> ifdef can go in that definition.)
Right... 

> 
> Although: don't we need to check whether the exported filesystem
> supports security labels?
I took a quick look around and didn't see any interface to do that.
Is it even possible to do this?

> 
>>  		if (!word2) {
>>  			if ((buflen -= 12) < 0)
>>  				goto out_resource;
>> @@ -2423,6 +2521,14 @@ out_acl:
>>  			get_parent_attributes(exp, &stat);
>>  		WRITE64(stat.ino);
>>  	}
>> +	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
>> +		status = nfsd4_encode_security_label(rqstp, dentry,
>> +				&p, &buflen);
>> +		if (status == nfserr_resource)
>> +			goto out_resource;
> 
> Just remove that, there's no real point to the out_resource goto.
Gone...

> 
>> +		if (status)
>> +			goto out;
> 
>> +	}
>>  	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
>>  		WRITE32(3);
>>  		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>> index de23db2..727fe44 100644
>> --- a/fs/nfsd/nfsd.h
>> +++ b/fs/nfsd/nfsd.h
>> @@ -308,10 +308,10 @@ void		nfsd_lockd_shutdown(void);
>>   | FATTR4_WORD1_OWNER	        | FATTR4_WORD1_OWNER_GROUP  | FATTR4_WORD1_RAWDEV           \
>>   | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
>>   | FATTR4_WORD1_SPACE_USED      | FATTR4_WORD1_TIME_ACCESS  | FATTR4_WORD1_TIME_ACCESS_SET  \
>> - | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
>> - | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
>> + | FATTR4_WORD1_TIME_DELTA	| FATTR4_WORD1_TIME_METADATA | FATTR4_WORD1_TIME_MODIFY     \
>> + | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
> 
> Did that actually change anything?  If not, just leave the formatting
> alone.
Gone...

> 
>>  
>> -#define NFSD4_SUPPORTED_ATTRS_WORD2 0
>> +#define NFSD4_SUPPORTED_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
> 
> That should be conditional on CONFIG_NFSD_V4_SECURITY_LABEL, shouldn't
> it?
Yes..

> 
>>  
>>  #define NFSD4_1_SUPPORTED_ATTRS_WORD0 \
>>  	NFSD4_SUPPORTED_ATTRS_WORD0
>> @@ -350,7 +350,7 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
>>  #define NFSD_WRITEABLE_ATTRS_WORD1 \
>>  	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
>>  	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
>> -#define NFSD_WRITEABLE_ATTRS_WORD2 0
>> +#define NFSD_WRITEABLE_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
>>  
>>  #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
>>  	NFSD_WRITEABLE_ATTRS_WORD0
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index d586117..0567fdc 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -28,6 +28,7 @@
>>  #include <asm/uaccess.h>
>>  #include <linux/exportfs.h>
>>  #include <linux/writeback.h>
>> +#include <linux/security.h>
>>  
>>  #ifdef CONFIG_NFSD_V3
>>  #include "xdr3.h"
>> @@ -621,6 +622,35 @@ int nfsd4_is_junction(struct dentry *dentry)
>>  		return 0;
>>  	return 1;
>>  }
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> +		struct nfs4_label *label)
>> +{
>> +	__be32 error;
>> +	int host_error;
>> +	struct dentry *dentry;
>> +
>> +	/* Get inode */
> 
> That comment's unnecessary.
Gone... 

> 
>> +	/* XXX: should we have a MAY_SSECCTX? */
> 
> I don't know, should we?
I vote no! ;-) What is that? 

steved.
