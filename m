Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:46912 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbaEAPtO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 11:49:14 -0400
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 May 2014 21:19:13 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 22/22] ext4: Add Ext4 compat richacl feature flag
In-Reply-To: <88FB2DB7-126A-400E-9B44-19E99A553B2B@dilger.ca>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1398615293-22931-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <88FB2DB7-126A-400E-9B44-19E99A553B2B@dilger.ca>
Date: Thu, 01 May 2014 21:18:51 +0530
Message-ID: <877g65biu4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andreas Dilger <adilger@dilger.ca> writes:

> On Apr 27, 2014, at 10:14 AM, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> This feature flag can be used to enable richacl on
>> the file system. Once enabled the "acl" mount option
>> will enable richacl instead of posix acl
>
> I was going to complain about this patch, because re-using the "acl"
> mount option to specify richacl instead of POSIX ACL would be very
> confusing, since older kernels used the "acl" mount option to enable
> POSIX ACLs.
>
> Looking closer, I see that "acl" and "noacl" just means enable or disable
> the ACL functionality on the filesystem.  Please fix up the commit
> comment.

Will clarify in the commit message.

>
> Some more comments inline.
>
>> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
>> index 6f9e6fadac04..2a0221652d79 100644
>> --- a/fs/ext4/super.c
>> +++ b/fs/ext4/super.c
>> @@ -1274,6 +1274,30 @@ static ext4_fsblk_t get_sb_block(void **data)
>> 	return sb_block;
>> }
>> 
>> +static void enable_acl(struct super_block *sb)
>> +{
>> +#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && !defined(CONFIG_EXT4_FS_RICHACL)
>> +	return;
>> +#endif
>> +	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
>> +		sb->s_flags |= MS_RICHACL;
>> +		sb->s_flags &= ~MS_POSIXACL;
>> +	} else {
>> +		sb->s_flags |= MS_POSIXACL;
>> +		sb->s_flags &= ~MS_RICHACL;
>> +	}
>
> This should put the #ifdef around the code that is being enabled/disabled,
> otherwise it just becomes dead code:
>
> static int enable_acl(struct super_block *sb)
> {
> 	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
> #if defined(CONFIG_EXT4_FS_RICHACL)
> 		sb->s_flags |= MS_RICHACL;
> 		sb->s_flags &= ~MS_POSIXACL;
> #else
> 		return -EOPNOTSUPP;
> #endif
> 	} else {
> #if defined(CONFIG_EXT4_FS_POSIX_ACL)
> 		sb->s_flags |= MS_POSIXACL;
> 		sb->s_flags &= ~MS_RICHACL;
> #else
> 		return -EOPNOTSUPP;
> #endif
> 	}
> 	return 0;
> }

That is too much #ifdef with no real benefit ?

>
>> +
>> +static void disable_acl(struct super_block *sb)
>> +{
>> +#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && !defined(CONFIG_EXT4_FS_RICHACL)
>> +	return;
>> +#endif
>> +	sb->s_flags &= ~(MS_POSIXACL | MS_RICHACL);
>> +	return;
>> +}
>
> "return" is not needed at the end of void functions. Same comment on
> #ifdef:

ok

>
> static void disable_acl(struct super_block *sb)
> {
> #if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
> 	sb->s_flags &= ~(MS_POSIXACL | MS_RICHACL);
> #endif
> }
>
>
>> +
>> #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
>> static char deprecated_msg[] = "Mount option \"%s\" will be removed by %s\n"
>> 	"Contact linux-ext4@vger.kernel.org if you think we should keep it.\n";
>> @@ -1417,9 +1441,9 @@ static const struct mount_opts {
>> 	 MOPT_NO_EXT2 | MOPT_DATAJ},
>> 	{Opt_user_xattr, EXT4_MOUNT_XATTR_USER, MOPT_SET},
>> 	{Opt_nouser_xattr, EXT4_MOUNT_XATTR_USER, MOPT_CLEAR},

....

>> 	if ((def_mount_opts & EXT4_DEFM_JMODE) == EXT4_DEFM_JMODE_DATA)
>> 		set_opt(sb, JOURNAL_DATA);
>> @@ -3569,8 +3593,12 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>> 			clear_opt(sb, DELALLOC);
>> 	}
>> 
>> -	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
>> -		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
>> +	/*
>> +	 * clear ACL flags
>> +	 */
>> +	disable_acl(sb);
>
> Is there any expectation that the flags would be set on a newly mounted
> filesystem?
>
>> +	if (test_opt(sb, ACL))
>> +		enable_acl(sb);
>> 
>> 	if (le32_to_cpu(es->s_rev_level) == EXT4_GOOD_OLD_REV &&
>> 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
>> @@ -4844,8 +4872,9 @@ static int ext4_remount(struct super_block *sb, int *flags, char *data)
>> 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
>> 		ext4_abort(sb, "Abort forced by user");
>> 
>> -	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
>> -		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
>> +	disable_acl(sb);
>> +	if (test_opt(sb, ACL))
>> +		enable_acl(sb);
>
> Similarly, it seems racy to me to disable ACL support and then re-enable
> it here during remount, since that might cause some concurrent operations
> to fail.  It seems like enable_acl() already handles clearing the flags
> correctly, so something like the following would be better:
>
> 	if (test_opt(sb, ACL))
> 		enable_acl(sb);
> 	else
> 		disable_acl(sb);
>
>

ok

-aneesh

