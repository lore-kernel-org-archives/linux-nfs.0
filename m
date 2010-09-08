Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39275 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552Ab0IHOg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 10:36:59 -0400
Message-ID: <4C879F81.6000500@suse.de>
Date: Wed, 08 Sep 2010 20:06:49 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
References: <4C84DFA7.7050507@suse.de>	 <1283869039.4291.16.camel@heimdal.trondhjem.org> <4C869D00.8030604@suse.de> <1283892577.2788.104.camel@heimdal.trondhjem.org>
In-Reply-To: <1283892577.2788.104.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/08/2010 02:19 AM, Trond Myklebust wrote:
> On Wed, 2010-09-08 at 01:43 +0530, Suresh Jayaraman wrote:

>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index eb51bd6..a13a83e 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -800,8 +800,13 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
>>  
>>  	nfs_inc_stats(inode, NFSIOS_VFSLOCK);
>>  
>> -	/* No mandatory locks over NFS */
>> -	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
>> +	/*
>> +	 * No mandatory locks over NFS.
>> +	 * fcntl lock is local if mounted with "-o llock=fcntl" or
>> +	 * "-o llock=posix"
>> +	 */
>> +	if ((__mandatory_lock(inode) && fl->fl_type != F_UNLCK) ||
>> +			(NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL))
>>  		goto out_err;
>>  
>>  	if (NFS_PROTO(inode)->lock_check_bounds != NULL) {
>> @@ -825,12 +830,16 @@ out_err:
>>   */
>>  static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
>>  {
>> +	struct inode *inode = filp->f_mapping->host;
>> +
>>  	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
>>  			filp->f_path.dentry->d_parent->d_name.name,
>>  			filp->f_path.dentry->d_name.name,
>>  			fl->fl_type, fl->fl_flags);
>>  
>> -	if (!(fl->fl_flags & FL_FLOCK))
>> +	/* flock is local if mounted with "-o llock=flock" */
>> +	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK) ||
>> +			(!(fl->fl_flags & FL_FLOCK)))
>>  		return -ENOLCK;
> 
> Is this really what we want to do? Shouldn't we rather default to
> treating this as if NFS_MOUNT_NONLM were set?
> 

ah, yes, you're right.

>>  
>>  static void nfs_umount_begin(struct super_block *);
>>  static int  nfs_statfs(struct dentry *, struct kstatfs *);
>> @@ -1412,6 +1429,33 @@ static int nfs_parse_mount_options(char *raw,
>>  			mnt->fscache_uniq = string;
>>  			mnt->options |= NFS_OPTION_FSCACHE;
>>  			break;
>> +		case Opt_llock:
>> +			string = match_strdup(args);
>> +			if (string == NULL)
>> +				goto out_nomem;
>> +			token = match_token(string, nfs_llock_tokens, args);
>> +			kfree(string);
>> +			switch (token) {
>> +			case Opt_llock_all:
>> +				mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
>> +					       NFS_MOUNT_LOCAL_FCNTL);
>> +				break;
>> +			case Opt_llock_flock:
>> +				mnt->flags |= NFS_MOUNT_LOCAL_FLOCK;
>> +				break;
>> +			case Opt_llock_fcntl:
>> +				mnt->flags |= NFS_MOUNT_LOCAL_FCNTL;
>> +				break;
>> +			case Opt_llock_none:
>> +				mnt->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
>> +						NFS_MOUNT_LOCAL_FCNTL);
>> +				break;
>> +			default:
>> +				dfprintk(MOUNT, "NFS:	invalid	"
>> +						"llock argument\n");
>> +				return 0;
>> +			};
>> +			break;
> 
> Could we perhaps also convert Opt_nolock so that it just sets
> NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL (and ditto for the legacy
> NFS_MOUNT_NONLM).
> 

Did you mean defining NFS_MOUNT_NONLM as

#define NFS_MOUNT_NONLM         (NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL) ?

This would be problematic when we want to say make flock local but
fcntl NLM lock.. or make fcntl local but flock NLM lock.. i.e
when we setup lockd, we check

 if (server->flags & NFS_MOUNT_NONLM)

which will succeed and nlmclnt would remain uninitialized..


Thanks,

-- 
Suresh Jayaraman
