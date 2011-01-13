Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:56558 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932498Ab1AMMIm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 07:08:42 -0500
Date: Thu, 13 Jan 2011 12:06:27 +0000
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: NFS root lockups with -next 20110113
Message-ID: <20110113120626.GB30351@opensource.wolfsonmicro.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With -next 20110113 I'm experiencing lockups shortly after userspace
starts when booting with my root filesystem on NFS, log below.  I can
boot into /bin/sh but running real userspace triggers this very easily.
This was introduced sometime this week.

I've not bisected or otherwise investigated much yet, but I do notice
code added recently by Nick in "fs: rcu-walk for path lookup" showing up
in the backtrace so including him in the CCs.

Tail of the console log:

INIT: version 2.86 booting
[   15.250000] BUG: spinlock recursion on CPU#0, rc/1151
[   15.250000]  lock: c74ad678, .magic: dead4ead, .owner: rc/1151, .owner_cpu: 0
[   15.260000] [<c0035118>] (unwind_backtrace+0x0/0xe4) from [<c0190454>] (do_raw_spin_lock+0x48/0x148)
[   15.260000] [<c0190454>] (do_raw_spin_lock+0x48/0x148) from [<c00c89f0>] (nameidata_dentry_drop_rcu+0x84/0x180)
[   15.270000] [<c00c89f0>] (nameidata_dentry_drop_rcu+0x84/0x180) from [<c00c8b1c>] (d_revalidate+0x30/0x58)
[   15.280000] [<c00c8b1c>] (d_revalidate+0x30/0x58) from [<c00cb82c>] (link_path_walk+0xad8/0xb00)
[   15.290000] [<c00cb82c>] (link_path_walk+0xad8/0xb00) from [<c00cba4c>] (do_path_lookup+0x44/0xcc)
[   15.300000] [<c00cba4c>] (do_path_lookup+0x44/0xcc) from [<c00cc3f4>] (user_path_at+0x58/0x90)
[   15.310000] [<c00cc3f4>] (user_path_at+0x58/0x90) from [<c00c4210>] (vfs_fstatat+0x28/0x54)
[   15.320000] [<c00c4210>] (vfs_fstatat+0x28/0x54) from [<c00c431c>] (sys_stat64+0x14/0x34)
[   15.330000] [<c00c431c>] (sys_stat64+0x14/0x34) from [<c002f4e0>] (ret_fast_syscall+0x0/0x30)
[   25.830000] BUG: spinlock lockup on CPU#0, rc/1151, c74ad678
[   25.830000] [<c0035118>] (unwind_backtrace+0x0/0xe4) from [<c0190518>] (do_raw_spin_lock+0x10c/0x148)
[   25.840000] [<c0190518>] (do_raw_spin_lock+0x10c/0x148) from [<c00c89f0>] (nameidata_dentry_drop_rcu+0x84/0x180)
[   25.850000] [<c00c89f0>] (nameidata_dentry_drop_rcu+0x84/0x180) from [<c00c8b1c>] (d_revalidate+0x30/0x58)
[   25.860000] [<c00c8b1c>] (d_revalidate+0x30/0x58) from [<c00cb82c>] (link_path_walk+0xad8/0xb00)
[   25.870000] [<c00cb82c>] (link_path_walk+0xad8/0xb00) from [<c00cba4c>] (do_path_lookup+0x44/0xcc)
[   25.870000] [<c00cba4c>] (do_path_lookup+0x44/0xcc) from [<c00cc3f4>] (user_path_at+0x58/0x90)
[   25.880000] [<c00cc3f4>] (user_path_at+0x58/0x90) from [<c00c4210>] (vfs_fstatat+0x28/0x54)
[   25.890000] [<c00c4210>] (vfs_fstatat+0x28/0x54) from [<c00c431c>] (sys_stat64+0x14/0x34)
[   25.900000] [<c00c431c>] (sys_stat64+0x14/0x34) from [<c002f4e0>] (ret_fast_syscall+0x0/0x30)

