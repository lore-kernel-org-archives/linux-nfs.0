Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757400Ab1CYDOf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 23:14:35 -0400
Subject: [GIT PULL] Please pull NFS client changesets...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Mar 2011 23:14:32 -0400
Message-ID: <1301022872.28661.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.39" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.39

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c                          |   89 ++++++++-
 fs/nfs/file.c                         |    3 +
 fs/nfs/getroot.c                      |    4 +
 fs/nfs/inode.c                        |   10 +-
 fs/nfs/internal.h                     |   27 +++-
 fs/nfs/namespace.c                    |  115 +++++++++++-
 fs/nfs/nfs3proc.c                     |    2 +-
 fs/nfs/nfs4_fs.h                      |    5 +-
 fs/nfs/nfs4filelayout.c               |  352 ++++++++++++++++++++++++++++++---
 fs/nfs/nfs4filelayout.h               |    2 +
 fs/nfs/nfs4filelayoutdev.c            |  178 ++++++++++++------
 fs/nfs/nfs4proc.c                     |  302 +++++++++++++++++++++++------
 fs/nfs/nfs4xdr.c                      |  313 +++++++++++++++++++++++++++--
 fs/nfs/pagelist.c                     |    8 +-
 fs/nfs/pnfs.c                         |  142 +++++++++++++
 fs/nfs/pnfs.h                         |   83 ++++++++-
 fs/nfs/proc.c                         |    2 +-
 fs/nfs/write.c                        |  214 ++++++++++++++-------
 fs/nfs_common/nfsacl.c                |    1 -
 include/linux/nfs4.h                  |    2 +
 include/linux/nfs_fs.h                |   10 +
 include/linux/nfs_page.h              |    7 +-
 include/linux/nfs_xdr.h               |   70 +++++++-
 include/linux/sunrpc/gss_api.h        |    3 +
 net/sunrpc/auth_gss/gss_mech_switch.c |   38 ++++
 net/sunrpc/xprtsock.c                 |    2 +
 26 files changed, 1728 insertions(+), 256 deletions(-)

commit 35124a0994fc02545b14b9fa3aad000b3331f1c0
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Thu Mar 24 16:48:21 2011 -0400

    Cleanup XDR parsing for LAYOUTGET, GETDEVICEINFO
    
    changes LAYOUTGET and GETDEVICEINFO XDR parsing to:
     - not use vmap, which doesn't work on incoherent archs
     - use xdr_stream parsing for all xdr
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef31153786bc1e4304e6b9422cc8b9efef455611
Author: Andy Adamson <andros@netapp.com>
Date:   Sat Mar 12 02:58:10 2011 -0500

    NFSv4.1 convert layoutcommit sync to boolean
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit de4b15c7e9fe9fdd1eb6333be0a08c822db1ca0e
Author: Andy Adamson <andros@netapp.com>
Date:   Sat Mar 12 02:58:09 2011 -0500

    NFSv4.1 pnfs_layoutcommit_inode fixes
    
    Test NFS_INO_LAYOUTCOMMIT before kzalloc
    Mark inode dirty to retry LAYOUTCOMMIT on kzalloc failure.
    Add comments.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8f70e95f9f4159184f557a1db60c909d7c1bd2e3
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Mar 24 17:12:31 2011 +0000

    NFS: Determine initial mount security
    
    When sec=<something> is not presented as a mount option,
    we should attempt to determine what security flavor the
    server is using.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7ebb931598cd95cccea10d4bc4c0123a464ea565
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Mar 24 17:12:30 2011 +0000

    NFS: use secinfo when crossing mountpoints
    
    A submount may use different security than the parent
    mount does.  We should figure out what sec flavor the
    submount uses at mount time.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5a5ea0d485c9715c86bf858bbdc5f6d373b3db88
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Mar 24 17:12:29 2011 +0000

    NFS: Add secinfo procedure
    
    This patch adds the nfs4 operation secinfo as a
    valid nfs rpc operation.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7c5130588d691a3b34d02312f1bd1b6d56fe0100
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Mar 24 17:12:24 2011 +0000

    NFS: lookup supports alternate client
    
    A later patch will need to perform a lookup using an
    alternate client with a different security flavor.
    This patch adds support for doing that on NFS v4.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e73b83f270828630a9ce33728f6ef61c37a82340
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Mar 24 17:12:23 2011 +0000

    NFS: convert call_sync() to a function
    
    This patch changes nfs4_call_sync() from a macro into a
    static inline function.  As a macro, the call_sync()
    function will not do any type checking and depends
    on the sequence arguments always having the same name.
    As a function, we get to have type checking and can
    rename the arguments if we so choose.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cccb4d063b263ac0713ab27d98460fda3b4f83ff
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:55 2011 +0000

    NFSv4.1 remove temp code that prevented ds commits
    
    Now that all the infrastructure is in place, we will do the
    right thing if we remove this special casing.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 863a3c6c686d5773f7192a4818769e15db12ce08
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Mar 23 13:27:54 2011 +0000

    NFSv4.1: layoutcommit
    
    The filelayout driver sends LAYOUTCOMMIT only when COMMIT goes to
    the data server (as opposed to the MDS) and the data server WRITE
    is not NFS_FILE_SYNC.
    
    Only whole file layout support means that there is only one IOMODE_RW layout
    segment.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
    Tested-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e0c2b3801828aadb65dec9f67f7c6b7a675ad007
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:53 2011 +0000

    NFSv4.1: filelayout driver specific code for COMMIT
    
    Implement all the hooks created in the previous patches.
    This requires exporting quite a few functions and adding a few
    structure fields.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 988b6dceb0ae6d642587c8594529b94f6be0c5ea
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:52 2011 +0000

    NFSv4.1: remove GETATTR from ds commits
    
    Any COMMIT compound directed to a data server needs to have the
    GETATTR calls suppressed.  We here, make sure the field we are testing
    (data->lseg) is set and refcounted correctly.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a861a1e1c398fe34701569fd8ac9225dfe0a9a7e
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:51 2011 +0000

    NFSv4.1: add generic layer hooks for pnfs COMMIT
    
    We create three major hooks for the pnfs code.
    
    pnfs_mark_request_commit() is called during writeback_done from
    nfs_mark_request_commit, which gives the driver an opportunity to
    claim it wants control over commiting a particular req.
    
    pnfs_choose_commit_list() is called from nfs_scan_list
    to choose which list a given req should be added to, based on
    where we intend to send it for COMMIT.  It is up to the driver
    to have preallocated list headers for each destination it may need.
    
    pnfs_commit_list() is how the driver actually takes control, it is
    used instead of nfs_commit_list().
    
    In order to pass information between the above functions, we create
    a union in nfs_page to hold a lseg (which is possible because the req is
    not on any list while in transition), and add some flags to indicate
    if we need to use the pnfs code.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 425eb736cd905181a4dd4dc8d66342a7c7ab2f27
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:50 2011 +0000

    NFSv4.1: alloc and free commit_buckets
    
    Create a preallocated list header to hold nfs_pages for each
    non-MDS COMMIT destination.  Note this is not necessarily each DS,
    but is basically each <DS, fh> pair.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c879513e91c9e38957f0d9647d22469f1887e4da
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:49 2011 +0000

    NFSv4.1: shift filelayout_free_lseg
    
    Move it up to avoid forward declaration in later patch.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5917ce8440ba0b3f2adee613b5f1258ac5efff02
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:48 2011 +0000

    NFSv4.1: pull out code from nfs_commit_release
    
    Create a separate support function for later use by data server
    commit code.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 64bfeb49bd1c2351a8415f7fe6b25eef208872a5
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:47 2011 +0000

    NFSv4.1: pull error handling out of nfs_commit_list
    
    Create a separate support function for later use by data server
    commit code.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5f452431e229ea14df61b0ac89eed5881414eef9
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:46 2011 +0000

    NFSv4.1: add callback to nfs4_commit_done
    
    Add a callback that the pnfs layout driver can use to do its own
    error handling of the data server's COMMIT response.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9ace33cdc6562699a780b4716d9d52c55dd2151a
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:45 2011 +0000

    NFSv4.1: rearrange nfs_commit_rpcsetup
    
    Reorder nfs_commit_rpcsetup, preparing for a pnfs entry point.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 465d52437d5ce8d4eb9da0d3e3818b51cff163a1
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Mar 23 13:27:44 2011 +0000

    NFSv4.1: don't send COMMIT to ds for data sync writes
    
    Based on consensus reached in Feb 2011 interim IETF meeting regarding
    use of LAYOUTCOMMIT, it has been decided that a NFS_DATA_SYNC return
    from a WRITE to data server should not initiate a COMMIT.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8ef2ce3e16d9bec6cf015207c1c82a5b864046ac
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Mar 23 15:04:31 2011 -0400

    NFS: Detect loops in a readdir due to bad cookies
    
    Some filesystems (such as ext4) can return the same cookie value for
    multiple files.  If we try to start a readdir with one of these cookies,
    the server will return the first file found with a cookie of the same
    value.  This can cause the client to enter an infinite loop.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 480c2006ebb44ae03165695db7b3e38c04e0d102
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Mar 23 14:48:29 2011 -0400

    NFS: Create nfs_open_dir_context
    
    nfs_opendir() created a context that held much more information than we
    need for a readdir.  This patch introduces a slimmed-down
    nfs_open_dir_context that contains only the cookie and the cred used for
    RPC operations.  The new context will eventually be used to help detect
    readdir loops.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e47c085afb3d16cbc6a4bfb10a3b074bb7c58998
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 23 08:43:09 2011 -0400

    NFS: Ensure that we update the readdir filp->f_pos correctly
    
    If we're doing a search by readdir cookie, we need to ensure that the
    resulting f_pos is updated. To do so, we need to update the
    desc->current_index, in the same way that we do in the search by
    file offset case.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 51e816564db151f7f08c739ad69b9d1dbd166663
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Mon Mar 21 20:35:49 2011 +0100

    Remove pointless memset in nfsacl_encode()
    
    Remove pointless memset() in nfsacl_encode().
    
    Thanks to Trond Myklebust <Trond.Myklebust@netapp.com> for pointing out
    that it is not needed since posix_acl_init() will set everything
    regardless..
    
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4667058b772857069378aa8f417203156e315e82
Author: Gusev Vitaliy <gusev.vitaliy@nexenta.com>
Date:   Wed Mar 23 00:40:25 2011 +0300

    nfs4: Fix NULL dereference at d_alloc_and_lookup()
    
    d_alloc_and_lookup() calls i_op->lookup method due to
    rootfh changes his fsid.
    
    During mount i_op of NFS root inode is set to
    nfs_mountpoint_inode_operations, if rpc_ops->getroot()
    and rpc_ops->getattr() return different fsid.
    
    After that  nfs_follow_remote_path() raised oops:
    
       BUG: unable to handle kernel NULL pointer dereference at (null)
       IP: [<          (null)>]           (null)
    
    stack trace:
    
         d_alloc_and_lookup+0x4c/0x74
         do_lookup+0x1e3/0x280
         link_path_walk+0x12e/0xab0
         nfs4_remote_get_sb+0x56/0x2c0 [nfs]
         path_walk+0x67/0xe0
         vfs_path_lookup+0x8e/0x100
         nfs_follow_remote_path+0x16f/0x3e0 [nfs]
         nfs4_try_mount+0x6f/0xd0 [nfs]
         nfs_get_sb+0x269/0x400 [nfs]
         vfs_kern_mount+0x8a/0x1f0
         do_kern_mount+0x52/0x130
         do_mount+0x20a/0x260
         sys_mount+0x90/0xe0
         system_call_fastpath+0x16/0x1b
    
    So just refresh fsid, as RFC3530 doesn't specify behavior
    in case of rootfh changes fsid.
    
    Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 246408dcd5dfeef2df437ccb0ef4d6ee87805f58
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 22 18:40:10 2011 -0400

    SUNRPC: Never reuse the socket port after an xs_close()
    
    If we call xs_close(), we're in one of two situations:
     - Autoclose, which means we don't expect to resend a request
     - bind+connect failed, which probably means the port is in use
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit b8413f98f997bb3ed7327e6d7117e7e91ce010c3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 21 15:37:01 2011 -0400

    NFS: Fix a hang/infinite loop in nfs_wb_page()
    
    When one of the two waits in nfs_commit_inode() is interrupted, it
    returns a non-negative value, which causes nfs_wb_page() to think
    that the operation was successful causing it to busy-loop rather
    than exiting.
    It also causes nfs_file_fsync() to incorrectly report the file as
    being successfully committed to disk.
    
    This patch fixes both problems by ensuring that we return an error
    if the attempts to wait fail.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit b31268ac793fd300da66b9c28bbf0a200339ab96
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 21 17:02:00 2011 -0400

    FS: Use stable writes when not doing a bulk flush
    
    If we're only doing a single write, and there are no other unstable
    writes being queued up, we might want to just flip to using a stable
    write RPC call.
    
    Reviewed-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

