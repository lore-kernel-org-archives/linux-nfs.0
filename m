Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab0LIDLd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 22:11:33 -0500
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Dec 2010 22:11:30 -0500
Message-ID: <1291864290.3618.1.camel@heimdal.trondhjem.org>
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
 Documentation/filesystems/Locking |    7 +++-
 Documentation/filesystems/vfs.txt |    7 +++
 fs/nfs/dir.c                      |   76 +++++++++++++++++--------------------
 fs/nfs/file.c                     |    2 +
 fs/nfs/inode.c                    |    1 +
 fs/nfs/nfs4proc.c                 |    9 ++++
 fs/nfs/pagelist.c                 |    4 +-
 fs/nfs/read.c                     |    1 -
 fs/nfs/super.c                    |    4 --
 fs/nfs/write.c                    |    3 +-
 include/linux/fs.h                |    1 +
 include/linux/nfs_fs.h            |    1 +
 include/linux/nfs_page.h          |    1 +
 mm/filemap.c                      |    5 ++
 mm/truncate.c                     |    4 ++
 mm/vmscan.c                       |    7 +++
 16 files changed, 83 insertions(+), 50 deletions(-)

commit 2df485a774ba59c3f43bfe84107672c1d9b731a0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 7 22:39:17 2010 -0500

    nfs: remove extraneous and problematic calls to nfs_clear_request
    
    When a nfs_page is freed, nfs_free_request is called which also calls
    nfs_clear_request to clean out the lock and open contexts and free the
    pagecache page.
    
    However, a couple of places in the nfs code call nfs_clear_request
    themselves. What happens here if the refcount on the request is still high?
    We'll be releasing contexts and freeing pointers while the request is
    possibly still in use.
    
    Remove those bare calls to nfs_clear_context. That should only be done when
    the request is being freed.
    
    Note that when doing this, we need to watch out for tests of req->wb_page.
    Previously, nfs_set_page_tag_locked() and nfs_clear_page_tag_locked()
    would check the value of req->wb_page to figure out if the page is mapped
    into the nfsi->nfs_page_tree. We now indicate the page is mapped using
    the new bit PG_MAPPED in req->wb_flags .
    
    Reported-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0de1b7e800188782973598158e0acbb9e08e6c99
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Sat Oct 30 10:19:33 2010 +0800

    nfs: kernel should return EPROTONOSUPPORT when not support NFSv4
    
      When nfs client(kernel) don't support NFSv4, maybe user build
      kernel without NFSv4, there is a problem.
    
      Using command "mount SERVER-IP:/nfsv3 /mnt/" to mount NFSv3
      filesystem, mount should should success, but fail and get error:
    
        "mount.nfs: an incorrect mount option was specified"
    
      System call mount "nfs"(not "nfs4") with "vers=4",
      if CONFIG_NFS_V4 is not defined, the "vers=4" will be parsed
      as invalid argument and kernel return EINVAL to nfs-utils.
    
      About that, we really want get EPROTONOSUPPORT rather than
      EINVAL. This path make sure kernel parses argument success,
      and return EPROTONOSUPPORT at nfs_validate_mount_data().
    
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 21ac19d484a8ffb66f64487846c8d53afef04d2b
Author: Sergey Vlasov <vsu@altlinux.ru>
Date:   Sun Nov 28 21:04:05 2010 +0000

    NFS: Fix fcntl F_GETLK not reporting some conflicts
    
    The commit 129a84de2347002f09721cda3155ccfd19fade40 (locks: fix F_GETLK
    regression (failure to find conflicts)) fixed the posix_test_lock()
    function by itself, however, its usage in NFS changed by the commit
    9d6a8c5c213e34c475e72b245a8eb709258e968c (locks: give posix_test_lock
    same interface as ->lock) remained broken - subsequent NFS-specific
    locking code received F_UNLCK instead of the user-specified lock type.
    To fix the problem, fl->fl_type needs to be saved before the
    posix_test_lock() call and restored if no local conflicts were reported.
    
    Reference: https://bugzilla.kernel.org/show_bug.cgi?id=23892
    Tested-by: Alexander Morozov <amorozov@etersoft.ru>
    Signed-off-by: Sergey Vlasov <vsu@altlinux.ru>
    Cc: <stable@kernel.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 08a22b392a141c201d7ed4d435de942aa853acd3
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Wed Dec 1 10:42:16 2010 +0000

    nfs: Discard ACL cache on mode update
    
    An update of mode bits can result in ACL value being changed. We need
    to mark the acl cache invalid when we update mode. Similarly we need
    to update file attribute when we change ACL value
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 47c716cbf638a16583441d78be3fc24345eab636
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 7 12:44:56 2010 -0500

    NFS: Readdir cleanups
    
    No functional changes, but clarify the code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 18fb5fe40ce7f789b5cfc3aa81ff1e6175b0a5be
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 7 12:41:58 2010 -0500

    NFS: nfs_readdir_search_for_cookie() don't mark as eof if cookie not found
    
    If we're searching for a specific cookie, and it isn't found in the page
    cache, we should try an uncached_readdir(). To do so, we return EBADCOOKIE,
    but we don't set desc->eof.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 11de3b11e08cac26d59e88efaf4e316701883552
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 1 14:17:06 2010 -0500

    NFS: Fix a memory leak in nfs_readdir
    
    We need to ensure that the entries in the nfs_cache_array get cleared
    when the page is removed from the page cache. To do so, we use the
    freepage address_space operation.
    
    Change nfs_readdir_clear_array to use kmap_atomic(), so that the
    function can be safely called from all contexts.
    
    Finally, modify the cache_page_release helper to call
    nfs_readdir_clear_array directly, when dealing with an anonymous
    page from 'uncached_readdir'.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6072d13c429373c5d63b69dadbbef40a9b035552
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Dec 1 13:35:19 2010 -0500

    Call the filesystem back whenever a page is removed from the page cache
    
    NFS needs to be able to release objects that are stored in the page
    cache once the page itself is no longer visible from the page cache.
    
    This patch adds a callback to the address space operations that allows
    filesystems to perform page cleanups once the page has been removed
    from the page cache.
    
    Original patch by: Linus Torvalds <torvalds@linux-foundation.org>
    [trondmy: cover the cases of invalidate_inode_pages2() and
              truncate_inode_pages()]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0aded708d125a3ff7e5abaea9c2d9c6d7ebbfdcd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Nov 30 21:56:32 2010 -0500

    NFS: Ensure we use the correct cookie in nfs_readdir_xdr_filler
    
    We need to use the cookie from the previous array entry, not the
    actual cookie that we are searching for (except for the case of
    uncached_readdir).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

