Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17743 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdGQJWG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jul 2017 05:22:06 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: i_lock contention during heavy I/O
Date: Mon, 17 Jul 2017 11:22:00 +0200
Message-Id: <2EBEB743-9230-4C7D-9BC5-FA6F58CAF5AB@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I found this in my notes. It gives a flavor of the
kind of lock contention we were discussing last week.

My client is a 12-core dual socket system. Networking
is 56Gbps IB, NFS/RDMA. I'm running some multi-threaded
iozone tests. Here I was mixing buffered and direct I/O
tests, so I can't say for certain if one is worse than
the other.

The output below is the first entry in /proc/lock_stat.

"sb->s_type->i_lock_key" looked like it was related to
the superblock, but looking at the actual code in the
functions named below, this is probably the inode lock.

The max lock holdtime is 82 milliseconds, if I read this
correctly. It's not clear how often that happens, but
that looks pathological.


lock_stat version 0.4
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total   waittime-avg    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total   holdtime-avg
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

               &sb->s_type->i_lock_key#2:      23185746       23275952           0.10       81771.03    27980172.31           1.20       81467297      238209945           0.09       81842.12    80513710.68           0.34
               -------------------------
               &sb->s_type->i_lock_key#2        1453378          [<ffffffffa06c6e49>] nfs_flush_incompatible+0x75/0x1ad [nfs]
               &sb->s_type->i_lock_key#2        4777000          [<ffffffffa06c4ed6>] nfs_lock_and_join_requests+0x68/0x2a3 [nfs]
               &sb->s_type->i_lock_key#2         157315          [<ffffffffa06c72f5>] nfs_updatepage+0x374/0x912 [nfs]
               &sb->s_type->i_lock_key#2        2085447          [<ffffffffa06c74d7>] nfs_updatepage+0x556/0x912 [nfs]
               -------------------------
               &sb->s_type->i_lock_key#2            132          [<ffffffff8123cc2c>] writeback_sb_inodes+0xfb/0x50c
               &sb->s_type->i_lock_key#2        7858928          [<ffffffffa06c4ed6>] nfs_lock_and_join_requests+0x68/0x2a3 [nfs]
               &sb->s_type->i_lock_key#2        1225835          [<ffffffffa06c6e49>] nfs_flush_incompatible+0x75/0x1ad [nfs]
               &sb->s_type->i_lock_key#2         111821          [<ffffffffa06c72f5>] nfs_updatepage+0x374/0x912 [nfs]


--
Chuck Lever



