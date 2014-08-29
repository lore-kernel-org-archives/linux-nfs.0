Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:45475 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbaH2Q1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2014 12:27:54 -0400
Received: by mail-vc0-f176.google.com with SMTP id ik5so2710760vcb.21
        for <linux-nfs@vger.kernel.org>; Fri, 29 Aug 2014 09:27:53 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 29 Aug 2014 12:27:53 -0400
Message-ID: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
Subject: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE automounted partitions
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tao Peng <tao.peng@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Al,

Our internal testing shows that commit aba809cf0944 (namespace.c: get
rid of mnt_ghosts) appears to break the NFS automounter functionality.
When unmounting, the user now gets a permanent -EBUSY, presumably due
to a refcounting issue with the patch.

The reproducer is as follows:

On the server, set up an export of the form:

% showmount -e 192.168.214.128
Export list for 192.168.214.128:
/export *

On the client:

[fedora19@~]$sudo mount 192.168.214.128:/ /mnt/
[fedora19@~]$df
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   38G   15G   24G  38% /
devtmpfs                 229M     0  229M   0% /dev
tmpfs                    242M   80K  242M   1% /dev/shm
tmpfs                    242M  1.5M  241M   1% /run
tmpfs                    242M     0  242M   0% /sys/fs/cgroup
tmpfs                    242M  4.0K  242M   1% /tmp
/dev/sda1                1.5G  248M  1.3G  17% /boot
192.168.214.128:/         28G   25G  1.1G  96% /mnt
[fedora19@~]$ls /mnt/export/
[fedora19@~]$df
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   38G   15G   24G  38% /
devtmpfs                 229M     0  229M   0% /dev
tmpfs                    242M   80K  242M   1% /dev/shm
tmpfs                    242M  1.5M  241M   1% /run
tmpfs                    242M     0  242M   0% /sys/fs/cgroup
tmpfs                    242M  4.0K  242M   1% /tmp
/dev/sda1                1.5G  248M  1.3G  17% /boot
192.168.214.128:/         28G   25G  1.1G  96% /mnt
192.168.214.128:/export   28G   25G  1.1G  96% /mnt/export
[fedora19@~]$sudo umount /mnt
umount.nfs4: /mnt: device is busy
[fedora19@~]$df
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   38G   15G   24G  38% /
devtmpfs                 229M     0  229M   0% /dev
tmpfs                    242M   80K  242M   1% /dev/shm
tmpfs                    242M  1.5M  241M   1% /run
tmpfs                    242M     0  242M   0% /sys/fs/cgroup
tmpfs                    242M  4.0K  242M   1% /tmp
/dev/sda1                1.5G  248M  1.3G  17% /boot
192.168.214.128:/         28G   25G  1.1G  96% /mnt

Reverting commit aba809cf0944 fixes the problem for us on a 3.14.15
client kernel.
(Thanks to Tao Peng for providing the above reproducer and for bisecting.)

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
