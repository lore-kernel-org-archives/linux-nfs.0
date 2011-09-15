Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29154 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934209Ab1IOSui convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2011 14:50:38 -0400
Subject: [GIT PULL] Please pull bugfixes for the NFS client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 15 Sep 2011 14:50:17 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316112617.5271.8.camel@lade.trondhjem.org.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/nfs4_fs.h    |    8 +++++---
 fs/nfs/nfs4proc.c   |   20 ++++++++++++++------
 fs/nfs/nfs4renewd.c |   12 +++++++++---
 fs/nfs/nfs4state.c  |    6 ++++++
 fs/nfs/super.c      |   23 ++++++++++++++++++++---
 fs/nfs/write.c      |    2 +-
 6 files changed, 55 insertions(+), 16 deletions(-)

commit fb2088ccc139ffbf1cf359216883712dab4ae43d
Author: Sachin Prabhu <sprabhu@redhat.com>
Date:   Mon Aug 1 12:10:12 2011 +0100

    nfs: Do not allow multiple mounts on same mountpoint when using -o noac
    
    Do not allow multiple mounts on same mountpoint when using -o noac
    
    When you normally attempt to mount a share twice on the same mountpoint,
    a check in do_add_mount causes it to return an error
    
    # mount localhost:/nfsv3 /mnt
    # mount localhost:/nfsv3 /mnt
    mount.nfs: /mnt is already mounted or busy
    
    However when using the option 'noac', the user is able to mount the same
    share on the same mountpoint multiple times. This happens because a
    share mounted with the noac option is automatically assigned the 'sync'
    flag MS_SYNCHRONOUS in nfs_initialise_sb(). This flag is set after the
    check for already existing superblocks is done in sget(). The check for
    the mount flags in nfs_compare_mount_options() does not take into
    account the 'sync' flag applied later on in the code path. This means
    that when using 'noac', a new superblock structure is assigned for every
    new mount of the same share and multiple shares on the same mountpoint
    are allowed.
    
    ie.
    # mount -onoac localhost:/nfsv3 /mnt
    can be run multiple times.
    
    The patch checks for noac and assigns the sync flag before sget() is
    called to obtain an already existing superblock structure.
    
    Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
    Reviewed-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f13c3620a4d1123dbf032f93f350b856ef292ced
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Sep 12 11:47:53 2011 -0400

    NFS: Fix a typo in nfs_flush_multi
    
    Fix a typo which causes an Oops in the RPC layer, when using wsize < 4k.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Tested-by: Sricharan R <r.sricharan@ti.com>

commit 042b60beb410caf68f576d63d6849d0f0a545eb0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 24 15:07:37 2011 -0400

    NFSv4: renewd needs to be able to handle the NFS4ERR_CB_PATH_DOWN error
    
    The NFSv4 spec does not specify that the server must repeat that error,
    so in order to avoid having the delegations revoked, we should handle
    it immediately.
    
    Also note that NFS4ERR_CB_PATH_DOWN does in fact renew the lease...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2f60ea6b8ceda61ae08bef71a652eac36ec193b3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 24 15:07:37 2011 -0400

    NFSv4: The NFSv4.0 client must send RENEW calls if it holds a delegation
    
    RFC3530 states that if the client holds a delegation, then it is obliged
    to continue to send RENEW calls once every lease period in order to allow
    the server to return NFS4ERR_CB_PATH_DOWN if the callback path is
    unreachable.
    
    This is not required for NFSv4.1, since the server can at any time set
    the SEQ4_STATUS_CB_PATH_DOWN_SESSION in any SEQUENCE operation.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8534d4ec055d854be6c94e8e5654fa87678ea5f7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 24 15:07:37 2011 -0400

    NFSv4: nfs4_proc_renew should be declared static
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b569ad34926defcff998f214afeb260331165985
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 24 15:07:35 2011 -0400

    NFSv4: nfs4_proc_async_renew should use a GFP_NOFS allocation
    
    We shouldn't allow the renew daemon to do direct reclaim on the NFS
    partition.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

