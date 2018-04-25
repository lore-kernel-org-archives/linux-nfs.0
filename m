Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:22015 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750882AbeDYGCv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2018 02:02:51 -0400
Received: from G08CNEXCHPEKD02.g08.fujitsu.local (unknown [10.167.33.83])
        by cn.fujitsu.com (Postfix) with ESMTP id F03304B3148E
        for <linux-nfs@vger.kernel.org>; Wed, 25 Apr 2018 14:02:45 +0800 (CST)
From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
To: <linux-nfs@vger.kernel.org>
Subject: SGID loss with nfsv3
Message-ID: <f9f2d605-b930-7db8-ad1e-fd189e074e9c@cn.fujitsu.com>
Date: Wed, 25 Apr 2018 14:03:20 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi, folks


I have client and server using nfsv3. The kernels are all 4.16-rc3.
In client I mount a partition or a disk formatted in xfs/ext4 in
/nfstest. It seems there is someting wrong with inheritance of sgid. I
try the following operations in the client.
> [root@localhost ]#id user1
> uid=1003(user1) gid=1006(testgroup1)
groups=1006(testgroup1),1007(testgroup2)
> [root@localhost ]# mount -t nfs -o vers=3 -o noac
192.168.56.9:/data/nfstest /mnt/test/
> [root@localhost ]# cd /mnt/test/
> [root@localhost ]# mkdir mainsub
> [root@localhost ]# setfacl -d -m u:user2:rwx mainsub/
> [root@localhost ]# chown user1:testgroup1 mainsub/
>                  # chmod 2775 mainsub/
> [root@localhost ]# runuser -u user1 -g testgroup1 mkdir mainsub/subdir1
> [root@localhost ]# runuser -u user1 -g testgroup2 mkdir mainsub/subdir2
> [root@localhost ]# ls -l mainsub/
> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir1
> drwxrwxr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir2


The subdir2 losts SGID. But if the same operations are applied in the
xfs or ext4 directedly, the SGID could be interited normally.

> [root@localhost ]# ls -l mainsub/
> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir1
> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir2

Is this a bug of NFSv3?

> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=073931017b49d9458aa351605b43a7e34598caef


Clear SGID bit when setting file permissions

It seems this patch will clear the nfs sgid. Should we keep it?


Xinyu Lu


