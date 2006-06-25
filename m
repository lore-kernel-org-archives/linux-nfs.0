From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [GIT] Please pull NFS updates...
Date: Sun, 25 Jun 2006 06:52:24 -0400
Message-ID: <1151232744.13127.40.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuSES-0001Ls-EK
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 03:52:48 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FuSER-0005h6-3D
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 03:52:48 -0700
To: Linus Torvalds <torvalds@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

(Apologies for the lateness of the merge request: I'm still on vacation
and will only be getting back to work tomorrow)

----
 Documentation/filesystems/automount-support.txt |    2 
 drivers/usb/core/inode.c                        |    2 
 fs/9p/vfs_super.c                               |    7 
 fs/afs/mntpt.c                                  |    2 
 fs/afs/super.c                                  |    2 
 fs/afs/super.h                                  |    2 
 fs/binfmt_misc.c                                |    3 
 fs/cifs/cifsfs.c                                |    6 
 fs/configfs/mount.c                             |    2 
 fs/debugfs/inode.c                              |    2 
 fs/fuse/inode.c                                 |    5 
 fs/libfs.c                                      |    4 
 fs/lockd/clntlock.c                             |   39 -
 fs/lockd/clntproc.c                             |   14 
 fs/lockd/host.c                                 |    9 
 fs/namespace.c                                  |  128 ++
 fs/nfs/Makefile                                 |    8 
 fs/nfs/callback.c                               |    2 
 fs/nfs/callback_xdr.c                           |    2 
 fs/nfs/dir.c                                    |   18 
 fs/nfs/direct.c                                 |    6 
 fs/nfs/file.c                                   |   30 
 fs/nfs/idmap.c                                  |    1 
 fs/nfs/inode.c                                  | 1315 +-------------------
 fs/nfs/internal.h                               |  186 +++
 fs/nfs/namespace.c                              |  229 +++
 fs/nfs/nfs2xdr.c                                |    8 
 fs/nfs/nfs3acl.c                                |   11 
 fs/nfs/nfs3proc.c                               |    5 
 fs/nfs/nfs3xdr.c                                |    6 
 fs/nfs/nfs4_fs.h                                |    4 
 fs/nfs/nfs4namespace.c                          |  201 +++
 fs/nfs/nfs4proc.c                               |  111 ++
 fs/nfs/nfs4xdr.c                                |  218 +++
 fs/nfs/pagelist.c                               |   51 -
 fs/nfs/proc.c                                   |    5 
 fs/nfs/read.c                                   |  122 +-
 fs/nfs/super.c                                  | 1537 +++++++++++++++++++++++
 fs/nfs/symlink.c                                |   13 
 fs/nfs/sysctl.c                                 |   10 
 fs/nfs/write.c                                  |   49 -
 fs/super.c                                      |    2 
 include/linux/fs.h                              |    4 
 include/linux/lockd/lockd.h                     |    4 
 include/linux/mount.h                           |    8 
 include/linux/nfs4.h                            |    1 
 include/linux/nfs_fs.h                          |   62 +
 include/linux/nfs_fs_sb.h                       |    1 
 include/linux/nfs_page.h                        |    5 
 include/linux/nfs_xdr.h                         |   61 +
 include/linux/sunrpc/xdr.h                      |    1 
 mm/shmem.c                                      |    2 
 net/sunrpc/auth_null.c                          |    2 
 net/sunrpc/auth_unix.c                          |    1 
 net/sunrpc/rpc_pipe.c                           |    2 
 net/sunrpc/xdr.c                                |   28 
 net/sunrpc/xprt.c                               |    4 
 net/sunrpc/xprtsock.c                           |   11 
 security/inode.c                                |    2 
 59 files changed, 3065 insertions(+), 1513 deletions(-)

commit 9bf2aa129a107a0e9e2a5318d35aca731ae7e666
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Sun Jun 25 02:41:28 2006 -0700

    nfs: remove nfs_put_link()
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6ab86aa13045e7f6742af0b3c3c45f952f9fbb8d
Author: Andrew Morton <akpm@osdl.org>
Date:   Sun Jun 25 02:41:27 2006 -0700

    nfs-build-fix-99
    
    fs/built-in.o:(__param+0x20): undefined reference to `nfs_idmap_cache_timeout'
    fs/built-in.o:(__param+0x48): undefined reference to `nfs_callback_set_tcpport'
    
    Cc: Alexey Dobriyan <adobriyan@gmail.com>
    Cc: Andreas Gruenbacher <agruen@suse.de>
    Cc: Andy Adamson <andros@citi.umich.edu>
    Cc: Chuck Lever <cel@netapp.com>
    Cc: David Howells <dhowells@redhat.com>
    Cc: J. Bruce Fields <bfields@fieldses.org>
    Cc: Manoj Naik <manoj@almaden.ibm.com>
    Cc: Marc Eshel <eshel@almaden.ibm.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d75d54147db9db5194040bd1c5022df6ba36ee48
Author: Andrew Morton <akpm@osdl.org>
Date:   Sun Jun 25 02:41:26 2006 -0700

    git-nfs-build-fixes
    
    Fix various problems with nfs4 disabled.  And various other things.
    
    In file included from fs/nfs/inode.c:50:
    fs/nfs/internal.h:24: error: static declaration of 'nfs_do_refmount' follows non-static declaration
    include/linux/nfs_fs.h:320: error: previous declaration of 'nfs_do_refmount' was here
    fs/nfs/internal.h:65: warning: 'struct nfs4_fs_locations' declared inside parameter list
    fs/nfs/internal.h:65: warning: its scope is only this definition or declaration, which is probably not what you want
    fs/nfs/internal.h: In function 'nfs4_path':
    fs/nfs/internal.h:97: error: 'struct nfs_server' has no member named 'mnt_path'
    fs/nfs/inode.c: In function 'init_once':
    fs/nfs/inode.c:1116: error: 'struct nfs_inode' has no member named 'open_states'
    fs/nfs/inode.c:1116: error: 'struct nfs_inode' has no member named 'delegation'
    fs/nfs/inode.c:1116: error: 'struct nfs_inode' has no member named 'delegation_state'
    fs/nfs/inode.c:1116: error: 'struct nfs_inode' has no member named 'rwsem'
    distcc[26452] ERROR: compile fs/nfs/inode.c on g5/64 failed
    make[1]: *** [fs/nfs/inode.o] Error 1
    make: *** [fs/nfs/inode.o] Error 2
    make: *** Waiting for unfinished jobs....
    In file included from fs/nfs/nfs3xdr.c:26:
    fs/nfs/internal.h:24: error: static declaration of 'nfs_do_refmount' follows non-static declaration
    include/linux/nfs_fs.h:320: error: previous declaration of 'nfs_do_refmount' was here
    fs/nfs/internal.h:65: warning: 'struct nfs4_fs_locations' declared inside parameter list
    fs/nfs/internal.h:65: warning: its scope is only this definition or declaration, which is probably not what you want
    fs/nfs/internal.h: In function 'nfs4_path':
    fs/nfs/internal.h:97: error: 'struct nfs_server' has no member named 'mnt_path'
    distcc[26486] ERROR: compile fs/nfs/nfs3xdr.c on g5/64 failed
    make[1]: *** [fs/nfs/nfs3xdr.o] Error 1
    make: *** [fs/nfs/nfs3xdr.o] Error 2
    In file included from fs/nfs/nfs3proc.c:24:
    fs/nfs/internal.h:24: error: static declaration of 'nfs_do_refmount' follows non-static declaration
    include/linux/nfs_fs.h:320: error: previous declaration of 'nfs_do_refmount' was here
    fs/nfs/internal.h:65: warning: 'struct nfs4_fs_locations' declared inside parameter list
    fs/nfs/internal.h:65: warning: its scope is only this definition or declaration, which is probably not what you want
    fs/nfs/internal.h: In function 'nfs4_path':
    fs/nfs/internal.h:97: error: 'struct nfs_server' has no member named 'mnt_path'
    distcc[26469] ERROR: compile fs/nfs/nfs3proc.c on bix/32 failed
    make[1]: *** [fs/nfs/nfs3proc.o] Error 1
    make: *** [fs/nfs/nfs3proc.o] Error 2
    **FAILED**
    
    Cc: Alexey Dobriyan <adobriyan@gmail.com>
    Cc: Andreas Gruenbacher <agruen@suse.de>
    Cc: Andy Adamson <andros@citi.umich.edu>
    Cc: Chuck Lever <cel@netapp.com>
    Cc: David Howells <dhowells@redhat.com>
    Cc: J. Bruce Fields <bfields@fieldses.org>
    Cc: Manoj Naik <manoj@almaden.ibm.com>
    Cc: Marc Eshel <eshel@almaden.ibm.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ccf01ef7aa9c6c293a1c64c27331a2ce227916ec
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jun 25 06:27:31 2006 -0400

    Merge branch 'odirect'

commit 82b145c5a572f7fa7211dffe2097234dc91bcecc
Author: Chuck Lever <cel@netapp.com>
Date:   Tue Jun 20 12:57:03 2006 -0400

    NFS: alloc nfs_read/write_data as direct I/O is scheduled
    
    Re-arrange the logic in the NFS direct I/O path so that nfs_read/write_data
    structs are allocated just before they are scheduled, rather than
    allocating them all at once before we start scheduling requests.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 06cf6f2ed0b19629700794727d86ed57b9c0583e
Author: Chuck Lever <cel@netapp.com>
Date:   Tue Jun 20 12:56:49 2006 -0400

    NFS: Eliminate nfs_get_user_pages()
    
    Neil Brown observed that the kmalloc() in nfs_get_user_pages() is more
    likely to fail if the I/O is large enough to require the allocation of more
    than a single page to keep track of all the pinned pages in the user's
    buffer.
    
    Instead of tracking one large page array per dreq/iocb, track pages per
    nfs_read/write_data, just like the cached I/O path does.  An array for
    pages is already allocated for us by nfs_readdata_alloc() (and the write
    and commit equivalents).
    
    This is also required for adding support for vectored I/O to the NFS direct
    I/O path.
    
    The original reason to pin the user buffer and allocate all the NFS data
    structures before trying to schedule I/O was to ensure all needed resources
    are allocated on the client before starting to send requests.  This reduces
    the chance that resource exhaustion on the client will cause a short read
    or write.
    
    On the other hand, for an application making very large application I/O
    requests, this means that it will be nearly impossible for the application
    to make forward progress on a resource-limited client.
    
    Thus, moving the buffer pinning functionality into the I/O scheduling
    loops should be good for scalability.  The next patch will do the same for
    NFS data structure allocation.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9c93ab7dff5eb22027ab15010557bb73f9b44c99
Author: Chuck Lever <cel@netapp.com>
Date:   Tue Jun 20 12:56:31 2006 -0400

    NFS: refactor nfs_direct_free_user_pages
    
    Clean-up and fix a minor bug: the logic was dirtying page cache pages on
    both read and write operations.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 51a7bc6caec94bab256b272bffd24d00ea81c698
Author: Chuck Lever <cel@netapp.com>
Date:   Tue Jun 20 12:56:16 2006 -0400

    NFS: remove user_addr, user_count, and pos from nfs_direct_req
    
    Make the user_addr, user_count, and pos parameters explicit to the
    scheduler routines, and remove the fields from nfs_direct_req.  The
    iovec API will be passing in a series of these, not just one set.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fedb595c66e1fbd5acafe0d43b7e95c13c936d61
Author: Chuck Lever <cel@netapp.com>
Date:   Tue Jun 20 12:55:45 2006 -0400

    NFS: "open code" the NFS direct write rescheduler
    
    An NFSv3/v4 client must reschedule on-the-wire writes if the writes are
    UNSTABLE, and the server reboots before the client can complete a
    subsequent COMMIT request.
    
    To support direct asynchronous scatter-gather writes, the write
    rescheduler in fs/nfs/direct.c must not depend on the I/O parameters
    in the controlling nfs_direct_req structure.  iovecs can be somewhat
    arbitrarily complex, so there could be an unbounded amount of information
    to save for a rarely encountered requirement.
    
    Refactor the direct write rescheduler so it uses information from each
    nfs_write_data structure to reschedule writes, instead of caching that
    information in the controlling nfs_direct_req structure.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b1c5921c5b715c207d7fe77cd7aaafbb322f09f5
Author: Chuck Lever <cel@netapp.com>
Date:   Tue Jun 20 12:55:19 2006 -0400

    NFS: Separate functions for counting outstanding NFS direct I/Os
    
    Factor out the logic that increments and decrements the outstanding I/O
    count.  This will be a commonly used bit of code in upcoming patches.
    Also make this an atomic_t again, since it will be very often manipulated
    outside dreq->spin lock.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 28df955a2ad484d602314b30183ea8496a9aa34a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:40:27 2006 -0400

    NLM: Fix reclaim races
    
    Currently it is possible for a task to remove its locks at the same time as
    the NLM recovery thread is trying to recover them. This quickly leads to an
    Oops.
    Protect the locks using an rw semaphore while they are being recovered.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5046791417dcac1ba126b77b8062af15a2f0b8e1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:40:24 2006 -0400

    NLM: sem to mutex conversion
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3134cbec5e172c3a86e2c3ef4af34b6cfd380bfa
Author: Marc Eshel <eshel@almaden.ibm.com>
Date:   Fri Jun 9 09:40:20 2006 -0400

    locks.c: add the fl_owner to nlm_compare_locks
    
    Add the fl_owner to NLM compare locks. Since two different client can
    present the same pid to the server it is not enough to distinguish locks
    from different clients. The fl_owner field is a pointer to the struct
    nlm_host which is unique for each client.
    
    Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 81039f1f204a0fd2952112a240284e114f1a25e6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:34 2006 -0400

    NFS: Display the chosen RPCSEC_GSS security flavour in /proc/mounts
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f7b422b17ee5ee4920e8ae24a6ad04bf3481ce72
Author: David Howells <dhowells@redhat.com>
Date:   Fri Jun 9 09:34:33 2006 -0400

    NFS: Split fs/nfs/inode.c
    
    As fs/nfs/inode.c is rather large, heterogenous and unwieldy, the attached
    patch splits it up into a number of files:
    
     (*) fs/nfs/inode.c
    
         Strictly inode specific functions.
    
     (*) fs/nfs/super.c
    
         Superblock management functions for NFS and NFS4, normal access, clones
         and referrals.  The NFS4 superblock functions _could_ move out into a
         separate conditionally compiled file, but it's probably not worth it as
         there're so many common bits.
    
     (*) fs/nfs/namespace.c
    
         Some namespace-specific functions have been moved here.
    
     (*) fs/nfs/nfs4namespace.c
    
         NFS4-specific namespace functions (this could be merged into the previous
         file).  This file is conditionally compiled.
    
     (*) fs/nfs/internal.h
    
         Inter-file declarations, plus a few simple utility functions moved from
         fs/nfs/inode.c.
    
         Additionally, all the in-.c-file externs have been moved here, and those
         files they were moved from now includes this file.
    
    For the most part, the functions have not been changed, only some multiplexor
    functions have changed significantly.
    
    I've also:
    
     (*) Added some extra banner comments above some functions.
    
     (*) Rearranged the function order within the files to be more logical and
         better grouped (IMO), though someone may prefer a different order.
    
     (*) Reduced the number of #ifdefs in .c files.
    
     (*) Added missing __init and __exit directives.
    
    Signed-Off-By: David Howells <dhowells@redhat.com>

commit 4e5ccf60c5aa79d325c123f47d288a068166f389
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:32 2006 -0400

    NFS: Fix typo in nfs_do_clone_mount()
    
    Doh!
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 860de07139980afe9856cc31eb5efbf321bbcea4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:31 2006 -0400

    NFS: Fix compile errors introduced by referrals patches
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 87e4ba1a62af8e05ee3e8f8aaca622714386ffb0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:30 2006 -0400

    NFSv4: Ensure that referral mounts bind to a reserved port
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 33a43f2802d8d7be3a9b541785c4ca9ad79e4310
Author: Andy Adamson <andros@citi.umich.edu>
Date:   Fri Jun 9 09:34:30 2006 -0400

    NFSv4: A root pathname is sent as a zero component4
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6b97fd3da1eab2cc490cfe884c7d4956522eaf8b
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:29 2006 -0400

    NFSv4: Follow a referral
    
    Respond to a moved error on NFS lookup by setting up the referral.
    Note: We don't actually follow the referral during lookup/getattr, but
    later when we detect fsid mismatch in inode revalidation (similar to the
    processing done for cloning submounts). Referrals will have fake attributes
    until they are actually followed or traversed.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9cdb3883c38f883436a84c2353a4cf964ff890a2
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:28 2006 -0400

    NFSv4: Ensure client submounts when following a referral
    
    Set up mountpoint when hitting a referral on moved error by getting
    fs_locations.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61f5164cab1f6fdf06871ea9d60fe2f912184078
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:27 2006 -0400

    NFS: Expand clone mounts to include other servers
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c818ba43f9ca2e8214412ab5f126b1f436c35098
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:26 2006 -0400

    NFSv4: Create NFSv4 transport and client
    
    Move existing code into a separate function so that it can be also used by
    referral code.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 830b8e33fe1900b87c8eb7ec5c646117a9f298d6
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:25 2006 -0400

    NFSv4: Define an fs_locations bitmap
    
    This is (similar to getattr bitmap) but includes fs_locations and
    mounted_on_fileid attributes. Use this bitmap for encoding in fs_locations
    requests.
    Note: We can probably do better by requesting locations as part of fsinfo
    itself.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 361e624f6d8bfbeac53769603d995d47535cfd46
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:24 2006 -0400

    NFSv4: GETATTR attributes on referral
    
    Per referral draft, only fs_locations, fsid, and mounted_on_fileid can be
    requested in a GETATTR on referrals.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 99baf625d3b9b8944920acc7c2d06079a37458c5
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:24 2006 -0400

    NFSv4: Decode mounted_on_fileid attribute in getattr.
    
    It is ignored if fileid is also requested. This will be used on referrals
    (fs_locations).
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7aaa0b3bd4d215d9ce4d62b6c2043a63ba650f93
Author: Manoj Naik <manoj@almaden.ibm.com>
Date:   Fri Jun 9 09:34:23 2006 -0400

    NFSv4: convert fs-locations-components to conform to RFC3530
    
    Use component4-style formats for decoding list of servers and pathnames in
    fs_locations.
    
    Signed-off-by: Manoj Naik <manoj@almaden.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 683b57b435326eb512c7305892683b6205669448
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:22 2006 -0400

    NFSv4: Implement the fs_locations function call
    
    NFSv4 allows for the fact that filesystems may be replicated across
    several servers or that they may be migrated to a backup server in case of
    failure of the primary server.
    fs_locations is an NFSv4 operation for retrieving information about the
    location of migrated and/or replicated filesystems.
    
    Based on an initial implementation by Jiaying Zhang <jiayingz@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b23ea7bedb8b45a5bb56745fa3ff11018acf04e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:21 2006 -0400

    RPC: Allow struc xdr_stream to read the page section of an xdr_buf
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 51d8fa6a109589d522c18a8e9bf3fb167a91b1bc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:20 2006 -0400

    NFS: Add timeout to submounts
    
    Make automounted partitions expire using the mark_mounts_for_expiry()
    function. The timeout is controlled via a sysctl.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 55a975937d40cac582e981ddc8ed783b3dcc043c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:19 2006 -0400

    NFS: Ensure the client submounts, when it crosses a server mountpoint.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b4bdcf8995dd92b23d2ec22b32aee8fbbb50e1c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:19 2006 -0400

    NFS: Store the file system "fsid" value in the NFS super block.
    
    This should enable us to detect if we are crossing a mountpoint in the
    case where the server is exporting "nohide" mounts.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b512d9a88875affe584bb3d2a7a235f84343b9e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:18 2006 -0400

    VFS: Remove dependency of ->umount_begin() call on MNT_FORCE
    
    Allow filesystems to decide to perform pre-umount processing whether or not
    MNT_FORCE is set.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5528f911b4c43a5de5da34bcbd7e3f2a62503617
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:17 2006 -0400

    VFS: Add shrink_submounts()
    
    Allow a submount to be marked as being 'shrinkable' by means of the
    vfsmount->mnt_flags, and then add a function 'shrink_submounts()' which
    attempts to recursively unmount these submounts.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f5ce9e93aa96a867f195ed45f6f77935175f12e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:16 2006 -0400

    VFS: Unexport do_kern_mount() and clean up simple_pin_fs()
    
    Replace all module uses with the new vfs_kern_mount() interface, and fix up
    simple_pin_fs().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bb4a58bf46473e3e83d84054bbc110db3a0f85e4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:15 2006 -0400

    VFS: Add GPL_EXPORTED function vfs_kern_mount()
    
    do_kern_mount() does not allow the kernel to use private mount interfaces
    without exposing the same interfaces to userland. The problem is that the
    filesystem is referenced by name, thus meaning that it and its mount
    interface must be registered in the global filesystem list.
    
    vfs_kern_mount() passes the struct file_system_type as an explicit
    parameter in order to overcome this limitation.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit da6d503aa0a75ec44f17d985a2b500077e7f6a74
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 1 17:26:35 2006 -0400

    NFS: Remove nfs_delete_inode()
    
    Now that we have a real nfs_invalidate_page() to ensure that
    truncate_inode_pages() does the right thing when there are pending dirty
    pages, we can get rid of nfs_delete_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d2ccddf042c403b146159beea438c6bfc4a445e2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 31 01:13:38 2006 -0400

    NFS: Flesh out nfs_invalidate_page()
    
    In the case of a call to truncate_inode_pages(), we should really try to
    cancel any pending writes on the page.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c04871e6345e4c6dfda564e302d7fd8c66420fd5
Author: J. Bruce Fields <bfields@fieldses.org>
Date:   Tue May 30 16:28:58 2006 -0400

    NFSv4: remove obviously bogus comparison from decode_getacl
    
    We just set *acl_len to zero, and attrlen is unsigned, so this comparison
    is clearly bogus.  I have no idea what I was thinking.
    
    Fixes a bug that caused getacl to fail over krb5p.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3873bc50e2271504da45799257f69222774d9550
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Sat May 27 03:31:12 2006 +0400

    NFSv4: really return status from decode_recall_args()
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4814f56d19137b3b9fa8e00e1d332b3683b950de
Author: Andreas Gruenbacher <agruen@suse.de>
Date:   Thu May 25 01:41:03 2006 -0400

    NFSv3: Client-side nfsacl caching fix
    
    Fix two errors in the client-side acl cache: First, when nfs3_proc_getacl
    requests only the default acl of a file and the access acl is not cached
    already, a NULL access acl entry is cached instead of ERR_PTR(-EAGAIN)
    ("not cached").
    
    Second, update the cached acls in nfs3_proc_setacls: nfs_refresh_inode does
    not always invalidate the cached acls, and when it does not, the cached acls
    get out of sync.
    
    Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1842bfb447cea8b344fd91af97fb6d604ecb11fa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:41:01 2006 -0400

    NFS: Fix up inode revalidation accounting
    
    Currently, we are accounting for all calls to nfs_revalidate_inode(), but not
    to nfs_revalidate_mapping(), or nfs_lookup_verify_inode(), etc...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 44b11874ff583b6e766a05856b04f3c492c32b84
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:40:59 2006 -0400

    NFS: Separate metadata and page cache revalidation mechanisms
    
    Separate out the function of revalidating the inode metadata, and
    revalidating the mapping. The former may be called by lookup(),
    and only really needs to check that permissions, ctime, etc haven't changed
    whereas the latter needs only done when we want to read data from the page
    cache, and may need to sync and then invalidate the mapping.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 38478b24e37587f1c4fedf8ac070ca54f052ed28
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:40:57 2006 -0400

    NFS: More page cache revalidation fixups
    
    Whenever the directory changes, we want to make sure that we always
    invalidate its page cache. Fix up update_changeattr() and
    nfs_mark_for_revalidate() so that they do so.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1bb0b92ba2cdfffe6e437f7a7da53138cf08d52
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:40:55 2006 -0400

    NFS: Fix page cache revalidation
    
    Fix up a bug in the handling of NFS_INO_REVAL_PAGECACHE: make sure that
    nfs_update_inode() clears it when we're sure we're not racing with other
    updates.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d0b5cb36faf7002a11736032313f06d6f3d881c
Author: Chuck Lever <cel@netapp.com>
Date:   Thu May 25 01:40:53 2006 -0400

    NFS: Optimize allocation of nfs_read/write_data structures
    
    Clean up use of page_array, and fix an off-by-one error noticed by Tom
    Talpey which causes kmalloc calls in cases where using the page_array
    is sufficient.
    
    Test plan:
    Normal client functional testing with r/wsize=32768.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf3fcf89552f24657bcfb6a9d73cd167ebb496c6
Author: Chuck Lever <cel@netapp.com>
Date:   Thu May 25 01:40:51 2006 -0400

    SUNRPC: NFS_ROOT always uses the same XIDs
    
    The XID generator uses get_random_bytes to generate an initial XID.
    NFS_ROOT starts up before the random driver, though, so get_random_bytes
    doesn't set a random XID for NFS_ROOT.  This causes NFS_ROOT mount points
    to reuse XIDs every time the client is booted.  If the client boots often
    enough, the server will start serving old replies out of its DRC.
    
    Use net_random() instead.
    
    Test plan:
    I/O intensive workloads should perform well and generate no errors.  Traces
    taken during client reboots should show that NFS_ROOT mounts use unique
    XIDs after every reboot.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b85d88068444ae5dcb1639bcef770ccbf085dd4e
Author: Chuck Lever <cel@netapp.com>
Date:   Thu May 25 01:40:49 2006 -0400

    SUNRPC: select privileged port numbers at random
    
    Make the RPC client select privileged ephemeral source ports at
    random.  This improves DRC behavior on the server by using the
    same port when reconnecting for the same mount point, but using
    a different port for fresh mounts.
    
    The Linux TCP implementation already does this for nonprivileged
    ports.  Note that TCP sockets in TIME_WAIT will prevent quick reuse
    of a random ephemeral port number by leaving the port INUSE until
    the connection transitions out of TIME_WAIT.
    
    Test plan:
    Connectathon against every known server implementation using multiple
    mount points.  Locking especially.
    
    Signed-off-by: Chuck Lever <cel@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 73a3d07c1082145a3b78407bb5252df290470c4c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:40:47 2006 -0400

    NFS: Clean up inode metadata updates
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9d1e9232223a7f065be7f956a7b749a4cbbbe16d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:40:46 2006 -0400

    NFSv4: Some NFSv4 servers have broken behaviour for the change attribute
    
    The Linux NFSv4 server violates RFC3530 in that the change attribute is not
    guaranteed to be updated for every change to the inode. Our optimisation
    for checking whether or not the inode metadata has changed or not is broken
    too. Grr....
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1de3fc12ea085690547a54b6efa01c7348f1cebd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 25 01:40:44 2006 -0400

    NFS: Clean up and fix page zeroing when we have short reads
    
    The code that is supposed to zero the uninitialised partial pages when the
    server returns a short read is currently broken: it looks at the nfs_page
    wb_pgbase and wb_bytes fields instead of the equivalent nfs_read_data
    values when deciding where to start truncating the page.
    
    Also ensure that we are more careful about setting PG_uptodate
    before retrying a short read: the retry will change the nfs_read_data
    args.pgbase and args.count.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/Documentation/filesystems/automount-support.txt b/Documentation/filesystems/automount-support.txt
index 58c65a1..7cac200 100644
--- a/Documentation/filesystems/automount-support.txt
+++ b/Documentation/filesystems/automount-support.txt
@@ -19,7 +19,7 @@ following procedure:
 
  (2) Have the follow_link() op do the following steps:
 
-     (a) Call do_kern_mount() to call the appropriate filesystem to set up a
+     (a) Call vfs_kern_mount() to call the appropriate filesystem to set up a
          superblock and gain a vfsmount structure representing it.
 
      (b) Copy the nameidata provided as an argument and substitute the dentry
diff --git a/drivers/usb/core/inode.c b/drivers/usb/core/inode.c
index 95f5ad9..bfc9b28 100644
--- a/drivers/usb/core/inode.c
+++ b/drivers/usb/core/inode.c
@@ -569,7 +569,7 @@ static int create_special_files (void)
 	ignore_mount = 1;
 
 	/* create the devices special file */
-	retval = simple_pin_fs("usbfs", &usbfs_mount, &usbfs_mount_count);
+	retval = simple_pin_fs(&usb_fs_type, &usbfs_mount, &usbfs_mount_count);
 	if (retval) {
 		err ("Unable to get usbfs mount");
 		goto exit;
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index 8729430..8b15bb2 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -256,11 +256,12 @@ static int v9fs_show_options(struct seq_
 }
 
 static void
-v9fs_umount_begin(struct super_block *sb)
+v9fs_umount_begin(struct vfsmount *vfsmnt, int flags)
 {
-	struct v9fs_session_info *v9ses = sb->s_fs_info;
+	struct v9fs_session_info *v9ses = vfsmnt->mnt_sb->s_fs_info;
 
-	v9fs_session_cancel(v9ses);
+	if (flags & MNT_FORCE)
+		v9fs_session_cancel(v9ses);
 }
 
 static struct super_operations v9fs_super_ops = {
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index b5cf9e1..99785a7 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -203,7 +203,7 @@ static struct vfsmount *afs_mntpt_do_aut
 
 	/* try and do the mount */
 	kdebug("--- attempting mount %s -o %s ---", devname, options);
-	mnt = do_kern_mount("afs", 0, devname, options);
+	mnt = vfs_kern_mount(&afs_fs_type, 0, devname, options);
 	kdebug("--- mount result %p ---", mnt);
 
 	free_page((unsigned long) devname);
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 82468df..67d1f5c 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -48,7 +48,7 @@ static void afs_put_super(struct super_b
 
 static void afs_destroy_inode(struct inode *inode);
 
-static struct file_system_type afs_fs_type = {
+struct file_system_type afs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "afs",
 	.get_sb		= afs_get_sb,
diff --git a/fs/afs/super.h b/fs/afs/super.h
index ac11362..32de8cc 100644
--- a/fs/afs/super.h
+++ b/fs/afs/super.h
@@ -38,6 +38,8 @@ static inline struct afs_super_info *AFS
 	return sb->s_fs_info;
 }
 
+extern struct file_system_type afs_fs_type;
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_AFS_SUPER_H */
diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
index 07a4996..34ebbc1 100644
--- a/fs/binfmt_misc.c
+++ b/fs/binfmt_misc.c
@@ -55,6 +55,7 @@ typedef struct {
 } Node;
 
 static DEFINE_RWLOCK(entries_lock);
+static struct file_system_type bm_fs_type;
 static struct vfsmount *bm_mnt;
 static int entry_count;
 
@@ -637,7 +638,7 @@ static ssize_t bm_register_write(struct 
 	if (!inode)
 		goto out2;
 
-	err = simple_pin_fs("binfmt_misc", &bm_mnt, &entry_count);
+	err = simple_pin_fs(&bm_fs_type, &bm_mnt, &entry_count);
 	if (err) {
 		iput(inode);
 		inode = NULL;
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 7520f46..8b4de6e 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -403,12 +403,14 @@ static struct quotactl_ops cifs_quotactl
 #endif
 
 #ifdef CONFIG_CIFS_EXPERIMENTAL
-static void cifs_umount_begin(struct super_block * sblock)
+static void cifs_umount_begin(struct vfsmount * vfsmnt, int flags)
 {
 	struct cifs_sb_info *cifs_sb;
 	struct cifsTconInfo * tcon;
 
-	cifs_sb = CIFS_SB(sblock);
+	if (!(flags & MNT_FORCE))
+		return;
+	cifs_sb = CIFS_SB(vfsmnt->mnt_sb);
 	if(cifs_sb == NULL)
 		return;
 
diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index 94dab7b..3e5fe84 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -118,7 +118,7 @@ static struct file_system_type configfs_
 
 int configfs_pin_fs(void)
 {
-	return simple_pin_fs("configfs", &configfs_mount,
+	return simple_pin_fs(&configfs_fs_type, &configfs_mount,
 			     &configfs_mnt_count);
 }
 
diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index 440128e..6fa1e04 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -199,7 +199,7 @@ struct dentry *debugfs_create_file(const
 
 	pr_debug("debugfs: creating file '%s'\n",name);
 
-	error = simple_pin_fs("debugfs", &debugfs_mount, &debugfs_mount_count);
+	error = simple_pin_fs(&debug_fs_type, &debugfs_mount, &debugfs_mount_count);
 	if (error)
 		goto exit;
 
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index a13c0f5..815c824 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -195,9 +195,10 @@ struct inode *fuse_iget(struct super_blo
 	return inode;
 }
 
-static void fuse_umount_begin(struct super_block *sb)
+static void fuse_umount_begin(struct vfsmount *vfsmnt, int flags)
 {
-	fuse_abort_conn(get_fuse_conn_super(sb));
+	if (flags & MNT_FORCE)
+		fuse_abort_conn(get_fuse_conn_super(vfsmnt->mnt_sb));
 }
 
 static void fuse_put_super(struct super_block *sb)
diff --git a/fs/libfs.c b/fs/libfs.c
index 1b11563..fc785d8 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -424,13 +424,13 @@ out:
 
 static DEFINE_SPINLOCK(pin_fs_lock);
 
-int simple_pin_fs(char *name, struct vfsmount **mount, int *count)
+int simple_pin_fs(struct file_system_type *type, struct vfsmount **mount, int *count)
 {
 	struct vfsmount *mnt = NULL;
 	spin_lock(&pin_fs_lock);
 	if (unlikely(!*mount)) {
 		spin_unlock(&pin_fs_lock);
-		mnt = do_kern_mount(name, 0, name, NULL);
+		mnt = vfs_kern_mount(type, 0, type->name, NULL);
 		if (IS_ERR(mnt))
 			return PTR_ERR(mnt);
 		spin_lock(&pin_fs_lock);
diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index bce7444..52774fe 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -147,11 +147,10 @@ u32 nlmclnt_grant(const struct sockaddr_
  * Someone has sent us an SM_NOTIFY. Ensure we bind to the new port number,
  * that we mark locks for reclaiming, and that we bump the pseudo NSM state.
  */
-static inline
-void nlmclnt_prepare_reclaim(struct nlm_host *host, u32 newstate)
+static void nlmclnt_prepare_reclaim(struct nlm_host *host)
 {
+	down_write(&host->h_rwsem);
 	host->h_monitored = 0;
-	host->h_nsmstate = newstate;
 	host->h_state++;
 	host->h_nextrebind = 0;
 	nlm_rebind_host(host);
@@ -164,6 +163,13 @@ void nlmclnt_prepare_reclaim(struct nlm_
 	dprintk("NLM: reclaiming locks for host %s", host->h_name);
 }
 
+static void nlmclnt_finish_reclaim(struct nlm_host *host)
+{
+	host->h_reclaiming = 0;
+	up_write(&host->h_rwsem);
+	dprintk("NLM: done reclaiming locks for host %s", host->h_name);
+}
+
 /*
  * Reclaim all locks on server host. We do this by spawning a separate
  * reclaimer thread.
@@ -171,12 +177,10 @@ void nlmclnt_prepare_reclaim(struct nlm_
 void
 nlmclnt_recovery(struct nlm_host *host, u32 newstate)
 {
-	if (host->h_reclaiming++) {
-		if (host->h_nsmstate == newstate)
-			return;
-		nlmclnt_prepare_reclaim(host, newstate);
-	} else {
-		nlmclnt_prepare_reclaim(host, newstate);
+	if (host->h_nsmstate == newstate)
+		return;
+	host->h_nsmstate = newstate;
+	if (!host->h_reclaiming++) {
 		nlm_get_host(host);
 		__module_get(THIS_MODULE);
 		if (kernel_thread(reclaimer, host, CLONE_KERNEL) < 0)
@@ -190,6 +194,7 @@ reclaimer(void *ptr)
 	struct nlm_host	  *host = (struct nlm_host *) ptr;
 	struct nlm_wait	  *block;
 	struct file_lock *fl, *next;
+	u32 nsmstate;
 
 	daemonize("%s-reclaim", host->h_name);
 	allow_signal(SIGKILL);
@@ -199,19 +204,25 @@ reclaimer(void *ptr)
 	lock_kernel();
 	lockd_up();
 
+	nlmclnt_prepare_reclaim(host);
 	/* First, reclaim all locks that have been marked. */
 restart:
+	nsmstate = host->h_nsmstate;
 	list_for_each_entry_safe(fl, next, &host->h_reclaim, fl_u.nfs_fl.list) {
 		list_del_init(&fl->fl_u.nfs_fl.list);
 
 		if (signalled())
 			continue;
-		if (nlmclnt_reclaim(host, fl) == 0)
-			list_add_tail(&fl->fl_u.nfs_fl.list, &host->h_granted);
-		goto restart;
+		if (nlmclnt_reclaim(host, fl) != 0)
+			continue;
+		list_add_tail(&fl->fl_u.nfs_fl.list, &host->h_granted);
+		if (host->h_nsmstate != nsmstate) {
+			/* Argh! The server rebooted again! */
+			list_splice_init(&host->h_granted, &host->h_reclaim);
+			goto restart;
+		}
 	}
-
-	host->h_reclaiming = 0;
+	nlmclnt_finish_reclaim(host);
 
 	/* Now, wake up all processes that sleep on a blocked lock */
 	list_for_each_entry(block, &nlm_blocked, b_list) {
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index f96e381..4db6209 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -508,7 +508,10 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 	}
 
 	block = nlmclnt_prepare_block(host, fl);
+again:
 	for(;;) {
+		/* Reboot protection */
+		fl->fl_u.nfs_fl.state = host->h_state;
 		status = nlmclnt_call(req, NLMPROC_LOCK);
 		if (status < 0)
 			goto out_unblock;
@@ -531,10 +534,16 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 	}
 
 	if (resp->status == NLM_LCK_GRANTED) {
-		fl->fl_u.nfs_fl.state = host->h_state;
+		down_read(&host->h_rwsem);
+		/* Check whether or not the server has rebooted */
+		if (fl->fl_u.nfs_fl.state != host->h_state) {
+			up_read(&host->h_rwsem);
+			goto again;
+		}
 		fl->fl_flags |= FL_SLEEP;
 		/* Ensure the resulting lock will get added to granted list */
 		do_vfs_lock(fl);
+		up_read(&host->h_rwsem);
 	}
 	status = nlm_stat_to_errno(resp->status);
 out_unblock:
@@ -596,6 +605,7 @@ nlmclnt_reclaim(struct nlm_host *host, s
 static int
 nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 {
+	struct nlm_host	*host = req->a_host;
 	struct nlm_res	*resp = &req->a_res;
 	int		status;
 
@@ -604,7 +614,9 @@ nlmclnt_unlock(struct nlm_rqst *req, str
 	 * request, or to deny it with NLM_LCK_DENIED_GRACE_PERIOD. In either
 	 * case, we want to unlock.
 	 */
+	down_read(&host->h_rwsem);
 	do_vfs_lock(fl);
+	up_read(&host->h_rwsem);
 
 	if (req->a_flags & RPC_TASK_ASYNC)
 		return nlm_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 729ac42..38b0e8a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -112,11 +112,12 @@ nlm_lookup_host(int server, struct socka
 	host->h_version    = version;
 	host->h_proto      = proto;
 	host->h_rpcclnt    = NULL;
-	init_MUTEX(&host->h_sema);
+	mutex_init(&host->h_mutex);
 	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
 	host->h_expires    = jiffies + NLM_HOST_EXPIRE;
 	atomic_set(&host->h_count, 1);
 	init_waitqueue_head(&host->h_gracewait);
+	init_rwsem(&host->h_rwsem);
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
 	host->h_server	   = server;
@@ -172,7 +173,7 @@ nlm_bind_host(struct nlm_host *host)
 			(unsigned)ntohl(host->h_addr.sin_addr.s_addr));
 
 	/* Lock host handle */
-	down(&host->h_sema);
+	mutex_lock(&host->h_mutex);
 
 	/* If we've already created an RPC client, check whether
 	 * RPC rebind is required
@@ -204,12 +205,12 @@ nlm_bind_host(struct nlm_host *host)
 		host->h_rpcclnt = clnt;
 	}
 
-	up(&host->h_sema);
+	mutex_unlock(&host->h_mutex);
 	return clnt;
 
 forgetit:
 	printk("lockd: couldn't create RPC handle for %s\n", host->h_name);
-	up(&host->h_sema);
+	mutex_unlock(&host->h_mutex);
 	return NULL;
 }
 
diff --git a/fs/namespace.c b/fs/namespace.c
index c13072a..866430b 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -585,8 +585,8 @@ static int do_umount(struct vfsmount *mn
 	 */
 
 	lock_kernel();
-	if ((flags & MNT_FORCE) && sb->s_op->umount_begin)
-		sb->s_op->umount_begin(sb);
+	if (sb->s_op->umount_begin)
+		sb->s_op->umount_begin(mnt, flags);
 	unlock_kernel();
 
 	/*
@@ -1172,13 +1172,46 @@ static void expire_mount(struct vfsmount
 }
 
 /*
+ * go through the vfsmounts we've just consigned to the graveyard to
+ * - check that they're still dead
+ * - delete the vfsmount from the appropriate namespace under lock
+ * - dispose of the corpse
+ */
+static void expire_mount_list(struct list_head *graveyard, struct list_head *mounts)
+{
+	struct namespace *namespace;
+	struct vfsmount *mnt;
+
+	while (!list_empty(graveyard)) {
+		LIST_HEAD(umounts);
+		mnt = list_entry(graveyard->next, struct vfsmount, mnt_expire);
+		list_del_init(&mnt->mnt_expire);
+
+		/* don't do anything if the namespace is dead - all the
+		 * vfsmounts from it are going away anyway */
+		namespace = mnt->mnt_namespace;
+		if (!namespace || !namespace->root)
+			continue;
+		get_namespace(namespace);
+
+		spin_unlock(&vfsmount_lock);
+		down_write(&namespace_sem);
+		expire_mount(mnt, mounts, &umounts);
+		up_write(&namespace_sem);
+		release_mounts(&umounts);
+		mntput(mnt);
+		put_namespace(namespace);
+		spin_lock(&vfsmount_lock);
+	}
+}
+
+/*
  * process a list of expirable mountpoints with the intent of discarding any
  * mountpoints that aren't in use and haven't been touched since last we came
  * here
  */
 void mark_mounts_for_expiry(struct list_head *mounts)
 {
-	struct namespace *namespace;
 	struct vfsmount *mnt, *next;
 	LIST_HEAD(graveyard);
 
@@ -1202,38 +1235,79 @@ void mark_mounts_for_expiry(struct list_
 		list_move(&mnt->mnt_expire, &graveyard);
 	}
 
-	/*
-	 * go through the vfsmounts we've just consigned to the graveyard to
-	 * - check that they're still dead
-	 * - delete the vfsmount from the appropriate namespace under lock
-	 * - dispose of the corpse
-	 */
-	while (!list_empty(&graveyard)) {
-		LIST_HEAD(umounts);
-		mnt = list_entry(graveyard.next, struct vfsmount, mnt_expire);
-		list_del_init(&mnt->mnt_expire);
+	expire_mount_list(&graveyard, mounts);
 
-		/* don't do anything if the namespace is dead - all the
-		 * vfsmounts from it are going away anyway */
-		namespace = mnt->mnt_namespace;
-		if (!namespace || !namespace->root)
+	spin_unlock(&vfsmount_lock);
+}
+
+EXPORT_SYMBOL_GPL(mark_mounts_for_expiry);
+
+/*
+ * Ripoff of 'select_parent()'
+ *
+ * search the list of submounts for a given mountpoint, and move any
+ * shrinkable submounts to the 'graveyard' list.
+ */
+static int select_submounts(struct vfsmount *parent, struct list_head *graveyard)
+{
+	struct vfsmount *this_parent = parent;
+	struct list_head *next;
+	int found = 0;
+
+repeat:
+	next = this_parent->mnt_mounts.next;
+resume:
+	while (next != &this_parent->mnt_mounts) {
+		struct list_head *tmp = next;
+		struct vfsmount *mnt = list_entry(tmp, struct vfsmount, mnt_child);
+
+		next = tmp->next;
+		if (!(mnt->mnt_flags & MNT_SHRINKABLE))
 			continue;
-		get_namespace(namespace);
+		/*
+		 * Descend a level if the d_mounts list is non-empty.
+		 */
+		if (!list_empty(&mnt->mnt_mounts)) {
+			this_parent = mnt;
+			goto repeat;
+		}
 
-		spin_unlock(&vfsmount_lock);
-		down_write(&namespace_sem);
-		expire_mount(mnt, mounts, &umounts);
-		up_write(&namespace_sem);
-		release_mounts(&umounts);
-		mntput(mnt);
-		put_namespace(namespace);
-		spin_lock(&vfsmount_lock);
+		if (!propagate_mount_busy(mnt, 1)) {
+			mntget(mnt);
+			list_move_tail(&mnt->mnt_expire, graveyard);
+			found++;
+		}
 	}
+	/*
+	 * All done at this level ... ascend and resume the search
+	 */
+	if (this_parent != parent) {
+		next = this_parent->mnt_child.next;
+		this_parent = this_parent->mnt_parent;
+		goto resume;
+	}
+	return found;
+}
+
+/*
+ * process a list of expirable mountpoints with the intent of discarding any
+ * submounts of a specific parent mountpoint
+ */
+void shrink_submounts(struct vfsmount *mountpoint, struct list_head *mounts)
+{
+	LIST_HEAD(graveyard);
+	int found;
+
+	spin_lock(&vfsmount_lock);
+
+	/* extract submounts of 'mountpoint' from the expiration list */
+	while ((found = select_submounts(mountpoint, &graveyard)) != 0)
+		expire_mount_list(&graveyard, mounts);
 
 	spin_unlock(&vfsmount_lock);
 }
 
-EXPORT_SYMBOL_GPL(mark_mounts_for_expiry);
+EXPORT_SYMBOL_GPL(shrink_submounts);
 
 /*
  * Some copy_from_user() implementations do not return the exact number of
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index ec61fd5..0b572a0 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -4,14 +4,16 @@ #
 
 obj-$(CONFIG_NFS_FS) += nfs.o
 
-nfs-y 			:= dir.o file.o inode.o nfs2xdr.o pagelist.o \
-			   proc.o read.o symlink.o unlink.o write.o
+nfs-y 			:= dir.o file.o inode.o super.o nfs2xdr.o pagelist.o \
+			   proc.o read.o symlink.o unlink.o write.o \
+			   namespace.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o mount_clnt.o      
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
-			   callback.o callback_xdr.o callback_proc.o
+			   callback.o callback_xdr.o callback_proc.o \
+			   nfs4namespace.o
 nfs-$(CONFIG_NFS_DIRECTIO) += direct.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-objs		:= $(nfs-y)
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 90c95ad..d53f8c6 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -182,8 +182,6 @@ static int nfs_callback_authenticate(str
 /*
  * Define NFS4 callback program
  */
-extern struct svc_version nfs4_callback_version1;
-
 static struct svc_version *nfs4_callback_version[] = {
 	[1] = &nfs4_callback_version1,
 };
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 05c38cf..c929913 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -202,7 +202,7 @@ static unsigned decode_recall_args(struc
 	status = decode_fh(xdr, &args->fh);
 out:
 	dprintk("%s: exit with status = %d\n", __FUNCTION__, status);
-	return 0;
+	return status;
 }
 
 static unsigned encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cae74dd..3ddda6f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -528,7 +528,7 @@ static int nfs_readdir(struct file *filp
 
 	lock_kernel();
 
-	res = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (res < 0) {
 		unlock_kernel();
 		return res;
@@ -868,6 +868,17 @@ int nfs_is_exclusive_create(struct inode
 	return (nd->intent.open.flags & O_EXCL) != 0;
 }
 
+static inline int nfs_reval_fsid(struct inode *dir,
+		struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	struct nfs_server *server = NFS_SERVER(dir);
+
+	if (!nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		/* Revalidate fsid on root dir */
+		return __nfs_revalidate_inode(server, dir->i_sb->s_root->d_inode);
+	return 0;
+}
+
 static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
@@ -900,6 +911,11 @@ static struct dentry *nfs_lookup(struct 
 		res = ERR_PTR(error);
 		goto out_unlock;
 	}
+	error = nfs_reval_fsid(dir, &fhandle, &fattr);
+	if (error < 0) {
+		res = ERR_PTR(error);
+		goto out_unlock;
+	}
 	inode = nfs_fhget(dentry->d_sb, &fhandle, &fattr);
 	res = (struct dentry *)inode;
 	if (IS_ERR(res))
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 3c72b0c..402005c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -892,7 +892,7 @@ out:
  * nfs_init_directcache - create a slab cache for nfs_direct_req structures
  *
  */
-int nfs_init_directcache(void)
+int __init nfs_init_directcache(void)
 {
 	nfs_direct_cachep = kmem_cache_create("nfs_direct_cache",
 						sizeof(struct nfs_direct_req),
@@ -906,10 +906,10 @@ int nfs_init_directcache(void)
 }
 
 /**
- * nfs_init_directcache - destroy the slab cache for nfs_direct_req structures
+ * nfs_destroy_directcache - destroy the slab cache for nfs_direct_req structures
  *
  */
-void nfs_destroy_directcache(void)
+void __exit nfs_destroy_directcache(void)
 {
 	if (kmem_cache_destroy(nfs_direct_cachep))
 		printk(KERN_INFO "nfs_direct_cache: not all structures were freed\n");
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index fa05c02..add2891 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -127,23 +127,6 @@ nfs_file_release(struct inode *inode, st
 }
 
 /**
- * nfs_revalidate_file - Revalidate the page cache & related metadata
- * @inode - pointer to inode struct
- * @file - pointer to file
- */
-static int nfs_revalidate_file(struct inode *inode, struct file *filp)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	int retval = 0;
-
-	if ((nfsi->cache_validity & (NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATTR))
-			|| nfs_attribute_timeout(inode))
-		retval = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	nfs_revalidate_mapping(inode, filp->f_mapping);
-	return 0;
-}
-
-/**
  * nfs_revalidate_size - Revalidate the file size
  * @inode - pointer to inode struct
  * @file - pointer to struct file
@@ -228,7 +211,7 @@ #endif
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long) pos);
 
-	result = nfs_revalidate_file(inode, iocb->ki_filp);
+	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 	nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, count);
 	if (!result)
 		result = generic_file_aio_read(iocb, buf, count, pos);
@@ -247,7 +230,7 @@ nfs_file_sendfile(struct file *filp, lof
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long long) *ppos);
 
-	res = nfs_revalidate_file(inode, filp);
+	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (!res)
 		res = generic_file_sendfile(filp, ppos, count, actor, target);
 	return res;
@@ -263,7 +246,7 @@ nfs_file_mmap(struct file * file, struct
 	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	status = nfs_revalidate_file(inode, file);
+	status = nfs_revalidate_mapping(inode, file->f_mapping);
 	if (!status)
 		status = generic_file_mmap(file, vma);
 	return status;
@@ -320,7 +303,11 @@ static int nfs_commit_write(struct file 
 
 static void nfs_invalidate_page(struct page *page, unsigned long offset)
 {
-	/* FIXME: we really should cancel any unstarted writes on this page */
+	struct inode *inode = page->mapping->host;
+
+	/* Cancel any unstarted writes on this page */
+	if (offset == 0)
+		nfs_sync_inode_wait(inode, page->index, 1, FLUSH_INVALIDATE);
 }
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
@@ -373,7 +360,6 @@ #endif
 		if (result)
 			goto out;
 	}
-	nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 
 	result = count;
 	if (!count)
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 3fab5b0..b81e7ed 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -47,7 +47,6 @@ #include <linux/sunrpc/clnt.h>
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 
-#include <linux/nfs_fs_sb.h>
 #include <linux/nfs_fs.h>
 
 #include <linux/nfs_idmap.h>
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 937fbfc..51bc88b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -36,6 +36,8 @@ #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
+#include <linux/inet.h>
+#include <linux/nfs_xdr.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -44,89 +46,17 @@ #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
 #include "iostat.h"
+#include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 #define NFS_PARANOIA 1
 
-/* Maximum number of readahead requests
- * FIXME: this should really be a sysctl so that users may tune it to suit
- *        their needs. People that do NFS over a slow network, might for
- *        instance want to reduce it to something closer to 1 for improved
- *        interactive response.
- */
-#define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
-
 static void nfs_invalidate_inode(struct inode *);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
 
-static struct inode *nfs_alloc_inode(struct super_block *sb);
-static void nfs_destroy_inode(struct inode *);
-static int nfs_write_inode(struct inode *,int);
-static void nfs_delete_inode(struct inode *);
-static void nfs_clear_inode(struct inode *);
-static void nfs_umount_begin(struct super_block *);
-static int  nfs_statfs(struct dentry *, struct kstatfs *);
-static int  nfs_show_options(struct seq_file *, struct vfsmount *);
-static int  nfs_show_stats(struct seq_file *, struct vfsmount *);
 static void nfs_zap_acl_cache(struct inode *);
 
-static struct rpc_program	nfs_program;
-
-static struct super_operations nfs_sops = { 
-	.alloc_inode	= nfs_alloc_inode,
-	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
-	.delete_inode	= nfs_delete_inode,
-	.statfs		= nfs_statfs,
-	.clear_inode	= nfs_clear_inode,
-	.umount_begin	= nfs_umount_begin,
-	.show_options	= nfs_show_options,
-	.show_stats	= nfs_show_stats,
-};
-
-/*
- * RPC cruft for NFS
- */
-static struct rpc_stat		nfs_rpcstat = {
-	.program		= &nfs_program
-};
-static struct rpc_version *	nfs_version[] = {
-	NULL,
-	NULL,
-	&nfs_version2,
-#if defined(CONFIG_NFS_V3)
-	&nfs_version3,
-#elif defined(CONFIG_NFS_V4)
-	NULL,
-#endif
-#if defined(CONFIG_NFS_V4)
-	&nfs_version4,
-#endif
-};
-
-static struct rpc_program	nfs_program = {
-	.name			= "nfs",
-	.number			= NFS_PROGRAM,
-	.nrvers			= ARRAY_SIZE(nfs_version),
-	.version		= nfs_version,
-	.stats			= &nfs_rpcstat,
-	.pipe_dir_name		= "/nfs",
-};
-
-#ifdef CONFIG_NFS_V3_ACL
-static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static struct rpc_version *	nfsacl_version[] = {
-	[3]			= &nfsacl_version3,
-};
-
-struct rpc_program		nfsacl_program = {
-	.name =			"nfsacl",
-	.number =		NFS_ACL_PROGRAM,
-	.nrvers =		ARRAY_SIZE(nfsacl_version),
-	.version =		nfsacl_version,
-	.stats =		&nfsacl_rpcstat,
-};
-#endif  /* CONFIG_NFS_V3_ACL */
+static kmem_cache_t * nfs_inode_cachep;
 
 static inline unsigned long
 nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
@@ -134,8 +64,7 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fat
 	return nfs_fileid_to_ino_t(fattr->fileid);
 }
 
-static int
-nfs_write_inode(struct inode *inode, int sync)
+int nfs_write_inode(struct inode *inode, int sync)
 {
 	int flags = sync ? FLUSH_SYNC : 0;
 	int ret;
@@ -146,31 +75,15 @@ nfs_write_inode(struct inode *inode, int
 	return 0;
 }
 
-static void
-nfs_delete_inode(struct inode * inode)
+void nfs_clear_inode(struct inode *inode)
 {
-	dprintk("NFS: delete_inode(%s/%ld)\n", inode->i_sb->s_id, inode->i_ino);
-
-	truncate_inode_pages(&inode->i_data, 0);
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct rpc_cred *cred;
 
-	nfs_wb_all(inode);
 	/*
 	 * The following should never happen...
 	 */
-	if (nfs_have_writebacks(inode)) {
-		printk(KERN_ERR "nfs_delete_inode: inode %ld has pending RPC requests\n", inode->i_ino);
-	}
-
-	clear_inode(inode);
-}
-
-static void
-nfs_clear_inode(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct rpc_cred *cred;
-
-	nfs_wb_all(inode);
+	BUG_ON(nfs_have_writebacks(inode));
 	BUG_ON (!list_empty(&nfsi->open_files));
 	nfs_zap_acl_cache(inode);
 	cred = nfsi->cache_access.cred;
@@ -179,555 +92,6 @@ nfs_clear_inode(struct inode *inode)
 	BUG_ON(atomic_read(&nfsi->data_updates) != 0);
 }
 
-void
-nfs_umount_begin(struct super_block *sb)
-{
-	struct rpc_clnt	*rpc = NFS_SB(sb)->client;
-
-	/* -EIO all pending I/O */
-	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc);
-	rpc = NFS_SB(sb)->client_acl;
-	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc);
-}
-
-
-static inline unsigned long
-nfs_block_bits(unsigned long bsize, unsigned char *nrbitsp)
-{
-	/* make sure blocksize is a power of two */
-	if ((bsize & (bsize - 1)) || nrbitsp) {
-		unsigned char	nrbits;
-
-		for (nrbits = 31; nrbits && !(bsize & (1 << nrbits)); nrbits--)
-			;
-		bsize = 1 << nrbits;
-		if (nrbitsp)
-			*nrbitsp = nrbits;
-	}
-
-	return bsize;
-}
-
-/*
- * Calculate the number of 512byte blocks used.
- */
-static inline unsigned long
-nfs_calc_block_size(u64 tsize)
-{
-	loff_t used = (tsize + 511) >> 9;
-	return (used > ULONG_MAX) ? ULONG_MAX : used;
-}
-
-/*
- * Compute and set NFS server blocksize
- */
-static inline unsigned long
-nfs_block_size(unsigned long bsize, unsigned char *nrbitsp)
-{
-	if (bsize < NFS_MIN_FILE_IO_SIZE)
-		bsize = NFS_DEF_FILE_IO_SIZE;
-	else if (bsize >= NFS_MAX_FILE_IO_SIZE)
-		bsize = NFS_MAX_FILE_IO_SIZE;
-
-	return nfs_block_bits(bsize, nrbitsp);
-}
-
-/*
- * Obtain the root inode of the file system.
- */
-static struct inode *
-nfs_get_root(struct super_block *sb, struct nfs_fh *rootfh, struct nfs_fsinfo *fsinfo)
-{
-	struct nfs_server	*server = NFS_SB(sb);
-	int			error;
-
-	error = server->rpc_ops->getroot(server, rootfh, fsinfo);
-	if (error < 0) {
-		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		return ERR_PTR(error);
-	}
-
-	return nfs_fhget(sb, rootfh, fsinfo->fattr);
-}
-
-/*
- * Do NFS version-independent mount processing, and sanity checking
- */
-static int
-nfs_sb_init(struct super_block *sb, rpc_authflavor_t authflavor)
-{
-	struct nfs_server	*server;
-	struct inode		*root_inode;
-	struct nfs_fattr	fattr;
-	struct nfs_fsinfo	fsinfo = {
-					.fattr = &fattr,
-				};
-	struct nfs_pathconf pathinfo = {
-			.fattr = &fattr,
-	};
-	int no_root_error = 0;
-	unsigned long max_rpc_payload;
-
-	/* We probably want something more informative here */
-	snprintf(sb->s_id, sizeof(sb->s_id), "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
-
-	server = NFS_SB(sb);
-
-	sb->s_magic      = NFS_SUPER_MAGIC;
-
-	server->io_stats = nfs_alloc_iostats();
-	if (server->io_stats == NULL)
-		return -ENOMEM;
-
-	root_inode = nfs_get_root(sb, &server->fh, &fsinfo);
-	/* Did getting the root inode fail? */
-	if (IS_ERR(root_inode)) {
-		no_root_error = PTR_ERR(root_inode);
-		goto out_no_root;
-	}
-	sb->s_root = d_alloc_root(root_inode);
-	if (!sb->s_root) {
-		no_root_error = -ENOMEM;
-		goto out_no_root;
-	}
-	sb->s_root->d_op = server->rpc_ops->dentry_ops;
-
-	/* mount time stamp, in seconds */
-	server->mount_time = jiffies;
-
-	/* Get some general file system info */
-	if (server->namelen == 0 &&
-	    server->rpc_ops->pathconf(server, &server->fh, &pathinfo) >= 0)
-		server->namelen = pathinfo.max_namelen;
-	/* Work out a lot of parameters */
-	if (server->rsize == 0)
-		server->rsize = nfs_block_size(fsinfo.rtpref, NULL);
-	if (server->wsize == 0)
-		server->wsize = nfs_block_size(fsinfo.wtpref, NULL);
-
-	if (fsinfo.rtmax >= 512 && server->rsize > fsinfo.rtmax)
-		server->rsize = nfs_block_size(fsinfo.rtmax, NULL);
-	if (fsinfo.wtmax >= 512 && server->wsize > fsinfo.wtmax)
-		server->wsize = nfs_block_size(fsinfo.wtmax, NULL);
-
-	max_rpc_payload = nfs_block_size(rpc_max_payload(server->client), NULL);
-	if (server->rsize > max_rpc_payload)
-		server->rsize = max_rpc_payload;
-	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
-		server->rsize = NFS_MAX_FILE_IO_SIZE;
-	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-
-	if (server->wsize > max_rpc_payload)
-		server->wsize = max_rpc_payload;
-	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
-		server->wsize = NFS_MAX_FILE_IO_SIZE;
-	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-
-	if (sb->s_blocksize == 0)
-		sb->s_blocksize = nfs_block_bits(server->wsize,
-							 &sb->s_blocksize_bits);
-	server->wtmult = nfs_block_bits(fsinfo.wtmult, NULL);
-
-	server->dtsize = nfs_block_size(fsinfo.dtpref, NULL);
-	if (server->dtsize > PAGE_CACHE_SIZE)
-		server->dtsize = PAGE_CACHE_SIZE;
-	if (server->dtsize > server->rsize)
-		server->dtsize = server->rsize;
-
-	if (server->flags & NFS_MOUNT_NOAC) {
-		server->acregmin = server->acregmax = 0;
-		server->acdirmin = server->acdirmax = 0;
-		sb->s_flags |= MS_SYNCHRONOUS;
-	}
-	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
-
-	sb->s_maxbytes = fsinfo.maxfilesize;
-	if (sb->s_maxbytes > MAX_LFS_FILESIZE) 
-		sb->s_maxbytes = MAX_LFS_FILESIZE; 
-
-	server->client->cl_intr = (server->flags & NFS_MOUNT_INTR) ? 1 : 0;
-	server->client->cl_softrtry = (server->flags & NFS_MOUNT_SOFT) ? 1 : 0;
-
-	/* We're airborne Set socket buffersize */
-	rpc_setbufsize(server->client, server->wsize + 100, server->rsize + 100);
-	return 0;
-	/* Yargs. It didn't work out. */
-out_no_root:
-	dprintk("nfs_sb_init: get root inode failed: errno %d\n", -no_root_error);
-	if (!IS_ERR(root_inode))
-		iput(root_inode);
-	return no_root_error;
-}
-
-static void nfs_init_timeout_values(struct rpc_timeout *to, int proto, unsigned int timeo, unsigned int retrans)
-{
-	to->to_initval = timeo * HZ / 10;
-	to->to_retries = retrans;
-	if (!to->to_retries)
-		to->to_retries = 2;
-
-	switch (proto) {
-	case IPPROTO_TCP:
-		if (!to->to_initval)
-			to->to_initval = 60 * HZ;
-		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
-			to->to_initval = NFS_MAX_TCP_TIMEOUT;
-		to->to_increment = to->to_initval;
-		to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
-		to->to_exponential = 0;
-		break;
-	case IPPROTO_UDP:
-	default:
-		if (!to->to_initval)
-			to->to_initval = 11 * HZ / 10;
-		if (to->to_initval > NFS_MAX_UDP_TIMEOUT)
-			to->to_initval = NFS_MAX_UDP_TIMEOUT;
-		to->to_maxval = NFS_MAX_UDP_TIMEOUT;
-		to->to_exponential = 1;
-		break;
-	}
-}
-
-/*
- * Create an RPC client handle.
- */
-static struct rpc_clnt *
-nfs_create_client(struct nfs_server *server, const struct nfs_mount_data *data)
-{
-	struct rpc_timeout	timeparms;
-	struct rpc_xprt		*xprt = NULL;
-	struct rpc_clnt		*clnt = NULL;
-	int			proto = (data->flags & NFS_MOUNT_TCP) ? IPPROTO_TCP : IPPROTO_UDP;
-
-	nfs_init_timeout_values(&timeparms, proto, data->timeo, data->retrans);
-
-	server->retrans_timeo = timeparms.to_initval;
-	server->retrans_count = timeparms.to_retries;
-
-	/* create transport and client */
-	xprt = xprt_create_proto(proto, &server->addr, &timeparms);
-	if (IS_ERR(xprt)) {
-		dprintk("%s: cannot create RPC transport. Error = %ld\n",
-				__FUNCTION__, PTR_ERR(xprt));
-		return (struct rpc_clnt *)xprt;
-	}
-	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
-				 server->rpc_ops->version, data->pseudoflavor);
-	if (IS_ERR(clnt)) {
-		dprintk("%s: cannot create RPC client. Error = %ld\n",
-				__FUNCTION__, PTR_ERR(xprt));
-		goto out_fail;
-	}
-
-	clnt->cl_intr     = 1;
-	clnt->cl_softrtry = 1;
-
-	return clnt;
-
-out_fail:
-	return clnt;
-}
-
-/*
- * The way this works is that the mount process passes a structure
- * in the data argument which contains the server's IP address
- * and the root file handle obtained from the server's mount
- * daemon. We stash these away in the private superblock fields.
- */
-static int
-nfs_fill_super(struct super_block *sb, struct nfs_mount_data *data, int silent)
-{
-	struct nfs_server	*server;
-	rpc_authflavor_t	authflavor;
-
-	server           = NFS_SB(sb);
-	sb->s_blocksize_bits = 0;
-	sb->s_blocksize = 0;
-	if (data->bsize)
-		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
-	if (data->rsize)
-		server->rsize = nfs_block_size(data->rsize, NULL);
-	if (data->wsize)
-		server->wsize = nfs_block_size(data->wsize, NULL);
-	server->flags    = data->flags & NFS_MOUNT_FLAGMASK;
-
-	server->acregmin = data->acregmin*HZ;
-	server->acregmax = data->acregmax*HZ;
-	server->acdirmin = data->acdirmin*HZ;
-	server->acdirmax = data->acdirmax*HZ;
-
-	/* Start lockd here, before we might error out */
-	if (!(server->flags & NFS_MOUNT_NONLM))
-		lockd_up();
-
-	server->namelen  = data->namlen;
-	server->hostname = kmalloc(strlen(data->hostname) + 1, GFP_KERNEL);
-	if (!server->hostname)
-		return -ENOMEM;
-	strcpy(server->hostname, data->hostname);
-
-	/* Check NFS protocol revision and initialize RPC op vector
-	 * and file handle pool. */
-#ifdef CONFIG_NFS_V3
-	if (server->flags & NFS_MOUNT_VER3) {
-		server->rpc_ops = &nfs_v3_clientops;
-		server->caps |= NFS_CAP_READDIRPLUS;
-	} else {
-		server->rpc_ops = &nfs_v2_clientops;
-	}
-#else
-	server->rpc_ops = &nfs_v2_clientops;
-#endif
-
-	/* Fill in pseudoflavor for mount version < 5 */
-	if (!(data->flags & NFS_MOUNT_SECFLAVOUR))
-		data->pseudoflavor = RPC_AUTH_UNIX;
-	authflavor = data->pseudoflavor;	/* save for sb_init() */
-	/* XXX maybe we want to add a server->pseudoflavor field */
-
-	/* Create RPC client handles */
-	server->client = nfs_create_client(server, data);
-	if (IS_ERR(server->client))
-		return PTR_ERR(server->client);
-	/* RFC 2623, sec 2.3.2 */
-	if (authflavor != RPC_AUTH_UNIX) {
-		struct rpc_auth *auth;
-
-		server->client_sys = rpc_clone_client(server->client);
-		if (IS_ERR(server->client_sys))
-			return PTR_ERR(server->client_sys);
-		auth = rpcauth_create(RPC_AUTH_UNIX, server->client_sys);
-		if (IS_ERR(auth))
-			return PTR_ERR(auth);
-	} else {
-		atomic_inc(&server->client->cl_count);
-		server->client_sys = server->client;
-	}
-	if (server->flags & NFS_MOUNT_VER3) {
-#ifdef CONFIG_NFS_V3_ACL
-		if (!(server->flags & NFS_MOUNT_NOACL)) {
-			server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
-			/* No errors! Assume that Sun nfsacls are supported */
-			if (!IS_ERR(server->client_acl))
-				server->caps |= NFS_CAP_ACLS;
-		}
-#else
-		server->flags &= ~NFS_MOUNT_NOACL;
-#endif /* CONFIG_NFS_V3_ACL */
-		/*
-		 * The VFS shouldn't apply the umask to mode bits. We will
-		 * do so ourselves when necessary.
-		 */
-		sb->s_flags |= MS_POSIXACL;
-		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
-			server->namelen = NFS3_MAXNAMLEN;
-		sb->s_time_gran = 1;
-	} else {
-		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
-			server->namelen = NFS2_MAXNAMLEN;
-	}
-
-	sb->s_op = &nfs_sops;
-	return nfs_sb_init(sb, authflavor);
-}
-
-static int
-nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
-{
-	struct super_block *sb = dentry->d_sb;
-	struct nfs_server *server = NFS_SB(sb);
-	unsigned char blockbits;
-	unsigned long blockres;
-	struct nfs_fh *rootfh = NFS_FH(sb->s_root->d_inode);
-	struct nfs_fattr fattr;
-	struct nfs_fsstat res = {
-			.fattr = &fattr,
-	};
-	int error;
-
-	lock_kernel();
-
-	error = server->rpc_ops->statfs(server, rootfh, &res);
-	buf->f_type = NFS_SUPER_MAGIC;
-	if (error < 0)
-		goto out_err;
-
-	/*
-	 * Current versions of glibc do not correctly handle the
-	 * case where f_frsize != f_bsize.  Eventually we want to
-	 * report the value of wtmult in this field.
-	 */
-	buf->f_frsize = sb->s_blocksize;
-
-	/*
-	 * On most *nix systems, f_blocks, f_bfree, and f_bavail
-	 * are reported in units of f_frsize.  Linux hasn't had
-	 * an f_frsize field in its statfs struct until recently,
-	 * thus historically Linux's sys_statfs reports these
-	 * fields in units of f_bsize.
-	 */
-	buf->f_bsize = sb->s_blocksize;
-	blockbits = sb->s_blocksize_bits;
-	blockres = (1 << blockbits) - 1;
-	buf->f_blocks = (res.tbytes + blockres) >> blockbits;
-	buf->f_bfree = (res.fbytes + blockres) >> blockbits;
-	buf->f_bavail = (res.abytes + blockres) >> blockbits;
-
-	buf->f_files = res.tfiles;
-	buf->f_ffree = res.afiles;
-
-	buf->f_namelen = server->namelen;
- out:
-	unlock_kernel();
-	return 0;
-
- out_err:
-	dprintk("%s: statfs error = %d\n", __FUNCTION__, -error);
-	buf->f_bsize = buf->f_blocks = buf->f_bfree = buf->f_bavail = -1;
-	goto out;
-
-}
-
-static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss, int showdefaults)
-{
-	static struct proc_nfs_info {
-		int flag;
-		char *str;
-		char *nostr;
-	} nfs_info[] = {
-		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
-		{ NFS_MOUNT_INTR, ",intr", "" },
-		{ NFS_MOUNT_NOCTO, ",nocto", "" },
-		{ NFS_MOUNT_NOAC, ",noac", "" },
-		{ NFS_MOUNT_NONLM, ",nolock", "" },
-		{ NFS_MOUNT_NOACL, ",noacl", "" },
-		{ 0, NULL, NULL }
-	};
-	struct proc_nfs_info *nfs_infop;
-	char buf[12];
-	char *proto;
-
-	seq_printf(m, ",vers=%d", nfss->rpc_ops->version);
-	seq_printf(m, ",rsize=%d", nfss->rsize);
-	seq_printf(m, ",wsize=%d", nfss->wsize);
-	if (nfss->acregmin != 3*HZ || showdefaults)
-		seq_printf(m, ",acregmin=%d", nfss->acregmin/HZ);
-	if (nfss->acregmax != 60*HZ || showdefaults)
-		seq_printf(m, ",acregmax=%d", nfss->acregmax/HZ);
-	if (nfss->acdirmin != 30*HZ || showdefaults)
-		seq_printf(m, ",acdirmin=%d", nfss->acdirmin/HZ);
-	if (nfss->acdirmax != 60*HZ || showdefaults)
-		seq_printf(m, ",acdirmax=%d", nfss->acdirmax/HZ);
-	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
-		if (nfss->flags & nfs_infop->flag)
-			seq_puts(m, nfs_infop->str);
-		else
-			seq_puts(m, nfs_infop->nostr);
-	}
-	switch (nfss->client->cl_xprt->prot) {
-		case IPPROTO_TCP:
-			proto = "tcp";
-			break;
-		case IPPROTO_UDP:
-			proto = "udp";
-			break;
-		default:
-			snprintf(buf, sizeof(buf), "%u", nfss->client->cl_xprt->prot);
-			proto = buf;
-	}
-	seq_printf(m, ",proto=%s", proto);
-	seq_printf(m, ",timeo=%lu", 10U * nfss->retrans_timeo / HZ);
-	seq_printf(m, ",retrans=%u", nfss->retrans_count);
-}
-
-static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
-{
-	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
-
-	nfs_show_mount_options(m, nfss, 0);
-
-	seq_puts(m, ",addr=");
-	seq_escape(m, nfss->hostname, " \t\n\\");
-
-	return 0;
-}
-
-static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
-{
-	int i, cpu;
-	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
-	struct rpc_auth *auth = nfss->client->cl_auth;
-	struct nfs_iostats totals = { };
-
-	seq_printf(m, "statvers=%s", NFS_IOSTAT_VERS);
-
-	/*
-	 * Display all mount option settings
-	 */
-	seq_printf(m, "\n\topts:\t");
-	seq_puts(m, mnt->mnt_sb->s_flags & MS_RDONLY ? "ro" : "rw");
-	seq_puts(m, mnt->mnt_sb->s_flags & MS_SYNCHRONOUS ? ",sync" : "");
-	seq_puts(m, mnt->mnt_sb->s_flags & MS_NOATIME ? ",noatime" : "");
-	seq_puts(m, mnt->mnt_sb->s_flags & MS_NODIRATIME ? ",nodiratime" : "");
-	nfs_show_mount_options(m, nfss, 1);
-
-	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
-
-	seq_printf(m, "\n\tcaps:\t");
-	seq_printf(m, "caps=0x%x", nfss->caps);
-	seq_printf(m, ",wtmult=%d", nfss->wtmult);
-	seq_printf(m, ",dtsize=%d", nfss->dtsize);
-	seq_printf(m, ",bsize=%d", nfss->bsize);
-	seq_printf(m, ",namelen=%d", nfss->namelen);
-
-#ifdef CONFIG_NFS_V4
-	if (nfss->rpc_ops->version == 4) {
-		seq_printf(m, "\n\tnfsv4:\t");
-		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
-		seq_printf(m, ",bm1=0x%x", nfss->attr_bitmask[1]);
-		seq_printf(m, ",acl=0x%x", nfss->acl_bitmask);
-	}
-#endif
-
-	/*
-	 * Display security flavor in effect for this mount
-	 */
-	seq_printf(m, "\n\tsec:\tflavor=%d", auth->au_ops->au_flavor);
-	if (auth->au_flavor)
-		seq_printf(m, ",pseudoflavor=%d", auth->au_flavor);
-
-	/*
-	 * Display superblock I/O counters
-	 */
-	for_each_possible_cpu(cpu) {
-		struct nfs_iostats *stats;
-
-		preempt_disable();
-		stats = per_cpu_ptr(nfss->io_stats, cpu);
-
-		for (i = 0; i < __NFSIOS_COUNTSMAX; i++)
-			totals.events[i] += stats->events[i];
-		for (i = 0; i < __NFSIOS_BYTESMAX; i++)
-			totals.bytes[i] += stats->bytes[i];
-
-		preempt_enable();
-	}
-
-	seq_printf(m, "\n\tevents:\t");
-	for (i = 0; i < __NFSIOS_COUNTSMAX; i++)
-		seq_printf(m, "%lu ", totals.events[i]);
-	seq_printf(m, "\n\tbytes:\t");
-	for (i = 0; i < __NFSIOS_BYTESMAX; i++)
-		seq_printf(m, "%Lu ", totals.bytes[i]);
-	seq_printf(m, "\n");
-
-	rpc_print_iostats(m, nfss->client);
-
-	return 0;
-}
-
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
  */
@@ -890,6 +254,14 @@ nfs_fhget(struct super_block *sb, struct
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
 			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
+			/* Deal with crossing mountpoints */
+			if (!nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
+				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+					inode->i_op = &nfs_referral_inode_operations;
+				else
+					inode->i_op = &nfs_mountpoint_inode_operations;
+				inode->i_fop = NULL;
+			}
 		} else if (S_ISLNK(inode->i_mode))
 			inode->i_op = &nfs_symlink_inode_operations;
 		else
@@ -1208,6 +580,7 @@ __nfs_revalidate_inode(struct nfs_server
 	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
 		inode->i_sb->s_id, (long long)NFS_FILEID(inode));
 
+	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
 	lock_kernel();
 	if (!inode || is_bad_inode(inode))
  		goto out_nowait;
@@ -1221,7 +594,7 @@ __nfs_revalidate_inode(struct nfs_server
 		status = -ESTALE;
 		/* Do we trust the cached ESTALE? */
 		if (NFS_ATTRTIMEO(inode) != 0) {
-			if (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATIME)) {
+			if (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME)) {
 				/* no */
 			} else
 				goto out;
@@ -1252,8 +625,6 @@ __nfs_revalidate_inode(struct nfs_server
 	}
 	spin_unlock(&inode->i_lock);
 
-	nfs_revalidate_mapping(inode, inode->i_mapping);
-
 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
 		nfs_zap_acl_cache(inode);
 
@@ -1287,8 +658,7 @@ int nfs_attribute_timeout(struct inode *
  */
 int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
-	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
-	if (!(NFS_I(inode)->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
+	if (!(NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATTR)
 			&& !nfs_attribute_timeout(inode))
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
@@ -1299,9 +669,16 @@ int nfs_revalidate_inode(struct nfs_serv
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
  */
-void nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
+int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int ret = 0;
+
+	if (NFS_STALE(inode))
+		ret = -ESTALE;
+	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
+			|| nfs_attribute_timeout(inode))
+		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 
 	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
 		nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
@@ -1322,6 +699,7 @@ void nfs_revalidate_mapping(struct inode
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode));
 	}
+	return ret;
 }
 
 /**
@@ -1361,12 +739,6 @@ static void nfs_wcc_update_inode(struct 
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	if ((fattr->valid & NFS_ATTR_PRE_CHANGE) != 0
-			&& nfsi->change_attr == fattr->pre_change_attr) {
-		nfsi->change_attr = fattr->change_attr;
-		nfsi->cache_change_attribute = jiffies;
-	}
-
 	/* If we have atomic WCC data, we may update some attributes */
 	if ((fattr->valid & NFS_ATTR_WCC) != 0) {
 		if (timespec_equal(&inode->i_ctime, &fattr->pre_ctime)) {
@@ -1400,9 +772,6 @@ static int nfs_check_inode_attributes(st
 	int data_unstable;
 
 
-	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
-		return 0;
-
 	/* Has the inode gone and changed behind our back? */
 	if (nfsi->fileid != fattr->fileid
 			|| (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT)) {
@@ -1415,20 +784,13 @@ static int nfs_check_inode_attributes(st
 	/* Do atomic weak cache consistency updates */
 	nfs_wcc_update_inode(inode, fattr);
 
-	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0) {
-		if (nfsi->change_attr == fattr->change_attr)
-			goto out;
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
-		if (!data_unstable)
-			nfsi->cache_validity |= NFS_INO_REVAL_PAGECACHE;
-	}
+	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
+			nfsi->change_attr != fattr->change_attr)
+		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
 	/* Verify a few of the more important attributes */
-	if (!timespec_equal(&inode->i_mtime, &fattr->mtime)) {
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
-		if (!data_unstable)
-			nfsi->cache_validity |= NFS_INO_REVAL_PAGECACHE;
-	}
+	if (!timespec_equal(&inode->i_mtime, &fattr->mtime))
+		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
 	cur_size = i_size_read(inode);
  	new_isize = nfs_size_to_loff_t(fattr->size);
@@ -1445,7 +807,6 @@ static int nfs_check_inode_attributes(st
 	if (inode->i_nlink != fattr->nlink)
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 
-out:
 	if (!timespec_equal(&inode->i_atime, &fattr->atime))
 		nfsi->cache_validity |= NFS_INO_INVALID_ATIME;
 
@@ -1471,7 +832,6 @@ int nfs_refresh_inode(struct inode *inod
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
 	spin_lock(&inode->i_lock);
-	nfsi->cache_validity &= ~NFS_INO_REVAL_PAGECACHE;
 	if (time_after(fattr->time_start, nfsi->last_updated))
 		status = nfs_update_inode(inode, fattr);
 	else
@@ -1496,7 +856,7 @@ int nfs_post_op_update_inode(struct inod
 
 	spin_lock(&inode->i_lock);
 	if (unlikely((fattr->valid & NFS_ATTR_FATTR) == 0)) {
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS;
+		nfsi->cache_validity |= NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 		goto out;
 	}
 	status = nfs_update_inode(inode, fattr);
@@ -1519,6 +879,7 @@ out:
  */
 static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
+	struct nfs_server *server;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	loff_t cur_isize, new_isize;
 	unsigned int	invalid = 0;
@@ -1528,9 +889,6 @@ static int nfs_update_inode(struct inode
 			__FUNCTION__, inode->i_sb->s_id, inode->i_ino,
 			atomic_read(&inode->i_count), fattr->valid);
 
-	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
-		return 0;
-
 	if (nfsi->fileid != fattr->fileid)
 		goto out_fileid;
 
@@ -1540,6 +898,12 @@ static int nfs_update_inode(struct inode
 	if ((inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		goto out_changed;
 
+	server = NFS_SERVER(inode);
+	/* Update the fsid if and only if this is the root directory */
+	if (inode == inode->i_sb->s_root->d_inode
+			&& !nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		server->fsid = fattr->fsid;
+
 	/*
 	 * Update the read time so we don't revalidate too often.
 	 */
@@ -1549,7 +913,7 @@ static int nfs_update_inode(struct inode
 	/* Are we racing with known updates of the metadata on the server? */
 	data_stable = nfs_verify_change_attribute(inode, fattr->time_start);
 	if (data_stable)
-		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME);
+		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATIME);
 
 	/* Do atomic weak cache consistency updates */
 	nfs_wcc_update_inode(inode, fattr);
@@ -1613,15 +977,13 @@ static int nfs_update_inode(struct inode
  		inode->i_blksize = fattr->du.nfs2.blocksize;
  	}
 
-	if ((fattr->valid & NFS_ATTR_FATTR_V4)) {
-		if (nfsi->change_attr != fattr->change_attr) {
-			dprintk("NFS: change_attr change on server for file %s/%ld\n",
-					inode->i_sb->s_id, inode->i_ino);
-			nfsi->change_attr = fattr->change_attr;
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-			nfsi->cache_change_attribute = jiffies;
-		} else
-			invalid &= ~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA);
+	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
+			nfsi->change_attr != fattr->change_attr) {
+		dprintk("NFS: change_attr change on server for file %s/%ld\n",
+				inode->i_sb->s_id, inode->i_ino);
+		nfsi->change_attr = fattr->change_attr;
+		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+		nfsi->cache_change_attribute = jiffies;
 	}
 
 	/* Update attrtimeo value if we're out of the unstable period */
@@ -1669,202 +1031,15 @@ #endif
 	goto out_err;
 }
 
-/*
- * File system information
- */
-
-static int nfs_set_super(struct super_block *s, void *data)
-{
-	s->s_fs_info = data;
-	return set_anon_super(s, data);
-}
- 
-static int nfs_compare_super(struct super_block *sb, void *data)
-{
-	struct nfs_server *server = data;
-	struct nfs_server *old = NFS_SB(sb);
-
-	if (old->addr.sin_addr.s_addr != server->addr.sin_addr.s_addr)
-		return 0;
-	if (old->addr.sin_port != server->addr.sin_port)
-		return 0;
-	return !nfs_compare_fh(&old->fh, &server->fh);
-}
-
-static int nfs_get_sb(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
-{
-	int error;
-	struct nfs_server *server = NULL;
-	struct super_block *s;
-	struct nfs_fh *root;
-	struct nfs_mount_data *data = raw_data;
-
-	error = -EINVAL;
-	if (data == NULL) {
-		dprintk("%s: missing data argument\n", __FUNCTION__);
-		goto out_err_noserver;
-	}
-	if (data->version <= 0 || data->version > NFS_MOUNT_VERSION) {
-		dprintk("%s: bad mount version\n", __FUNCTION__);
-		goto out_err_noserver;
-	}
-	switch (data->version) {
-		case 1:
-			data->namlen = 0;
-		case 2:
-			data->bsize  = 0;
-		case 3:
-			if (data->flags & NFS_MOUNT_VER3) {
-				dprintk("%s: mount structure version %d does not support NFSv3\n",
-						__FUNCTION__,
-						data->version);
-				goto out_err_noserver;
-			}
-			data->root.size = NFS2_FHSIZE;
-			memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
-		case 4:
-			if (data->flags & NFS_MOUNT_SECFLAVOUR) {
-				dprintk("%s: mount structure version %d does not support strong security\n",
-						__FUNCTION__,
-						data->version);
-				goto out_err_noserver;
-			}
-		case 5:
-			memset(data->context, 0, sizeof(data->context));
-	}
-#ifndef CONFIG_NFS_V3
-	/* If NFSv3 is not compiled in, return -EPROTONOSUPPORT */
-	error = -EPROTONOSUPPORT;
-	if (data->flags & NFS_MOUNT_VER3) {
-		dprintk("%s: NFSv3 not compiled into kernel\n", __FUNCTION__);
-		goto out_err_noserver;
-	}
-#endif /* CONFIG_NFS_V3 */
-
-	error = -ENOMEM;
-	server = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
-	if (!server)
-		goto out_err_noserver;
-	/* Zero out the NFS state stuff */
-	init_nfsv4_state(server);
-	server->client = server->client_sys = server->client_acl = ERR_PTR(-EINVAL);
-
-	root = &server->fh;
-	if (data->flags & NFS_MOUNT_VER3)
-		root->size = data->root.size;
-	else
-		root->size = NFS2_FHSIZE;
-	error = -EINVAL;
-	if (root->size > sizeof(root->data)) {
-		dprintk("%s: invalid root filehandle\n", __FUNCTION__);
-		goto out_err;
-	}
-	memcpy(root->data, data->root.data, root->size);
-
-	/* We now require that the mount process passes the remote address */
-	memcpy(&server->addr, &data->addr, sizeof(server->addr));
-	if (server->addr.sin_addr.s_addr == INADDR_ANY) {
-		dprintk("%s: mount program didn't pass remote address!\n",
-				__FUNCTION__);
-		goto out_err;
-	}
-
-	/* Fire up rpciod if not yet running */
-	error = rpciod_up();
-	if (error < 0) {
-		dprintk("%s: couldn't start rpciod! Error = %d\n",
-				__FUNCTION__, error);
-		goto out_err;
-	}
-
-	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
-	if (IS_ERR(s)) {
-		error = PTR_ERR(s);
-		goto out_err_rpciod;
-	}
-
-	if (s->s_root)
-		goto out_rpciod_down;
-
-	s->s_flags = flags;
-
-	error = nfs_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
-	if (error) {
-		up_write(&s->s_umount);
-		deactivate_super(s);
-		return error;
-	}
-	s->s_flags |= MS_ACTIVE;
-	return simple_set_mnt(mnt, s);
-
-out_rpciod_down:
-	rpciod_down();
-	kfree(server);
-	return simple_set_mnt(mnt, s);
-
-out_err_rpciod:
-	rpciod_down();
-out_err:
-	kfree(server);
-out_err_noserver:
-	return error;
-}
-
-static void nfs_kill_super(struct super_block *s)
-{
-	struct nfs_server *server = NFS_SB(s);
-
-	kill_anon_super(s);
-
-	if (!IS_ERR(server->client))
-		rpc_shutdown_client(server->client);
-	if (!IS_ERR(server->client_sys))
-		rpc_shutdown_client(server->client_sys);
-	if (!IS_ERR(server->client_acl))
-		rpc_shutdown_client(server->client_acl);
-
-	if (!(server->flags & NFS_MOUNT_NONLM))
-		lockd_down();	/* release rpc.lockd */
-
-	rpciod_down();		/* release rpciod */
-
-	nfs_free_iostats(server->io_stats);
-	kfree(server->hostname);
-	kfree(server);
-}
-
-static struct file_system_type nfs_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs",
-	.get_sb		= nfs_get_sb,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
 
 #ifdef CONFIG_NFS_V4
 
-static void nfs4_clear_inode(struct inode *);
-
-
-static struct super_operations nfs4_sops = { 
-	.alloc_inode	= nfs_alloc_inode,
-	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
-	.delete_inode	= nfs_delete_inode,
-	.statfs		= nfs_statfs,
-	.clear_inode	= nfs4_clear_inode,
-	.umount_begin	= nfs_umount_begin,
-	.show_options	= nfs_show_options,
-	.show_stats	= nfs_show_stats,
-};
-
 /*
  * Clean out any remaining NFSv4 state that might be left over due
  * to open() calls that passed nfs_atomic_lookup, but failed to call
  * nfs_open().
  */
-static void nfs4_clear_inode(struct inode *inode)
+void nfs4_clear_inode(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -1888,365 +1063,9 @@ static void nfs4_clear_inode(struct inod
 		nfs4_close_state(state, state->state);
 	}
 }
-
-
-static int nfs4_fill_super(struct super_block *sb, struct nfs4_mount_data *data, int silent)
-{
-	struct nfs_server *server;
-	struct nfs4_client *clp = NULL;
-	struct rpc_xprt *xprt = NULL;
-	struct rpc_clnt *clnt = NULL;
-	struct rpc_timeout timeparms;
-	rpc_authflavor_t authflavour;
-	int err = -EIO;
-
-	sb->s_blocksize_bits = 0;
-	sb->s_blocksize = 0;
-	server = NFS_SB(sb);
-	if (data->rsize != 0)
-		server->rsize = nfs_block_size(data->rsize, NULL);
-	if (data->wsize != 0)
-		server->wsize = nfs_block_size(data->wsize, NULL);
-	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
-	server->caps = NFS_CAP_ATOMIC_OPEN;
-
-	server->acregmin = data->acregmin*HZ;
-	server->acregmax = data->acregmax*HZ;
-	server->acdirmin = data->acdirmin*HZ;
-	server->acdirmax = data->acdirmax*HZ;
-
-	server->rpc_ops = &nfs_v4_clientops;
-
-	nfs_init_timeout_values(&timeparms, data->proto, data->timeo, data->retrans);
-
-	server->retrans_timeo = timeparms.to_initval;
-	server->retrans_count = timeparms.to_retries;
-
-	clp = nfs4_get_client(&server->addr.sin_addr);
-	if (!clp) {
-		dprintk("%s: failed to create NFS4 client.\n", __FUNCTION__);
-		return -EIO;
-	}
-
-	/* Now create transport and client */
-	authflavour = RPC_AUTH_UNIX;
-	if (data->auth_flavourlen != 0) {
-		if (data->auth_flavourlen != 1) {
-			dprintk("%s: Invalid number of RPC auth flavours %d.\n",
-					__FUNCTION__, data->auth_flavourlen);
-			err = -EINVAL;
-			goto out_fail;
-		}
-		if (copy_from_user(&authflavour, data->auth_flavours, sizeof(authflavour))) {
-			err = -EFAULT;
-			goto out_fail;
-		}
-	}
-
-	down_write(&clp->cl_sem);
-	if (IS_ERR(clp->cl_rpcclient)) {
-		xprt = xprt_create_proto(data->proto, &server->addr, &timeparms);
-		if (IS_ERR(xprt)) {
-			up_write(&clp->cl_sem);
-			err = PTR_ERR(xprt);
-			dprintk("%s: cannot create RPC transport. Error = %d\n",
-					__FUNCTION__, err);
-			goto out_fail;
-		}
-		clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
-				server->rpc_ops->version, authflavour);
-		if (IS_ERR(clnt)) {
-			up_write(&clp->cl_sem);
-			err = PTR_ERR(clnt);
-			dprintk("%s: cannot create RPC client. Error = %d\n",
-					__FUNCTION__, err);
-			goto out_fail;
-		}
-		clnt->cl_intr     = 1;
-		clnt->cl_softrtry = 1;
-		clp->cl_rpcclient = clnt;
-		memcpy(clp->cl_ipaddr, server->ip_addr, sizeof(clp->cl_ipaddr));
-		nfs_idmap_new(clp);
-	}
-	list_add_tail(&server->nfs4_siblings, &clp->cl_superblocks);
-	clnt = rpc_clone_client(clp->cl_rpcclient);
-	if (!IS_ERR(clnt))
-			server->nfs4_state = clp;
-	up_write(&clp->cl_sem);
-	clp = NULL;
-
-	if (IS_ERR(clnt)) {
-		err = PTR_ERR(clnt);
-		dprintk("%s: cannot create RPC client. Error = %d\n",
-				__FUNCTION__, err);
-		return err;
-	}
-
-	server->client    = clnt;
-
-	if (server->nfs4_state->cl_idmap == NULL) {
-		dprintk("%s: failed to create idmapper.\n", __FUNCTION__);
-		return -ENOMEM;
-	}
-
-	if (clnt->cl_auth->au_flavor != authflavour) {
-		struct rpc_auth *auth;
-
-		auth = rpcauth_create(authflavour, clnt);
-		if (IS_ERR(auth)) {
-			dprintk("%s: couldn't create credcache!\n", __FUNCTION__);
-			return PTR_ERR(auth);
-		}
-	}
-
-	sb->s_time_gran = 1;
-
-	sb->s_op = &nfs4_sops;
-	err = nfs_sb_init(sb, authflavour);
-	if (err == 0)
-		return 0;
-out_fail:
-	if (clp)
-		nfs4_put_client(clp);
-	return err;
-}
-
-static int nfs4_compare_super(struct super_block *sb, void *data)
-{
-	struct nfs_server *server = data;
-	struct nfs_server *old = NFS_SB(sb);
-
-	if (strcmp(server->hostname, old->hostname) != 0)
-		return 0;
-	if (strcmp(server->mnt_path, old->mnt_path) != 0)
-		return 0;
-	return 1;
-}
-
-static void *
-nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
-{
-	void *p = NULL;
-
-	if (!src->len)
-		return ERR_PTR(-EINVAL);
-	if (src->len < maxlen)
-		maxlen = src->len;
-	if (dst == NULL) {
-		p = dst = kmalloc(maxlen + 1, GFP_KERNEL);
-		if (p == NULL)
-			return ERR_PTR(-ENOMEM);
-	}
-	if (copy_from_user(dst, src->data, maxlen)) {
-		kfree(p);
-		return ERR_PTR(-EFAULT);
-	}
-	dst[maxlen] = '\0';
-	return dst;
-}
-
-static int nfs4_get_sb(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
-{
-	int error;
-	struct nfs_server *server;
-	struct super_block *s;
-	struct nfs4_mount_data *data = raw_data;
-	void *p;
-
-	if (data == NULL) {
-		dprintk("%s: missing data argument\n", __FUNCTION__);
-		return -EINVAL;
-	}
-	if (data->version <= 0 || data->version > NFS4_MOUNT_VERSION) {
-		dprintk("%s: bad mount version\n", __FUNCTION__);
-		return -EINVAL;
-	}
-
-	server = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
-	if (!server)
-		return -ENOMEM;
-	/* Zero out the NFS state stuff */
-	init_nfsv4_state(server);
-	server->client = server->client_sys = server->client_acl = ERR_PTR(-EINVAL);
-
-	p = nfs_copy_user_string(NULL, &data->hostname, 256);
-	if (IS_ERR(p))
-		goto out_err;
-	server->hostname = p;
-
-	p = nfs_copy_user_string(NULL, &data->mnt_path, 1024);
-	if (IS_ERR(p))
-		goto out_err;
-	server->mnt_path = p;
-
-	p = nfs_copy_user_string(server->ip_addr, &data->client_addr,
-			sizeof(server->ip_addr) - 1);
-	if (IS_ERR(p))
-		goto out_err;
-
-	/* We now require that the mount process passes the remote address */
-	if (data->host_addrlen != sizeof(server->addr)) {
-		error = -EINVAL;
-		goto out_free;
-	}
-	if (copy_from_user(&server->addr, data->host_addr, sizeof(server->addr))) {
-		error = -EFAULT;
-		goto out_free;
-	}
-	if (server->addr.sin_family != AF_INET ||
-	    server->addr.sin_addr.s_addr == INADDR_ANY) {
-		dprintk("%s: mount program didn't pass remote IP address!\n",
-				__FUNCTION__);
-		error = -EINVAL;
-		goto out_free;
-	}
-
-	/* Fire up rpciod if not yet running */
-	error = rpciod_up();
-	if (error < 0) {
-		dprintk("%s: couldn't start rpciod! Error = %d\n",
-				__FUNCTION__, error);
-		goto out_free;
-	}
-
-	s = sget(fs_type, nfs4_compare_super, nfs_set_super, server);
-	if (IS_ERR(s)) {
-		error = PTR_ERR(s);
-		goto out_free;
-	}
-
-	if (s->s_root) {
-		kfree(server->mnt_path);
-		kfree(server->hostname);
-		kfree(server);
-		return simple_set_mnt(mnt, s);
-	}
-
-	s->s_flags = flags;
-
-	error = nfs4_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
-	if (error) {
-		up_write(&s->s_umount);
-		deactivate_super(s);
-		return error;
-	}
-	s->s_flags |= MS_ACTIVE;
-	return simple_set_mnt(mnt, s);
-out_err:
-	error = PTR_ERR(p);
-out_free:
-	kfree(server->mnt_path);
-	kfree(server->hostname);
-	kfree(server);
-	return error;
-}
-
-static void nfs4_kill_super(struct super_block *sb)
-{
-	struct nfs_server *server = NFS_SB(sb);
-
-	nfs_return_all_delegations(sb);
-	kill_anon_super(sb);
-
-	nfs4_renewd_prepare_shutdown(server);
-
-	if (server->client != NULL && !IS_ERR(server->client))
-		rpc_shutdown_client(server->client);
-
-	destroy_nfsv4_state(server);
-
-	rpciod_down();
-
-	nfs_free_iostats(server->io_stats);
-	kfree(server->hostname);
-	kfree(server);
-}
-
-static struct file_system_type nfs4_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.get_sb		= nfs4_get_sb,
-	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
-static const int nfs_set_port_min = 0;
-static const int nfs_set_port_max = 65535;
-static int param_set_port(const char *val, struct kernel_param *kp)
-{
-	char *endp;
-	int num = simple_strtol(val, &endp, 0);
-	if (endp == val || *endp || num < nfs_set_port_min || num > nfs_set_port_max)
-		return -EINVAL;
-	*((int *)kp->arg) = num;
-	return 0;
-}
-
-module_param_call(callback_tcpport, param_set_port, param_get_int,
-		 &nfs_callback_set_tcpport, 0644);
-
-static int param_set_idmap_timeout(const char *val, struct kernel_param *kp)
-{
-	char *endp;
-	int num = simple_strtol(val, &endp, 0);
-	int jif = num * HZ;
-	if (endp == val || *endp || num < 0 || jif < num)
-		return -EINVAL;
-	*((int *)kp->arg) = jif;
-	return 0;
-}
-
-module_param_call(idmap_cache_timeout, param_set_idmap_timeout, param_get_int,
-		 &nfs_idmap_cache_timeout, 0644);
-
-#define nfs4_init_once(nfsi) \
-	do { \
-		INIT_LIST_HEAD(&(nfsi)->open_states); \
-		nfsi->delegation = NULL; \
-		nfsi->delegation_state = 0; \
-		init_rwsem(&nfsi->rwsem); \
-	} while(0)
-
-static inline int register_nfs4fs(void)
-{
-	int ret;
-
-	ret = nfs_register_sysctl();
-	if (ret != 0)
-		return ret;
-	ret = register_filesystem(&nfs4_fs_type);
-	if (ret != 0)
-		nfs_unregister_sysctl();
-	return ret;
-}
-
-static inline void unregister_nfs4fs(void)
-{
-	unregister_filesystem(&nfs4_fs_type);
-	nfs_unregister_sysctl();
-}
-#else
-#define nfs4_init_once(nfsi) \
-	do { } while (0)
-#define register_nfs4fs() (0)
-#define unregister_nfs4fs()
 #endif
 
-extern int nfs_init_nfspagecache(void);
-extern void nfs_destroy_nfspagecache(void);
-extern int nfs_init_readpagecache(void);
-extern void nfs_destroy_readpagecache(void);
-extern int nfs_init_writepagecache(void);
-extern void nfs_destroy_writepagecache(void);
-#ifdef CONFIG_NFS_DIRECTIO
-extern int nfs_init_directcache(void);
-extern void nfs_destroy_directcache(void);
-#endif
-
-static kmem_cache_t * nfs_inode_cachep;
-
-static struct inode *nfs_alloc_inode(struct super_block *sb)
+struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
 	nfsi = (struct nfs_inode *)kmem_cache_alloc(nfs_inode_cachep, SLAB_KERNEL);
@@ -2265,11 +1084,21 @@ #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
 }
 
-static void nfs_destroy_inode(struct inode *inode)
+void nfs_destroy_inode(struct inode *inode)
 {
 	kmem_cache_free(nfs_inode_cachep, NFS_I(inode));
 }
 
+static inline void nfs4_init_once(struct nfs_inode *nfsi)
+{
+#ifdef CONFIG_NFS_V4
+	INIT_LIST_HEAD(&nfsi->open_states);
+	nfsi->delegation = NULL;
+	nfsi->delegation_state = 0;
+	init_rwsem(&nfsi->rwsem);
+#endif
+}
+
 static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
 {
 	struct nfs_inode *nfsi = (struct nfs_inode *) foo;
@@ -2290,7 +1119,7 @@ static void init_once(void * foo, kmem_c
 	}
 }
  
-static int nfs_init_inodecache(void)
+static int __init nfs_init_inodecache(void)
 {
 	nfs_inode_cachep = kmem_cache_create("nfs_inode_cache",
 					     sizeof(struct nfs_inode),
@@ -2303,7 +1132,7 @@ static int nfs_init_inodecache(void)
 	return 0;
 }
 
-static void nfs_destroy_inodecache(void)
+static void __exit nfs_destroy_inodecache(void)
 {
 	if (kmem_cache_destroy(nfs_inode_cachep))
 		printk(KERN_INFO "nfs_inode_cache: not all structures were freed\n");
@@ -2332,29 +1161,22 @@ static int __init init_nfs_fs(void)
 	if (err)
 		goto out1;
 
-#ifdef CONFIG_NFS_DIRECTIO
 	err = nfs_init_directcache();
 	if (err)
 		goto out0;
-#endif
 
 #ifdef CONFIG_PROC_FS
 	rpc_proc_register(&nfs_rpcstat);
 #endif
-        err = register_filesystem(&nfs_fs_type);
-	if (err)
-		goto out;
-	if ((err = register_nfs4fs()) != 0)
+	if ((err = register_nfs_fs()) != 0)
 		goto out;
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
-#ifdef CONFIG_NFS_DIRECTIO
 	nfs_destroy_directcache();
 out0:
-#endif
 	nfs_destroy_writepagecache();
 out1:
 	nfs_destroy_readpagecache();
@@ -2368,9 +1190,7 @@ out4:
 
 static void __exit exit_nfs_fs(void)
 {
-#ifdef CONFIG_NFS_DIRECTIO
 	nfs_destroy_directcache();
-#endif
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
 	nfs_destroy_inodecache();
@@ -2378,8 +1198,7 @@ #endif
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
-	unregister_filesystem(&nfs_fs_type);
-	unregister_nfs4fs();
+	unregister_nfs_fs();
 }
 
 /* Not quite true; I just maintain it */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
new file mode 100644
index 0000000..bd2815e
--- /dev/null
+++ b/fs/nfs/internal.h
@@ -0,0 +1,186 @@
+/*
+ * NFS internal definitions
+ */
+
+#include <linux/mount.h>
+
+struct nfs_clone_mount {
+	const struct super_block *sb;
+	const struct dentry *dentry;
+	struct nfs_fh *fh;
+	struct nfs_fattr *fattr;
+	char *hostname;
+	char *mnt_path;
+	struct sockaddr_in *addr;
+	rpc_authflavor_t authflavor;
+};
+
+/* namespace-nfs4.c */
+#ifdef CONFIG_NFS_V4
+extern struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentry *dentry);
+#else
+static inline
+struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentry *dentry)
+{
+	return ERR_PTR(-ENOENT);
+}
+#endif
+
+/* callback_xdr.c */
+extern struct svc_version nfs4_callback_version1;
+
+/* pagelist.c */
+extern int __init nfs_init_nfspagecache(void);
+extern void __exit nfs_destroy_nfspagecache(void);
+extern int __init nfs_init_readpagecache(void);
+extern void __exit nfs_destroy_readpagecache(void);
+extern int __init nfs_init_writepagecache(void);
+extern void __exit nfs_destroy_writepagecache(void);
+
+#ifdef CONFIG_NFS_DIRECTIO
+extern int __init nfs_init_directcache(void);
+extern void __exit nfs_destroy_directcache(void);
+#else
+#define nfs_init_directcache() (0)
+#define nfs_destroy_directcache() do {} while(0)
+#endif
+
+/* nfs2xdr.c */
+extern struct rpc_procinfo nfs_procedures[];
+extern u32 * nfs_decode_dirent(u32 *, struct nfs_entry *, int);
+
+/* nfs3xdr.c */
+extern struct rpc_procinfo nfs3_procedures[];
+extern u32 *nfs3_decode_dirent(u32 *, struct nfs_entry *, int);
+
+/* nfs4xdr.c */
+extern int nfs_stat_to_errno(int);
+extern u32 *nfs4_decode_dirent(u32 *p, struct nfs_entry *entry, int plus);
+
+/* nfs4proc.c */
+#ifdef CONFIG_NFS_V4
+extern struct rpc_procinfo nfs4_procedures[];
+
+extern int nfs4_proc_fs_locations(struct inode *dir, struct dentry *dentry,
+				  struct nfs4_fs_locations *fs_locations,
+				  struct page *page);
+#endif
+
+/* inode.c */
+extern struct inode *nfs_alloc_inode(struct super_block *sb);
+extern void nfs_destroy_inode(struct inode *);
+extern int nfs_write_inode(struct inode *,int);
+extern void nfs_clear_inode(struct inode *);
+#ifdef CONFIG_NFS_V4
+extern void nfs4_clear_inode(struct inode *);
+#endif
+
+/* super.c */
+extern struct file_system_type nfs_referral_nfs4_fs_type;
+extern struct file_system_type clone_nfs_fs_type;
+#ifdef CONFIG_NFS_V4
+extern struct file_system_type clone_nfs4_fs_type;
+#endif
+#ifdef CONFIG_PROC_FS
+extern struct rpc_stat nfs_rpcstat;
+#endif
+extern int __init register_nfs_fs(void);
+extern void __exit unregister_nfs_fs(void);
+
+/* namespace.c */
+extern char *nfs_path(const char *base, const struct dentry *dentry,
+		      char *buffer, ssize_t buflen);
+
+/*
+ * Determine the mount path as a string
+ */
+static inline char *
+nfs4_path(const struct dentry *dentry, char *buffer, ssize_t buflen)
+{
+#ifdef CONFIG_NFS_V4
+	return nfs_path(NFS_SB(dentry->d_sb)->mnt_path, dentry, buffer, buflen);
+#else
+	return NULL;
+#endif
+}
+
+/*
+ * Determine the device name as a string
+ */
+static inline char *nfs_devname(const struct vfsmount *mnt_parent,
+			 const struct dentry *dentry,
+			 char *buffer, ssize_t buflen)
+{
+	return nfs_path(mnt_parent->mnt_devname, dentry, buffer, buflen);
+}
+
+/*
+ * Determine the actual block size (and log2 thereof)
+ */
+static inline
+unsigned long nfs_block_bits(unsigned long bsize, unsigned char *nrbitsp)
+{
+	/* make sure blocksize is a power of two */
+	if ((bsize & (bsize - 1)) || nrbitsp) {
+		unsigned char	nrbits;
+
+		for (nrbits = 31; nrbits && !(bsize & (1 << nrbits)); nrbits--)
+			;
+		bsize = 1 << nrbits;
+		if (nrbitsp)
+			*nrbitsp = nrbits;
+	}
+
+	return bsize;
+}
+
+/*
+ * Calculate the number of 512byte blocks used.
+ */
+static inline unsigned long nfs_calc_block_size(u64 tsize)
+{
+	loff_t used = (tsize + 511) >> 9;
+	return (used > ULONG_MAX) ? ULONG_MAX : used;
+}
+
+/*
+ * Compute and set NFS server blocksize
+ */
+static inline
+unsigned long nfs_block_size(unsigned long bsize, unsigned char *nrbitsp)
+{
+	if (bsize < NFS_MIN_FILE_IO_SIZE)
+		bsize = NFS_DEF_FILE_IO_SIZE;
+	else if (bsize >= NFS_MAX_FILE_IO_SIZE)
+		bsize = NFS_MAX_FILE_IO_SIZE;
+
+	return nfs_block_bits(bsize, nrbitsp);
+}
+
+/*
+ * Determine the maximum file size for a superblock
+ */
+static inline
+void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
+{
+	sb->s_maxbytes = (loff_t)maxfilesize;
+	if (sb->s_maxbytes > MAX_LFS_FILESIZE || sb->s_maxbytes <= 0)
+		sb->s_maxbytes = MAX_LFS_FILESIZE;
+}
+
+/*
+ * Check if the string represents a "valid" IPv4 address
+ */
+static inline int valid_ipaddr4(const char *buf)
+{
+	int rc, count, in[4];
+
+	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
+	if (rc != 4)
+		return -EINVAL;
+	for (count = 0; count < 4; count++) {
+		if (in[count] > 255)
+			return -EINVAL;
+	}
+	return 0;
+}
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
new file mode 100644
index 0000000..19b98ca
--- /dev/null
+++ b/fs/nfs/namespace.c
@@ -0,0 +1,229 @@
+/*
+ * linux/fs/nfs/namespace.c
+ *
+ * Copyright (C) 2005 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ * NFS namespace
+ */
+
+#include <linux/config.h>
+
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/nfs_fs.h>
+#include <linux/string.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/vfs.h>
+#include "internal.h"
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+static void nfs_expire_automounts(void *list);
+
+LIST_HEAD(nfs_automount_list);
+static DECLARE_WORK(nfs_automount_task, nfs_expire_automounts, &nfs_automount_list);
+int nfs_mountpoint_expiry_timeout = 500 * HZ;
+
+/*
+ * nfs_path - reconstruct the path given an arbitrary dentry
+ * @base - arbitrary string to prepend to the path
+ * @dentry - pointer to dentry
+ * @buffer - result buffer
+ * @buflen - length of buffer
+ *
+ * Helper function for constructing the path from the
+ * root dentry to an arbitrary hashed dentry.
+ *
+ * This is mainly for use in figuring out the path on the
+ * server side when automounting on top of an existing partition.
+ */
+char *nfs_path(const char *base, const struct dentry *dentry,
+	       char *buffer, ssize_t buflen)
+{
+	char *end = buffer+buflen;
+	int namelen;
+
+	*--end = '\0';
+	buflen--;
+	spin_lock(&dcache_lock);
+	while (!IS_ROOT(dentry)) {
+		namelen = dentry->d_name.len;
+		buflen -= namelen + 1;
+		if (buflen < 0)
+			goto Elong;
+		end -= namelen;
+		memcpy(end, dentry->d_name.name, namelen);
+		*--end = '/';
+		dentry = dentry->d_parent;
+	}
+	spin_unlock(&dcache_lock);
+	namelen = strlen(base);
+	/* Strip off excess slashes in base string */
+	while (namelen > 0 && base[namelen - 1] == '/')
+		namelen--;
+	buflen -= namelen;
+	if (buflen < 0)
+		goto Elong;
+	end -= namelen;
+	memcpy(end, base, namelen);
+	return end;
+Elong:
+	return ERR_PTR(-ENAMETOOLONG);
+}
+
+/*
+ * nfs_follow_mountpoint - handle crossing a mountpoint on the server
+ * @dentry - dentry of mountpoint
+ * @nd - nameidata info
+ *
+ * When we encounter a mountpoint on the server, we want to set up
+ * a mountpoint on the client too, to prevent inode numbers from
+ * colliding, and to allow "df" to work properly.
+ * On NFSv4, we also want to allow for the fact that different
+ * filesystems may be migrated to different servers in a failover
+ * situation, and that different filesystems may want to use
+ * different security flavours.
+ */
+static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
+{
+	struct vfsmount *mnt;
+	struct nfs_server *server = NFS_SERVER(dentry->d_inode);
+	struct dentry *parent;
+	struct nfs_fh fh;
+	struct nfs_fattr fattr;
+	int err;
+
+	BUG_ON(IS_ROOT(dentry));
+	dprintk("%s: enter\n", __FUNCTION__);
+	dput(nd->dentry);
+	nd->dentry = dget(dentry);
+	if (d_mountpoint(nd->dentry))
+		goto out_follow;
+	/* Look it up again */
+	parent = dget_parent(nd->dentry);
+	err = server->rpc_ops->lookup(parent->d_inode, &nd->dentry->d_name, &fh, &fattr);
+	dput(parent);
+	if (err != 0)
+		goto out_err;
+
+	if (fattr.valid & NFS_ATTR_FATTR_V4_REFERRAL)
+		mnt = nfs_do_refmount(nd->mnt, nd->dentry);
+	else
+		mnt = nfs_do_submount(nd->mnt, nd->dentry, &fh, &fattr);
+	err = PTR_ERR(mnt);
+	if (IS_ERR(mnt))
+		goto out_err;
+
+	mntget(mnt);
+	err = do_add_mount(mnt, nd, nd->mnt->mnt_flags|MNT_SHRINKABLE, &nfs_automount_list);
+	if (err < 0) {
+		mntput(mnt);
+		if (err == -EBUSY)
+			goto out_follow;
+		goto out_err;
+	}
+	mntput(nd->mnt);
+	dput(nd->dentry);
+	nd->mnt = mnt;
+	nd->dentry = dget(mnt->mnt_root);
+	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
+out:
+	dprintk("%s: done, returned %d\n", __FUNCTION__, err);
+	return ERR_PTR(err);
+out_err:
+	path_release(nd);
+	goto out;
+out_follow:
+	while(d_mountpoint(nd->dentry) && follow_down(&nd->mnt, &nd->dentry))
+		;
+	err = 0;
+	goto out;
+}
+
+struct inode_operations nfs_mountpoint_inode_operations = {
+	.follow_link	= nfs_follow_mountpoint,
+	.getattr	= nfs_getattr,
+};
+
+struct inode_operations nfs_referral_inode_operations = {
+	.follow_link	= nfs_follow_mountpoint,
+};
+
+static void nfs_expire_automounts(void *data)
+{
+	struct list_head *list = (struct list_head *)data;
+
+	mark_mounts_for_expiry(list);
+	if (!list_empty(list))
+		schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
+}
+
+void nfs_release_automount_timer(void)
+{
+	if (list_empty(&nfs_automount_list)) {
+		cancel_delayed_work(&nfs_automount_task);
+		flush_scheduled_work();
+	}
+}
+
+/*
+ * Clone a mountpoint of the appropriate type
+ */
+static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server, char *devname,
+					   struct nfs_clone_mount *mountdata)
+{
+#ifdef CONFIG_NFS_V4
+	struct vfsmount *mnt = NULL;
+	switch (server->rpc_ops->version) {
+		case 2:
+		case 3:
+			mnt = vfs_kern_mount(&clone_nfs_fs_type, 0, devname, mountdata);
+			break;
+		case 4:
+			mnt = vfs_kern_mount(&clone_nfs4_fs_type, 0, devname, mountdata);
+	}
+	return mnt;
+#else
+	return vfs_kern_mount(&clone_nfs_fs_type, 0, devname, mountdata);
+#endif
+}
+
+/**
+ * nfs_do_submount - set up mountpoint when crossing a filesystem boundary
+ * @mnt_parent - mountpoint of parent directory
+ * @dentry - parent directory
+ * @fh - filehandle for new root dentry
+ * @fattr - attributes for new root inode
+ *
+ */
+struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
+		const struct dentry *dentry, struct nfs_fh *fh,
+		struct nfs_fattr *fattr)
+{
+	struct nfs_clone_mount mountdata = {
+		.sb = mnt_parent->mnt_sb,
+		.dentry = dentry,
+		.fh = fh,
+		.fattr = fattr,
+	};
+	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
+	char *page = (char *) __get_free_page(GFP_USER);
+	char *devname;
+
+	dprintk("%s: submounting on %s/%s\n", __FUNCTION__,
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name);
+	if (page == NULL)
+		goto out;
+	devname = nfs_devname(mnt_parent, dentry, page, PAGE_SIZE);
+	mnt = (struct vfsmount *)devname;
+	if (IS_ERR(devname))
+		goto free_page;
+	mnt = nfs_do_clone_mount(NFS_SB(mnt_parent->mnt_sb), devname, &mountdata);
+free_page:
+	free_page((unsigned long)page);
+out:
+	dprintk("%s: done\n", __FUNCTION__);
+	return mnt;
+}
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index f0015fa..3b939e0 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -23,12 +23,13 @@ #include <linux/sunrpc/clnt.h>
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs_fs.h>
+#include "internal.h"
+
+#include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 /* #define NFS_PARANOIA 1 */
 
-extern int			nfs_stat_to_errno(int stat);
-
 /* Mapping from NFS error code to "errno" error code. */
 #define errno_NFSERR_IO		EIO
 
@@ -131,7 +132,8 @@ xdr_decode_fattr(u32 *p, struct nfs_fatt
 	fattr->du.nfs2.blocksize = ntohl(*p++);
 	rdev = ntohl(*p++);
 	fattr->du.nfs2.blocks = ntohl(*p++);
-	fattr->fsid_u.nfs3 = ntohl(*p++);
+	fattr->fsid.major = ntohl(*p++);
+	fattr->fsid.minor = 0;
 	fattr->fileid = ntohl(*p++);
 	p = xdr_decode_time(p, &fattr->atime);
 	p = xdr_decode_time(p, &fattr->mtime);
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 3328787..7322da4 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -172,8 +172,10 @@ static void nfs3_cache_acls(struct inode
 		inode->i_ino, acl, dfacl);
 	spin_lock(&inode->i_lock);
 	__nfs3_forget_cached_acls(NFS_I(inode));
-	nfsi->acl_access = posix_acl_dup(acl);
-	nfsi->acl_default = posix_acl_dup(dfacl);
+	if (!IS_ERR(acl))
+		nfsi->acl_access = posix_acl_dup(acl);
+	if (!IS_ERR(dfacl))
+		nfsi->acl_default = posix_acl_dup(dfacl);
 	spin_unlock(&inode->i_lock);
 }
 
@@ -254,7 +256,9 @@ struct posix_acl *nfs3_proc_getacl(struc
 			res.acl_access = NULL;
 		}
 	}
-	nfs3_cache_acls(inode, res.acl_access, res.acl_default);
+	nfs3_cache_acls(inode,
+		(res.mask & NFS_ACL)   ? res.acl_access  : ERR_PTR(-EINVAL),
+		(res.mask & NFS_DFACL) ? res.acl_default : ERR_PTR(-EINVAL));
 
 	switch(type) {
 		case ACL_TYPE_ACCESS:
@@ -329,6 +333,7 @@ static int nfs3_proc_setacls(struct inod
 	switch (status) {
 		case 0:
 			status = nfs_refresh_inode(inode, &fattr);
+			nfs3_cache_acls(inode, acl, dfacl);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index cf186f0..7143b1f 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -20,11 +20,10 @@ #include <linux/smp_lock.h>
 #include <linux/nfs_mount.h>
 
 #include "iostat.h"
+#include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
-extern struct rpc_procinfo nfs3_procedures[];
-
 /* A wrapper to handle the EJUKEBOX error message */
 static int
 nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
@@ -809,8 +808,6 @@ nfs3_proc_pathconf(struct nfs_server *se
 	return status;
 }
 
-extern u32 *nfs3_decode_dirent(u32 *, struct nfs_entry *, int);
-
 static int nfs3_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index ec23361..0250269 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -22,14 +22,13 @@ #include <linux/nfs.h>
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfsacl.h>
+#include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
 /* Mapping from NFS error code to "errno" error code. */
 #define errno_NFSERR_IO		EIO
 
-extern int			nfs_stat_to_errno(int);
-
 /*
  * Declare the space requirements for NFS arguments and replies as
  * number of 32bit-words
@@ -166,7 +165,8 @@ xdr_decode_fattr(u32 *p, struct nfs_fatt
 	if (MAJOR(fattr->rdev) != major || MINOR(fattr->rdev) != minor)
 		fattr->rdev = 0;
 
-	p = xdr_decode_hyper(p, &fattr->fsid_u.nfs3);
+	p = xdr_decode_hyper(p, &fattr->fsid.major);
+	fattr->fsid.minor = 0;
 	p = xdr_decode_hyper(p, &fattr->fileid);
 	p = xdr_decode_time3(p, &fattr->atime);
 	p = xdr_decode_time3(p, &fattr->mtime);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 0f5e4e7..9a10286 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -217,6 +217,9 @@ extern int nfs4_proc_renew(struct nfs4_c
 extern int nfs4_do_close(struct inode *inode, struct nfs4_state *state);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
+extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
+extern int nfs4_proc_fs_locations(struct inode *dir, struct dentry *dentry,
+		struct nfs4_fs_locations *fs_locations, struct page *page);
 
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
 extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
@@ -225,6 +228,7 @@ extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
 extern const u32 nfs4_pathconf_bitmap[2];
 extern const u32 nfs4_fsinfo_bitmap[2];
+extern const u32 nfs4_fs_locations_bitmap[2];
 
 /* nfs4renewd.c */
 extern void nfs4_schedule_state_renewal(struct nfs4_client *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
new file mode 100644
index 0000000..ea38d27
--- /dev/null
+++ b/fs/nfs/nfs4namespace.c
@@ -0,0 +1,201 @@
+/*
+ * linux/fs/nfs/nfs4namespace.c
+ *
+ * Copyright (C) 2005 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ * NFSv4 namespace
+ */
+
+#include <linux/config.h>
+
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/nfs_fs.h>
+#include <linux/string.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/vfs.h>
+#include <linux/inet.h>
+#include "internal.h"
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+/*
+ * Check if fs_root is valid
+ */
+static inline char *nfs4_pathname_string(struct nfs4_pathname *pathname,
+					 char *buffer, ssize_t buflen)
+{
+	char *end = buffer + buflen;
+	int n;
+
+	*--end = '\0';
+	buflen--;
+
+	n = pathname->ncomponents;
+	while (--n >= 0) {
+		struct nfs4_string *component = &pathname->components[n];
+		buflen -= component->len + 1;
+		if (buflen < 0)
+			goto Elong;
+		end -= component->len;
+		memcpy(end, component->data, component->len);
+		*--end = '/';
+	}
+	return end;
+Elong:
+	return ERR_PTR(-ENAMETOOLONG);
+}
+
+
+/**
+ * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
+ * @mnt_parent - mountpoint of parent directory
+ * @dentry - parent directory
+ * @fspath - fs path returned in fs_locations
+ * @mntpath - mount path to new server
+ * @hostname - hostname of new server
+ * @addr - host addr of new server
+ *
+ */
+static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
+					    const struct dentry *dentry,
+					    struct nfs4_fs_locations *locations)
+{
+	struct vfsmount *mnt = ERR_PTR(-ENOENT);
+	struct nfs_clone_mount mountdata = {
+		.sb = mnt_parent->mnt_sb,
+		.dentry = dentry,
+		.authflavor = NFS_SB(mnt_parent->mnt_sb)->client->cl_auth->au_flavor,
+	};
+	char *page, *page2;
+	char *path, *fs_path;
+	char *devname;
+	int loc, s;
+
+	if (locations == NULL || locations->nlocations <= 0)
+		goto out;
+
+	dprintk("%s: referral at %s/%s\n", __FUNCTION__,
+		dentry->d_parent->d_name.name, dentry->d_name.name);
+
+	/* Ensure fs path is a prefix of current dentry path */
+	page = (char *) __get_free_page(GFP_USER);
+	if (page == NULL)
+		goto out;
+	page2 = (char *) __get_free_page(GFP_USER);
+	if (page2 == NULL)
+		goto out;
+
+	path = nfs4_path(dentry, page, PAGE_SIZE);
+	if (IS_ERR(path))
+		goto out_free;
+
+	fs_path = nfs4_pathname_string(&locations->fs_path, page2, PAGE_SIZE);
+	if (IS_ERR(fs_path))
+		goto out_free;
+
+	if (strncmp(path, fs_path, strlen(fs_path)) != 0) {
+		dprintk("%s: path %s does not begin with fsroot %s\n", __FUNCTION__, path, fs_path);
+		goto out_free;
+	}
+
+	devname = nfs_devname(mnt_parent, dentry, page, PAGE_SIZE);
+	if (IS_ERR(devname)) {
+		mnt = (struct vfsmount *)devname;
+		goto out_free;
+	}
+
+	loc = 0;
+	while (loc < locations->nlocations && IS_ERR(mnt)) {
+		struct nfs4_fs_location *location = &locations->locations[loc];
+		char *mnt_path;
+
+		if (location == NULL || location->nservers <= 0 ||
+		    location->rootpath.ncomponents == 0) {
+			loc++;
+			continue;
+		}
+
+		mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
+		if (IS_ERR(mnt_path)) {
+			loc++;
+			continue;
+		}
+		mountdata.mnt_path = mnt_path;
+
+		s = 0;
+		while (s < location->nservers) {
+			struct sockaddr_in addr = {};
+
+			if (location->servers[s].len <= 0 ||
+			    valid_ipaddr4(location->servers[s].data) < 0) {
+				s++;
+				continue;
+			}
+
+			mountdata.hostname = location->servers[s].data;
+			addr.sin_addr.s_addr = in_aton(mountdata.hostname);
+			addr.sin_family = AF_INET;
+			addr.sin_port = htons(NFS_PORT);
+			mountdata.addr = &addr;
+
+			mnt = vfs_kern_mount(&nfs_referral_nfs4_fs_type, 0, devname, &mountdata);
+			if (!IS_ERR(mnt)) {
+				break;
+			}
+			s++;
+		}
+		loc++;
+	}
+
+out_free:
+	free_page((unsigned long)page);
+	free_page((unsigned long)page2);
+out:
+	dprintk("%s: done\n", __FUNCTION__);
+	return mnt;
+}
+
+/*
+ * nfs_do_refmount - handle crossing a referral on server
+ * @dentry - dentry of referral
+ * @nd - nameidata info
+ *
+ */
+struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentry *dentry)
+{
+	struct vfsmount *mnt = ERR_PTR(-ENOENT);
+	struct dentry *parent;
+	struct nfs4_fs_locations *fs_locations = NULL;
+	struct page *page;
+	int err;
+
+	/* BUG_ON(IS_ROOT(dentry)); */
+	dprintk("%s: enter\n", __FUNCTION__);
+
+	page = alloc_page(GFP_KERNEL);
+	if (page == NULL)
+		goto out;
+
+	fs_locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
+	if (fs_locations == NULL)
+		goto out_free;
+
+	/* Get locations */
+	parent = dget_parent(dentry);
+	dprintk("%s: getting locations for %s/%s\n", __FUNCTION__, parent->d_name.name, dentry->d_name.name);
+	err = nfs4_proc_fs_locations(parent->d_inode, dentry, fs_locations, page);
+	dput(parent);
+	if (err != 0 || fs_locations->nlocations <= 0 ||
+	    fs_locations->fs_path.ncomponents <= 0)
+		goto out_free;
+
+	mnt = nfs_follow_referral(mnt_parent, dentry, fs_locations);
+out_free:
+	__free_page(page);
+	kfree(fs_locations);
+out:
+	dprintk("%s: done\n", __FUNCTION__);
+	return mnt;
+}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d86c0db..b4916b0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -65,8 +65,6 @@ static int nfs4_async_handle_error(struc
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry);
 static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception);
 static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs4_client *clp);
-extern u32 *nfs4_decode_dirent(u32 *p, struct nfs_entry *entry, int plus);
-extern struct rpc_procinfo nfs4_procedures[];
 
 /* Prevent leaks of NFSv4 errors into userland */
 int nfs4_map_errors(int err)
@@ -121,6 +119,25 @@ const u32 nfs4_fsinfo_bitmap[2] = { FATT
 			0
 };
 
+const u32 nfs4_fs_locations_bitmap[2] = {
+	FATTR4_WORD0_TYPE
+	| FATTR4_WORD0_CHANGE
+	| FATTR4_WORD0_SIZE
+	| FATTR4_WORD0_FSID
+	| FATTR4_WORD0_FILEID
+	| FATTR4_WORD0_FS_LOCATIONS,
+	FATTR4_WORD1_MODE
+	| FATTR4_WORD1_NUMLINKS
+	| FATTR4_WORD1_OWNER
+	| FATTR4_WORD1_OWNER_GROUP
+	| FATTR4_WORD1_RAWDEV
+	| FATTR4_WORD1_SPACE_USED
+	| FATTR4_WORD1_TIME_ACCESS
+	| FATTR4_WORD1_TIME_METADATA
+	| FATTR4_WORD1_TIME_MODIFY
+	| FATTR4_WORD1_MOUNTED_ON_FILEID
+};
+
 static void nfs4_setup_readdir(u64 cookie, u32 *verifier, struct dentry *dentry,
 		struct nfs4_readdir_arg *readdir)
 {
@@ -185,15 +202,15 @@ static void renew_lease(const struct nfs
 	spin_unlock(&clp->cl_lock);
 }
 
-static void update_changeattr(struct inode *inode, struct nfs4_change_info *cinfo)
+static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_inode *nfsi = NFS_I(dir);
 
-	spin_lock(&inode->i_lock);
-	nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
+	spin_lock(&dir->i_lock);
+	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
 	if (cinfo->before == nfsi->change_attr && cinfo->atomic)
 		nfsi->change_attr = cinfo->after;
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&dir->i_lock);
 }
 
 struct nfs4_opendata {
@@ -1331,7 +1348,7 @@ static int _nfs4_server_capabilities(str
 	return status;
 }
 
-static int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
+int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -1443,6 +1460,50 @@ out:
 	return nfs4_map_errors(status);
 }
 
+/*
+ * Get locations and (maybe) other attributes of a referral.
+ * Note that we'll actually follow the referral later when
+ * we detect fsid mismatch in inode revalidation
+ */
+static int nfs4_get_referral(struct inode *dir, struct qstr *name, struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+{
+	int status = -ENOMEM;
+	struct page *page = NULL;
+	struct nfs4_fs_locations *locations = NULL;
+	struct dentry dentry = {};
+
+	page = alloc_page(GFP_KERNEL);
+	if (page == NULL)
+		goto out;
+	locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
+	if (locations == NULL)
+		goto out;
+
+	dentry.d_name.name = name->name;
+	dentry.d_name.len = name->len;
+	status = nfs4_proc_fs_locations(dir, &dentry, locations, page);
+	if (status != 0)
+		goto out;
+	/* Make sure server returned a different fsid for the referral */
+	if (nfs_fsid_equal(&NFS_SERVER(dir)->fsid, &locations->fattr.fsid)) {
+		dprintk("%s: server did not return a different fsid for a referral at %s\n", __FUNCTION__, name->name);
+		status = -EIO;
+		goto out;
+	}
+
+	memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
+	fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
+	if (!fattr->mode)
+		fattr->mode = S_IFDIR;
+	memset(fhandle, 0, sizeof(struct nfs_fh));
+out:
+	if (page)
+		__free_page(page);
+	if (locations)
+		kfree(locations);
+	return status;
+}
+
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs4_getattr_arg args = {
@@ -1547,6 +1608,8 @@ static int _nfs4_proc_lookup(struct inod
 	
 	dprintk("NFS call  lookup %s\n", name->name);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
+	if (status == -NFS4ERR_MOVED)
+		status = nfs4_get_referral(dir, name, fattr, fhandle);
 	dprintk("NFS reply lookup: %d\n", status);
 	return status;
 }
@@ -2008,7 +2071,7 @@ static int _nfs4_proc_link(struct inode 
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
-		nfs_refresh_inode(inode, res.fattr);
+		nfs_post_op_update_inode(inode, res.fattr);
 	}
 
 	return status;
@@ -3570,6 +3633,36 @@ ssize_t nfs4_listxattr(struct dentry *de
 	return len;
 }
 
+int nfs4_proc_fs_locations(struct inode *dir, struct dentry *dentry,
+		struct nfs4_fs_locations *fs_locations, struct page *page)
+{
+	struct nfs_server *server = NFS_SERVER(dir);
+	u32 bitmask[2] = {
+		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
+		[1] = FATTR4_WORD1_MOUNTED_ON_FILEID,
+	};
+	struct nfs4_fs_locations_arg args = {
+		.dir_fh = NFS_FH(dir),
+		.name = &dentry->d_name,
+		.page = page,
+		.bitmask = bitmask,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_argp = &args,
+		.rpc_resp = fs_locations,
+	};
+	int status;
+
+	dprintk("%s: start\n", __FUNCTION__);
+	fs_locations->fattr.valid = 0;
+	fs_locations->server = server;
+	fs_locations->nlocations = 0;
+	status = rpc_call_sync(server->client, &msg, 0);
+	dprintk("%s: returned status = %d\n", __FUNCTION__, status);
+	return status;
+}
+
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7c5d70e..1750d99 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -411,6 +411,15 @@ #define NFS4_enc_setacl_sz	(compound_enc
 #define NFS4_dec_setacl_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
 				op_decode_hdr_maxsz + nfs4_fattr_bitmap_maxsz)
+#define NFS4_enc_fs_locations_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_getattr_maxsz)
+#define NFS4_dec_fs_locations_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_putfh_maxsz + \
+				 op_decode_hdr_maxsz + \
+				 nfs4_fattr_bitmap_maxsz)
 
 static struct {
 	unsigned int	mode;
@@ -722,6 +731,13 @@ static int encode_fsinfo(struct xdr_stre
 			bitmask[1] & nfs4_fsinfo_bitmap[1]);
 }
 
+static int encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask)
+{
+	return encode_getattr_two(xdr,
+				  bitmask[0] & nfs4_fs_locations_bitmap[0],
+				  bitmask[1] & nfs4_fs_locations_bitmap[1]);
+}
+
 static int encode_getfh(struct xdr_stream *xdr)
 {
 	uint32_t *p;
@@ -2003,6 +2019,38 @@ out:
 }
 
 /*
+ * Encode FS_LOCATIONS request
+ */
+static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, uint32_t *p, struct nfs4_fs_locations_arg *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops = 3,
+	};
+	struct rpc_auth *auth = req->rq_task->tk_auth;
+	int replen;
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+		goto out;
+	if ((status = encode_lookup(&xdr, args->name)) != 0)
+		goto out;
+	if ((status = encode_fs_locations(&xdr, args->bitmask)) != 0)
+		goto out;
+	/* set up reply
+	 *   toplevel_status + OP_PUTFH + status
+	 *   + OP_LOOKUP + status + OP_GETATTR + status = 7
+	 */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + 7) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen, &args->page,
+			0, PAGE_SIZE);
+out:
+	return status;
+}
+
+/*
  * START OF "GENERIC" DECODE ROUTINES.
  *   These may look a little ugly since they are imported from a "generic"
  * set of XDR encode/decode routines which are intended to be shared by
@@ -2036,7 +2084,7 @@ #define READ_BUF(nbytes)  do { \
 	} \
 } while (0)
 
-static int decode_opaque_inline(struct xdr_stream *xdr, uint32_t *len, char **string)
+static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
 {
 	uint32_t *p;
 
@@ -2087,7 +2135,7 @@ static int decode_op_hdr(struct xdr_stre
 static int decode_ace(struct xdr_stream *xdr, void *ace, struct nfs4_client *clp)
 {
 	uint32_t *p;
-	uint32_t strlen;
+	unsigned int strlen;
 	char *str;
 
 	READ_BUF(12);
@@ -2217,7 +2265,7 @@ static int decode_attr_symlink_support(s
 	return 0;
 }
 
-static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fsid *fsid)
+static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_fsid *fsid)
 {
 	uint32_t *p;
 
@@ -2285,6 +2333,22 @@ static int decode_attr_fileid(struct xdr
 	return 0;
 }
 
+static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
+{
+	uint32_t *p;
+
+	*fileid = 0;
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_MOUNTED_ON_FILEID - 1U)))
+		return -EIO;
+	if (likely(bitmap[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)) {
+		READ_BUF(8);
+		READ64(*fileid);
+		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
+	}
+	dprintk("%s: fileid=%Lu\n", __FUNCTION__, (unsigned long long)*fileid);
+	return 0;
+}
+
 static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
 {
 	uint32_t *p;
@@ -2336,6 +2400,116 @@ static int decode_attr_files_total(struc
 	return status;
 }
 
+static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
+{
+	int n;
+	uint32_t *p;
+	int status = 0;
+
+	READ_BUF(4);
+	READ32(n);
+	if (n < 0)
+		goto out_eio;
+	if (n == 0)
+		goto root_path;
+	dprintk("path ");
+	path->ncomponents = 0;
+	while (path->ncomponents < n) {
+		struct nfs4_string *component = &path->components[path->ncomponents];
+		status = decode_opaque_inline(xdr, &component->len, &component->data);
+		if (unlikely(status != 0))
+			goto out_eio;
+		if (path->ncomponents != n)
+			dprintk("/");
+		dprintk("%s", component->data);
+		if (path->ncomponents < NFS4_PATHNAME_MAXCOMPONENTS)
+			path->ncomponents++;
+		else {
+			dprintk("cannot parse %d components in path\n", n);
+			goto out_eio;
+		}
+	}
+out:
+	dprintk("\n");
+	return status;
+root_path:
+/* a root pathname is sent as a zero component4 */
+	path->ncomponents = 1;
+	path->components[0].len=0;
+	path->components[0].data=NULL;
+	dprintk("path /\n");
+	goto out;
+out_eio:
+	dprintk(" status %d", status);
+	status = -EIO;
+	goto out;
+}
+
+static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
+{
+	int n;
+	uint32_t *p;
+	int status = -EIO;
+
+	if (unlikely(bitmap[0] & (FATTR4_WORD0_FS_LOCATIONS -1U)))
+		goto out;
+	status = 0;
+	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
+		goto out;
+	dprintk("%s: fsroot ", __FUNCTION__);
+	status = decode_pathname(xdr, &res->fs_path);
+	if (unlikely(status != 0))
+		goto out;
+	READ_BUF(4);
+	READ32(n);
+	if (n <= 0)
+		goto out_eio;
+	res->nlocations = 0;
+	while (res->nlocations < n) {
+		int m;
+		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
+
+		READ_BUF(4);
+		READ32(m);
+		if (m <= 0)
+			goto out_eio;
+
+		loc->nservers = 0;
+		dprintk("%s: servers ", __FUNCTION__);
+		while (loc->nservers < m) {
+			struct nfs4_string *server = &loc->servers[loc->nservers];
+			status = decode_opaque_inline(xdr, &server->len, &server->data);
+			if (unlikely(status != 0))
+				goto out_eio;
+			dprintk("%s ", server->data);
+			if (loc->nservers < NFS4_FS_LOCATION_MAXSERVERS)
+				loc->nservers++;
+			else {
+				int i;
+				dprintk("%s: using first %d of %d servers returned for location %d\n", __FUNCTION__, NFS4_FS_LOCATION_MAXSERVERS, m, res->nlocations);
+				for (i = loc->nservers; i < m; i++) {
+					int len;
+					char *data;
+					status = decode_opaque_inline(xdr, &len, &data);
+					if (unlikely(status != 0))
+						goto out_eio;
+				}
+			}
+		}
+		status = decode_pathname(xdr, &loc->rootpath);
+		if (unlikely(status != 0))
+			goto out_eio;
+		if (res->nlocations < NFS4_FS_LOCATIONS_MAXENTRIES)
+			res->nlocations++;
+	}
+out:
+	dprintk("%s: fs_locations done, error = %d\n", __FUNCTION__, status);
+	return status;
+out_eio:
+	status = -EIO;
+	goto out;
+}
+
 static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
 {
 	uint32_t *p;
@@ -2841,6 +3015,7 @@ static int decode_getfattr(struct xdr_st
 		 bitmap[2] = {0},
 		 type;
 	int status, fmode = 0;
+	uint64_t fileid;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
 		goto xdr_error;
@@ -2863,10 +3038,14 @@ static int decode_getfattr(struct xdr_st
 		goto xdr_error;
 	if ((status = decode_attr_size(xdr, bitmap, &fattr->size)) != 0)
 		goto xdr_error;
-	if ((status = decode_attr_fsid(xdr, bitmap, &fattr->fsid_u.nfs4)) != 0)
+	if ((status = decode_attr_fsid(xdr, bitmap, &fattr->fsid)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_fileid(xdr, bitmap, &fattr->fileid)) != 0)
 		goto xdr_error;
+	if ((status = decode_attr_fs_locations(xdr, bitmap, container_of(fattr,
+						struct nfs4_fs_locations,
+						fattr))) != 0)
+		goto xdr_error;
 	if ((status = decode_attr_mode(xdr, bitmap, &fattr->mode)) != 0)
 		goto xdr_error;
 	fattr->mode |= fmode;
@@ -2886,6 +3065,10 @@ static int decode_getfattr(struct xdr_st
 		goto xdr_error;
 	if ((status = decode_attr_time_modify(xdr, bitmap, &fattr->mtime)) != 0)
 		goto xdr_error;
+	if ((status = decode_attr_mounted_on_fileid(xdr, bitmap, &fileid)) != 0)
+		goto xdr_error;
+	if (fattr->fileid == 0 && fileid != 0)
+		fattr->fileid = fileid;
 	if ((status = verify_attr_len(xdr, savep, attrlen)) == 0)
 		fattr->valid = NFS_ATTR_FATTR | NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4;
 xdr_error:
@@ -3350,8 +3533,7 @@ static int decode_getacl(struct xdr_stre
 					attrlen, recvd);
 			return -EINVAL;
 		}
-		if (attrlen <= *acl_len)
-			xdr_read_pages(xdr, attrlen);
+		xdr_read_pages(xdr, attrlen);
 		*acl_len = attrlen;
 	} else
 		status = -EOPNOTSUPP;
@@ -4211,6 +4393,29 @@ out:
 	return status;
 }
 
+/*
+ * FS_LOCATIONS request
+ */
+static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, uint32_t *p, struct nfs4_fs_locations *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status != 0)
+		goto out;
+	if ((status = decode_putfh(&xdr)) != 0)
+		goto out;
+	if ((status = decode_lookup(&xdr)) != 0)
+		goto out;
+	xdr_enter_page(&xdr, PAGE_SIZE);
+	status = decode_getfattr(&xdr, &res->fattr, res->server);
+out:
+	return status;
+}
+
 uint32_t *nfs4_decode_dirent(uint32_t *p, struct nfs_entry *entry, int plus)
 {
 	uint32_t bitmap[2] = {0};
@@ -4382,6 +4587,7 @@ struct rpc_procinfo	nfs4_procedures[] = 
   PROC(DELEGRETURN,	enc_delegreturn, dec_delegreturn),
   PROC(GETACL,		enc_getacl,	dec_getacl),
   PROC(SETACL,		enc_setacl,	dec_setacl),
+  PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 };
 
 struct rpc_version		nfs_version4 = {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 106aca3..ef94296 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -325,6 +325,7 @@ out:
 
 /**
  * nfs_scan_list - Scan a list for matching requests
+ * @nfsi: NFS inode
  * @head: One of the NFS inode request lists
  * @dst: Destination list
  * @idx_start: lower bound of page->index to scan
@@ -336,14 +337,15 @@ out:
  * The requests are *not* checked to ensure that they form a contiguous set.
  * You must be holding the inode's req_lock when calling this function
  */
-int
-nfs_scan_list(struct list_head *head, struct list_head *dst,
-	      unsigned long idx_start, unsigned int npages)
+int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head,
+		struct list_head *dst, unsigned long idx_start,
+		unsigned int npages)
 {
-	struct list_head	*pos, *tmp;
-	struct nfs_page		*req;
-	unsigned long		idx_end;
-	int			res;
+	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
+	struct nfs_page *req;
+	unsigned long idx_end;
+	int found, i;
+	int res;
 
 	res = 0;
 	if (npages == 0)
@@ -351,25 +353,32 @@ nfs_scan_list(struct list_head *head, st
 	else
 		idx_end = idx_start + npages - 1;
 
-	list_for_each_safe(pos, tmp, head) {
-
-		req = nfs_list_entry(pos);
-
-		if (req->wb_index < idx_start)
-			continue;
-		if (req->wb_index > idx_end)
+	for (;;) {
+		found = radix_tree_gang_lookup(&nfsi->nfs_page_tree,
+				(void **)&pgvec[0], idx_start,
+				NFS_SCAN_MAXENTRIES);
+		if (found <= 0)
 			break;
+		for (i = 0; i < found; i++) {
+			req = pgvec[i];
+			if (req->wb_index > idx_end)
+				goto out;
+			idx_start = req->wb_index + 1;
+			if (req->wb_list_head != head)
+				continue;
+			if (nfs_set_page_writeback_locked(req)) {
+				nfs_list_remove_request(req);
+				nfs_list_add_request(req, dst);
+				res++;
+			}
+		}
 
-		if (!nfs_set_page_writeback_locked(req))
-			continue;
-		nfs_list_remove_request(req);
-		nfs_list_add_request(req, dst);
-		res++;
 	}
+out:
 	return res;
 }
 
-int nfs_init_nfspagecache(void)
+int __init nfs_init_nfspagecache(void)
 {
 	nfs_page_cachep = kmem_cache_create("nfs_page",
 					    sizeof(struct nfs_page),
@@ -381,7 +390,7 @@ int nfs_init_nfspagecache(void)
 	return 0;
 }
 
-void nfs_destroy_nfspagecache(void)
+void __exit nfs_destroy_nfspagecache(void)
 {
 	if (kmem_cache_destroy(nfs_page_cachep))
 		printk(KERN_INFO "nfs_page: not all structures were freed\n");
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 9dd85ca..b3899ea 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -44,11 +44,10 @@ #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
 #include <linux/smp_lock.h>
+#include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
-extern struct rpc_procinfo nfs_procedures[];
-
 /*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
@@ -611,8 +610,6 @@ nfs_proc_pathconf(struct nfs_server *ser
 	return 0;
 }
 
-extern u32 * nfs_decode_dirent(u32 *, struct nfs_entry *, int);
-
 static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	if (task->tk_status >= 0) {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 624ca71..41c2ffe 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -51,14 +51,11 @@ struct nfs_read_data *nfs_readdata_alloc
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		if (pagecount < NFS_PAGEVEC_SIZE)
-			p->pagevec = &p->page_array[0];
+		if (pagecount <= ARRAY_SIZE(p->page_array))
+			p->pagevec = p->page_array;
 		else {
-			size_t size = ++pagecount * sizeof(struct page *);
-			p->pagevec = kmalloc(size, GFP_NOFS);
-			if (p->pagevec) {
-				memset(p->pagevec, 0, size);
-			} else {
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			if (!p->pagevec) {
 				mempool_free(p, nfs_rdata_mempool);
 				p = NULL;
 			}
@@ -104,6 +101,28 @@ int nfs_return_empty_page(struct page *p
 	return 0;
 }
 
+static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
+{
+	unsigned int remainder = data->args.count - data->res.count;
+	unsigned int base = data->args.pgbase + data->res.count;
+	unsigned int pglen;
+	struct page **pages;
+
+	if (data->res.eof == 0 || remainder == 0)
+		return;
+	/*
+	 * Note: "remainder" can never be negative, since we check for
+	 * 	this in the XDR code.
+	 */
+	pages = &data->args.pages[base >> PAGE_CACHE_SHIFT];
+	base &= ~PAGE_CACHE_MASK;
+	pglen = PAGE_CACHE_SIZE - base;
+	if (pglen < remainder)
+		memclear_highpage_flush(*pages, base, pglen);
+	else
+		memclear_highpage_flush(*pages, base, remainder);
+}
+
 /*
  * Read a page synchronously.
  */
@@ -177,11 +196,9 @@ static int nfs_readpage_sync(struct nfs_
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
 	spin_unlock(&inode->i_lock);
 
-	if (count)
-		memclear_highpage_flush(page, rdata->args.pgbase, count);
-	SetPageUptodate(page);
-	if (PageError(page))
-		ClearPageError(page);
+	nfs_readpage_truncate_uninitialised_page(rdata);
+	if (rdata->res.eof || rdata->res.count == rdata->args.count)
+		SetPageUptodate(page);
 	result = 0;
 
 io_error:
@@ -436,20 +453,12 @@ static void nfs_readpage_result_partial(
 	struct nfs_page *req = data->req;
 	struct page *page = req->wb_page;
  
+	if (likely(task->tk_status >= 0))
+		nfs_readpage_truncate_uninitialised_page(data);
+	else
+		SetPageError(page);
 	if (nfs_readpage_result(task, data) != 0)
 		return;
-	if (task->tk_status >= 0) {
-		unsigned int request = data->args.count;
-		unsigned int result = data->res.count;
-
-		if (result < request) {
-			memclear_highpage_flush(page,
-						data->args.pgbase + result,
-						request - result);
-		}
-	} else
-		SetPageError(page);
-
 	if (atomic_dec_and_test(&req->wb_complete)) {
 		if (!PageError(page))
 			SetPageUptodate(page);
@@ -462,6 +471,40 @@ static const struct rpc_call_ops nfs_rea
 	.rpc_release = nfs_readdata_release,
 };
 
+static void nfs_readpage_set_pages_uptodate(struct nfs_read_data *data)
+{
+	unsigned int count = data->res.count;
+	unsigned int base = data->args.pgbase;
+	struct page **pages;
+
+	if (unlikely(count == 0))
+		return;
+	pages = &data->args.pages[base >> PAGE_CACHE_SHIFT];
+	base &= ~PAGE_CACHE_MASK;
+	count += base;
+	for (;count >= PAGE_CACHE_SIZE; count -= PAGE_CACHE_SIZE, pages++)
+		SetPageUptodate(*pages);
+	/*
+	 * Was this an eof or a short read? If the latter, don't mark the page
+	 * as uptodate yet.
+	 */
+	if (count > 0 && (data->res.eof || data->args.count == data->res.count))
+		SetPageUptodate(*pages);
+}
+
+static void nfs_readpage_set_pages_error(struct nfs_read_data *data)
+{
+	unsigned int count = data->args.count;
+	unsigned int base = data->args.pgbase;
+	struct page **pages;
+
+	pages = &data->args.pages[base >> PAGE_CACHE_SHIFT];
+	base &= ~PAGE_CACHE_MASK;
+	count += base;
+	for (;count >= PAGE_CACHE_SIZE; count -= PAGE_CACHE_SIZE, pages++)
+		SetPageError(*pages);
+}
+
 /*
  * This is the callback from RPC telling us whether a reply was
  * received or some error occurred (timeout or socket shutdown).
@@ -469,27 +512,24 @@ static const struct rpc_call_ops nfs_rea
 static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	unsigned int count = data->res.count;
 
+	/*
+	 * Note: nfs_readpage_result may change the values of
+	 * data->args. In the multi-page case, we therefore need
+	 * to ensure that we call the next nfs_readpage_set_page_uptodate()
+	 * first in the multi-page case.
+	 */
+	if (likely(task->tk_status >= 0)) {
+		nfs_readpage_truncate_uninitialised_page(data);
+		nfs_readpage_set_pages_uptodate(data);
+	} else
+		nfs_readpage_set_pages_error(data);
 	if (nfs_readpage_result(task, data) != 0)
 		return;
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
-		struct page *page = req->wb_page;
-		nfs_list_remove_request(req);
 
-		if (task->tk_status >= 0) {
-			if (count < PAGE_CACHE_SIZE) {
-				if (count < req->wb_bytes)
-					memclear_highpage_flush(page,
-							req->wb_pgbase + count,
-							req->wb_bytes - count);
-				count = 0;
-			} else
-				count -= PAGE_CACHE_SIZE;
-			SetPageUptodate(page);
-		} else
-			SetPageError(page);
+		nfs_list_remove_request(req);
 		nfs_readpage_release(req);
 	}
 }
@@ -654,7 +694,7 @@ int nfs_readpages(struct file *filp, str
 	return ret;
 }
 
-int nfs_init_readpagecache(void)
+int __init nfs_init_readpagecache(void)
 {
 	nfs_rdata_cachep = kmem_cache_create("nfs_read_data",
 					     sizeof(struct nfs_read_data),
@@ -671,7 +711,7 @@ int nfs_init_readpagecache(void)
 	return 0;
 }
 
-void nfs_destroy_readpagecache(void)
+void __exit nfs_destroy_readpagecache(void)
 {
 	mempool_destroy(nfs_rdata_mempool);
 	if (kmem_cache_destroy(nfs_rdata_cachep))
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
new file mode 100644
index 0000000..e8a9bee
--- /dev/null
+++ b/fs/nfs/super.c
@@ -0,0 +1,1537 @@
+/*
+ *  linux/fs/nfs/super.c
+ *
+ *  Copyright (C) 1992  Rick Sladkey
+ *
+ *  nfs superblock handling functions
+ *
+ *  Modularised by Alan Cox <Alan.Cox@linux.org>, while hacking some
+ *  experimental NFS changes. Modularisation taken straight from SYS5 fs.
+ *
+ *  Change to nfs_read_super() to permit NFS mounts to multi-homed hosts.
+ *  J.S.Peatfield@damtp.cam.ac.uk
+ *
+ *  Split from inode.c by David Howells <dhowells@redhat.com>
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/init.h>
+
+#include <linux/time.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/stat.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/metrics.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
+#include <linux/nfs4_mount.h>
+#include <linux/lockd/bind.h>
+#include <linux/smp_lock.h>
+#include <linux/seq_file.h>
+#include <linux/mount.h>
+#include <linux/nfs_idmap.h>
+#include <linux/vfs.h>
+#include <linux/inet.h>
+#include <linux/nfs_xdr.h>
+
+#include <asm/system.h>
+#include <asm/uaccess.h>
+
+#include "nfs4_fs.h"
+#include "callback.h"
+#include "delegation.h"
+#include "iostat.h"
+#include "internal.h"
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+/* Maximum number of readahead requests
+ * FIXME: this should really be a sysctl so that users may tune it to suit
+ *        their needs. People that do NFS over a slow network, might for
+ *        instance want to reduce it to something closer to 1 for improved
+ *        interactive response.
+ */
+#define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
+
+/*
+ * RPC cruft for NFS
+ */
+static struct rpc_version * nfs_version[] = {
+	NULL,
+	NULL,
+	&nfs_version2,
+#if defined(CONFIG_NFS_V3)
+	&nfs_version3,
+#elif defined(CONFIG_NFS_V4)
+	NULL,
+#endif
+#if defined(CONFIG_NFS_V4)
+	&nfs_version4,
+#endif
+};
+
+static struct rpc_program nfs_program = {
+	.name			= "nfs",
+	.number			= NFS_PROGRAM,
+	.nrvers			= ARRAY_SIZE(nfs_version),
+	.version		= nfs_version,
+	.stats			= &nfs_rpcstat,
+	.pipe_dir_name		= "/nfs",
+};
+
+struct rpc_stat nfs_rpcstat = {
+	.program		= &nfs_program
+};
+
+
+#ifdef CONFIG_NFS_V3_ACL
+static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
+static struct rpc_version *	nfsacl_version[] = {
+	[3]			= &nfsacl_version3,
+};
+
+struct rpc_program		nfsacl_program = {
+	.name =			"nfsacl",
+	.number =		NFS_ACL_PROGRAM,
+	.nrvers =		ARRAY_SIZE(nfsacl_version),
+	.version =		nfsacl_version,
+	.stats =		&nfsacl_rpcstat,
+};
+#endif  /* CONFIG_NFS_V3_ACL */
+
+static void nfs_umount_begin(struct vfsmount *, int);
+static int  nfs_statfs(struct dentry *, struct kstatfs *);
+static int  nfs_show_options(struct seq_file *, struct vfsmount *);
+static int  nfs_show_stats(struct seq_file *, struct vfsmount *);
+static int nfs_get_sb(struct file_system_type *, int, const char *, void *, struct vfsmount *);
+static int nfs_clone_nfs_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static void nfs_kill_super(struct super_block *);
+
+static struct file_system_type nfs_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs",
+	.get_sb		= nfs_get_sb,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type clone_nfs_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs",
+	.get_sb		= nfs_clone_nfs_sb,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static struct super_operations nfs_sops = {
+	.alloc_inode	= nfs_alloc_inode,
+	.destroy_inode	= nfs_destroy_inode,
+	.write_inode	= nfs_write_inode,
+	.statfs		= nfs_statfs,
+	.clear_inode	= nfs_clear_inode,
+	.umount_begin	= nfs_umount_begin,
+	.show_options	= nfs_show_options,
+	.show_stats	= nfs_show_stats,
+};
+
+#ifdef CONFIG_NFS_V4
+static int nfs4_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static int nfs_clone_nfs4_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static int nfs_referral_nfs4_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static void nfs4_kill_super(struct super_block *sb);
+
+static struct file_system_type nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.get_sb		= nfs4_get_sb,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type clone_nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.get_sb		= nfs_clone_nfs4_sb,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+struct file_system_type nfs_referral_nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.get_sb		= nfs_referral_nfs4_sb,
+	.kill_sb	= nfs4_kill_super,
+	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
+static struct super_operations nfs4_sops = {
+	.alloc_inode	= nfs_alloc_inode,
+	.destroy_inode	= nfs_destroy_inode,
+	.write_inode	= nfs_write_inode,
+	.statfs		= nfs_statfs,
+	.clear_inode	= nfs4_clear_inode,
+	.umount_begin	= nfs_umount_begin,
+	.show_options	= nfs_show_options,
+	.show_stats	= nfs_show_stats,
+};
+#endif
+
+#ifdef CONFIG_NFS_V4
+static const int nfs_set_port_min = 0;
+static const int nfs_set_port_max = 65535;
+
+static int param_set_port(const char *val, struct kernel_param *kp)
+{
+	char *endp;
+	int num = simple_strtol(val, &endp, 0);
+	if (endp == val || *endp || num < nfs_set_port_min || num > nfs_set_port_max)
+		return -EINVAL;
+	*((int *)kp->arg) = num;
+	return 0;
+}
+
+module_param_call(callback_tcpport, param_set_port, param_get_int,
+		 &nfs_callback_set_tcpport, 0644);
+#endif
+
+#ifdef CONFIG_NFS_V4
+static int param_set_idmap_timeout(const char *val, struct kernel_param *kp)
+{
+	char *endp;
+	int num = simple_strtol(val, &endp, 0);
+	int jif = num * HZ;
+	if (endp == val || *endp || num < 0 || jif < num)
+		return -EINVAL;
+	*((int *)kp->arg) = jif;
+	return 0;
+}
+
+module_param_call(idmap_cache_timeout, param_set_idmap_timeout, param_get_int,
+		 &nfs_idmap_cache_timeout, 0644);
+#endif
+
+/*
+ * Register the NFS filesystems
+ */
+int __init register_nfs_fs(void)
+{
+	int ret;
+
+        ret = register_filesystem(&nfs_fs_type);
+	if (ret < 0)
+		goto error_0;
+
+#ifdef CONFIG_NFS_V4
+	ret = nfs_register_sysctl();
+	if (ret < 0)
+		goto error_1;
+	ret = register_filesystem(&nfs4_fs_type);
+	if (ret < 0)
+		goto error_2;
+#endif
+	return 0;
+
+#ifdef CONFIG_NFS_V4
+error_2:
+	nfs_unregister_sysctl();
+error_1:
+	unregister_filesystem(&nfs_fs_type);
+#endif
+error_0:
+	return ret;
+}
+
+/*
+ * Unregister the NFS filesystems
+ */
+void __exit unregister_nfs_fs(void)
+{
+#ifdef CONFIG_NFS_V4
+	unregister_filesystem(&nfs4_fs_type);
+	nfs_unregister_sysctl();
+#endif
+	unregister_filesystem(&nfs_fs_type);
+}
+
+/*
+ * Deliver file system statistics to userspace
+ */
+static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
+{
+	struct super_block *sb = dentry->d_sb;
+	struct nfs_server *server = NFS_SB(sb);
+	unsigned char blockbits;
+	unsigned long blockres;
+	struct nfs_fh *rootfh = NFS_FH(sb->s_root->d_inode);
+	struct nfs_fattr fattr;
+	struct nfs_fsstat res = {
+			.fattr = &fattr,
+	};
+	int error;
+
+	lock_kernel();
+
+	error = server->rpc_ops->statfs(server, rootfh, &res);
+	buf->f_type = NFS_SUPER_MAGIC;
+	if (error < 0)
+		goto out_err;
+
+	/*
+	 * Current versions of glibc do not correctly handle the
+	 * case where f_frsize != f_bsize.  Eventually we want to
+	 * report the value of wtmult in this field.
+	 */
+	buf->f_frsize = sb->s_blocksize;
+
+	/*
+	 * On most *nix systems, f_blocks, f_bfree, and f_bavail
+	 * are reported in units of f_frsize.  Linux hasn't had
+	 * an f_frsize field in its statfs struct until recently,
+	 * thus historically Linux's sys_statfs reports these
+	 * fields in units of f_bsize.
+	 */
+	buf->f_bsize = sb->s_blocksize;
+	blockbits = sb->s_blocksize_bits;
+	blockres = (1 << blockbits) - 1;
+	buf->f_blocks = (res.tbytes + blockres) >> blockbits;
+	buf->f_bfree = (res.fbytes + blockres) >> blockbits;
+	buf->f_bavail = (res.abytes + blockres) >> blockbits;
+
+	buf->f_files = res.tfiles;
+	buf->f_ffree = res.afiles;
+
+	buf->f_namelen = server->namelen;
+ out:
+	unlock_kernel();
+	return 0;
+
+ out_err:
+	dprintk("%s: statfs error = %d\n", __FUNCTION__, -error);
+	buf->f_bsize = buf->f_blocks = buf->f_bfree = buf->f_bavail = -1;
+	goto out;
+
+}
+
+static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
+{
+	static struct {
+		rpc_authflavor_t flavour;
+		const char *str;
+	} sec_flavours[] = {
+		{ RPC_AUTH_NULL, "null" },
+		{ RPC_AUTH_UNIX, "sys" },
+		{ RPC_AUTH_GSS_KRB5, "krb5" },
+		{ RPC_AUTH_GSS_KRB5I, "krb5i" },
+		{ RPC_AUTH_GSS_KRB5P, "krb5p" },
+		{ RPC_AUTH_GSS_LKEY, "lkey" },
+		{ RPC_AUTH_GSS_LKEYI, "lkeyi" },
+		{ RPC_AUTH_GSS_LKEYP, "lkeyp" },
+		{ RPC_AUTH_GSS_SPKM, "spkm" },
+		{ RPC_AUTH_GSS_SPKMI, "spkmi" },
+		{ RPC_AUTH_GSS_SPKMP, "spkmp" },
+		{ -1, "unknown" }
+	};
+	int i;
+
+	for (i=0; sec_flavours[i].flavour != -1; i++) {
+		if (sec_flavours[i].flavour == flavour)
+			break;
+	}
+	return sec_flavours[i].str;
+}
+
+/*
+ * Describe the mount options in force on this server representation
+ */
+static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss, int showdefaults)
+{
+	static struct proc_nfs_info {
+		int flag;
+		char *str;
+		char *nostr;
+	} nfs_info[] = {
+		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
+		{ NFS_MOUNT_INTR, ",intr", "" },
+		{ NFS_MOUNT_NOCTO, ",nocto", "" },
+		{ NFS_MOUNT_NOAC, ",noac", "" },
+		{ NFS_MOUNT_NONLM, ",nolock", "" },
+		{ NFS_MOUNT_NOACL, ",noacl", "" },
+		{ 0, NULL, NULL }
+	};
+	struct proc_nfs_info *nfs_infop;
+	char buf[12];
+	char *proto;
+
+	seq_printf(m, ",vers=%d", nfss->rpc_ops->version);
+	seq_printf(m, ",rsize=%d", nfss->rsize);
+	seq_printf(m, ",wsize=%d", nfss->wsize);
+	if (nfss->acregmin != 3*HZ || showdefaults)
+		seq_printf(m, ",acregmin=%d", nfss->acregmin/HZ);
+	if (nfss->acregmax != 60*HZ || showdefaults)
+		seq_printf(m, ",acregmax=%d", nfss->acregmax/HZ);
+	if (nfss->acdirmin != 30*HZ || showdefaults)
+		seq_printf(m, ",acdirmin=%d", nfss->acdirmin/HZ);
+	if (nfss->acdirmax != 60*HZ || showdefaults)
+		seq_printf(m, ",acdirmax=%d", nfss->acdirmax/HZ);
+	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
+		if (nfss->flags & nfs_infop->flag)
+			seq_puts(m, nfs_infop->str);
+		else
+			seq_puts(m, nfs_infop->nostr);
+	}
+	switch (nfss->client->cl_xprt->prot) {
+		case IPPROTO_TCP:
+			proto = "tcp";
+			break;
+		case IPPROTO_UDP:
+			proto = "udp";
+			break;
+		default:
+			snprintf(buf, sizeof(buf), "%u", nfss->client->cl_xprt->prot);
+			proto = buf;
+	}
+	seq_printf(m, ",proto=%s", proto);
+	seq_printf(m, ",timeo=%lu", 10U * nfss->retrans_timeo / HZ);
+	seq_printf(m, ",retrans=%u", nfss->retrans_count);
+	seq_printf(m, ",sec=%s", nfs_pseudoflavour_to_name(nfss->client->cl_auth->au_flavor));
+}
+
+/*
+ * Describe the mount options on this VFS mountpoint
+ */
+static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
+{
+	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
+
+	nfs_show_mount_options(m, nfss, 0);
+
+	seq_puts(m, ",addr=");
+	seq_escape(m, nfss->hostname, " \t\n\\");
+
+	return 0;
+}
+
+/*
+ * Present statistical information for this VFS mountpoint
+ */
+static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
+{
+	int i, cpu;
+	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
+	struct rpc_auth *auth = nfss->client->cl_auth;
+	struct nfs_iostats totals = { };
+
+	seq_printf(m, "statvers=%s", NFS_IOSTAT_VERS);
+
+	/*
+	 * Display all mount option settings
+	 */
+	seq_printf(m, "\n\topts:\t");
+	seq_puts(m, mnt->mnt_sb->s_flags & MS_RDONLY ? "ro" : "rw");
+	seq_puts(m, mnt->mnt_sb->s_flags & MS_SYNCHRONOUS ? ",sync" : "");
+	seq_puts(m, mnt->mnt_sb->s_flags & MS_NOATIME ? ",noatime" : "");
+	seq_puts(m, mnt->mnt_sb->s_flags & MS_NODIRATIME ? ",nodiratime" : "");
+	nfs_show_mount_options(m, nfss, 1);
+
+	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
+
+	seq_printf(m, "\n\tcaps:\t");
+	seq_printf(m, "caps=0x%x", nfss->caps);
+	seq_printf(m, ",wtmult=%d", nfss->wtmult);
+	seq_printf(m, ",dtsize=%d", nfss->dtsize);
+	seq_printf(m, ",bsize=%d", nfss->bsize);
+	seq_printf(m, ",namelen=%d", nfss->namelen);
+
+#ifdef CONFIG_NFS_V4
+	if (nfss->rpc_ops->version == 4) {
+		seq_printf(m, "\n\tnfsv4:\t");
+		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
+		seq_printf(m, ",bm1=0x%x", nfss->attr_bitmask[1]);
+		seq_printf(m, ",acl=0x%x", nfss->acl_bitmask);
+	}
+#endif
+
+	/*
+	 * Display security flavor in effect for this mount
+	 */
+	seq_printf(m, "\n\tsec:\tflavor=%d", auth->au_ops->au_flavor);
+	if (auth->au_flavor)
+		seq_printf(m, ",pseudoflavor=%d", auth->au_flavor);
+
+	/*
+	 * Display superblock I/O counters
+	 */
+	for_each_possible_cpu(cpu) {
+		struct nfs_iostats *stats;
+
+		preempt_disable();
+		stats = per_cpu_ptr(nfss->io_stats, cpu);
+
+		for (i = 0; i < __NFSIOS_COUNTSMAX; i++)
+			totals.events[i] += stats->events[i];
+		for (i = 0; i < __NFSIOS_BYTESMAX; i++)
+			totals.bytes[i] += stats->bytes[i];
+
+		preempt_enable();
+	}
+
+	seq_printf(m, "\n\tevents:\t");
+	for (i = 0; i < __NFSIOS_COUNTSMAX; i++)
+		seq_printf(m, "%lu ", totals.events[i]);
+	seq_printf(m, "\n\tbytes:\t");
+	for (i = 0; i < __NFSIOS_BYTESMAX; i++)
+		seq_printf(m, "%Lu ", totals.bytes[i]);
+	seq_printf(m, "\n");
+
+	rpc_print_iostats(m, nfss->client);
+
+	return 0;
+}
+
+/*
+ * Begin unmount by attempting to remove all automounted mountpoints we added
+ * in response to traversals
+ */
+static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
+{
+	struct nfs_server *server;
+	struct rpc_clnt	*rpc;
+
+	shrink_submounts(vfsmnt, &nfs_automount_list);
+	if (!(flags & MNT_FORCE))
+		return;
+	/* -EIO all pending I/O */
+	server = NFS_SB(vfsmnt->mnt_sb);
+	rpc = server->client;
+	if (!IS_ERR(rpc))
+		rpc_killall_tasks(rpc);
+	rpc = server->client_acl;
+	if (!IS_ERR(rpc))
+		rpc_killall_tasks(rpc);
+}
+
+/*
+ * Obtain the root inode of the file system.
+ */
+static struct inode *
+nfs_get_root(struct super_block *sb, struct nfs_fh *rootfh, struct nfs_fsinfo *fsinfo)
+{
+	struct nfs_server	*server = NFS_SB(sb);
+	int			error;
+
+	error = server->rpc_ops->getroot(server, rootfh, fsinfo);
+	if (error < 0) {
+		dprintk("nfs_get_root: getattr error = %d\n", -error);
+		return ERR_PTR(error);
+	}
+
+	server->fsid = fsinfo->fattr->fsid;
+	return nfs_fhget(sb, rootfh, fsinfo->fattr);
+}
+
+/*
+ * Do NFS version-independent mount processing, and sanity checking
+ */
+static int
+nfs_sb_init(struct super_block *sb, rpc_authflavor_t authflavor)
+{
+	struct nfs_server	*server;
+	struct inode		*root_inode;
+	struct nfs_fattr	fattr;
+	struct nfs_fsinfo	fsinfo = {
+					.fattr = &fattr,
+				};
+	struct nfs_pathconf pathinfo = {
+			.fattr = &fattr,
+	};
+	int no_root_error = 0;
+	unsigned long max_rpc_payload;
+
+	/* We probably want something more informative here */
+	snprintf(sb->s_id, sizeof(sb->s_id), "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
+
+	server = NFS_SB(sb);
+
+	sb->s_magic      = NFS_SUPER_MAGIC;
+
+	server->io_stats = nfs_alloc_iostats();
+	if (server->io_stats == NULL)
+		return -ENOMEM;
+
+	root_inode = nfs_get_root(sb, &server->fh, &fsinfo);
+	/* Did getting the root inode fail? */
+	if (IS_ERR(root_inode)) {
+		no_root_error = PTR_ERR(root_inode);
+		goto out_no_root;
+	}
+	sb->s_root = d_alloc_root(root_inode);
+	if (!sb->s_root) {
+		no_root_error = -ENOMEM;
+		goto out_no_root;
+	}
+	sb->s_root->d_op = server->rpc_ops->dentry_ops;
+
+	/* mount time stamp, in seconds */
+	server->mount_time = jiffies;
+
+	/* Get some general file system info */
+	if (server->namelen == 0 &&
+	    server->rpc_ops->pathconf(server, &server->fh, &pathinfo) >= 0)
+		server->namelen = pathinfo.max_namelen;
+	/* Work out a lot of parameters */
+	if (server->rsize == 0)
+		server->rsize = nfs_block_size(fsinfo.rtpref, NULL);
+	if (server->wsize == 0)
+		server->wsize = nfs_block_size(fsinfo.wtpref, NULL);
+
+	if (fsinfo.rtmax >= 512 && server->rsize > fsinfo.rtmax)
+		server->rsize = nfs_block_size(fsinfo.rtmax, NULL);
+	if (fsinfo.wtmax >= 512 && server->wsize > fsinfo.wtmax)
+		server->wsize = nfs_block_size(fsinfo.wtmax, NULL);
+
+	max_rpc_payload = nfs_block_size(rpc_max_payload(server->client), NULL);
+	if (server->rsize > max_rpc_payload)
+		server->rsize = max_rpc_payload;
+	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
+		server->rsize = NFS_MAX_FILE_IO_SIZE;
+	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+
+	if (server->wsize > max_rpc_payload)
+		server->wsize = max_rpc_payload;
+	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
+		server->wsize = NFS_MAX_FILE_IO_SIZE;
+	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+
+	if (sb->s_blocksize == 0)
+		sb->s_blocksize = nfs_block_bits(server->wsize,
+							 &sb->s_blocksize_bits);
+	server->wtmult = nfs_block_bits(fsinfo.wtmult, NULL);
+
+	server->dtsize = nfs_block_size(fsinfo.dtpref, NULL);
+	if (server->dtsize > PAGE_CACHE_SIZE)
+		server->dtsize = PAGE_CACHE_SIZE;
+	if (server->dtsize > server->rsize)
+		server->dtsize = server->rsize;
+
+	if (server->flags & NFS_MOUNT_NOAC) {
+		server->acregmin = server->acregmax = 0;
+		server->acdirmin = server->acdirmax = 0;
+		sb->s_flags |= MS_SYNCHRONOUS;
+	}
+	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+
+	nfs_super_set_maxbytes(sb, fsinfo.maxfilesize);
+
+	server->client->cl_intr = (server->flags & NFS_MOUNT_INTR) ? 1 : 0;
+	server->client->cl_softrtry = (server->flags & NFS_MOUNT_SOFT) ? 1 : 0;
+
+	/* We're airborne Set socket buffersize */
+	rpc_setbufsize(server->client, server->wsize + 100, server->rsize + 100);
+	return 0;
+	/* Yargs. It didn't work out. */
+out_no_root:
+	dprintk("nfs_sb_init: get root inode failed: errno %d\n", -no_root_error);
+	if (!IS_ERR(root_inode))
+		iput(root_inode);
+	return no_root_error;
+}
+
+/*
+ * Initialise the timeout values for a connection
+ */
+static void nfs_init_timeout_values(struct rpc_timeout *to, int proto, unsigned int timeo, unsigned int retrans)
+{
+	to->to_initval = timeo * HZ / 10;
+	to->to_retries = retrans;
+	if (!to->to_retries)
+		to->to_retries = 2;
+
+	switch (proto) {
+	case IPPROTO_TCP:
+		if (!to->to_initval)
+			to->to_initval = 60 * HZ;
+		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
+			to->to_initval = NFS_MAX_TCP_TIMEOUT;
+		to->to_increment = to->to_initval;
+		to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
+		to->to_exponential = 0;
+		break;
+	case IPPROTO_UDP:
+	default:
+		if (!to->to_initval)
+			to->to_initval = 11 * HZ / 10;
+		if (to->to_initval > NFS_MAX_UDP_TIMEOUT)
+			to->to_initval = NFS_MAX_UDP_TIMEOUT;
+		to->to_maxval = NFS_MAX_UDP_TIMEOUT;
+		to->to_exponential = 1;
+		break;
+	}
+}
+
+/*
+ * Create an RPC client handle.
+ */
+static struct rpc_clnt *
+nfs_create_client(struct nfs_server *server, const struct nfs_mount_data *data)
+{
+	struct rpc_timeout	timeparms;
+	struct rpc_xprt		*xprt = NULL;
+	struct rpc_clnt		*clnt = NULL;
+	int			proto = (data->flags & NFS_MOUNT_TCP) ? IPPROTO_TCP : IPPROTO_UDP;
+
+	nfs_init_timeout_values(&timeparms, proto, data->timeo, data->retrans);
+
+	server->retrans_timeo = timeparms.to_initval;
+	server->retrans_count = timeparms.to_retries;
+
+	/* create transport and client */
+	xprt = xprt_create_proto(proto, &server->addr, &timeparms);
+	if (IS_ERR(xprt)) {
+		dprintk("%s: cannot create RPC transport. Error = %ld\n",
+				__FUNCTION__, PTR_ERR(xprt));
+		return (struct rpc_clnt *)xprt;
+	}
+	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
+				 server->rpc_ops->version, data->pseudoflavor);
+	if (IS_ERR(clnt)) {
+		dprintk("%s: cannot create RPC client. Error = %ld\n",
+				__FUNCTION__, PTR_ERR(xprt));
+		goto out_fail;
+	}
+
+	clnt->cl_intr     = 1;
+	clnt->cl_softrtry = 1;
+
+	return clnt;
+
+out_fail:
+	return clnt;
+}
+
+/*
+ * Clone a server record
+ */
+static struct nfs_server *nfs_clone_server(struct super_block *sb, struct nfs_clone_mount *data)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_server *parent = NFS_SB(data->sb);
+	struct inode *root_inode;
+	struct nfs_fsinfo fsinfo;
+	void *err = ERR_PTR(-ENOMEM);
+
+	sb->s_op = data->sb->s_op;
+	sb->s_blocksize = data->sb->s_blocksize;
+	sb->s_blocksize_bits = data->sb->s_blocksize_bits;
+	sb->s_maxbytes = data->sb->s_maxbytes;
+
+	server->client_sys = server->client_acl = ERR_PTR(-EINVAL);
+	server->io_stats = nfs_alloc_iostats();
+	if (server->io_stats == NULL)
+		goto out;
+
+	server->client = rpc_clone_client(parent->client);
+	if (IS_ERR((err = server->client)))
+		goto out;
+
+	if (!IS_ERR(parent->client_sys)) {
+		server->client_sys = rpc_clone_client(parent->client_sys);
+		if (IS_ERR((err = server->client_sys)))
+			goto out;
+	}
+	if (!IS_ERR(parent->client_acl)) {
+		server->client_acl = rpc_clone_client(parent->client_acl);
+		if (IS_ERR((err = server->client_acl)))
+			goto out;
+	}
+	root_inode = nfs_fhget(sb, data->fh, data->fattr);
+	if (!root_inode)
+		goto out;
+	sb->s_root = d_alloc_root(root_inode);
+	if (!sb->s_root)
+		goto out_put_root;
+	fsinfo.fattr = data->fattr;
+	if (NFS_PROTO(root_inode)->fsinfo(server, data->fh, &fsinfo) == 0)
+		nfs_super_set_maxbytes(sb, fsinfo.maxfilesize);
+	sb->s_root->d_op = server->rpc_ops->dentry_ops;
+	sb->s_flags |= MS_ACTIVE;
+	return server;
+out_put_root:
+	iput(root_inode);
+out:
+	return err;
+}
+
+/*
+ * Copy an existing superblock and attach revised data
+ */
+static int nfs_clone_generic_sb(struct nfs_clone_mount *data,
+		struct super_block *(*fill_sb)(struct nfs_server *, struct nfs_clone_mount *),
+		struct nfs_server *(*fill_server)(struct super_block *, struct nfs_clone_mount *),
+		struct vfsmount *mnt)
+{
+	struct nfs_server *server;
+	struct nfs_server *parent = NFS_SB(data->sb);
+	struct super_block *sb = ERR_PTR(-EINVAL);
+	char *hostname;
+	int error = -ENOMEM;
+	int len;
+
+	server = kmalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (server == NULL)
+		goto out_err;
+	memcpy(server, parent, sizeof(*server));
+	hostname = (data->hostname != NULL) ? data->hostname : parent->hostname;
+	len = strlen(hostname) + 1;
+	server->hostname = kmalloc(len, GFP_KERNEL);
+	if (server->hostname == NULL)
+		goto free_server;
+	memcpy(server->hostname, hostname, len);
+	error = rpciod_up();
+	if (error != 0)
+		goto free_hostname;
+
+	sb = fill_sb(server, data);
+	if (IS_ERR(sb)) {
+		error = PTR_ERR(sb);
+		goto kill_rpciod;
+	}
+		
+	if (sb->s_root)
+		goto out_rpciod_down;
+
+	server = fill_server(sb, data);
+	if (IS_ERR(server)) {
+		error = PTR_ERR(server);
+		goto out_deactivate;
+	}
+	return simple_set_mnt(mnt, sb);
+out_deactivate:
+	up_write(&sb->s_umount);
+	deactivate_super(sb);
+	return error;
+out_rpciod_down:
+	rpciod_down();
+	kfree(server->hostname);
+	kfree(server);
+	return simple_set_mnt(mnt, sb);
+kill_rpciod:
+	rpciod_down();
+free_hostname:
+	kfree(server->hostname);
+free_server:
+	kfree(server);
+out_err:
+	return error;
+}
+
+/*
+ * Set up an NFS2/3 superblock
+ *
+ * The way this works is that the mount process passes a structure
+ * in the data argument which contains the server's IP address
+ * and the root file handle obtained from the server's mount
+ * daemon. We stash these away in the private superblock fields.
+ */
+static int
+nfs_fill_super(struct super_block *sb, struct nfs_mount_data *data, int silent)
+{
+	struct nfs_server	*server;
+	rpc_authflavor_t	authflavor;
+
+	server           = NFS_SB(sb);
+	sb->s_blocksize_bits = 0;
+	sb->s_blocksize = 0;
+	if (data->bsize)
+		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
+	if (data->rsize)
+		server->rsize = nfs_block_size(data->rsize, NULL);
+	if (data->wsize)
+		server->wsize = nfs_block_size(data->wsize, NULL);
+	server->flags    = data->flags & NFS_MOUNT_FLAGMASK;
+
+	server->acregmin = data->acregmin*HZ;
+	server->acregmax = data->acregmax*HZ;
+	server->acdirmin = data->acdirmin*HZ;
+	server->acdirmax = data->acdirmax*HZ;
+
+	/* Start lockd here, before we might error out */
+	if (!(server->flags & NFS_MOUNT_NONLM))
+		lockd_up();
+
+	server->namelen  = data->namlen;
+	server->hostname = kmalloc(strlen(data->hostname) + 1, GFP_KERNEL);
+	if (!server->hostname)
+		return -ENOMEM;
+	strcpy(server->hostname, data->hostname);
+
+	/* Check NFS protocol revision and initialize RPC op vector
+	 * and file handle pool. */
+#ifdef CONFIG_NFS_V3
+	if (server->flags & NFS_MOUNT_VER3) {
+		server->rpc_ops = &nfs_v3_clientops;
+		server->caps |= NFS_CAP_READDIRPLUS;
+	} else {
+		server->rpc_ops = &nfs_v2_clientops;
+	}
+#else
+	server->rpc_ops = &nfs_v2_clientops;
+#endif
+
+	/* Fill in pseudoflavor for mount version < 5 */
+	if (!(data->flags & NFS_MOUNT_SECFLAVOUR))
+		data->pseudoflavor = RPC_AUTH_UNIX;
+	authflavor = data->pseudoflavor;	/* save for sb_init() */
+	/* XXX maybe we want to add a server->pseudoflavor field */
+
+	/* Create RPC client handles */
+	server->client = nfs_create_client(server, data);
+	if (IS_ERR(server->client))
+		return PTR_ERR(server->client);
+	/* RFC 2623, sec 2.3.2 */
+	if (authflavor != RPC_AUTH_UNIX) {
+		struct rpc_auth *auth;
+
+		server->client_sys = rpc_clone_client(server->client);
+		if (IS_ERR(server->client_sys))
+			return PTR_ERR(server->client_sys);
+		auth = rpcauth_create(RPC_AUTH_UNIX, server->client_sys);
+		if (IS_ERR(auth))
+			return PTR_ERR(auth);
+	} else {
+		atomic_inc(&server->client->cl_count);
+		server->client_sys = server->client;
+	}
+	if (server->flags & NFS_MOUNT_VER3) {
+#ifdef CONFIG_NFS_V3_ACL
+		if (!(server->flags & NFS_MOUNT_NOACL)) {
+			server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
+			/* No errors! Assume that Sun nfsacls are supported */
+			if (!IS_ERR(server->client_acl))
+				server->caps |= NFS_CAP_ACLS;
+		}
+#else
+		server->flags &= ~NFS_MOUNT_NOACL;
+#endif /* CONFIG_NFS_V3_ACL */
+		/*
+		 * The VFS shouldn't apply the umask to mode bits. We will
+		 * do so ourselves when necessary.
+		 */
+		sb->s_flags |= MS_POSIXACL;
+		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
+			server->namelen = NFS3_MAXNAMLEN;
+		sb->s_time_gran = 1;
+	} else {
+		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
+			server->namelen = NFS2_MAXNAMLEN;
+	}
+
+	sb->s_op = &nfs_sops;
+	return nfs_sb_init(sb, authflavor);
+}
+
+static int nfs_set_super(struct super_block *s, void *data)
+{
+	s->s_fs_info = data;
+	return set_anon_super(s, data);
+}
+
+static int nfs_compare_super(struct super_block *sb, void *data)
+{
+	struct nfs_server *server = data;
+	struct nfs_server *old = NFS_SB(sb);
+
+	if (old->addr.sin_addr.s_addr != server->addr.sin_addr.s_addr)
+		return 0;
+	if (old->addr.sin_port != server->addr.sin_port)
+		return 0;
+	return !nfs_compare_fh(&old->fh, &server->fh);
+}
+
+static int nfs_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	int error;
+	struct nfs_server *server = NULL;
+	struct super_block *s;
+	struct nfs_fh *root;
+	struct nfs_mount_data *data = raw_data;
+
+	error = -EINVAL;
+	if (data == NULL) {
+		dprintk("%s: missing data argument\n", __FUNCTION__);
+		goto out_err_noserver;
+	}
+	if (data->version <= 0 || data->version > NFS_MOUNT_VERSION) {
+		dprintk("%s: bad mount version\n", __FUNCTION__);
+		goto out_err_noserver;
+	}
+	switch (data->version) {
+		case 1:
+			data->namlen = 0;
+		case 2:
+			data->bsize  = 0;
+		case 3:
+			if (data->flags & NFS_MOUNT_VER3) {
+				dprintk("%s: mount structure version %d does not support NFSv3\n",
+						__FUNCTION__,
+						data->version);
+				goto out_err_noserver;
+			}
+			data->root.size = NFS2_FHSIZE;
+			memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
+		case 4:
+			if (data->flags & NFS_MOUNT_SECFLAVOUR) {
+				dprintk("%s: mount structure version %d does not support strong security\n",
+						__FUNCTION__,
+						data->version);
+				goto out_err_noserver;
+			}
+		case 5:
+			memset(data->context, 0, sizeof(data->context));
+	}
+#ifndef CONFIG_NFS_V3
+	/* If NFSv3 is not compiled in, return -EPROTONOSUPPORT */
+	error = -EPROTONOSUPPORT;
+	if (data->flags & NFS_MOUNT_VER3) {
+		dprintk("%s: NFSv3 not compiled into kernel\n", __FUNCTION__);
+		goto out_err_noserver;
+	}
+#endif /* CONFIG_NFS_V3 */
+
+	error = -ENOMEM;
+	server = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (!server)
+		goto out_err_noserver;
+	/* Zero out the NFS state stuff */
+	init_nfsv4_state(server);
+	server->client = server->client_sys = server->client_acl = ERR_PTR(-EINVAL);
+
+	root = &server->fh;
+	if (data->flags & NFS_MOUNT_VER3)
+		root->size = data->root.size;
+	else
+		root->size = NFS2_FHSIZE;
+	error = -EINVAL;
+	if (root->size > sizeof(root->data)) {
+		dprintk("%s: invalid root filehandle\n", __FUNCTION__);
+		goto out_err;
+	}
+	memcpy(root->data, data->root.data, root->size);
+
+	/* We now require that the mount process passes the remote address */
+	memcpy(&server->addr, &data->addr, sizeof(server->addr));
+	if (server->addr.sin_addr.s_addr == INADDR_ANY) {
+		dprintk("%s: mount program didn't pass remote address!\n",
+				__FUNCTION__);
+		goto out_err;
+	}
+
+	/* Fire up rpciod if not yet running */
+	error = rpciod_up();
+	if (error < 0) {
+		dprintk("%s: couldn't start rpciod! Error = %d\n",
+				__FUNCTION__, error);
+		goto out_err;
+	}
+
+	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
+	if (IS_ERR(s)) {
+		error = PTR_ERR(s);
+		goto out_err_rpciod;
+	}
+
+	if (s->s_root)
+		goto out_rpciod_down;
+
+	s->s_flags = flags;
+
+	error = nfs_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
+	if (error) {
+		up_write(&s->s_umount);
+		deactivate_super(s);
+		return error;
+	}
+	s->s_flags |= MS_ACTIVE;
+	return simple_set_mnt(mnt, s);
+
+out_rpciod_down:
+	rpciod_down();
+	kfree(server);
+	return simple_set_mnt(mnt, s);
+
+out_err_rpciod:
+	rpciod_down();
+out_err:
+	kfree(server);
+out_err_noserver:
+	return error;
+}
+
+static void nfs_kill_super(struct super_block *s)
+{
+	struct nfs_server *server = NFS_SB(s);
+
+	kill_anon_super(s);
+
+	if (!IS_ERR(server->client))
+		rpc_shutdown_client(server->client);
+	if (!IS_ERR(server->client_sys))
+		rpc_shutdown_client(server->client_sys);
+	if (!IS_ERR(server->client_acl))
+		rpc_shutdown_client(server->client_acl);
+
+	if (!(server->flags & NFS_MOUNT_NONLM))
+		lockd_down();	/* release rpc.lockd */
+
+	rpciod_down();		/* release rpciod */
+
+	nfs_free_iostats(server->io_stats);
+	kfree(server->hostname);
+	kfree(server);
+	nfs_release_automount_timer();
+}
+
+static struct super_block *nfs_clone_sb(struct nfs_server *server, struct nfs_clone_mount *data)
+{
+	struct super_block *sb;
+
+	server->fsid = data->fattr->fsid;
+	nfs_copy_fh(&server->fh, data->fh);
+	sb = sget(&nfs_fs_type, nfs_compare_super, nfs_set_super, server);
+	if (!IS_ERR(sb) && sb->s_root == NULL && !(server->flags & NFS_MOUNT_NONLM))
+		lockd_up();
+	return sb;
+}
+
+static int nfs_clone_nfs_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	struct nfs_clone_mount *data = raw_data;
+	return nfs_clone_generic_sb(data, nfs_clone_sb, nfs_clone_server, mnt);
+}
+
+#ifdef CONFIG_NFS_V4
+static struct rpc_clnt *nfs4_create_client(struct nfs_server *server,
+	struct rpc_timeout *timeparms, int proto, rpc_authflavor_t flavor)
+{
+	struct nfs4_client *clp;
+	struct rpc_xprt *xprt = NULL;
+	struct rpc_clnt *clnt = NULL;
+	int err = -EIO;
+
+	clp = nfs4_get_client(&server->addr.sin_addr);
+	if (!clp) {
+		dprintk("%s: failed to create NFS4 client.\n", __FUNCTION__);
+		return ERR_PTR(err);
+	}
+
+	/* Now create transport and client */
+	down_write(&clp->cl_sem);
+	if (IS_ERR(clp->cl_rpcclient)) {
+		xprt = xprt_create_proto(proto, &server->addr, timeparms);
+		if (IS_ERR(xprt)) {
+			up_write(&clp->cl_sem);
+			err = PTR_ERR(xprt);
+			dprintk("%s: cannot create RPC transport. Error = %d\n",
+					__FUNCTION__, err);
+			goto out_fail;
+		}
+		/* Bind to a reserved port! */
+		xprt->resvport = 1;
+		clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
+				server->rpc_ops->version, flavor);
+		if (IS_ERR(clnt)) {
+			up_write(&clp->cl_sem);
+			err = PTR_ERR(clnt);
+			dprintk("%s: cannot create RPC client. Error = %d\n",
+					__FUNCTION__, err);
+			goto out_fail;
+		}
+		clnt->cl_intr     = 1;
+		clnt->cl_softrtry = 1;
+		clp->cl_rpcclient = clnt;
+		memcpy(clp->cl_ipaddr, server->ip_addr, sizeof(clp->cl_ipaddr));
+		nfs_idmap_new(clp);
+	}
+	list_add_tail(&server->nfs4_siblings, &clp->cl_superblocks);
+	clnt = rpc_clone_client(clp->cl_rpcclient);
+	if (!IS_ERR(clnt))
+		server->nfs4_state = clp;
+	up_write(&clp->cl_sem);
+	clp = NULL;
+
+	if (IS_ERR(clnt)) {
+		dprintk("%s: cannot create RPC client. Error = %d\n",
+				__FUNCTION__, err);
+		return clnt;
+	}
+
+	if (server->nfs4_state->cl_idmap == NULL) {
+		dprintk("%s: failed to create idmapper.\n", __FUNCTION__);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (clnt->cl_auth->au_flavor != flavor) {
+		struct rpc_auth *auth;
+
+		auth = rpcauth_create(flavor, clnt);
+		if (IS_ERR(auth)) {
+			dprintk("%s: couldn't create credcache!\n", __FUNCTION__);
+			return (struct rpc_clnt *)auth;
+		}
+	}
+	return clnt;
+
+ out_fail:
+	if (clp)
+		nfs4_put_client(clp);
+	return ERR_PTR(err);
+}
+
+/*
+ * Set up an NFS4 superblock
+ */
+static int nfs4_fill_super(struct super_block *sb, struct nfs4_mount_data *data, int silent)
+{
+	struct nfs_server *server;
+	struct rpc_timeout timeparms;
+	rpc_authflavor_t authflavour;
+	int err = -EIO;
+
+	sb->s_blocksize_bits = 0;
+	sb->s_blocksize = 0;
+	server = NFS_SB(sb);
+	if (data->rsize != 0)
+		server->rsize = nfs_block_size(data->rsize, NULL);
+	if (data->wsize != 0)
+		server->wsize = nfs_block_size(data->wsize, NULL);
+	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
+	server->caps = NFS_CAP_ATOMIC_OPEN;
+
+	server->acregmin = data->acregmin*HZ;
+	server->acregmax = data->acregmax*HZ;
+	server->acdirmin = data->acdirmin*HZ;
+	server->acdirmax = data->acdirmax*HZ;
+
+	server->rpc_ops = &nfs_v4_clientops;
+
+	nfs_init_timeout_values(&timeparms, data->proto, data->timeo, data->retrans);
+
+	server->retrans_timeo = timeparms.to_initval;
+	server->retrans_count = timeparms.to_retries;
+
+	/* Now create transport and client */
+	authflavour = RPC_AUTH_UNIX;
+	if (data->auth_flavourlen != 0) {
+		if (data->auth_flavourlen != 1) {
+			dprintk("%s: Invalid number of RPC auth flavours %d.\n",
+					__FUNCTION__, data->auth_flavourlen);
+			err = -EINVAL;
+			goto out_fail;
+		}
+		if (copy_from_user(&authflavour, data->auth_flavours, sizeof(authflavour))) {
+			err = -EFAULT;
+			goto out_fail;
+		}
+	}
+
+	server->client = nfs4_create_client(server, &timeparms, data->proto, authflavour);
+	if (IS_ERR(server->client)) {
+		err = PTR_ERR(server->client);
+			dprintk("%s: cannot create RPC client. Error = %d\n",
+					__FUNCTION__, err);
+			goto out_fail;
+	}
+
+	sb->s_time_gran = 1;
+
+	sb->s_op = &nfs4_sops;
+	err = nfs_sb_init(sb, authflavour);
+
+ out_fail:
+	return err;
+}
+
+static int nfs4_compare_super(struct super_block *sb, void *data)
+{
+	struct nfs_server *server = data;
+	struct nfs_server *old = NFS_SB(sb);
+
+	if (strcmp(server->hostname, old->hostname) != 0)
+		return 0;
+	if (strcmp(server->mnt_path, old->mnt_path) != 0)
+		return 0;
+	return 1;
+}
+
+static void *
+nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
+{
+	void *p = NULL;
+
+	if (!src->len)
+		return ERR_PTR(-EINVAL);
+	if (src->len < maxlen)
+		maxlen = src->len;
+	if (dst == NULL) {
+		p = dst = kmalloc(maxlen + 1, GFP_KERNEL);
+		if (p == NULL)
+			return ERR_PTR(-ENOMEM);
+	}
+	if (copy_from_user(dst, src->data, maxlen)) {
+		kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
+	dst[maxlen] = '\0';
+	return dst;
+}
+
+static int nfs4_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	int error;
+	struct nfs_server *server;
+	struct super_block *s;
+	struct nfs4_mount_data *data = raw_data;
+	void *p;
+
+	if (data == NULL) {
+		dprintk("%s: missing data argument\n", __FUNCTION__);
+		return -EINVAL;
+	}
+	if (data->version <= 0 || data->version > NFS4_MOUNT_VERSION) {
+		dprintk("%s: bad mount version\n", __FUNCTION__);
+		return -EINVAL;
+	}
+
+	server = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (!server)
+		return -ENOMEM;
+	/* Zero out the NFS state stuff */
+	init_nfsv4_state(server);
+	server->client = server->client_sys = server->client_acl = ERR_PTR(-EINVAL);
+
+	p = nfs_copy_user_string(NULL, &data->hostname, 256);
+	if (IS_ERR(p))
+		goto out_err;
+	server->hostname = p;
+
+	p = nfs_copy_user_string(NULL, &data->mnt_path, 1024);
+	if (IS_ERR(p))
+		goto out_err;
+	server->mnt_path = p;
+
+	p = nfs_copy_user_string(server->ip_addr, &data->client_addr,
+			sizeof(server->ip_addr) - 1);
+	if (IS_ERR(p))
+		goto out_err;
+
+	/* We now require that the mount process passes the remote address */
+	if (data->host_addrlen != sizeof(server->addr)) {
+		error = -EINVAL;
+		goto out_free;
+	}
+	if (copy_from_user(&server->addr, data->host_addr, sizeof(server->addr))) {
+		error = -EFAULT;
+		goto out_free;
+	}
+	if (server->addr.sin_family != AF_INET ||
+	    server->addr.sin_addr.s_addr == INADDR_ANY) {
+		dprintk("%s: mount program didn't pass remote IP address!\n",
+				__FUNCTION__);
+		error = -EINVAL;
+		goto out_free;
+	}
+
+	/* Fire up rpciod if not yet running */
+	error = rpciod_up();
+	if (error < 0) {
+		dprintk("%s: couldn't start rpciod! Error = %d\n",
+				__FUNCTION__, error);
+		goto out_free;
+	}
+
+	s = sget(fs_type, nfs4_compare_super, nfs_set_super, server);
+
+	if (IS_ERR(s)) {
+		error = PTR_ERR(s);
+		goto out_free;
+	}
+
+	if (s->s_root) {
+		kfree(server->mnt_path);
+		kfree(server->hostname);
+		kfree(server);
+		return simple_set_mnt(mnt, s);
+	}
+
+	s->s_flags = flags;
+
+	error = nfs4_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
+	if (error) {
+		up_write(&s->s_umount);
+		deactivate_super(s);
+		return error;
+	}
+	s->s_flags |= MS_ACTIVE;
+	return simple_set_mnt(mnt, s);
+out_err:
+	error = PTR_ERR(p);
+out_free:
+	kfree(server->mnt_path);
+	kfree(server->hostname);
+	kfree(server);
+	return error;
+}
+
+static void nfs4_kill_super(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	nfs_return_all_delegations(sb);
+	kill_anon_super(sb);
+
+	nfs4_renewd_prepare_shutdown(server);
+
+	if (server->client != NULL && !IS_ERR(server->client))
+		rpc_shutdown_client(server->client);
+
+	destroy_nfsv4_state(server);
+
+	rpciod_down();
+
+	nfs_free_iostats(server->io_stats);
+	kfree(server->hostname);
+	kfree(server);
+	nfs_release_automount_timer();
+}
+
+/*
+ * Constructs the SERVER-side path
+ */
+static inline char *nfs4_dup_path(const struct dentry *dentry)
+{
+	char *page = (char *) __get_free_page(GFP_USER);
+	char *path;
+
+	path = nfs4_path(dentry, page, PAGE_SIZE);
+	if (!IS_ERR(path)) {
+		int len = PAGE_SIZE + page - path;
+		char *tmp = path;
+
+		path = kmalloc(len, GFP_KERNEL);
+		if (path)
+			memcpy(path, tmp, len);
+		else
+			path = ERR_PTR(-ENOMEM);
+	}
+	free_page((unsigned long)page);
+	return path;
+}
+
+static struct super_block *nfs4_clone_sb(struct nfs_server *server, struct nfs_clone_mount *data)
+{
+	const struct dentry *dentry = data->dentry;
+	struct nfs4_client *clp = server->nfs4_state;
+	struct super_block *sb;
+
+	server->fsid = data->fattr->fsid;
+	nfs_copy_fh(&server->fh, data->fh);
+	server->mnt_path = nfs4_dup_path(dentry);
+	if (IS_ERR(server->mnt_path)) {
+		sb = (struct super_block *)server->mnt_path;
+		goto err;
+	}
+	sb = sget(&nfs4_fs_type, nfs4_compare_super, nfs_set_super, server);
+	if (IS_ERR(sb) || sb->s_root)
+		goto free_path;
+	nfs4_server_capabilities(server, &server->fh);
+
+	down_write(&clp->cl_sem);
+	atomic_inc(&clp->cl_count);
+	list_add_tail(&server->nfs4_siblings, &clp->cl_superblocks);
+	up_write(&clp->cl_sem);
+	return sb;
+free_path:
+	kfree(server->mnt_path);
+err:
+	server->mnt_path = NULL;
+	return sb;
+}
+
+static int nfs_clone_nfs4_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	struct nfs_clone_mount *data = raw_data;
+	return nfs_clone_generic_sb(data, nfs4_clone_sb, nfs_clone_server, mnt);
+}
+
+static struct super_block *nfs4_referral_sb(struct nfs_server *server, struct nfs_clone_mount *data)
+{
+	struct super_block *sb = ERR_PTR(-ENOMEM);
+	int len;
+
+	len = strlen(data->mnt_path) + 1;
+	server->mnt_path = kmalloc(len, GFP_KERNEL);
+	if (server->mnt_path == NULL)
+		goto err;
+	memcpy(server->mnt_path, data->mnt_path, len);
+	memcpy(&server->addr, data->addr, sizeof(struct sockaddr_in));
+
+	sb = sget(&nfs4_fs_type, nfs4_compare_super, nfs_set_super, server);
+	if (IS_ERR(sb) || sb->s_root)
+		goto free_path;
+	return sb;
+free_path:
+	kfree(server->mnt_path);
+err:
+	server->mnt_path = NULL;
+	return sb;
+}
+
+static struct nfs_server *nfs4_referral_server(struct super_block *sb, struct nfs_clone_mount *data)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	struct rpc_timeout timeparms;
+	int proto, timeo, retrans;
+	void *err;
+
+	proto = IPPROTO_TCP;
+	/* Since we are following a referral and there may be alternatives,
+	   set the timeouts and retries to low values */
+	timeo = 2;
+	retrans = 1;
+	nfs_init_timeout_values(&timeparms, proto, timeo, retrans);
+
+	server->client = nfs4_create_client(server, &timeparms, proto, data->authflavor);
+	if (IS_ERR((err = server->client)))
+		goto out_err;
+
+	sb->s_time_gran = 1;
+	sb->s_op = &nfs4_sops;
+	err = ERR_PTR(nfs_sb_init(sb, data->authflavor));
+	if (!IS_ERR(err))
+		return server;
+out_err:
+	return (struct nfs_server *)err;
+}
+
+static int nfs_referral_nfs4_sb(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	struct nfs_clone_mount *data = raw_data;
+	return nfs_clone_generic_sb(data, nfs4_referral_sb, nfs4_referral_server, mnt);
+}
+
+#endif
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 18dc95b..600bbe6 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -52,7 +52,7 @@ static void *nfs_follow_link(struct dent
 {
 	struct inode *inode = dentry->d_inode;
 	struct page *page;
-	void *err = ERR_PTR(nfs_revalidate_inode(NFS_SERVER(inode), inode));
+	void *err = ERR_PTR(nfs_revalidate_mapping(inode, inode->i_mapping));
 	if (err)
 		goto read_failed;
 	page = read_cache_page(&inode->i_data, 0,
@@ -75,22 +75,13 @@ read_failed:
 	return NULL;
 }
 
-static void nfs_put_link(struct dentry *dentry, struct nameidata *nd, void *cookie)
-{
-	if (cookie) {
-		struct page *page = cookie;
-		kunmap(page);
-		page_cache_release(page);
-	}
-}
-
 /*
  * symlinks can't do much...
  */
 struct inode_operations nfs_symlink_inode_operations = {
 	.readlink	= generic_readlink,
 	.follow_link	= nfs_follow_link,
-	.put_link	= nfs_put_link,
+	.put_link	= page_put_link,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 };
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 4c486eb..db61e51 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -12,6 +12,7 @@ #include <linux/sysctl.h>
 #include <linux/module.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_fs.h>
 
 #include "callback.h"
 
@@ -46,6 +47,15 @@ #ifdef CONFIG_NFS_V4
 		.strategy = &sysctl_jiffies,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nfs_mountpoint_timeout",
+		.data		= &nfs_mountpoint_expiry_timeout,
+		.maxlen		= sizeof(nfs_mountpoint_expiry_timeout),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4cfada2..b383fdd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -98,11 +98,10 @@ struct nfs_write_data *nfs_commit_alloc(
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		if (pagecount < NFS_PAGEVEC_SIZE)
-			p->pagevec = &p->page_array[0];
+		if (pagecount <= ARRAY_SIZE(p->page_array))
+			p->pagevec = p->page_array;
 		else {
-			size_t size = ++pagecount * sizeof(struct page *);
-			p->pagevec = kzalloc(size, GFP_NOFS);
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
 			if (!p->pagevec) {
 				mempool_free(p, nfs_commit_mempool);
 				p = NULL;
@@ -126,14 +125,11 @@ struct nfs_write_data *nfs_writedata_all
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		if (pagecount < NFS_PAGEVEC_SIZE)
-			p->pagevec = &p->page_array[0];
+		if (pagecount <= ARRAY_SIZE(p->page_array))
+			p->pagevec = p->page_array;
 		else {
-			size_t size = ++pagecount * sizeof(struct page *);
-			p->pagevec = kmalloc(size, GFP_NOFS);
-			if (p->pagevec) {
-				memset(p->pagevec, 0, size);
-			} else {
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			if (!p->pagevec) {
 				mempool_free(p, nfs_wdata_mempool);
 				p = NULL;
 			}
@@ -583,6 +579,17 @@ static int nfs_wait_on_requests(struct i
 	return ret;
 }
 
+static void nfs_cancel_requests(struct list_head *head)
+{
+	struct nfs_page *req;
+	while(!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		nfs_inode_remove_request(req);
+		nfs_clear_page_writeback(req);
+	}
+}
+
 /*
  * nfs_scan_dirty - Scan an inode for dirty requests
  * @inode: NFS inode to scan
@@ -627,7 +634,7 @@ nfs_scan_commit(struct inode *inode, str
 	int res = 0;
 
 	if (nfsi->ncommit != 0) {
-		res = nfs_scan_list(&nfsi->commit, dst, idx_start, npages);
+		res = nfs_scan_list(nfsi, &nfsi->commit, dst, idx_start, npages);
 		nfsi->ncommit -= res;
 		if ((nfsi->ncommit == 0) != list_empty(&nfsi->commit))
 			printk(KERN_ERR "NFS: desynchronized value of nfs_i.ncommit.\n");
@@ -1495,15 +1502,25 @@ int nfs_sync_inode_wait(struct inode *in
 		pages = nfs_scan_dirty(inode, &head, idx_start, npages);
 		if (pages != 0) {
 			spin_unlock(&nfsi->req_lock);
-			ret = nfs_flush_list(inode, &head, pages, how);
+			if (how & FLUSH_INVALIDATE)
+				nfs_cancel_requests(&head);
+			else
+				ret = nfs_flush_list(inode, &head, pages, how);
 			spin_lock(&nfsi->req_lock);
 			continue;
 		}
 		if (nocommit)
 			break;
-		pages = nfs_scan_commit(inode, &head, 0, 0);
+		pages = nfs_scan_commit(inode, &head, idx_start, npages);
 		if (pages == 0)
 			break;
+		if (how & FLUSH_INVALIDATE) {
+			spin_unlock(&nfsi->req_lock);
+			nfs_cancel_requests(&head);
+			spin_lock(&nfsi->req_lock);
+			continue;
+		}
+		pages += nfs_scan_commit(inode, &head, 0, 0);
 		spin_unlock(&nfsi->req_lock);
 		ret = nfs_commit_list(inode, &head, how);
 		spin_lock(&nfsi->req_lock);
@@ -1512,7 +1529,7 @@ int nfs_sync_inode_wait(struct inode *in
 	return ret;
 }
 
-int nfs_init_writepagecache(void)
+int __init nfs_init_writepagecache(void)
 {
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
 					     sizeof(struct nfs_write_data),
@@ -1534,7 +1551,7 @@ int nfs_init_writepagecache(void)
 	return 0;
 }
 
-void nfs_destroy_writepagecache(void)
+void __exit nfs_destroy_writepagecache(void)
 {
 	mempool_destroy(nfs_commit_mempool);
 	mempool_destroy(nfs_wdata_mempool);
diff --git a/fs/super.c b/fs/super.c
index 057b532..8a669f6 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -871,8 +871,6 @@ do_kern_mount(const char *fstype, int fl
 	return mnt;
 }
 
-EXPORT_SYMBOL_GPL(do_kern_mount);
-
 struct vfsmount *kern_mount(struct file_system_type *type)
 {
 	return vfs_kern_mount(type, 0, type->name, NULL);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dba4cbd..2d8b348 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1100,7 +1100,7 @@ struct super_operations {
 	int (*statfs) (struct dentry *, struct kstatfs *);
 	int (*remount_fs) (struct super_block *, int *, char *);
 	void (*clear_inode) (struct inode *);
-	void (*umount_begin) (struct super_block *);
+	void (*umount_begin) (struct vfsmount *, int);
 
 	int (*show_options)(struct seq_file *, struct vfsmount *);
 	int (*show_stats)(struct seq_file *, struct vfsmount *);
@@ -1767,7 +1767,7 @@ extern struct inode_operations simple_di
 struct tree_descr { char *name; const struct file_operations *ops; int mode; };
 struct dentry *d_alloc_name(struct dentry *, const char *);
 extern int simple_fill_super(struct super_block *, int, struct tree_descr *);
-extern int simple_pin_fs(char *name, struct vfsmount **mount, int *count);
+extern int simple_pin_fs(struct file_system_type *, struct vfsmount **mount, int *count);
 extern void simple_release_fs(struct vfsmount **mount, int *count);
 
 extern ssize_t simple_read_from_buffer(void __user *, size_t, loff_t *, const void *, size_t);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a8876bc..aa4fe90 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -49,11 +49,12 @@ struct nlm_host {
 				h_killed     : 1,
 				h_monitored  : 1;
 	wait_queue_head_t	h_gracewait;	/* wait while reclaiming */
+	struct rw_semaphore	h_rwsem;	/* Reboot recovery lock */
 	u32			h_state;	/* pseudo-state counter */
 	u32			h_nsmstate;	/* true remote NSM state */
 	u32			h_pidcount;	/* Pseudopids */
 	atomic_t		h_count;	/* reference count */
-	struct semaphore	h_sema;		/* mutex for pmap binding */
+	struct mutex		h_mutex;	/* mutex for pmap binding */
 	unsigned long		h_nextrebind;	/* next portmap call */
 	unsigned long		h_expires;	/* eligible for GC */
 	struct list_head	h_lockowners;	/* Lockowners for the client */
@@ -219,6 +220,7 @@ static __inline__ int
 nlm_compare_locks(const struct file_lock *fl1, const struct file_lock *fl2)
 {
 	return	fl1->fl_pid   == fl2->fl_pid
+	     && fl1->fl_owner == fl2->fl_owner
 	     && fl1->fl_start == fl2->fl_start
 	     && fl1->fl_end   == fl2->fl_end
 	     &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 60718f1..403d1a9 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -28,6 +28,8 @@ #define MNT_NOEXEC	0x04
 #define MNT_NOATIME	0x08
 #define MNT_NODIRATIME	0x10
 
+#define MNT_SHRINKABLE	0x100
+
 #define MNT_SHARED	0x1000	/* if the vfsmount is a shared mount */
 #define MNT_UNBINDABLE	0x2000	/* if the vfsmount is a unbindable mount */
 #define MNT_PNODE_MASK	0x3000	/* propogation flag mask */
@@ -78,12 +80,18 @@ extern struct vfsmount *alloc_vfsmnt(con
 extern struct vfsmount *do_kern_mount(const char *fstype, int flags,
 				      const char *name, void *data);
 
+struct file_system_type;
+extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
+				      int flags, const char *name,
+				      void *data);
+
 struct nameidata;
 
 extern int do_add_mount(struct vfsmount *newmnt, struct nameidata *nd,
 			int mnt_flags, struct list_head *fslist);
 
 extern void mark_mounts_for_expiry(struct list_head *mounts);
+extern void shrink_submounts(struct vfsmount *mountpoint, struct list_head *mounts);
 
 extern spinlock_t vfsmount_lock;
 extern dev_t name_to_dev_t(char *name);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1059e6d..5f681d5 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -384,6 +384,7 @@ enum {
 	NFSPROC4_CLNT_DELEGRETURN,
 	NFSPROC4_CLNT_GETACL,
 	NFSPROC4_CLNT_SETACL,
+	NFSPROC4_CLNT_FS_LOCATIONS,
 };
 
 #endif
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7e079f8..0a1740b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -9,6 +9,27 @@
 #ifndef _LINUX_NFS_FS_H
 #define _LINUX_NFS_FS_H
 
+#include <linux/config.h>
+#include <linux/in.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rwsem.h>
+#include <linux/wait.h>
+
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/auth.h>
+#include <linux/sunrpc/clnt.h>
+
+#include <linux/nfs.h>
+#include <linux/nfs2.h>
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_xdr.h>
+
+#include <linux/nfs_fs_sb.h>
+
+#include <linux/rwsem.h>
+#include <linux/mempool.h>
 
 /*
  * Enable debugging support for nfs client.
@@ -41,27 +62,9 @@ #define FLUSH_STABLE		4	/* commit to sta
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
 #define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
+#define FLUSH_INVALIDATE	64	/* Invalidate the page cache */
 
 #ifdef __KERNEL__
-#include <linux/in.h>
-#include <linux/mm.h>
-#include <linux/pagemap.h>
-#include <linux/rwsem.h>
-#include <linux/wait.h>
-
-#include <linux/nfs_fs_sb.h>
-
-#include <linux/sunrpc/debug.h>
-#include <linux/sunrpc/auth.h>
-#include <linux/sunrpc/clnt.h>
-
-#include <linux/nfs.h>
-#include <linux/nfs2.h>
-#include <linux/nfs3.h>
-#include <linux/nfs4.h>
-#include <linux/nfs_xdr.h>
-#include <linux/rwsem.h>
-#include <linux/mempool.h>
 
 /*
  * NFSv3/v4 Access mode cache entry
@@ -233,8 +236,12 @@ static inline int nfs_caches_unstable(st
 
 static inline void nfs_mark_for_revalidate(struct inode *inode)
 {
+	struct nfs_inode *nfsi = NFS_I(inode);
+
 	spin_lock(&inode->i_lock);
-	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS;
+	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS;
+	if (S_ISDIR(inode->i_mode))
+		nfsi->cache_validity |= NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 }
 
@@ -296,7 +303,7 @@ extern int nfs_release(struct inode *, s
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
-extern void nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
+extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern void nfs_begin_attr_update(struct inode *);
@@ -306,6 +313,10 @@ extern void nfs_end_data_update(struct i
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, int mode);
+extern struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
+					const struct dentry *dentry,
+					struct nfs_fh *fh,
+					struct nfs_fattr *fattr);
 
 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
 extern u32 root_nfs_parse_addr(char *name); /*__init*/
@@ -392,6 +403,15 @@ #define nfs_unregister_sysctl() do { } w
 #endif
 
 /*
+ * linux/fs/nfs/namespace.c
+ */
+extern struct list_head nfs_automount_list;
+extern struct inode_operations nfs_mountpoint_inode_operations;
+extern struct inode_operations nfs_referral_inode_operations;
+extern int nfs_mountpoint_expiry_timeout;
+extern void nfs_release_automount_timer(void);
+
+/*
  * linux/fs/nfs/unlink.c
  */
 extern int  nfs_async_unlink(struct dentry *);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 65dec21..6b4a13c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -35,6 +35,7 @@ struct nfs_server {
 	char *			hostname;	/* remote hostname */
 	struct nfs_fh		fh;
 	struct sockaddr_in	addr;
+	struct nfs_fsid		fsid;
 	unsigned long		mount_time;	/* when this fs was mounted */
 #ifdef CONFIG_NFS_V4
 	/* Our own IP address, as a null-terminated string.
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 66e2ed6..1f7bd28 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -13,7 +13,6 @@ #define _LINUX_NFS_PAGE_H
 #include <linux/list.h>
 #include <linux/pagemap.h>
 #include <linux/wait.h>
-#include <linux/nfs_fs_sb.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/nfs_xdr.h>
 
@@ -63,8 +62,8 @@ extern	void nfs_release_request(struct n
 
 extern  int nfs_scan_lock_dirty(struct nfs_inode *nfsi, struct list_head *dst,
 				unsigned long idx_start, unsigned int npages);
-extern	int nfs_scan_list(struct list_head *, struct list_head *,
-			  unsigned long, unsigned int);
+extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *head, struct list_head *dst,
+			  unsigned long idx_start, unsigned int npages);
 extern	int nfs_coalesce_requests(struct list_head *, struct list_head *,
 				  unsigned int);
 extern  int nfs_wait_on_request(struct nfs_page *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7fafc4c..7c7320f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -14,11 +14,19 @@ #define NFS_MAX_FILE_IO_SIZE	(1048576U)
 #define NFS_DEF_FILE_IO_SIZE	(4096U)
 #define NFS_MIN_FILE_IO_SIZE	(1024U)
 
-struct nfs4_fsid {
-	__u64 major;
-	__u64 minor;
+struct nfs_fsid {
+	uint64_t		major;
+	uint64_t		minor;
 };
 
+/*
+ * Helper for checking equality between 2 fsids.
+ */
+static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid *b)
+{
+	return a->major == b->major && a->minor == b->minor;
+}
+
 struct nfs_fattr {
 	unsigned short		valid;		/* which fields are valid */
 	__u64			pre_size;	/* pre_op_attr.size	  */
@@ -40,10 +48,7 @@ struct nfs_fattr {
 		} nfs3;
 	} du;
 	dev_t			rdev;
-	union {
-		__u64		nfs3;		/* also nfs2 */
-		struct nfs4_fsid nfs4;
-	} fsid_u;
+	struct nfs_fsid		fsid;
 	__u64			fileid;
 	struct timespec		atime;
 	struct timespec		mtime;
@@ -57,8 +62,8 @@ struct nfs_fattr {
 #define NFS_ATTR_WCC		0x0001		/* pre-op WCC data    */
 #define NFS_ATTR_FATTR		0x0002		/* post-op attributes */
 #define NFS_ATTR_FATTR_V3	0x0004		/* NFSv3 attributes */
-#define NFS_ATTR_FATTR_V4	0x0008
-#define NFS_ATTR_PRE_CHANGE	0x0010
+#define NFS_ATTR_FATTR_V4	0x0008		/* NFSv4 change attribute */
+#define NFS_ATTR_FATTR_V4_REFERRAL	0x0010		/* NFSv4 referral */
 
 /*
  * Info on the file system
@@ -675,6 +680,40 @@ struct nfs4_server_caps_res {
 	u32				has_symlinks;
 };
 
+struct nfs4_string {
+	unsigned int len;
+	char *data;
+};
+
+#define NFS4_PATHNAME_MAXCOMPONENTS 512
+struct nfs4_pathname {
+	unsigned int ncomponents;
+	struct nfs4_string components[NFS4_PATHNAME_MAXCOMPONENTS];
+};
+
+#define NFS4_FS_LOCATION_MAXSERVERS 10
+struct nfs4_fs_location {
+	unsigned int nservers;
+	struct nfs4_string servers[NFS4_FS_LOCATION_MAXSERVERS];
+	struct nfs4_pathname rootpath;
+};
+
+#define NFS4_FS_LOCATIONS_MAXENTRIES 10
+struct nfs4_fs_locations {
+	struct nfs_fattr fattr;
+	const struct nfs_server *server;
+	struct nfs4_pathname fs_path;
+	int nlocations;
+	struct nfs4_fs_location locations[NFS4_FS_LOCATIONS_MAXENTRIES];
+};
+
+struct nfs4_fs_locations_arg {
+	const struct nfs_fh *dir_fh;
+	const struct qstr *name;
+	struct page *page;
+	const u32 *bitmask;
+};
+
 #endif /* CONFIG_NFS_V4 */
 
 struct nfs_page;
@@ -695,7 +734,7 @@ struct nfs_read_data {
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-	struct page		*page_array[NFS_PAGEVEC_SIZE + 1];
+	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
 struct nfs_write_data {
@@ -713,7 +752,7 @@ struct nfs_write_data {
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-	struct page		*page_array[NFS_PAGEVEC_SIZE + 1];
+	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
 struct nfs_access_entry;
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 84c35d4..e6d3d34 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -194,6 +194,7 @@ extern void xdr_write_pages(struct xdr_s
 extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, uint32_t *p);
 extern uint32_t *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
+extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 
 #endif /* __KERNEL__ */
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 84b5cf9..38bc333 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2255,7 +2255,7 @@ static int __init init_tmpfs(void)
 #ifdef CONFIG_TMPFS
 	devfs_mk_dir("shm");
 #endif
-	shm_mnt = do_kern_mount(tmpfs_fs_type.name, MS_NOUSER,
+	shm_mnt = vfs_kern_mount(&tmpfs_fs_type, MS_NOUSER,
 				tmpfs_fs_type.name, NULL);
 	if (IS_ERR(shm_mnt)) {
 		error = PTR_ERR(shm_mnt);
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index f56767a..2eccffa 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -118,6 +118,8 @@ struct rpc_auth null_auth = {
 	.au_cslack	= 4,
 	.au_rslack	= 2,
 	.au_ops		= &authnull_ops,
+	.au_flavor	= RPC_AUTH_NULL,
+	.au_count	= ATOMIC_INIT(0),
 };
 
 static
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index df14b6b..74c7406 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -225,6 +225,7 @@ struct rpc_auth		unix_auth = {
 	.au_cslack	= UNX_WRITESLACK,
 	.au_rslack	= 2,			/* assume AUTH_NULL verf */
 	.au_ops		= &authunix_ops,
+	.au_flavor	= RPC_AUTH_UNIX,
 	.au_count	= ATOMIC_INIT(0),
 	.au_credcache	= &unix_cred_cache,
 };
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8241fa7..dafe793 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -439,7 +439,7 @@ struct vfsmount *rpc_get_mount(void)
 {
 	int err;
 
-	err = simple_pin_fs("rpc_pipefs", &rpc_mount, &rpc_mount_count);
+	err = simple_pin_fs(&rpc_pipe_fs_type, &rpc_mount, &rpc_mount_count);
 	if (err != 0)
 		return ERR_PTR(err);
 	return rpc_mount;
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index ca4bfa5..49174f0 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -568,8 +568,7 @@ EXPORT_SYMBOL(xdr_inline_decode);
  *
  * Moves data beyond the current pointer position from the XDR head[] buffer
  * into the page list. Any data that lies beyond current position + "len"
- * bytes is moved into the XDR tail[]. The current pointer is then
- * repositioned at the beginning of the XDR tail.
+ * bytes is moved into the XDR tail[].
  */
 void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 {
@@ -606,6 +605,31 @@ void xdr_read_pages(struct xdr_stream *x
 }
 EXPORT_SYMBOL(xdr_read_pages);
 
+/**
+ * xdr_enter_page - decode data from the XDR page
+ * @xdr: pointer to xdr_stream struct
+ * @len: number of bytes of page data
+ *
+ * Moves data beyond the current pointer position from the XDR head[] buffer
+ * into the page list. Any data that lies beyond current position + "len"
+ * bytes is moved into the XDR tail[]. The current pointer is then
+ * repositioned at the beginning of the first XDR page.
+ */
+void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
+{
+	char * kaddr = page_address(xdr->buf->pages[0]);
+	xdr_read_pages(xdr, len);
+	/*
+	 * Position current pointer at beginning of tail, and
+	 * set remaining message length.
+	 */
+	if (len > PAGE_CACHE_SIZE - xdr->buf->page_base)
+		len = PAGE_CACHE_SIZE - xdr->buf->page_base;
+	xdr->p = (uint32_t *)(kaddr + xdr->buf->page_base);
+	xdr->end = (uint32_t *)((char *)xdr->p + len);
+}
+EXPORT_SYMBOL(xdr_enter_page);
+
 static struct kvec empty_iov = {.iov_base = NULL, .iov_len = 0};
 
 void
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4dd5b3c..02060d0 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -41,7 +41,7 @@ #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/workqueue.h>
-#include <linux/random.h>
+#include <linux/net.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/metrics.h>
@@ -830,7 +830,7 @@ static inline u32 xprt_alloc_xid(struct 
 
 static inline void xprt_init_xid(struct rpc_xprt *xprt)
 {
-	get_random_bytes(&xprt->xid, sizeof(xprt->xid));
+	xprt->xid = net_random();
 }
 
 static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4b4e7df..21006b1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -930,6 +930,13 @@ static void xs_udp_timer(struct rpc_task
 	xprt_adjust_cwnd(task, -ETIMEDOUT);
 }
 
+static unsigned short xs_get_random_port(void)
+{
+	unsigned short range = xprt_max_resvport - xprt_min_resvport;
+	unsigned short rand = (unsigned short) net_random() % range;
+	return rand + xprt_min_resvport;
+}
+
 /**
  * xs_set_port - reset the port number in the remote endpoint address
  * @xprt: generic transport
@@ -1275,7 +1282,7 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 	memset(xprt->slot, 0, slot_table_size);
 
 	xprt->prot = IPPROTO_UDP;
-	xprt->port = xprt_max_resvport;
+	xprt->port = xs_get_random_port();
 	xprt->tsh_size = 0;
 	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
@@ -1317,7 +1324,7 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
 	memset(xprt->slot, 0, slot_table_size);
 
 	xprt->prot = IPPROTO_TCP;
-	xprt->port = xprt_max_resvport;
+	xprt->port = xs_get_random_port();
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
diff --git a/security/inode.c b/security/inode.c
index e6fc29a..98a0df5 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -224,7 +224,7 @@ struct dentry *securityfs_create_file(co
 
 	pr_debug("securityfs: creating file '%s'\n",name);
 
-	error = simple_pin_fs("securityfs", &mount, &mount_count);
+	error = simple_pin_fs(&fs_type, &mount, &mount_count);
 	if (error) {
 		dentry = ERR_PTR(error);
 		goto exit;



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
