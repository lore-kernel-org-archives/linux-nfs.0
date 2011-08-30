Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:40072 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414Ab1H3UBJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 16:01:09 -0400
Subject: Re: [PATCH] NFSD: Add a cache for fs_locations information
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110830151845.4dec5b40@tlielax.poochiereds.net>
Date: Tue, 30 Aug 2011 16:00:52 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <852F14A9-7826-47A0-BCD6-D5D46E38A39C@oracle.com>
References: <20110829185115.3413.92459.stgit@matisse.1015granger.net> <20110830151845.4dec5b40@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 30, 2011, at 3:18 PM, Jeff Layton wrote:

> On Mon, 29 Aug 2011 14:51:15 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> 
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> [ cel: since this is server-side, use nfsd4_ prefix instead of nfs4_ prefix. ]
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfsd/nfsd.h |    7 +++++++
>> fs/nfsd/vfs.c  |   15 +++++++++++++++
>> 2 files changed, 22 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>> index 7ecfa24..d314812 100644
>> --- a/fs/nfsd/nfsd.h
>> +++ b/fs/nfsd/nfsd.h
>> @@ -335,6 +335,13 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
>> #define NFSD_SUPPATTR_EXCLCREAT_WORD2 \
>> 	NFSD_WRITEABLE_ATTRS_WORD2
>> 
>> +extern int nfsd4_is_junction(struct dentry *dentry);
>> +#else
>> +static inline int nfsd4_is_junction(struct dentry *dentry)
>> +{
>> +	return 0;
>> +}
>> +
>> #endif /* CONFIG_NFSD_V4 */
>> 
>> #endif /* LINUX_NFSD_NFSD_H */
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index fd0acca..5dac667 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -168,6 +168,8 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
>> {
>> 	if (d_mountpoint(dentry))
>> 		return 1;
>> +	if (nfsd4_is_junction(dentry))
>> +		return 1;
>> 	if (!(exp->ex_flags & NFSEXP_V4ROOT))
>> 		return 0;
>> 	return dentry->d_inode != NULL;
>> @@ -592,6 +594,19 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct nfs4_ac
>> 	return error;
>> }
>> 
>> +#define NFSD_XATTR_JUNCTION_PREFIX XATTR_TRUSTED_PREFIX "junction."
>> +#define NFSD_XATTR_JUNCTION_TYPE NFSD_XATTR_JUNCTION_PREFIX "type"
>> +int nfsd4_is_junction(struct dentry *dentry)
>> +{
>> +	ssize_t ret;
>> +
>> +	if (dentry->d_inode != NULL) {
>> +		ret = vfs_getxattr(dentry, NFSD_XATTR_JUNCTION_TYPE, NULL, 0);
>> +		if (ret > 0)
>> +			return 1;
>> +	}
>> +	return 0;
>> +}
> 
> Won't the above check be rather expensive? You'll need to do a
> getxattr call on almost every path component of every lookup, right?
> 
> I may be misremembering your talk from connectathon, but I thought you
> were planning to use a well-known mode for junctions that would cut
> down on the number of unnecessary getxattrs...

Yes, that's the plan.  To reduce overhead, the S_ISVTX bit must be set before NFSD does the expensive xattr test.  However, I don't think this kind of filtering was ever implemented.  I got the patch from here:

  http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=shortlog;h=refs/heads/fedfs-for-2.6.34

and that doesn't seem to have it either.  I can implement something and repost these.

>> #endif /* defined(CONFIG_NFSD_V4) */
>> 
>> #ifdef CONFIG_NFSD_V3
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> -- 
> Jeff Layton <jlayton@poochiereds.net>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




