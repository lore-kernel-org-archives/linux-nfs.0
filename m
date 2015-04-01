Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:40822 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbbDAJzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2015 05:55:10 -0400
Message-ID: <551BC077.1030402@free.fr>
Date: Wed, 01 Apr 2015 11:55:03 +0200
From: Mason <slash.tmp@free.fr>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: nfsroot protocol version
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everyone,

My embedded system is supposed to mount the rootfs via NFS.
https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt

So I set these options in my kernel .config

CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_ROOT_NFS=y
CONFIG_NFS_V4=y

But it didn't work, the system would panic after a long time out
(around 95 seconds)

[   98.567037] VFS: Unable to mount root fs via NFS, trying floppy.
[   98.573238] Freeing unused kernel memory: 144K (c0332000 - c0356000)
[   98.579698] Kernel panic - not syncing: No working init found.
	Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.

I then enabled NFSv2 and NFSv3, and then it worked.

When I was debugging the problem, I ran across NFS_DEF_OPTIONS
in fs/nfs/nfsroot.c

#define NFS_DEF_OPTIONS		"vers=2,udp,rsize=4096,wsize=4096"

IIUC, we are explicitly requesting NFSv2?

Would that explain why it fails when NFSv2 support is not compiled in?

Would it make sense to use version 3?
(So NFSv2 is not needed just to load the rootfs.)

Regards.
