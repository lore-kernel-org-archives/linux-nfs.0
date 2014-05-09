Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:56091 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaEIHzb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 May 2014 03:55:31 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so3421462pdi.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 May 2014 00:55:31 -0700 (PDT)
Message-ID: <536C89D7.6090902@gmail.com>
Date: Fri, 09 May 2014 15:55:03 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Don't clear SUID/SGID after root writing data
References: <534AA92B.8010805@gmail.com> <20140418130220.GF18612@fieldses.org> <53512DE5.7050907@gmail.com> <5351501B.1010507@gmail.com> <20140508161256.GC20976@fieldses.org>
In-Reply-To: <20140508161256.GC20976@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/9/2014 00:12, J. Bruce Fields wrote:
> On Sat, Apr 19, 2014 at 12:17:31AM +0800, Kinglong Mee wrote:
>> SUID/SGID is not cleared after writing data with (root, local ext4),
>> #touch test; chmod 4777 test; stat test; echo 1234 > test; stat test;
>>   File: ‘test’
>>   Size: 0               Blocks: 0          IO Block: 4096   regular
>> empty file
>> Device: 803h/2051d      Inode: 1200137     Links: 1
>> Access: (4777/-rwsrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>> Context: unconfined_u:object_r:admin_home_t:s0
>> Access: 2014-04-18 21:36:31.016029014 +0800
>> Modify: 2014-04-18 21:36:31.016029014 +0800
>> Change: 2014-04-18 21:36:31.026030285 +0800
>>  Birth: -
>>   File: ‘test’
>>   Size: 5               Blocks: 8          IO Block: 4096   regular file
>> Device: 803h/2051d      Inode: 1200137     Links: 1
>> Access: (4777/-rwsrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>> Context: unconfined_u:object_r:admin_home_t:s0
>> Access: 2014-04-18 21:36:31.016029014 +0800
>> Modify: 2014-04-18 21:36:31.040032065 +0800
>> Change: 2014-04-18 21:36:31.040032065 +0800
>>  Birth: -
>>
>> With no_root_squash, (root, remote ext4), SUID/SGID are cleared,
>> #touch test; chmod 4777 test; stat test; echo 1234 > test; stat test;
>>   File: ‘test’
>>   Size: 0               Blocks: 0          IO Block: 262144 regular
>> empty file
>> Device: 24h/36d Inode: 786439      Links: 1
>> Access: (4777/-rwsrwxrwx)  Uid: ( 1000/    test)   Gid: ( 1000/    test)
>> Context: system_u:object_r:nfs_t:s0
>> Access: 2014-04-18 21:45:32.155805097 +0800
>> Modify: 2014-04-18 21:45:32.155805097 +0800
>> Change: 2014-04-18 21:45:32.168806749 +0800
>>  Birth: -
>>   File: ‘test’
>>   Size: 5               Blocks: 8          IO Block: 262144 regular file
>> Device: 24h/36d Inode: 786439      Links: 1
>> Access: (0777/-rwxrwxrwx)  Uid: ( 1000/    test)   Gid: ( 1000/    test)
>> Context: system_u:object_r:nfs_t:s0
>> Access: 2014-04-18 21:45:32.155805097 +0800
>> Modify: 2014-04-18 21:45:32.184808783 +0800
>> Change: 2014-04-18 21:45:32.184808783 +0800
>>  Birth: -
>>
>> This patch drops codes that kills SGID/SUID visibly,
>> because vfs_writev() can kills it if necessary.
>>
>> With this patch, the above problem will not exist.
> 
> I'd like to apply this if only to remove the redundant code.
> 
> I'd like to understand, though, whether this is something that caused an
> actual practical problem for someone, or if you just happened to notice
> the inconsistency between nfs and ext4 behavior?

I test it with ext2,ext3,btrfs,xfs.
Test result is same as ext4.
So, we needs remove the redundant killing of suid/sgid.

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/vfs.c | 18 ------------------
>>  1 file changed, 18 deletions(-)
>>
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 16f0673..6aaa305 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -857,20 +857,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct
>> svc_fh *fhp, struct file *file,
>>  	return err;
>>  }
>>
>> -static void kill_suid(struct dentry *dentry)
>> -{
>> -	struct iattr	ia;
>> -	ia.ia_valid = ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
>> -
>> -	mutex_lock(&dentry->d_inode->i_mutex);
>> -	/*
>> -	 * Note we call this on write, so notify_change will not
>> -	 * encounter any conflicting delegations:
>> -	 */
>> -	notify_change(dentry, &ia, NULL);
>> -	mutex_unlock(&dentry->d_inode->i_mutex);
>> -}
>> -
>>  /*
>>   * Gathered writes: If another process is currently writing to the file,
>>   * there's a high chance this is another nfsd (triggered by a bulk write
>> @@ -942,10 +928,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct
>> svc_fh *fhp, struct file *file,
>>  	nfsdstats.io_write += host_err;
>>  	fsnotify_modify(file);
>>
>> -	/* clear setuid/setgid flag after write */
>> -	if (inode->i_mode & (S_ISUID | S_ISGID))
>> -		kill_suid(dentry);
>> -
>>  	if (stable) {
>>  		if (use_wgather)
>>  			host_err = wait_for_concurrent_writes(file);
>> -- 
>> 1.9.0
>>
> 
