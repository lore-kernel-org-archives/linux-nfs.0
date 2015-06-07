Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35138 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbFGIZS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jun 2015 04:25:18 -0400
Received: by qkhq76 with SMTP id q76so63192634qkh.2
        for <linux-nfs@vger.kernel.org>; Sun, 07 Jun 2015 01:25:17 -0700 (PDT)
Message-ID: <5573FFE7.6040000@gmail.com>
Date: Sun, 07 Jun 2015 16:25:11 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>,
        linux-nfs@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>,
        "SHUANG.QIU" <shuang.qiu@oracle.com>, kinglongmee@gmail.com
Subject: Re: nfsd: EACCES vs EPERM on utime()/utimes() calls
References: <556C73AE.4090900@oracle.com> <20150601212317.GF26972@fieldses.org> <556DD52D.5040405@oracle.com> <557047E2.10804@gmail.com> <20150604202725.GE5209@fieldses.org>
In-Reply-To: <20150604202725.GE5209@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/5/2015 4:27 AM, J. Bruce Fields wrote:
> On Thu, Jun 04, 2015 at 08:43:14PM +0800, Kinglong Mee wrote:
>> On 6/3/2015 12:09 AM, Stanislav Kholmanskikh wrote:
>>> On 06/02/2015 12:23 AM, bfields@fieldses.org wrote:
>>>> On Mon, Jun 01, 2015 at 06:01:02PM +0300, Stanislav Kholmanskikh wrote:
>>>>> Hello.
>>>>>
>>>>> As the man page for utime/utimes states [1], EPERM is returned if
>>>>> the second argument of utime/utimes is not NULL and:
>>>>>   * the caller's effective user id does not match the owner of the file
>>>>>   * the caller does not have write access to the file
>>>>>   * the caller is not privileged
>>>>>
>>>>> However, I don't see this behavior with NFS, I see EACCES is
>>>>> generated instead.
>>>>
>>>> Agreed that it's probably a server bug.  (Have you run across a case
>>>> where this makes a difference?)
>>>
>>> Thank you.
>>>
>>> No, I've not seen such a real-word scenario.
>>>
>>> I have these LTP test cases failing:
>>>
>>> * https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/utime/utime06.c
>>> * https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/utimes/utimes01.c
>>>
>>> and it makes me a bit nervous :)
>>>
>>>>
>>>> Looking at nfsd_setattr()....  The main work is done by notify_change(),
>>>> which is probably doing the right thing.  But before that there's an
>>>> fh_verify()--looks like that is expected to fail in your case.  I bet
>>>> that's the cause.
>>
>> Yes, it is.
>>
>> nfsd do the permission checking before notify_change() as,
>>
>> /* This assumes  NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC} */
>> err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
>>
>> return -EACCES for non-owner user.
>>
>>>
>>> I doubt I can fix it by myself (at least quickly). So I am happy if anyone more experienced will look at it as well :)
>>>
>>> Anyway, if nobody is interested, I'll give it a try, but later.
>>
>> Here is a diff patch for this problem, please try testing.
>> If okay, I will send an official patch.
>>
>> Note: must apply the following patch first in the url,
>> http://git.linux-nfs.org/?p=bfields/linux.git;a=commitdiff;h=cc265089ce1b176dde963c74b53593446ee7f99a
> 
> We could do that if we have to.
> 
> I wonder if we could instead skip the fh_verify's inode_permission call
> entirely?  Most callers of fh_verify don't need the inode_permission
> call at all as far as I can tell, because the following vfs operation
> does permission checking already.
> 
> We still need some nfs-specific checking, I guess (e.g. to make sure we
> aren't allowing setattr on a read-only export of a writeable mount), but
> the inode_permission itself I think we can usually skip.

I have made a draft for fh_verify without inode_permisson as following.
1. rename the check_nfsd_access() to rqst_check_access() that only
   checking the request's flavor.  (Maybe a split patch is better)
2. split a new helper nfsd_check_access() from nfsd_permission()
   for checking nfsd access.
3. nfsd_permission() is not changed by call nfsd_check_access().
4. let fh_verify() call nfsd_check_access(), not nfsd_permission().
5. add nfsd_permission() for do_open_permission().

I just test with pynfs, and the result is same as the old.

> 
> Andreas Gruenbacher has also been complaining that the redundant
> inode_permission calls make the richacl work more difficult, I can't
> remember why exactly.

I will check those patch and discuss of richacl, but maybe later. 

thanks,
Kinglong Mee

-----------------------------------------------------------------------------
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f79521a..3199fec 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -935,7 +935,7 @@ static struct svc_export *exp_find(struct cache_detail *cd,
 	return exp;
 }
 
-__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
+__be32 rqst_check_access(struct svc_export *exp, struct svc_rqst *rqstp)
 {
 	struct exp_flavor_info *f;
 	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..20a50c5 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -80,7 +80,7 @@ struct svc_expkey {
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 
 int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp);
-__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
+__be32 rqst_check_access(struct svc_export *exp, struct svc_rqst *rqstp);
 
 /*
  * Function declarations
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 864e200..d85d620 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -203,8 +203,11 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 		accmode |= NFSD_MAY_WRITE;
 
 	status = fh_verify(rqstp, current_fh, S_IFREG, accmode);
+	if (status)
+		return status;
 
-	return status;
+	return nfsd_permission(rqstp, current_fh->fh_export,
+				current_fh->fh_dentry, accmode);
 }
 
 static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
@@ -1708,7 +1711,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 				clear_current_stateid(cstate);
 
 			if (need_wrongsec_check(rqstp))
-				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
+				op->status = rqst_check_access(current_fh->fh_export, rqstp);
 		}
 
 encode_op:
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 158badf..33c6c14 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2843,7 +2843,7 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
 			nfserr = nfserrno(err);
 			goto out_put;
 		}
-		nfserr = check_nfsd_access(exp, cd->rd_rqstp);
+		nfserr = rqst_check_access(exp, cd->rd_rqstp);
 		if (nfserr)
 			goto out_put;
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 350041a..f3b04e5 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -360,13 +360,13 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type, int access)
 			&& exp->ex_path.dentry == dentry)
 		goto skip_pseudoflavor_check;
 
-	error = check_nfsd_access(exp, rqstp);
+	error = rqst_check_access(exp, rqstp);
 	if (error)
 		goto out;
 
 skip_pseudoflavor_check:
 	/* Finally, check access permissions. */
-	error = nfsd_permission(rqstp, exp, dentry, access);
+	error = nfsd_check_access(rqstp, exp, dentry, access);
 
 	if (error) {
 		dprintk("fh_verify: %pd2 permission failure, "
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84d770b..5a12d2d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -262,7 +262,7 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
 	if (err)
 		return err;
-	err = check_nfsd_access(exp, rqstp);
+	err = rqst_check_access(exp, rqstp);
 	if (err)
 		goto out;
 	/*
@@ -2012,11 +2012,10 @@ static int exp_rdonly(struct svc_rqst *rqstp, struct svc_export *exp)
  * Check for a user's access permissions to this inode.
  */
 __be32
-nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
+nfsd_check_access(struct svc_rqst *rqstp, struct svc_export *exp,
 					struct dentry *dentry, int acc)
 {
 	struct inode	*inode = d_inode(dentry);
-	int		err;
 
 	if ((acc & NFSD_MAY_MASK) == NFSD_MAY_NOP)
 		return 0;
@@ -2052,6 +2051,18 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 		}
 	if ((acc & NFSD_MAY_TRUNC) && IS_APPEND(inode))
 		return nfserr_perm;
+	return 0;
+}
+__be32
+nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
+					struct dentry *dentry, int acc)
+{
+	struct inode	*inode = d_inode(dentry);
+	int		err;
+
+	err = nfsd_check_access(rqstp, exp, dentry, acc);
+	if (err)
+		return err;
 
 	if (acc & NFSD_MAY_LOCK) {
 		/* If we cannot rely on authentication in NLM requests,
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 2050cb0..e3e8eed 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -101,6 +101,8 @@ __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 				struct kstatfs *, int access);
 
+__be32		nfsd_check_access(struct svc_rqst *, struct svc_export *,
+				struct dentry *, int);
 __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
 
