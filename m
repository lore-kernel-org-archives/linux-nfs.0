Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:20684 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751525AbeCMGUj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 02:20:39 -0400
Subject: Fwd: Crash of Nfstest_Delegation
References: <b758807a-1e5b-44ff-a3b3-4029e67f7d98@cn.fujitsu.com>
To: <mora@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
Message-ID: <86328fc7-2441-39cf-80e6-9e965fa85386@cn.fujitsu.com>
Date: Tue, 13 Mar 2018 14:20:42 +0800
MIME-Version: 1.0
In-Reply-To: <b758807a-1e5b-44ff-a3b3-4029e67f7d98@cn.fujitsu.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Jorge

  Maybe there was something wrong with my email client and the last mail
got lost.
  I ran the nfstest-2.1.5 on RHEL7.5beta with kernel
3.10. It crashed at delegation_recall04 and all the
following tests were skipped.

>   DBG3: 23:00:35.812283 - Open file /mnt/t/nfstest_delegation_20180301225932_f_1 so open owner sticks around
>     DBG3: 23:00:35.832005 - Open file for WRITE [/mnt/t/nfstest_delegation_20180301225932_f_7]
>     DBG3: 23:00:35.835889 - Lock file (F_SETLKW) start=0 len=0
>     DBG2: 23:00:35.939107 - Write same file from another client to recall delegation [/mnt/t/nfstest_delegation_20180301225932_f_7]
>     FAIL: Traceback (most recent call last):
>             File "./nfstest_delegation", line 708, in <module>
>               x.run_tests()
>             File "/home/test_admin/NFStest-2.1.5/nfstest/test_util.py", line 913, in run_tests
>               getattr(self, testmethod)(**kwargs)
>             File "./nfstest_delegation", line 674, in recall04_test
>               self.recall_deleg_test(OPEN_DELEGATE_WRITE, lock=True)
>             File "./nfstest_delegation", line 502, in recall_deleg_test
>               os.close(fd)
>           OSError: [Errno 5] Input/output error
>           
>     DBG3: 23:00:36.282999 - Sync all buffers to disk
>     DBG2: 23:00:37.290874 - Unmount volume: ssh -t -t 192.168.56.8 "/usr/bin/sudo umount -f /mnt/t"
>     TIME: 4.690745s
> 
>     DBG7: 23:00:37.534359 - CLEANUP starts
>     DBG3: 23:00:37.534555 -     Stop remote procedure server at 192.168.56.8
>     DBG5: 23:00:37.541372 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_7]
>     DBG5: 23:00:37.544663 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_6]
>     DBG5: 23:00:37.548944 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_5]
>     DBG5: 23:00:37.552021 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_4]
>     DBG5: 23:00:37.554800 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_3]
>     DBG5: 23:00:37.557419 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_2]
>     DBG5: 23:00:37.559556 -     Removing file [/mnt/t/nfstest_delegation_20180301225932_f_1]
>     DBG3: 23:00:37.566209 - Sync all buffers to disk
>     DBG2: 23:00:38.582031 - Unmount volume: /usr/bin/sudo umount -f /mnt/t
>     DBG2: 23:00:38.630358 - umount.nfs4: /mnt/t: device is busy
>           
>     DBG2: 23:00:39.632131 - Unmount volume: /usr/bin/sudo umount -f /mnt/t
>     DBG2: 23:00:39.680915 - umount.nfs4: /mnt/t: device is busy
>           
>     DBG2: 23:00:40.682569 - Unmount volume: /usr/bin/sudo umount -f /mnt/t
>     DBG2: 23:00:40.730187 - umount.nfs4: /mnt/t: device is busy
>           
>     DBG2: 23:00:41.731738 - Unmount volume: /usr/bin/sudo umount -f /mnt/t
>     DBG2: 23:00:41.757786 - umount.nfs4: /mnt/t: device is busy
>           
>     DBG2: 23:00:42.759246 - Unmount volume: /usr/bin/sudo umount -f /mnt/t
>     DBG2: 23:00:42.784288 - umount.nfs4: /mnt/t: device is busy
>           
>     DBG7: 23:00:42.784526 - CLEANUP done
>     TIME: 5.258319s

It seems recall06 and recall10 also have this problem.
Server's /etc/exports:
> /nfsroot      *(rw,insecure,no_subtree_check,no_root_squash,fsid=1

And the file system is xfs. Should the nfstest_delegation be corrected?

Thanks!
Lu Xinyu


