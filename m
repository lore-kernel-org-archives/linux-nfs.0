Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753537Ab0D0UVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Apr 2010 16:21:35 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3RKLZAS008161
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 16:21:35 -0400
Date: Tue, 27 Apr 2010 16:21:33 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: branto@redhat.com
Subject: should unstable pages be committed on close() ?
Message-ID: <20100427162133.227cc6dd@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've got a bug report about a possible regression from one of our QA
people. They were testing some of the recent write_inode/COMMIT changes
with this script:

----------------[snip]-----------------
#! /usr/bin/env bash
servers="server:/export"
nfsstat -c -3

for SRV in $servers
do
 mount $SRV /media -o nfsvers=3
 rm -f /media/tmp.file
 time dd if=/dev/zero bs=1024k count=2000 of=/media/tmp.file
 umount /media
 nfsstat -c -3
done
----------------[snip]-----------------

The changes have definitely reduced the number of commit calls, but
frequently we see these errors pop and the filesystem isn't unmounted.

umount.nfs: /media: device is busy
umount.nfs: /media: device is busy

...if I call /bin/sync just before the umount, then it works fine. I
added a cat /proc/meminfo just before the umount and see this:

MemTotal:         980376 kB
MemFree:           12364 kB
Buffers:            3804 kB
Cached:           803584 kB
SwapCached:            0 kB
Active:           172376 kB
Inactive:         650252 kB
Active(anon):       5592 kB
Inactive(anon):     9808 kB
Active(file):     166784 kB
Inactive(file):   640444 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       2064376 kB
SwapFree:        2064376 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         15240 kB
Mapped:             9008 kB
Shmem:               160 kB
Slab:             123572 kB
SReclaimable:      28096 kB
SUnreclaim:        95476 kB
KernelStack:        1016 kB
PageTables:         2428 kB
NFS_Unstable:      90384 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     2554564 kB
Committed_AS:      80836 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       41980 kB
VmallocChunk:   34359685244 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        8128 kB
DirectMap2M:     1040384 kB

...note that Dirty and Writeback are 0, but NFS_Unstable is still at
90M or so. So, I think the problem is likely that the unstable pages
are preventing the umount.

I've not done much investigation beyond this yet, but figured I'd toss
the bug report out here in case anyone has thoughts on the cause and
how it should be fixed. I can reproduce this fairly easily on my
virtualized test rig in case anyone has patches that they want me to
test.

-- 
Jeff Layton <jlayton@redhat.com>
