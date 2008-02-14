From: "Font Bella" <fontbella@gmail.com>
Subject: Performance question
Date: Thu, 14 Feb 2008 16:40:53 +0100
Message-ID: <90d010000802140740y3ff2706ybc169728fbafbfb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:65158 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758924AbYBNPk6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 10:40:58 -0500
Received: by fk-out-0910.google.com with SMTP id z23so386855fkz.5
        for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 07:40:54 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

some of our apps are experiencing slow nfs performance in our new cluster, in
comparison with the old one. The nfs setups for both clusters are very
similar, and we are wondering what's going on. The details of both setups are
given below for reference.

The problem seems to occur with apps that do heavy i/o, creating, writing,
reading, and deleting many files. However, writing or reading a large file
(as measure with `time dd if=/dev/zero of=2gbfile bs=1024 count=2000`) is not
slow.

We have performed some tests with the disk benchmark 'dbench', which reports
i/o performance of 60 Mb/sec in the old cluster down to about 6Mb/sec in the
new one.

After noticing this problem, we tried the user-mode nfs server instead of the
kernel-mode server, and just installing the user-mode server helped improving
throughput up to 12 Mb/sec, but still far away from the good old 60 Mb/sec.

After going through the "Optimizing NFS performance" section of the
NFS-Howto and tweaking the rsize,wsize parameters (the optimal seems to be
2048, which seems kind of weird to me, specially compared to the 8192 used in
the old cluster), throughput increased to 21 Mb/sec, but is still too far
from the old 60Mb/sec.

We are stuck at this point. Any help/comment/suggestion will be greatly
appreciated.
/P

**************************** OLD CLUSTER *****************************

SATA disks.

Filesystem: ext3.

* the version of nfs-utils you are using: I don't know. It's the most
  recent version in debian sarge (oldstable).

user-mode nfs server.

nfs version 2, as reported with rpcinfo.

* the version of the kernel and any non-stock applied kernels: 2.6.12
* the distribution of linux you are using: Debian sarge x386 on Intel Xeon
  processors.
* the version(s) of other operating systems involved: no other OS.

It is also useful to know the networking configuration connecting the hosts:
Typical beowulf setup, with all servers connected to a switch, 1Gb network.

/etc/exports:

/srv/homes      192.168.1.0/255.255.255.0 (rw,no_root_squash)

/etc/fstab:

server:/srv/homes/user /mnt/user nfs rw,hard,intr,rsize=8192,wsize=8192 0 0

**************************** NEW CLUSTER *****************************

SAS 10k disks.

Filesystem: ext3 over LVM.

* the version of nfs-utils you are using: I don't know. It's the most
  recent version in debian etch (stable).

kernel-mode nfs server.

nfs version 2, as reported with rpcinfo.

* the version of the kernel and any non-stock applied kernels: 2.6.18-5-amd64
* the distribution of linux you are using: Debian etch AMD64 on Intel Xeon
  processors.
* the version(s) of other operating systems involved: no other OS.

It is also useful to know the networking configuration connecting the hosts:
Typical beowulf setup, with all servers connected to a switch, 1Gb network.

/etc/exports:

/srv/homes      192.168.1.0/255.255.255.0 (no_root_squash)

mount options:

rsize=8192,wsize=8192
