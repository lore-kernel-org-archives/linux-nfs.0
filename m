Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f52.google.com ([209.85.160.52]:61898 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbaDMOyR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 10:54:17 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so7252471pbb.25
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 07:54:16 -0700 (PDT)
Message-ID: <534AA4FD.3060202@gmail.com>
Date: Sun, 13 Apr 2014 22:53:49 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: add FATTR4_WORD1_MODE flags for cache_consistency_bitmask
References: <534A8CEF.6000609@gmail.com> <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>
In-Reply-To: <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



ÓÚ 2014/4/13 22:28, Trond Myklebust Ð´µÀ:
> 
> On Apr 13, 2014, at 9:11, Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> After writing data at NFS client, file's access mode is inconsistent
>> with server.
>> Because WRITE proceduce changes the S_ISUID and S_ISGID bits,
>> but client don't get it.
>>
>> #touch hello; chmod 06777 hello; stat hello;
>>   File: ¡®hello¡¯
>>   Size: 0               Blocks: 0          IO Block: 262144 regular
>> empty file
>> Device: 24h/36d Inode: 786434      Links: 1
>> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>> Context: system_u:object_r:nfs_t:s0
>> Access: 2014-04-13 21:00:44.996908708 +0800
>> Modify: 2014-04-13 21:00:44.996908708 +0800
>> Change: 2014-04-13 21:00:45.033908705 +0800
>> Birth: -
>>
>> #echo 12324 > hello; stat hello; stat /nfstest/hello
>>   File: ¡®hello¡¯
>>   Size: 6               Blocks: 0          IO Block: 262144 regular file
>> Device: 24h/36d Inode: 786434      Links: 1
>> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>>          ^^^^^ it should be 0777
>> Context: system_u:object_r:nfs_t:s0
>> Access: 2014-04-13 21:00:44.996908708 +0800
>> Modify: 2014-04-13 21:00:45.061908703 +0800
>> Change: 2014-04-13 21:00:45.061908703 +0800
>> Birth: -
>>   File: ¡®/nfstest/hello¡¯
>>   Size: 6               Blocks: 8          IO Block: 4096   regular file
>> Device: 803h/2051d      Inode: 786434      Links: 1
>> Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>>          ^^^^^ bits on the server
>> Context: system_u:object_r:default_t:s0
>> Access: 2014-04-13 21:00:44.996908708 +0800
>> Modify: 2014-04-13 21:00:45.061908703 +0800
>> Change: 2014-04-13 21:00:45.061908703 +0800
>> Birth: -
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>> fs/nfs/nfs4proc.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 397be39..f234af7 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2819,7 +2819,7 @@ static int _nfs4_server_capabilities(struct
>> nfs_server *server, struct nfs_fh *f
>>
>> 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask,
>> sizeof(server->cache_consistency_bitmask));
>> 		server->cache_consistency_bitmask[0] &=
>> FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
>> -		server->cache_consistency_bitmask[1] &=
>> FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
>> +		server->cache_consistency_bitmask[1] &=
>> FATTR4_WORD1_MODE|FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
>> 		server->cache_consistency_bitmask[2] = 0;
>> 		server->acl_bitmask = res.acl_bitmask;
>> 		server->fh_expire_type = res.fh_expire_type;
>> -- 
>> 1.9.0
>>
> 
> Instead of requesting a new attribute on each and every operation just in order to deal with an extremely rare corner case, is there any reason why we can¡¯t just do this by checking should_remove_suid(), clearing the mode bits ourselves, and then marking the attributes for revalidation?

Right now, the suid/sgid should be cleared in nfs_setattr,
 485 int
 486 nfs_setattr(struct dentry *dentry, struct iattr *attr)
 487 {
 ... ...
 494         /* skip mode change if it's just for clearing setuid/setgid */
 495         if (attr->ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
 496                 attr->ia_valid &= ~ATTR_MODE;
 497

but, NFS client can't pass ATTR_KILL_SUID/SGID to NFS server,
NFS server just kill those bits in nfsd_vfs_write,
 860 static void kill_suid(struct dentry *dentry)
 861 {
 862         struct iattr    ia;
 863         ia.ia_valid = ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
 864
 865         mutex_lock(&dentry->d_inode->i_mutex);
 866         /*
 867          * Note we call this on write, so notify_change will not
 868          * encounter any conflicting delegations:
 869          */
 870         notify_change(dentry, &ia, NULL);
 871         mutex_unlock(&dentry->d_inode->i_mutex);
 872 }
 ... ...
 911 static __be32
 912 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct
file *file,
 913                                 loff_t offset, struct kvec *vec,
int vlen,
 914                                 unsigned long *cnt, int *stablep)
 915 {
 ... ...
 945         /* clear setuid/setgid flag after write */
 946         if (inode->i_mode & (S_ISUID | S_ISGID))
 947                 kill_suid(dentry);

IMO, client shoulds get all metadatas from server, so, adds the flag.
I think should_remove_suid() should be called by nfsd, not NFS client.

thanks,
Kinglong Mee
