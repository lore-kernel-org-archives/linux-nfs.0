Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49315 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbaDRNwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 09:52:07 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so1479167pbb.26
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 06:52:06 -0700 (PDT)
Message-ID: <53512DE5.7050907@gmail.com>
Date: Fri, 18 Apr 2014 21:51:33 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Checking whether kill_suid by should_remove_suid()
References: <534AA92B.8010805@gmail.com> <20140418130220.GF18612@fieldses.org>
In-Reply-To: <20140418130220.GF18612@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014/4/18 21:02, J. Bruce Fields wrote:
> On Sun, Apr 13, 2014 at 11:11:39PM +0800, Kinglong Mee wrote:
>> As local filesystem, writing data to the file by non-owner will
>> clears the SUID+SGID, owner will not.
>
> Are you sure about this?  (Do you have a test case that fails?)

Sorry, maybe there are some fault of the comment,
and also, there are some problems needs rechecking.
Please ignore this patch.

I test it using command line with (root, local ext4),
touch test; chmod 4777 test; stat test; echo 1234 > test; stat test;
   File: ‘test’
   Size: 0               Blocks: 0          IO Block: 4096   regular 
empty file
Device: 803h/2051d      Inode: 1200137     Links: 1
Access: (4777/-rwsrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:admin_home_t:s0
Access: 2014-04-18 21:36:31.016029014 +0800
Modify: 2014-04-18 21:36:31.016029014 +0800
Change: 2014-04-18 21:36:31.026030285 +0800
  Birth: -
   File: ‘test’
   Size: 5               Blocks: 8          IO Block: 4096   regular file
Device: 803h/2051d      Inode: 1200137     Links: 1
Access: (4777/-rwsrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:admin_home_t:s0
Access: 2014-04-18 21:36:31.016029014 +0800
Modify: 2014-04-18 21:36:31.040032065 +0800
Change: 2014-04-18 21:36:31.040032065 +0800
  Birth: -

With no_root_squash, (root, remote ext4),
should not change the sgid/suid, but got

   File: ‘test’
   Size: 0               Blocks: 0          IO Block: 262144 regular 
empty file
Device: 24h/36d Inode: 786439      Links: 1
Access: (4777/-rwsrwxrwx)  Uid: ( 1000/    test)   Gid: ( 1000/    test)
Context: system_u:object_r:nfs_t:s0
Access: 2014-04-18 21:45:32.155805097 +0800
Modify: 2014-04-18 21:45:32.155805097 +0800
Change: 2014-04-18 21:45:32.168806749 +0800
  Birth: -
   File: ‘test’
   Size: 5               Blocks: 8          IO Block: 262144 regular file
Device: 24h/36d Inode: 786439      Links: 1
Access: (0777/-rwxrwxrwx)  Uid: ( 1000/    test)   Gid: ( 1000/    test)
Context: system_u:object_r:nfs_t:s0
Access: 2014-04-18 21:45:32.155805097 +0800
Modify: 2014-04-18 21:45:32.184808783 +0800
Change: 2014-04-18 21:45:32.184808783 +0800
  Birth: -

thanks,
Kinglong Mee

> I don't see an owner check in should_remove_suid.
>
> And I think that an nfsd thread will always have CAP_FSETID set (see
> cap_raise_nfsd_set and the definition of CAP_NFSD_SET), so that
> should_remove_suid() will always return 0.
>
> --b.
>
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>   fs/nfsd/vfs.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 16f0673..19c0931 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -943,7 +943,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh
>> *fhp, struct file *file,
>>   	fsnotify_modify(file);
>>
>>   	/* clear setuid/setgid flag after write */
>> -	if (inode->i_mode & (S_ISUID | S_ISGID))
>> +	if (should_remove_suid(dentry))
>>   		kill_suid(dentry);
>>
>>   	if (stable) {
>> --
>> 1.9.0
>>
>
