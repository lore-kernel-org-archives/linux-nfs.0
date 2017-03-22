Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:27586 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760033AbdCVOiI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 10:38:08 -0400
Received: from HHMAIL01.hh.imgtec.org (unknown [10.100.10.19])
        by Forcepoint Email with ESMTPS id C8FEEFD299186
        for <linux-nfs@vger.kernel.org>; Wed, 22 Mar 2017 14:37:55 +0000 (GMT)
To: <linux-nfs@vger.kernel.org>
From: Marcin Nowakowski <marcin.nowakowski@imgtec.com>
Subject: NFS invalid refcount warnings
Message-ID: <95b51cbe-438c-e4a6-4a3f-37bb24fbcf2c@imgtec.com>
Date: Wed, 22 Mar 2017 15:37:58 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm trying to debug an issue I'm seeing on my test machine that occurs 
quite reliably, although I'm unfortunately unable to descibe any 
specific steps to reproduce the issue.

The system is running kernel 4.10.4
The rootfs is on an NFS share mounted with the following opts:

<***> on / type nfs 
(rw,relatime,vers=3,rsize=4096,wsize=4096,namlen=255,hard,nolock,
proto=udp,timeo=10,retrans=3,sec=sys,mountaddr=<***>,
mountvers=3,mountproto=udp,local_lock=all,addr=<***>)

The system running linux is an FPGA so it is relatively slow and it 
performs various stability tests running a lot of applications in 
parallel, which makes it particularly slow due to heavy load ;)

It usually takes 30 to 60 minutes for the following error to occur:

warning in nfs_scan_commit_list::kref_get()
[ 3671.685359] [<80453ae4>] nfs_scan_commit_list+0x228/0x248
[ 3671.685359] [<80453ba0>] nfs_scan_commit+0x9c/0x118
[ 3671.685359] [<80453ef8>] nfs_commit_inode+0xf8/0x17c
[ 3671.752838] [<80454300>] nfs_wb_all+0x140/0x278
[ 3671.752838] [<80443390>] nfs_setattr+0x364/0x47c
[ 3671.752838] [<8032ae58>] notify_change+0x1c0/0x4c4
[ 3671.752838] [<80349ab0>] utimes_common+0xc8/0x194
[ 3671.752838] [<80349cd8>] do_utimes+0x15c/0x188
[ 3671.752838] [<80349e9c>] SyS_utimensat+0xa8/0xf8
[ 3671.752838] [<8011a5d8>] syscall_common+0x34/0x58

After the first error, there are usually more that follow, sometimes 
with the same call stack, sometimes different, eg.
[ 3674.001118] [<80453ae4>] nfs_scan_commit_list+0x228/0x248
[ 3674.001118] [<80453ba0>] nfs_scan_commit+0x9c/0x118
[ 3674.001118] [<80453ef8>] nfs_commit_inode+0xf8/0x17c
[ 3674.001118] [<80454198>] nfs_write_inode+0xa4/0xcc
[ 3674.001118] [<80342da4>] __writeback_single_inode+0x360/0x6e0
[ 3674.001118] [<80343934>] writeback_sb_inodes+0x2b8/0x514
[ 3674.001118] [<80343c50>] __writeback_inodes_wb+0xc0/0x114
[ 3674.001118] [<80343fd4>] wb_writeback+0x330/0x494
[ 3674.001118] [<80344eb0>] wb_workfn+0x2cc/0x77c
[ 3674.001118] [<80179154>] process_one_work+0x20c/0x69c
[ 3674.001118] [<80179760>] worker_thread+0x17c/0x530
[ 3674.001118] [<8018077c>] kthread+0x164/0x194
[ 3674.001118] [<80105dd4>] ret_from_kernel_thread+0x14/0x1c

A few of those warnings are usually followed by a linked-list debug 
warnings or dereferences of NULL pointers in  nfs_inode_remove_request 
(req->wb_context is null)

I'd appreciate any help with debugging this issue, as I'm struggling to 
get a better understanding of what may be happening (obviously this 
looks like it might be caused by incorrect locking somewhere, but as I'm 
not familiar with the nfs code it's not easy to understand how it works, 
especially given its async structure)


thanks,
Marcin

