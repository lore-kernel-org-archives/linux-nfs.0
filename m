Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bluewatersys.com ([202.124.120.130]:48414 "EHLO
	hayes.bluewaternz.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753252Ab1C1Bzq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 21:55:46 -0400
From: Ryan Mallon <ryan@bluewatersys.com>
To: viro@zeniv.linux.org.uk, dchinner@redhat.com, Trond.Myklebust@netapp.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Ryan Mallon <ryan@bluewatersys.com>
Subject: [RFC PATCH 0/2] Introduce unlocked version of igrab 
Date: Mon, 28 Mar 2011 14:55:59 +1300
Message-Id: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect 
inode->i_state with inode->i_lock" introduces a change to igrab to acquire
inode->i_lock. 

This change causes a panic on boot on my ARM EP93xx board when the rootfs
uses NFS. The problem occurs because nfs_inode_add_request acquires
inode->i_lock and then calls igrab, resulting in the following panic:

BUG: spinlock recursion on CPU#0, getty/262
 lock: cc421cb4, .magic: dead4ead, .owner: getty/262, .owner_cpu: 0
[<c0031b0c>] (unwind_backtrace+0x0/0xe4) from [<c015f16c>] (do_raw_spin_lock+0x40/0x13c)
[<c015f16c>] (do_raw_spin_lock+0x40/0x13c) from [<c00a938c>] (igrab+0x14/0x48)
[<c00a938c>] (igrab+0x14/0x48) from [<c01186bc>] (nfs_updatepage+0x2e0/0x524)
[<c01186bc>] (nfs_updatepage+0x2e0/0x524) from [<c010b19c>] (nfs_write_end+0x23c/0x270)
[<c010b19c>] (nfs_write_end+0x23c/0x270) from [<c006b484>] (generic_file_buffered_write+0x180/0x248)
[<c006b484>] (generic_file_buffered_write+0x180/0x248) from [<c006d060>] (__generic_file_aio_write+0x3b8/0x3f4)
[<c006d060>] (__generic_file_aio_write+0x3b8/0x3f4) from [<c006d108>] (generic_file_aio_write+0x6c/0xdc)
[<c006d108>] (generic_file_aio_write+0x6c/0xdc) from [<c010bce0>] (nfs_file_write+0xec/0x178)
[<c010bce0>] (nfs_file_write+0xec/0x178) from [<c00956ac>] (do_sync_write+0xa4/0xe4)
[<c00956ac>] (do_sync_write+0xa4/0xe4) from [<c00960c8>] (vfs_write+0xb4/0x12c)
[<c00960c8>] (vfs_write+0xb4/0x12c) from [<c00961f0>] (sys_write+0x3c/0x68)
[<c00961f0>] (sys_write+0x3c/0x68) from [<c002c8e0>] (ret_fast_syscall+0x0/0x2c)

This series introduces a new function called __igrab, which is an unlocked
version of igrab and modifies nfs_inode_add_request to use the unlocked
version.

Ryan Mallon (2):
  Add unlocked version of igrab.
  Use __igrab instead of igrab in nfs_inode_add_request

 fs/inode.c         |   16 ++++++++++++----
 fs/nfs/write.c     |    2 +-
 include/linux/fs.h |    1 +
 3 files changed, 14 insertions(+), 5 deletions(-)

