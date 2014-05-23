Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f42.google.com ([209.85.219.42]:55614 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbaEWCqa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 22:46:30 -0400
Received: by mail-oa0-f42.google.com with SMTP id j17so4946339oag.15
        for <linux-nfs@vger.kernel.org>; Thu, 22 May 2014 19:46:30 -0700 (PDT)
Message-ID: <537EB673.3050302@gmail.com>
Date: Fri, 23 May 2014 10:46:11 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: Get "device is busy" when umounting nfsv4 file
References: <537EAF05.2020900@gmail.com> <CAHQdGtQh0be=_tByxukQAPG3ZRJJ6UDWgRiH7Q+9Ry__5YxzaA@mail.gmail.com>
In-Reply-To: <CAHQdGtQh0be=_tByxukQAPG3ZRJJ6UDWgRiH7Q+9Ry__5YxzaA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/23/2014 10:18, Trond Myklebust wrote:
> 
> On May 22, 2014 10:14 PM, "Kinglong Mee" <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>> wrote:
>>
>> When using NFSv4 on Fedora 20 with latest kernel (3.15.0-rc6+),
>> I can't umount the mountpoint after only an 'ls' operation.
>>
>> [root@localhost ~]# cat /etc/exports
>> /nfstest        *(rw,no_root_squash,no_subtree_check,insecure)
>> [root@localhost ~]# mount -t nfs 127.0.0.1:/ /mnt/
>> [root@localhost ~]# ls /mnt/
>> nfstest
>> [root@localhost ~]# umount /mnt/
>> umount.nfs4: /mnt: device is busy
> 
> Hi Kinglong
> 
> Nothing springs out to me. Could you please bisect?

Trying it on rhel7 with 3.10.0-121.el7.x86_64, 
also got "device is busy".
[root@localhost ~]# umount /mnt/
umount.nfs4: /mnt: device is busy

Maybe this problem has exist a long time.

thanks,
Kinglong Mee
