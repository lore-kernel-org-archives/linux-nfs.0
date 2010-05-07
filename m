Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12849 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719Ab0EGCWs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 22:22:48 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Howells <dhowells@redhat.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 May 2010 22:22:43 -0400
Message-ID: <1273198963.2661.12.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/delegation.c |   86 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 51 insertions(+), 35 deletions(-)

commit 17d2c0a0c4d4e074f0a2a5c0090ff6d88f5e1d44
Author: David Howells <dhowells@redhat.com>
Date:   Sat May 1 12:37:18 2010 -0400

    NFS: Fix RCU issues in the NFSv4 delegation code
    
    Fix a number of RCU issues in the NFSv4 delegation code.
    
     (1) delegation->cred doesn't need to be RCU protected as it's essentially an
         invariant refcounted structure.
    
         By the time we get to nfs_free_delegation(), the delegation is being
         released, so no one else should be attempting to use the saved
         credentials, and they can be cleared.
    
         However, since the list of delegations could still be under traversal at
         this point by such as nfs_client_return_marked_delegations(), the cred
         should be released in nfs_do_free_delegation() rather than in
         nfs_free_delegation().  Simply using rcu_assign_pointer() to clear it is
         insufficient as that doesn't stop the cred from being destroyed, and nor
         does calling put_rpccred() after call_rcu(), given that the latter is
         asynchronous.
    
     (2) nfs_detach_delegation_locked() and nfs_inode_set_delegation() should use
         rcu_derefence_protected() because they can only be called if
         nfs_client::cl_lock is held, and that guards against anyone changing
         nfsi->delegation under it.  Furthermore, the barrier imposed by
         rcu_dereference() is superfluous, given that the spin_lock() is also a
         barrier.
    
     (3) nfs_detach_delegation_locked() is now passed a pointer to the nfs_client
         struct so that it can issue lockdep advice based on clp->cl_lock for (2).
    
     (4) nfs_inode_return_delegation_noreclaim() and nfs_inode_return_delegation()
         should use rcu_access_pointer() outside the spinlocked region as they
         merely examine the pointer and don't follow it, thus rendering unnecessary
         the need to impose a partial ordering over the one item of interest.
    
         These result in an RCU warning like the following:
    
    [ INFO: suspicious rcu_dereference_check() usage. ]
    ---------------------------------------------------
    fs/nfs/delegation.c:332 invoked rcu_dereference_check() without protection!
    
    other info that might help us debug this:
    
    rcu_scheduler_active = 1, debug_locks = 0
    2 locks held by mount.nfs4/2281:
     #0:  (&type->s_umount_key#34){+.+...}, at: [<ffffffff810b25b4>] deactivate_super+0x60/0x80
     #1:  (iprune_sem){+.+...}, at: [<ffffffff810c332a>] invalidate_inodes+0x39/0x13a
    
    stack backtrace:
    Pid: 2281, comm: mount.nfs4 Not tainted 2.6.34-rc1-cachefs #110
    Call Trace:
     [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
     [<ffffffffa00b4591>] nfs_inode_return_delegation_noreclaim+0x5b/0xa0 [nfs]
     [<ffffffffa0095d63>] nfs4_clear_inode+0x11/0x1e [nfs]
     [<ffffffff810c2d92>] clear_inode+0x9e/0xf8
     [<ffffffff810c3028>] dispose_list+0x67/0x10e
     [<ffffffff810c340d>] invalidate_inodes+0x11c/0x13a
     [<ffffffff810b1dc1>] generic_shutdown_super+0x42/0xf4
     [<ffffffff810b1ebe>] kill_anon_super+0x11/0x4f
     [<ffffffffa009893c>] nfs4_kill_super+0x3f/0x72 [nfs]
     [<ffffffff810b25bc>] deactivate_super+0x68/0x80
     [<ffffffff810c6744>] mntput_no_expire+0xbb/0xf8
     [<ffffffff810c681b>] release_mounts+0x9a/0xb0
     [<ffffffff810c689b>] put_mnt_ns+0x6a/0x79
     [<ffffffffa00983a1>] nfs_follow_remote_path+0x5a/0x146 [nfs]
     [<ffffffffa0098334>] ? nfs_do_root_mount+0x82/0x95 [nfs]
     [<ffffffffa00985a9>] nfs4_try_mount+0x75/0xaf [nfs]
     [<ffffffffa0098874>] nfs4_get_sb+0x291/0x31a [nfs]
     [<ffffffff810b2059>] vfs_kern_mount+0xb8/0x177
     [<ffffffff810b2176>] do_kern_mount+0x48/0xe8
     [<ffffffff810c810b>] do_mount+0x782/0x7f9
     [<ffffffff810c8205>] sys_mount+0x83/0xbe
     [<ffffffff81001eeb>] system_call_fastpath+0x16/0x1b
    
    Also on:
    
    fs/nfs/delegation.c:215 invoked rcu_dereference_check() without protection!
     [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
     [<ffffffffa00b4223>] nfs_inode_set_delegation+0xfe/0x219 [nfs]
     [<ffffffffa00a9c6f>] nfs4_opendata_to_nfs4_state+0x2c2/0x30d [nfs]
     [<ffffffffa00aa15d>] nfs4_do_open+0x2a6/0x3a6 [nfs]
     ...
    
    And:
    
    fs/nfs/delegation.c:40 invoked rcu_dereference_check() without protection!
     [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
     [<ffffffffa00b3bef>] nfs_free_delegation+0x3d/0x6e [nfs]
     [<ffffffffa00b3e71>] nfs_do_return_delegation+0x26/0x30 [nfs]
     [<ffffffffa00b406a>] __nfs_inode_return_delegation+0x1ef/0x1fe [nfs]
     [<ffffffffa00b448a>] nfs_client_return_marked_delegations+0xc9/0x124 [nfs]
     ...
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8f649c376254755f2261a693b3d48d09126218dc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat May 1 12:36:18 2010 -0400

    NFSv4: Fix the locking in nfs_inode_reclaim_delegation()
    
    Ensure that we correctly rcu-dereference the delegation itself, and that we
    protect against removal while we're changing the contents.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: David Howells <dhowells@redhat.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>


