Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756751Ab1FUSgb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2011 14:36:31 -0400
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 21 Jun 2011 14:36:24 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1308681384.26456.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Bakeathon testing in Ann Arbor last week uncovered a number of bugs
in the existing NFS code (mainly in NFSv4.1).

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/clntproc.c            |    8 ++++++-
 fs/nfs/inode.c                 |    6 +++-
 fs/nfs/internal.h              |   11 +++++++++
 fs/nfs/nfs4filelayout.c        |   21 ++++++++++++------
 fs/nfs/nfs4proc.c              |   45 ++++++++++++++++++++++++----------------
 fs/nfs/nfs4xdr.c               |   26 ++++++++++++----------
 fs/nfs/objlayout/objio_osd.c   |    4 ++-
 fs/nfs/objlayout/objlayout.c   |    2 +-
 fs/nfs/pagelist.c              |    3 +-
 fs/nfs/pnfs.c                  |   44 +++++++++++++++++++++++++++-----------
 fs/nfs/pnfs.h                  |    1 +
 fs/nfs/pnfs_dev.c              |   17 ++++++++++----
 include/linux/nfs_page.h       |    3 ++
 include/linux/nfs_xdr.h        |    1 -
 include/linux/sunrpc/sched.h   |    3 +-
 net/sunrpc/auth_gss/auth_gss.c |    4 +-
 net/sunrpc/clnt.c              |    5 +++-
 net/sunrpc/sched.c             |    1 +
 18 files changed, 139 insertions(+), 66 deletions(-)

commit 1650add23578b5ca35c1f1e863987180a8c03779
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Jun 2 15:07:35 2011 -0400

    NFS: Fix decode_secinfo_maxsz
    
    I initially did the calculation in bytes, and not words
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19982ba8562e33083cb5bbb59a74855d8a9624ea
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 10 13:30:23 2011 -0400

    NFSv4.1: Fix an off-by-one error in pnfs_generic_pg_test
    
    And document what is going on there...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8f7d5efbef8718a774ac5e347b4ec069f17fd9b4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 10 13:30:22 2011 -0400

    NFSv4.1: Fix some issues with pnfs_generic_pg_test
    
    1. If the intention is to coalesce requests 'prev' and 'req' then we
       have to ensure at least that we have a layout starting at
       req_offset(prev).
    
    2. If we're only requesting a minimal layout of length desc->pg_count,
       we need to test the length actually returned by the server before
       we allow the coalescing to occur.
    
    3. We need to deal correctly with (pgio->lseg == NULL)
    
    4. Fixup the test guarding the pnfs_update_layout.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19345cb299e8234006c5125151ab723e851a1d24
Author: Benny Halevy <benny@tonian.com>
Date:   Sun Jun 19 18:33:46 2011 -0400

    NFSv4.1: file layout must consider pg_bsize for coalescing
    
    Otherwise we end up overflowing the rpc buffer size on the receive end.
    
    Signed-off-by: Benny Halevy <benny@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit df18d127f4fed7a0284bcfa8d2843800cdb63b72
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jun 17 16:25:51 2011 -0400

    pnfs-obj: No longer needed to take an extra ref at add_device
    
    Andy's last device_cache patches, already take an extra
    reference on the newly inserted device_id. So we can remove it
    from obj-io.
    
    Without this patch the device_ids are leaked.
    
    Andy's patches are not in Linus tree yet. So I'm not sure if they are
    scheduled for this Kernel or the next. This patch should be added as
    part of these.
    
    CC: Andy Adamson <andros@netapp.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5afa9133cfe67f1bfead6049a9640c9262a7101c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 17 10:14:59 2011 -0400

    SUNRPC: Ensure the RPC client only quits on fatal signals
    
    Fix a couple of instances where we were exiting the RPC client on
    arbitrary signals. We should only do so on fatal signals.
    
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee7b75fc4f3ae49e1f25bf56219bb5de3c29afaf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 16 13:15:41 2011 -0400

    NFSv4: Fix a readdir regression
    
    Commit 7ebb9315 (NFS: use secinfo when crossing mountpoints) introduces
    a regression when decoding an NFSv4 readdir entry that sets the
    rdattr_error field.
    By treating the resulting value as if it is a decoding error, the current
    code may cause us to skip valid readdir entries.
    
    Reported-by: Andy Adamson <andros@netapp.com>
    Cc: stable@kernel.org [2.6.39]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9e2dfdb3081edfae66a49013517e80dd8a0469fa
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Jun 15 14:32:02 2011 -0400

    nfs4.1: mark layout as bad on error path in _pnfs_return_layout
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ea0ded748bdea78f9e2fefb571f7d6ce9edb4f89
Author: Fred Isaman <iisaman@netapp.com>
Date:   Wed Jun 15 12:31:02 2011 -0400

    nfs4.1: prevent race that allowed use of freed layout in _pnfs_return_layout
    
    mark_matching_lsegs_invalid could put the last ref to the layout, so
    the get_layout_hdr needs to be called first.
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1ed3a8539af7b36aa5c977f304e80f7fc8d27bfc
Author: Benny Halevy <benny@tonian.com>
Date:   Wed Jun 15 11:39:57 2011 -0400

    NFSv4.1: need to put_layout_hdr on _pnfs_return_layout error path
    
    We always get a reference on the layout header and we rely on
    nfs4_layoutreturn_release to put it.  If we hit an allocation error
    before starting the rpc proc we bail out early without dereferncing
    the layout header properly.
    
    Signed-off-by: Benny Halevy <benny@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c7fd06228b994190d8369a2a0acf5224e4e13d1a
Author: David Howells <dhowells@redhat.com>
Date:   Wed Jun 15 00:55:44 2011 +0100

    NFS: (d)printks should use %zd for ssize_t arguments
    
    (d)printks should use %zd for ssize_t arguments not %ld, otherwise they might
    get a warning.  I see the following with MN10300.
    
    fs/nfs/objlayout/objlayout.c: In function 'objlayout_read_done':
    fs/nfs/objlayout/objlayout.c:294: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t'
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    cc: linux-nfs@vger.kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d771e3a43e23a37398b7e05a9d1b1036d698263c
Author: Benny Halevy <benny@tonian.com>
Date:   Tue Jun 14 16:30:16 2011 -0400

    NFSv4.1: fix break condition in pnfs_find_lseg
    
    The break condition to skip out of the loop got broken when cmp_layout
    was change.  Essentially, we want to stop looking once we know no layout
    on the remainder of the list can match the first byte of the looked-up
    range.
    
    Reported-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <benny@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a2e1d4f2e5ed83850de92a491ef225824cb457bd
Author: Fred Isaman <iisaman@netapp.com>
Date:   Mon Jun 13 18:54:53 2011 -0400

    nfs4.1: fix several problems with _pnfs_return_layout
    
    _pnfs_return_layout had the following problems:
    
    - it did not call pnfs_free_lseg_list on all paths
    - it unintentionally did a forgetful return when there was no outstanding io
    - it raced with concurrent LAYOUTGETS
    
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cec765cf5891c7fc3d905832b481bfb6fd55825d
Author: Andy Adamson <andros@netapp.com>
Date:   Mon Jun 13 18:36:17 2011 -0400

    NFSv4.1: allow zero fh array in filelayout decode layout
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    cc:stable@kernel.org [2.6.39]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 533eb4611c9eea53072eb6a61d5a6393b6a77ed7
Author: Andy Adamson <andros@netapp.com>
Date:   Mon Jun 13 18:25:56 2011 -0400

    NFSv4.1: allow nfs_fhget to succeed with mounted on fileid
    
    Commit 28331a46d88459788c8fca72dbb0415cd7f514c9 "Ensure we request the
    ordinary fileid when doing readdirplus"
    changed the meaning of NFS_ATTR_FATTR_FILEID which used to be set when
    FATTR4_WORD1_MOUNTED_ON_FILED was requested.
    
    Allow nfs_fhget to succeed with only a mounted on fileid when crossing
    a mountpoint or a referral.
    
    Ask for the fileid of the absent file system if mounted_on_fileid is not
    supported.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    cc:stable@kernel.org [2.6.39]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1d92a08da23848a38eece4df7eaa4e8ec0e6c699
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 14 12:07:38 2011 -0400

    NFSv4.1: Fix a refcounting issue in the pNFS device id cache
    
    When we add something to the global device id cache, we need to bump the
    reference count, so that the cache itself holds a reference.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c9c30dd5f73dccaa326a54dfcf490316946aea87
Author: Benny Halevy <benny@tonian.com>
Date:   Sat Jun 11 17:08:39 2011 -0400

    NFSv4.1: deprecate headerpadsz in CREATE_SESSION
    
    We don't support header padding yet so better off ditching it
    
    Reported-by: Sid Moore <learnmost@gmail.com>
    Signed-off-by: Benny Halevy <benny@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f66b5984df2fe1617c05900a39a7ef493ca9de9
Author: Peng Tao <bergwolf@gmail.com>
Date:   Sat Oct 16 22:07:46 2010 -0700

    NFS41: do not update isize if inode needs layoutcommit
    
    nfs_update_inode will update isize if there is no queued pages. For pNFS,
    layoutcommit is supposed to change file size on server, the same effect as queued
    pages. nfs_update_inode may be called when dirty pages are written back (nfsi->npages==0)
    but layoutcommit is not sent, and it will change client file size according to server
    file size. Then client ends up losing what it just writes back in pNFS path.
    So we should skip updating client file size if file needs layoutcommit.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Cc: stable@kernel.org   [2.6.39]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0b760113a3a155269a3fba93a409c640031dd68f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue May 31 15:15:34 2011 -0400

    NLM: Don't hang forever on NLM unlock requests
    
    If the NLM daemon is killed on the NFS server, we can currently end up
    hanging forever on an 'unlock' request, instead of aborting. Basically,
    if the rpcbind request fails, or the server keeps returning garbage, we
    really want to quit instead of retrying.
    
    Tested-by: Vasily Averin <vvs@sw.ru>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 9e3bd4e24e94d60d2e0762e919aab6c9a7fc0c5b
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Tue May 31 21:46:50 2011 -0400

    NFS: fix umount of pnfs filesystems
    
    Unmounting a pnfs filesystem hangs using filelayout and possibly others.
    This fixes the use of the rcu protected node by making use of a new 'tmpnode'
    for the temporary purge list. Also, the spinlock shouldn't be held when calling
    synchronize_rcu().
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

