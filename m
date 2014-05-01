Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:51276 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334AbaEAPSR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 11:18:17 -0400
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 2 May 2014 01:18:15 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Dave Chinner <david@fromorbit.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 06/22] vfs: Add delete child and delete self permission flags
In-Reply-To: <20140429000758.GP15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1398615293-22931-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140429000758.GP15995@dastard>
Date: Thu, 01 May 2014 20:48:04 +0530
Message-ID: <87lhulbk9f.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave Chinner <david@fromorbit.com> writes:

> On Sun, Apr 27, 2014 at 09:44:37PM +0530, Aneesh Kumar K.V wrote:
>> From: Andreas Gruenbacher <agruen@kernel.org>
>> 
>> Normally, deleting a file requires write access to the parent directory.
>> Some permission models use a different permission on the parent
>> directory to indicate delete access.  In addition, a process can have
>> per-file delete access even without delete access on the parent
>> directory.
>> 
>> Introduce two new inode_permission() mask flags and use them in
>> may_delete()
>> 
>> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  fs/namei.c         | 45 ++++++++++++++++++++++++++++++++++-----------
>>  include/linux/fs.h |  2 ++
>>  2 files changed, 36 insertions(+), 11 deletions(-)
>> 
>> diff --git a/fs/namei.c b/fs/namei.c
>> index 028bc8bcf77c..56ac7613fbca 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -446,7 +446,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
>>   * changing the "normal" UIDs which are used for other things.
>>   *
>>   * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
>> - * MAY_WRITE must also be set in @mask.
>> + * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
>>   */
>>  int inode_permission(struct inode *inode, int mask)
>>  {
>> @@ -2366,11 +2366,25 @@ kern_path_mountpoint(int dfd, const char *name, struct path *path,
>>  }
>>  EXPORT_SYMBOL(kern_path_mountpoint);
>>  
>> +
>> +/*
>> + * We should have exec permission on directory and MAY_DELETE_SELF
>> + * on the object being deleted.
>> + */
>> +static int richacl_may_selfdelete(struct inode *dir,
>> +				  struct inode *inode, int replace_mask)
>> +{
>> +	return (IS_RICHACL(inode) &&
>> +		(inode_permission(dir, MAY_EXEC | replace_mask) == 0) &&
>> +		(inode_permission(inode, MAY_DELETE_SELF) == 0));
>> +}
>
> Can't say I like these "richacl" prefixes. Why not just "may_*"
> like all the other permission checks?

Will update.

>
>
>> @@ -2414,13 +2431,19 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
>>  	BUG_ON(victim->d_parent->d_inode != dir);
>>  	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
>>  
>> -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
>> +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
>> +	if (replace)
>> +		replace_mask = S_ISDIR(inode->i_mode) ?
>> +				MAY_CREATE_DIR : MAY_CREATE_FILE;
>> +	error = inode_permission(dir, mask | replace_mask);
>> +	if (error && richacl_may_selfdelete(dir, inode, replace_mask))
>> +		error = 0;

....

>>  
>>  		if (!(flags & RENAME_EXCHANGE))
>> -			error = may_delete(new_dir, new_dentry, is_dir);
>> +			error = may_delete(new_dir, new_dentry, is_dir, 1);
>>  		else
>> -			error = may_delete(new_dir, new_dentry, new_is_dir);
>> +			error = may_delete(new_dir, new_dentry, new_is_dir, 1);
>
> Another boolean parameter that means nothing at the call site.  This
> should really be passing a flags field, not a bunch of booleans that
> are simply evaluated into flags...
>

Will update

Thanks
-aneesh

