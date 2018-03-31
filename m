Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:62442 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751404AbeCaFfY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Mar 2018 01:35:24 -0400
Received: from G08CNEXCHPEKD02.g08.fujitsu.local (unknown [10.167.33.83])
        by cn.fujitsu.com (Postfix) with ESMTP id 29FAE48AE76D
        for <linux-nfs@vger.kernel.org>; Sat, 31 Mar 2018 13:35:23 +0800 (CST)
From: sunlianwen <sunlw.fnst@cn.fujitsu.com>
Subject: [BUG] nfsv3 mkdir miss SGID
To: <linux-nfs@vger.kernel.org>
Message-ID: <863682d4-75ee-28ed-664b-d62cb3f01d01@cn.fujitsu.com>
Date: Sat, 31 Mar 2018 13:35:26 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi ,

I report a bug about nfsv3 , the reproducer is below:

----------                       ---------
|         |-eth0 -------   eth0-|         |
|  host1  |                     |  host2  |
| (Client)|                     | (Server)|
|         |                     |         |
----------                       ----------
Host1 : eth0 192.168.56.7/24
Host2 : eth0 192.168.56.9/24


Host2:
# mkdir –m 777 /nfstest
# cat /etc/exports
/nfstest      *(rw,insecure,no_subtree_check,no_root_squash,fsid=1)
# systemctl restart rpcbind
# systenctl restart nfs

Host1:
# mkdir –m 777 /mnt/test
# mount -t nfs -o vers=3 -o noac 192.168.56.9:/nfstest/mnt/test/
# useradd user1
# useradd user2
# groupadd testgroup1
# groupadd testgroup2
# usermod –G testgroup1,testgroup2 user1
# usermod –g testgroup1 user1
# id user1
uid=1001(user1) gid=1002(testgroup1) 
groups=1002(testgroup1),1003(testgroup2)
# id user2
uid=1003(user2) gid=1007(user2) groups=1007(user2)
# cd /mnt/test/
# mkdir mainsub
# setfacl -d -m u:user2:rwx mainsub/
# chown user1:testgroup1 mainsub/
# chmod 2755 mainsub/
# runuser -u user1 -g testgroup1 mkdir mainsub/subdir1
# runuser -u user1 -g testgroup2 mkdir mainsub/subdir2
# ls -l mainsub/
drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir1
drwxrwxr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir2

the "drwxrwxr-x+ 2" on subdir2 do not have the flage of "s" which mean 
the "SGID" is miss.


Thanks,
Lianwen Sun





