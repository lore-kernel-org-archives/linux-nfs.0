Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:63872 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051Ab1C1GCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 02:02:05 -0400
Date: Mon, 28 Mar 2011 17:01:57 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ryan Mallon <ryan@bluewatersys.com>
Cc: sage@newdream.net, viro@zeniv.linux.org.uk, dchinner@redhat.com,
        Trond.Myklebust@netapp.com, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [RFC PATCH 0/2] Introduce unlocked version of igrab
Message-ID: <20110328060157.GA3008@dastard>
References: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com>
 <20110328044334.GA1022@dastard>
 <4D9012C5.8070401@bluewatersys.com>
 <4D9016B7.1080505@bluewatersys.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D9016B7.1080505@bluewatersys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 28, 2011 at 06:03:51PM +1300, Ryan Mallon wrote:
> On 03/28/2011 05:47 PM, Ryan Mallon wrote:
> > On 03/28/2011 05:43 PM, Dave Chinner wrote:
> >> On Mon, Mar 28, 2011 at 02:55:59PM +1300, Ryan Mallon wrote:
> >>> Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect 
> >>> inode->i_state with inode->i_lock" introduces a change to igrab to acquire
> >>> inode->i_lock. 
> >>>
> >>> This change causes a panic on boot on my ARM EP93xx board when the rootfs
> >>> uses NFS. The problem occurs because nfs_inode_add_request acquires
> >>> inode->i_lock and then calls igrab, resulting in the following panic:
> >>>
> >>> BUG: spinlock recursion on CPU#0, getty/262
> >>>  lock: cc421cb4, .magic: dead4ead, .owner: getty/262, .owner_cpu: 0
> >>> [<c0031b0c>] (unwind_backtrace+0x0/0xe4) from [<c015f16c>] (do_raw_spin_lock+0x40/0x13c)
> >>> [<c015f16c>] (do_raw_spin_lock+0x40/0x13c) from [<c00a938c>] (igrab+0x14/0x48)
> >>> [<c00a938c>] (igrab+0x14/0x48) from [<c01186bc>] (nfs_updatepage+0x2e0/0x524)
> >>> [<c01186bc>] (nfs_updatepage+0x2e0/0x524) from [<c010b19c>] (nfs_write_end+0x23c/0x270)
> >>> [<c010b19c>] (nfs_write_end+0x23c/0x270) from [<c006b484>] (generic_file_buffered_write+0x180/0x248)
> >>> [<c006b484>] (generic_file_buffered_write+0x180/0x248) from [<c006d060>] (__generic_file_aio_write+0x3b8/0x3f4)
> >>> [<c006d060>] (__generic_file_aio_write+0x3b8/0x3f4) from [<c006d108>] (generic_file_aio_write+0x6c/0xdc)
> >>> [<c006d108>] (generic_file_aio_write+0x6c/0xdc) from [<c010bce0>] (nfs_file_write+0xec/0x178)
> >>> [<c010bce0>] (nfs_file_write+0xec/0x178) from [<c00956ac>] (do_sync_write+0xa4/0xe4)
> >>> [<c00956ac>] (do_sync_write+0xa4/0xe4) from [<c00960c8>] (vfs_write+0xb4/0x12c)
> >>> [<c00960c8>] (vfs_write+0xb4/0x12c) from [<c00961f0>] (sys_write+0x3c/0x68)
> >>> [<c00961f0>] (sys_write+0x3c/0x68) from [<c002c8e0>] (ret_fast_syscall+0x0/0x2c)
> >>>
> >>> This series introduces a new function called __igrab, which is an unlocked
> >>> version of igrab and modifies nfs_inode_add_request to use the unlocked
> >>> version.
> >> It's called ihold() and already exists.
> > Thanks. Missed that one.
> >
> > Is ihold the correct replacement for the fs/ceph cases I mentioned in my
> > other email?
> >
> > ~Ryan
> >
> 
> i.e. this:
> ---
> 
> fs/ceph: Use ihold instead of igrab when i_lock is already held
> 
> Signed-off-by: Ryan Mallon <ryan@bluewatersys.com>

In essence, yes, though the NFS case (nfs4state.c) also needs the
same treatment. I posted a patch that fixes all the cases you
reported so you can continue to work without needing Tronnnd's
bigger fix for the initial problem.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
