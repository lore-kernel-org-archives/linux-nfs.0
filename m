Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757558Ab0D3Qsn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Apr 2010 12:48:43 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 29 Apr 2010 12:48:41 -0400
Message-ID: <1272559721.3844.7.camel@localhost.localdomain>
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
 fs/nfs/client.c        |    2 +
 fs/nfs/dir.c           |    2 +-
 fs/nfs/nfs4proc.c      |    5 +++-
 fs/nfs/super.c         |    3 +-
 fs/nfs/write.c         |   55 +++++++++++++++++++++++++++++++----------------
 include/linux/nfs_fs.h |    1 +
 net/sunrpc/auth.c      |    2 +-
 7 files changed, 47 insertions(+), 23 deletions(-)

commit 9699eda6bc1f708a28acb716e1477aa351362fe2
Author: Xiaotian Feng <dfeng@redhat.com>
Date:   Thu Apr 22 18:56:17 2010 +0800

    nfs: fix memory leak in nfs_get_sb with CONFIG_NFS_V4
    
    With CONFIG_NFS_V4 and data version 4, nfs_get_sb will allocate memory for
    export_path in nfs4_validate_text_mount_data, so we need to free it then.
    This is addressed in following kmemleak report:
    
    unreferenced object 0xffff88016bf48a50 (size 16):
      comm "mount.nfs", pid 22567, jiffies 4651574704 (age 175471.200s)
      hex dump (first 16 bytes):
        2f 6f 70 74 2f 77 6f 72 6b 00 6b 6b 6b 6b 6b a5  /opt/work.kkkkk.
      backtrace:
        [<ffffffff814b34f9>] kmemleak_alloc+0x60/0xa7
        [<ffffffff81102c76>] kmemleak_alloc_recursive.clone.5+0x1b/0x1d
        [<ffffffff811046b3>] __kmalloc_track_caller+0x18f/0x1b7
        [<ffffffff810e1b08>] kstrndup+0x37/0x54
        [<ffffffffa0336971>] nfs_parse_devname+0x152/0x204 [nfs]
        [<ffffffffa0336af3>] nfs4_validate_text_mount_data+0xd0/0xdc [nfs]
        [<ffffffffa0338deb>] nfs_get_sb+0x325/0x736 [nfs]
        [<ffffffff81113671>] vfs_kern_mount+0xbd/0x17c
        [<ffffffff81113798>] do_kern_mount+0x4d/0xed
        [<ffffffff81129a87>] do_mount+0x787/0x7fe
        [<ffffffff81129b86>] sys_mount+0x88/0xc2
        [<ffffffff81009b42>] system_call_fastpath+0x16/0x1b
    
    Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: Chuck Lever <chuck.lever@oracle.com>
    Cc: Benny Halevy <bhalevy@panasas.com>
    Cc: Al Viro <viro@ZenIV.linux.org.uk>
    Cc: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit acf82b85a70f39786e3cbb1ffed8655bcc972424
Author: Dan Carpenter <error27@gmail.com>
Date:   Thu Apr 22 11:28:39 2010 +0200

    nfs: fix some issues in nfs41_proc_reclaim_complete()
    
    The original code passed an ERR_PTR() to rpc_put_task() and instead of
    returning zero on success it returned -ENOMEM.
    
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba8b06e67ed7a560b0e7c80091bcadda4f4727a5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 27 18:33:54 2010 -0400

    NFS: Ensure that nfs_wb_page() waits for Pg_writeback to clear
    
    Neil Brown reports that he is seeing the BUG_ON(ret == 0) trigger in
    nfs_page_async_flush. According to the trace in
         https://bugzilla.novell.com/show_bug.cgi?id=599628
    the problem appears to be due to nfs_wb_page() not waiting for the
    PG_writeback flag to clear.
    
    There is a ditto problem in nfs_wb_page_cancel()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 71d0a6112a363e703e383ae5b12c492485c39701
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 22 15:35:57 2010 -0400

    NFS: Fix an unstable write data integrity race
    
    Commit 2c61be0a9478258f77b66208a0c4b1f5f8161c3c (NFS: Ensure that the WRITE
    and COMMIT RPC calls are always uninterruptible) exposed a race on file
    close. In order to ensure correct close-to-open behaviour, we want to wait
    for all outstanding background commit operations to complete.
    
    This patch adds an inode flag that indicates if a commit operation is under
    way, and provides a mechanism to allow ->write_inode() to wait for its
    completion if this is a data integrity flush.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cdd29ecfcb9554132cd94b82ae8b69ba37adb3b5
Author: Dan Carpenter <error27@gmail.com>
Date:   Thu Apr 22 15:35:56 2010 -0400

    nfs: testing for null instead of ERR_PTR()
    
    nfs_path() returns an ERR_PTR(), it doesn't return null.
    
    Signed-off-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 356e76b855bdbfd8d1c5e75bcf0c6bf0dfe83496
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Apr 22 15:35:56 2010 -0400

    NFS: rsize and wsize settings ignored on v4 mounts
    
    NFSv4 mounts ignore the rsize and wsize mount options, and always use
    the default transfer size for both.  This seems to be because all
    NFSv4 mounts are now cloned, and the cloning logic doesn't copy the
    rsize and wsize settings from the parent nfs_server.
    
    I tested Fedora's 2.6.32.11-99 and it seems to have this problem as
    well, so I'm guessing that .33, .32, and perhaps older kernels have
    this issue as well.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Stable <stable@kernel.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f063d2cdf332a8a5722006b1345d15d16007c6e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 22 15:35:55 2010 -0400

    NFSv4: Don't attempt an atomic open if the file is a mountpoint
    
    Fix https://bugzilla.kernel.org/show_bug.cgi?id=15789
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3d7b08945e54a3a5358d5890240619a013cb7388
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 22 15:35:55 2010 -0400

    SUNRPC: Fix a bug in rpcauth_prune_expired
    
    Don't want to evict a credential if cred->cr_expire == jiffies, since that
    means that it was just placed on the cred_unused list. We therefore need to
    use time_in_range() rather than time_in_range_open().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


