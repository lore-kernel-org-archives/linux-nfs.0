Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33656 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbCXMxU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 08:53:20 -0400
Message-ID: <55115E3C.2030104@m4x.org>
Date: Tue, 24 Mar 2015 20:53:16 +0800
From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
MIME-Version: 1.0
To: Li RongQing <roy.qing.li@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
CC: linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: nfs: wrong function to increment NFSIOS_READPAGES/WRITEPAGES stat
 counters?
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Since commit 5a254d08b086 ("nfs: replace nfs_add_stats with
nfs_inc_stats when add one") [1], nfs_readpage and nfs_do_writepage  use
nfs_inc_stats to increment NFSIOS_READPAGES and NFSIOS_WRITEPAGES
instead of nfs_add_stats.

However nfs_inc_stats is not similar as nfs_add_stats with parameter 1
because these functions work on distinct stats:
nfs_inc_stats increments stats from "enum nfs_stat_eventcounters" (in
server->io_stats->events) and nfs_add_stats those from "enum
nfs_stat_bytecounters" (in server->io_stats->bytes), according to their
implementations in fs/nfs/iostat.h [2].

If I understand the code correctly, "nfs_inc_stats(inode,
NFSIOS_READPAGES);" is in fact executed as "nfs_inc_stats(inode,
NFSIOS_VFSACCESS);" and "nfs_inc_stats(inode, NFSIOS_WRITEPAGES);" as
"nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);".

As this looks like a bug to me, I am reporting it in hope it could be
fixed, for example by reverting 5a254d08b086.  Of course, I may be
wrong, in which case an explanation about what I missed in my analysis
would be appreciated.


By the way, I found this while trying to compile LLVMLinux on current
master branch of Linux.  clang reported the following warnings:

fs/nfs/read.c:287:23: warning: implicit conversion from enumeration type
'enum nfs_stat_bytecounters' to different enumeration type 'enum
nfs_stat_eventcounters' [-Wenum-conversion]
            nfs_inc_stats(inode, NFSIOS_READPAGES);
            ~~~~~~~~~~~~~        ^~~~~~~~~~~~~~~~

fs/nfs/write.c:583:23: warning: implicit conversion from enumeration
type 'enum nfs_stat_bytecounters' to different enumeration type 'enum
nfs_stat_eventcounters' [-Wenum-conversion]
            nfs_inc_stats(inode, NFSIOS_WRITEPAGES);
            ~~~~~~~~~~~~~        ^~~~~~~~~~~~~~~~~

Thanks,

Nicolas

[1]
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5a254d08b086d80cbead2ebcee6d2a4b3a15587a
[2]
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/nfs/iostat.h?id=90a5a895cc8b284ac522757a01de15e36710c2b9
