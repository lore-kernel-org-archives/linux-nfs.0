Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:2567 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751042AbeCGHLX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 02:11:23 -0500
Received: from G08CNEXCHPEKD02.g08.fujitsu.local (unknown [10.167.33.83])
        by cn.fujitsu.com (Postfix) with ESMTP id 4D2CA48AE761
        for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2018 15:11:19 +0800 (CST)
Subject: Inheritance of sgid in nfsv3 (supplement)
References: <e5575bea-dd50-36f2-271e-46404dc0cc7d@cn.fujitsu.com>
To: <linux-nfs@vger.kernel.org>
From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
Message-ID: <95ae6cdf-4b42-3da5-eab8-6e458db84b07@cn.fujitsu.com>
Date: Wed, 7 Mar 2018 15:11:24 +0800
MIME-Version: 1.0
In-Reply-To: <e5575bea-dd50-36f2-271e-46404dc0cc7d@cn.fujitsu.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi, folks


I have client and server using nfsv3. The kernels are all 4.16-rc3.
In client I mount a partition or a disk formatted in xfs/ext4 in
/nfstest. It seems there is someting wrong with inheritance of sgid. I
try the following operations in the client.
> [root@localhost ]#id user1
> uid=1003(user1) gid=1006(testgroup1) groups=1006(testgroup1),1007(testgroup2)
> [root@localhost ]# mount -t nfs -o vers=3 -o noac 192.168.56.9:/data/nfstest /mnt/test/ 
> [root@localhost ]# cd /mnt/test/
> [root@localhost ]# mkdir mainsub
> [root@localhost ]# setfacl -d -m u:user2:rwx mainsub/
> [root@localhost ]# chown user1:testgroup1 mainsub/
      (supplement) # chmod 2775 mainsub/
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


Lu Xinyu


