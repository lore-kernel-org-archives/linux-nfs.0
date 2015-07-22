Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934181AbbGVPem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 11:34:42 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: jlayton@poochiereds.net, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: nfs4_put_lock_state() wants some nfs4_state on cleanup
Date: Wed, 22 Jul 2015 11:34:41 -0400
Message-Id: <1437579281-26810-1-git-send-email-bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our QE folks are noticing the old leftover locks WARN popping up in RHEL7
(it's since been removed).  While investigating upstream, I found I could
make this happen by locking, then closing and signaling a process in a loop:

 #0 [ffff88007a4874a0] __schedule at ffffffff81736d8a
 #1 [ffff88007a4874f0] schedule at ffffffff81737407
 #2 [ffff88007a487510] do_exit at ffffffff8109e18f
 #3 [ffff88007a487590] oops_end at ffffffff8101822e
 #4 [ffff88007a4875c0] no_context at ffffffff81063b55
 #5 [ffff88007a487630] __bad_area_nosemaphore at ffffffff81063e1b
 #6 [ffff88007a487680] bad_area_nosemaphore at ffffffff81063fa3
 #7 [ffff88007a487690] __do_page_fault at ffffffff81064251
 #8 [ffff88007a4876f0] trace_do_page_fault at ffffffff81064677
 #9 [ffff88007a487730] do_async_page_fault at ffffffff8105ed0e
#10 [ffff88007a487750] async_page_fault at ffffffff8173d078
    [exception RIP: nfs4_put_lock_state+82]
    RIP: ffffffffa02dd5b2  RSP: ffff88007a487808  RFLAGS: 00010207
    RAX: 0000003fffffffff  RBX: ffff8800351d2000  RCX: 0000000000000024
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000009
    RBP: ffff88007a487818   R8: 0000000000000000   R9: 0000000000000000
    R10: 000000000000028b  R11: 0000000000aaaaaa  R12: ffff88003675e240
    R13: ffff88003504d5b0  R14: ffff88007a487b30  R15: ffff880035097c40
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#11 [ffff88007a487800] nfs4_put_lock_state at ffffffffa02dd59b [nfsv4]
#12 [ffff88007a487820] nfs4_fl_release_lock at ffffffffa02dd605 [nfsv4]
#13 [ffff88007a487830] locks_release_private at ffffffff81258548
#14 [ffff88007a487850] locks_free_lock at ffffffff81258dbb
#15 [ffff88007a487870] locks_dispose_list at ffffffff81258f68
#16 [ffff88007a4878a0] __posix_lock_file at ffffffff81259ab6
#17 [ffff88007a487930] posix_lock_inode_wait at ffffffff8125a02a
#18 [ffff88007a4879b0] do_vfs_lock at ffffffffa02c4687 [nfsv4]
#19 [ffff88007a4879c0] nfs4_proc_lock at ffffffffa02cc1a1 [nfsv4]
#20 [ffff88007a487a70] do_unlk at ffffffffa0273d9e [nfs]
#21 [ffff88007a487ac0] nfs_lock at ffffffffa0273fa9 [nfs]
#22 [ffff88007a487b10] vfs_lock_file at ffffffff8125a76e
#23 [ffff88007a487b20] locks_remove_posix at ffffffff8125a819
#24 [ffff88007a487c10] locks_remove_posix at ffffffff8125a878
#25 [ffff88007a487c20] filp_close at ffffffff812092a2
#26 [ffff88007a487c50] put_files_struct at ffffffff812290c5
#27 [ffff88007a487ca0] exit_files at ffffffff812291c1
#28 [ffff88007a487cc0] do_exit at ffffffff8109dc5f
#29 [ffff88007a487d40] do_group_exit at ffffffff8109e3b5
#30 [ffff88007a487d70] get_signal at ffffffff810a9504
#31 [ffff88007a487e00] do_signal at ffffffff81014447
#32 [ffff88007a487f30] do_notify_resume at ffffffff81014b0e
#33 [ffff88007a487f50] int_signal at ffffffff8173b2fc

The nfs4_lock_state->ls_state pointer is pointing to free memory.

I think what's happening here is that a signal is bumping us out of
do_unlk() waiting on the io_counter while we try to release locks on
__fput().  Since the lock is never released, it sticks around on the inode
until another lock replaces it, and when it is freed it wants some bits from
nfs4_state, but the nfs4_state was already cleaned up.

Probably we need to do a better job not bailing out of do_unlk on file
close, but while I work on that, something like the following keeps the
nfs4_state around for proper cleanup of the nfs4_lock_state:

Is this sane?

Ben

8<--------------------------------------------------------------------
