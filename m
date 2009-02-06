From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
 client --revised
Date: Fri, 06 Feb 2009 10:58:40 +0800
Message-ID: <498BA760.2090603@oracle.com>
References: <200901121216.n0CCGYMx001106@acsinet13.oracle.com> <20090204234924.GE20917@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org, greg.marsden@oracle.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:39999 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbZBFDAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2009 22:00:00 -0500
In-Reply-To: <20090204234924.GE20917@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Jan 12, 2009 at 08:14:46PM +0800, wengang wang wrote:
>> for descriptions for the problem and solution please see my former post with
>> Subject "nfsd(v2/v3): fix the failure of creation from HPUX client".
> 
> Could you just repeat that introduction each time?  I want to commit it
> with the patch, and that will save me some work hunting down the old
> email.

Sorry.
OK, will follow that for later patch postings.

>> comparing with former post, this patch puts the trick to nfsd_create_setattr().
>>
>> the patch is based on 2.6.27.10.
>>
>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> --
>>  vfs.c |   20 +++++++++++++++++---
>>  1 file changed, 17 insertions(+), 3 deletions(-)
>> diff -up ./fs/nfsd/vfs.c.orig ./fs/nfsd/vfs.c
>> --- ./fs/nfsd/vfs.c.orig	2008-12-23 14:11:14.000000000 +0800
>> +++ ./fs/nfsd/vfs.c	2009-01-12 19:35:13.000000000 +0800
>> @@ -1155,7 +1155,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
>>  
>>  static __be32
>>  nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
>> -			struct iattr *iap)
>> +			struct iattr *iap, int newfile)
>>  {
>>  	/*
>>  	 * Mode has already been set earlier in create:
>> @@ -1168,6 +1168,16 @@ nfsd_create_setattr(struct svc_rqst *rqs
>>  	 */
>>  	if (current->fsuid != 0)
>>  		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
>> +	/*
>> +	 * HPUX client sometimes creates a file in mode 000, and set
>> +	 * size to 0. setting size to 0 may fail for some spcific
>> +	 * file systems by the permission checking which requires
>> +	 * WRITE privilege but the mode is 000.
>> +	 * we ignore setting size to 0 for the creation, since it's
>> +	 * just 0 after created.
>> +	 * */
>> +	if (newfile && (iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
>> +		iap->ia_valid &= ~ATTR_SIZE;
> 
> It seems that all newfile does is tell us whether the net thing that was
> created is a regular file or not.  Does it even make sense to set size
> on other objects?  If not, then why not just make this:
> 
> 	if (iap->ia_size == 0)
> 		iap->ia_valid &= ~ATTR_SIZE;
> 
> and remove the need for "newfile"?
> 

I want it tell us whether it's new created(vfs_create()ed) file or a 
already existing one to be truncated.
the later is in case of

if (dchild->d_inode) {
	...
	switch (createmode) {
	case NFS3_CREATE_UNCHECKED:
		...
		else {
			...
			goto set_attr;
	
I think we should resize file to zero for the truncating case.
maybe I'm wrong somethere?

> Also: I'm curious, can you tell where exactly in the code the permission
> error is getting set?  

the original call trace for it is like following

@ got the stack that generic_permission() returns -EACCESS
@ generic_permission error -13 

@
@  [<f8ad1930>] gfs_permission+0x61/0x74 [gfs] 

@
@  [<f8ad18cf>] gfs_permission+0x0/0x74 [gfs]
@  [<c047c0f3>] permission+0x78/0xb5
@  [<f8ad19f6>] gfs_setattr+0xb3/0x378 [gfs]
@  [<c0487187>] notify_change+0x138/0x305
@  [<f8b41b0b>] nfsd_setattr+0x337/0x3d5 [nfsd]
@  [<f8b4304d>] nfsd_create_v3+0x30d/0x3c0 [nfsd]
@  [<f8b4759b>] nfsd3_proc_create+0x11c/0x12d [nfsd]
@  [<f8b3e1a4>] <7>Dead loop on netdevice eth0, fix it urgently!
@ nfsd_dispatch+0xbb/0x1a9 [nfsd]
@  [<f8972549>] svc_process+0x3c8/0x633 [sunrpc]
@  [<f8b3e68c>] nfsd+0x17e/0x286 [nfsd]
@  [<f8b3e50e>] nfsd+0x0/0x286 [nfsd]
@  [<c0405c3b>] kernel_thread_helper+0x7/0x10

generic_permission() is called from gfs code, and it returns -EACCESS
because mode is 0.


 From a quick look at nfsd_setattr() it appears
> it's doing all permissions checks with NFSD_MAY_OWNER_OVERRIDE, which
> should allow the setting of size, even in the case of mode 0, as long as
> the caller is the owner of the new file.  

I think you are mentioning the call nfsd_permission() in nfsd_setattr().
if you are, the call is under a condition of
	if (iap->ia_size < inode->i_size) {
in this case iap->ia_size(being 0) equals to inode->i_size, so 
nfsd_permission() is not called.

and from above call trace, it's not within nfsd_permission() where error 
returns.

Is HPUX also trying to set the
> onwer?
> 

No for uid but yes for gid.

thanks
wengang.
> --b.
> 
>>  	if (iap->ia_valid)
>>  		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
>>  	return 0;
>> @@ -1191,6 +1201,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>>  	__be32		err;
>>  	__be32		err2;
>>  	int		host_err;
>> +	int		newfile = 0;
>>  
>>  	err = nfserr_perm;
>>  	if (!flen)
>> @@ -1268,6 +1279,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>>  	switch (type) {
>>  	case S_IFREG:
>>  		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);
>> +		newfile = 1;
>>  		break;
>>  	case S_IFDIR:
>>  		host_err = vfs_mkdir(dirp, dchild, iap->ia_mode);
>> @@ -1289,7 +1301,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>>  		write_inode_now(dchild->d_inode, 1);
>>  	}
>>  
>> -	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
>> +	err2 = nfsd_create_setattr(rqstp, resfhp, iap, newfile);
>>  	if (err2)
>>  		err = err2;
>>  	mnt_drop_write(fhp->fh_export->ex_path.mnt);
>> @@ -1324,6 +1336,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>>  	__be32		err2;
>>  	int		host_err;
>>  	__u32		v_mtime=0, v_atime=0;
>> +	int		newfile = 0;
>>  
>>  	err = nfserr_perm;
>>  	if (!flen)
>> @@ -1415,6 +1428,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>>  	}
>>  	if (created)
>>  		*created = 1;
>> +	newfile = 1;
>>  
>>  	if (EX_ISSYNC(fhp->fh_export)) {
>>  		err = nfserrno(nfsd_sync_dir(dentry));
>> @@ -1433,7 +1447,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>>  	}
>>  
>>   set_attr:
>> -	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
>> +	err2 = nfsd_create_setattr(rqstp, resfhp, iap, newfile);
>>  	if (err2)
>>  		err = err2;
>>  
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
