Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bluewatersys.com ([202.124.120.130]:45037 "EHLO
	hayes.bluewaternz.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750788Ab1C1FDj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 01:03:39 -0400
Message-ID: <4D9016B7.1080505@bluewatersys.com>
Date: Mon, 28 Mar 2011 18:03:51 +1300
From: Ryan Mallon <ryan@bluewatersys.com>
To: Dave Chinner <david@fromorbit.com>, sage@newdream.net
CC: viro@zeniv.linux.org.uk, dchinner@redhat.com, Trond.Myklebust@netapp.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [RFC PATCH 0/2] Introduce unlocked version of igrab
References: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com> <20110328044334.GA1022@dastard> <4D9012C5.8070401@bluewatersys.com>
In-Reply-To: <4D9012C5.8070401@bluewatersys.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/28/2011 05:47 PM, Ryan Mallon wrote:
> On 03/28/2011 05:43 PM, Dave Chinner wrote:
>> On Mon, Mar 28, 2011 at 02:55:59PM +1300, Ryan Mallon wrote:
>>> Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect 
>>> inode->i_state with inode->i_lock" introduces a change to igrab to acquire
>>> inode->i_lock. 
>>>
>>> This change causes a panic on boot on my ARM EP93xx board when the rootfs
>>> uses NFS. The problem occurs because nfs_inode_add_request acquires
>>> inode->i_lock and then calls igrab, resulting in the following panic:
>>>
>>> BUG: spinlock recursion on CPU#0, getty/262
>>>  lock: cc421cb4, .magic: dead4ead, .owner: getty/262, .owner_cpu: 0
>>> [<c0031b0c>] (unwind_backtrace+0x0/0xe4) from [<c015f16c>] (do_raw_spin_lock+0x40/0x13c)
>>> [<c015f16c>] (do_raw_spin_lock+0x40/0x13c) from [<c00a938c>] (igrab+0x14/0x48)
>>> [<c00a938c>] (igrab+0x14/0x48) from [<c01186bc>] (nfs_updatepage+0x2e0/0x524)
>>> [<c01186bc>] (nfs_updatepage+0x2e0/0x524) from [<c010b19c>] (nfs_write_end+0x23c/0x270)
>>> [<c010b19c>] (nfs_write_end+0x23c/0x270) from [<c006b484>] (generic_file_buffered_write+0x180/0x248)
>>> [<c006b484>] (generic_file_buffered_write+0x180/0x248) from [<c006d060>] (__generic_file_aio_write+0x3b8/0x3f4)
>>> [<c006d060>] (__generic_file_aio_write+0x3b8/0x3f4) from [<c006d108>] (generic_file_aio_write+0x6c/0xdc)
>>> [<c006d108>] (generic_file_aio_write+0x6c/0xdc) from [<c010bce0>] (nfs_file_write+0xec/0x178)
>>> [<c010bce0>] (nfs_file_write+0xec/0x178) from [<c00956ac>] (do_sync_write+0xa4/0xe4)
>>> [<c00956ac>] (do_sync_write+0xa4/0xe4) from [<c00960c8>] (vfs_write+0xb4/0x12c)
>>> [<c00960c8>] (vfs_write+0xb4/0x12c) from [<c00961f0>] (sys_write+0x3c/0x68)
>>> [<c00961f0>] (sys_write+0x3c/0x68) from [<c002c8e0>] (ret_fast_syscall+0x0/0x2c)
>>>
>>> This series introduces a new function called __igrab, which is an unlocked
>>> version of igrab and modifies nfs_inode_add_request to use the unlocked
>>> version.
>> It's called ihold() and already exists.
> Thanks. Missed that one.
>
> Is ihold the correct replacement for the fs/ceph cases I mentioned in my
> other email?
>
> ~Ryan
>

i.e. this:
---

fs/ceph: Use ihold instead of igrab when i_lock is already held

Signed-off-by: Ryan Mallon <ryan@bluewatersys.com>
---
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 561438b..37368ba 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -92,7 +92,7 @@ static int ceph_set_page_dirty(struct page *page)
 		ci->i_head_snapc = ceph_get_snap_context(snapc);
 	++ci->i_wrbuffer_ref_head;
 	if (ci->i_wrbuffer_ref == 0)
-		igrab(inode);
+		ihold(inode);
 	++ci->i_wrbuffer_ref;
 	dout("%p set_page_dirty %p idx %lu head %d/%d -> %d/%d "
 	     "snapc %p seq %lld (%d snaps)\n",
diff --git a/fs/ceph/snap.c b/fs/ceph/snap.c
index f40b913..03afa8e 100644
--- a/fs/ceph/snap.c
+++ b/fs/ceph/snap.c
@@ -463,7 +463,7 @@ void ceph_queue_cap_snap(struct ceph_inode_info *ci)
 
 		dout("queue_cap_snap %p cap_snap %p queuing under %p\n", inode,
 		     capsnap, snapc);
-		igrab(inode);
+		ihold(inode);
 		
 		atomic_set(&capsnap->nref, 1);
 		capsnap->ci = ci;


