From: tvrtko.ursulin@sophos.com
Subject: Strange NFS(D) behaviour
Date: Tue, 7 Dec 2004 16:19:40 +0000
Message-ID: <OF973958E1.9601CF51-ON80256F63.0058704F-80256F63.0059B12C@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	trond.myklebust@fys.uio.no, viro@math.psu.edu
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261852AbULGQTt@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hello to everyone, and apologies to the ones I didn't have to CC!

I am experiencing a strange behaviour in a interaction of kernel 2.6.8.1 
(2.6.9 also tested) and util-linux 2.12c. It is 100% reproducable.

The setup:

Reboot.

start portmapper
start nfsserver (kernel one)

cat /etc/exports
/test   127.0.0.1(rw,all_squash,async)

ls -ld /test
drwxr-xr-x 3 root root 96 2004-12-06 14:59 /test

ls -l /test
total 4
-rw-r--r-- 1 root root 11 2004-12-06 14:59 a
drwxr-xr-x 2 root root 48 2004-12-06 14:59 mnt

cd /test
mount localhost:/test mnt
find
umount mnt
umount: /test/mnt: device is busy
umount: /test/mnt: device is busy
umount -l mnt (ok)
mount localhost:/test mnt
find
umount mnt (ok)

And it is now impossible to get -EBUSY on umount. Also, before the first 
umount -l mnt invocation, it is impossible to un-mount mnt without 
specifying "-l" no matter how long I wait, or how much I try.

I found this strange, the behavior should be consistent, no?
