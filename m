Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f178.google.com ([209.85.214.178]:41867 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbaEWCwR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 22:52:17 -0400
Received: by mail-ob0-f178.google.com with SMTP id va2so4779589obc.37
        for <linux-nfs@vger.kernel.org>; Thu, 22 May 2014 19:52:16 -0700 (PDT)
Message-ID: <537EB7CE.4090600@gmail.com>
Date: Fri, 23 May 2014 10:51:58 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: Get "device is busy" when umounting nfsv4 file
References: <537EAF05.2020900@gmail.com> <CAHQdGtQh0be=_tByxukQAPG3ZRJJ6UDWgRiH7Q+9Ry__5YxzaA@mail.gmail.com> <537EB673.3050302@gmail.com>
In-Reply-To: <537EB673.3050302@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/23/2014 10:46, Kinglong Mee wrote:
> On 5/23/2014 10:18, Trond Myklebust wrote:
>>
>> On May 22, 2014 10:14 PM, "Kinglong Mee" <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>> wrote:
>>>
>>> When using NFSv4 on Fedora 20 with latest kernel (3.15.0-rc6+),
>>> I can't umount the mountpoint after only an 'ls' operation.
>>>
>>> [root@localhost ~]# cat /etc/exports
>>> /nfstest        *(rw,no_root_squash,no_subtree_check,insecure)
>>> [root@localhost ~]# mount -t nfs 127.0.0.1:/ /mnt/
>>> [root@localhost ~]# ls /mnt/
>>> nfstest
>>> [root@localhost ~]# umount /mnt/
>>> umount.nfs4: /mnt: device is busy
>>
>> Hi Kinglong
>>
>> Nothing springs out to me. Could you please bisect?
> 
> Trying it on rhel7 with 3.10.0-121.el7.x86_64, 
> also got "device is busy".
> [root@localhost ~]# umount /mnt/
> umount.nfs4: /mnt: device is busy
> 
> Maybe this problem has exist a long time.

I find thant -EBUSY errno is return at,

"fs/namespace.c"
1284 static int do_umount(struct mount *mnt, int flags)
1285 {
1286         struct super_block *sb = mnt->mnt.mnt_sb;
......
1358         if (flags & MNT_DETACH) {
1359                 if (!list_empty(&mnt->mnt_list))
1360                         umount_tree(mnt, 2);
1361                 retval = 0;
1362         } else {
1363                 shrink_submounts(mnt);
1364                 retval = -EBUSY;
1365                 if (!propagate_mount_busy(mnt, 2)) {

propagate_mount_busy return 1 for mnt's refcnt is 3 (bigger than 2).

1366                         if (!list_empty(&mnt->mnt_list))
1367                                 umount_tree(mnt, 1);
1368                         retval = 0;
1369                 }
1370         }

thanks,
Kinglong Mee
