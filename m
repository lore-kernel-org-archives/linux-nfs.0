Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48280 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755844Ab2APWHz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Jan 2012 17:07:55 -0500
Message-ID: <1326751673.2921.1.camel@lade.trondhjem.org>
Subject: [GIT PULL] Please pull more NFS client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Mon, 16 Jan 2012 17:07:53 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the signed tag "nfs-for-3.3-2" in the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tag nfs-for-3.3-2

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/blocklayout/blocklayout.c |  202 ++++++++++++++++++++++++-------------
 fs/nfs/blocklayout/blocklayout.h |   12 ++-
 fs/nfs/blocklayout/extents.c     |  176 ++++++++++++++-------------------
 fs/nfs/callback.h                |    2 +-
 fs/nfs/callback_xdr.c            |    4 +
 fs/nfs/nfs4filelayoutdev.c       |    2 +-
 fs/nfs/nfs4proc.c                |    2 +-
 7 files changed, 222 insertions(+), 178 deletions(-)

commit 7c5465d6ccd759caa959828e2add5603518dafc4
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:46 2012 +0800

    pnfsblock: alloc short extent before submit bio
    
    As discussed earlier, it is better for block client to allocate memory for
    tracking extents state before submitting bio. So the patch does it by allocating
    a short_extent for every INVALID extent touched by write pagelist and for
    every zeroing page we created, saving them in layout header. Then in end_io we
    can just use them to create commit list items and avoid memory allocation there.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c0411a94a8f318379464e29dd81db806249dbca6
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:44 2012 +0800

    pnfsblock: remove rpc_call_ops from struct parallel_io
    
    block layout can just make use of generic read/write_done.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 72c508879979522de347bcec706507e00d7c443d
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:42 2012 +0800

    pnfsblock: move find lock page logic out of bl_write_pagelist
    
    Also avoid unnecessary lock_page if page is handled by others.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 60c52e3a72fda10e82f38b6f979956eb2dcb3d4e
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:40 2012 +0800

    pnfsblock: cleanup bl_mark_sectors_init
    
    It does not need to manipulate on partial initialized blocks.
    Writeback code takes care of it.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 74a6eeb44ca6174d9cc93b9b8b4d58211c57bc80
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:48 2012 +0800

    pnfsblock: limit bio page count
    
    One bio can have at most BIO_MAX_PAGES pages. We should limit it bec otherwise
    bio_alloc will fail when there are many pages in one read/write_pagelist.
    
    Cc: <stable@vger.kernel.org> #3.1+
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 93a3844ee0f843b05a1df4b52e1a19ff26b98d24
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:47 2012 +0800

    pnfsblock: don't spinlock when freeing block_dev
    
    bl_free_block_dev() may sleep. We can not call it with spinlock held.
    Besides, there is no need to take bm_lock as we are last user freeing bm_devlist.
    
    Cc: <stable@vger.kernel.org> #3.1+
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 57582b372f63d0f655b1a35b0d306d73d1a46775
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:45 2012 +0800

    pnfsblock: clean up _add_entry
    
    It is wrong to kmalloc in _add_entry() as it is inside
    spinlock. memory should be already allocated _add_entry() is called.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 82b906d6550ee5fe0d5553359b3c9692dd0aed31
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:43 2012 +0800

    pnfsblock: set read/write tk_status to pnfs_error
    
    To pass the IO status to upper layer.
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 39e567ae36fe03c2b446e1b83ee3d39bea08f90b
Author: Peng Tao <bergwolf@gmail.com>
Date:   Thu Jan 12 23:18:41 2012 +0800

    pnfsblock: acquire im_lock in _preload_range
    
    When calling _add_entry, we should take the im_lock to protect
    agains other modifiers.
    
    Cc: <stable@vger.kernel.org> #3.1+
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit de040beccd52bb5fcac90031505384d037b1111c
Author: Peng Tao <bergwolf@gmail.com>
Date:   Tue Jan 10 22:42:47 2012 +0800

    NFS4: fix compile warnings in nfs4proc.c
    
    compile in nfs-for-3.3 branch shows following warnings. Fix it here.
    
    fs/nfs/nfs4proc.c: In function ‘__nfs4_get_acl_uncached’:
    fs/nfs/nfs4proc.c:3589: warning: format ‘%ld’ expects type ‘long int’, but argument 4 has type ‘size_t’
    fs/nfs/nfs4proc.c:3589: warning: format ‘%ld’ expects type ‘long int’, but argument 6 has type ‘size_t’
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 363e0df057ea8da539645fe4c3c227e3d44054cc
Author: Dan Carpenter <dan.carpenter@oracle.com>
Date:   Thu Jan 12 10:16:14 2012 +0300

    nfs: check for integer overflow in decode_devicenotify_args()
    
    On 32 bit, if n is too large then "n * sizeof(*args->devs)" could
    overflow and args->devs would be smaller than expected.
    
    Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 13fff2f35fd21d69ee84ef6a78610420e1a42818
Author: Dan Carpenter <dan.carpenter@oracle.com>
Date:   Thu Jan 12 10:07:35 2012 +0300

    NFS: cleanup endian type in decode_ds_addr()
    
    port is supposed to be a __be16 here.  The existing code should work
    fine, but this is a cleanup.
    
    Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0e0243dc35a2349b3946e54f90e874be396fdb8b
Author: Dan Carpenter <dan.carpenter@oracle.com>
Date:   Thu Jan 12 10:06:05 2012 +0300

    NFS: add an endian notation
    
    This function returns a big endian value.  The implementation in
    fs/nfs/callback_proc.c is declared with "__be32" but the .h file uses
    "unsigned" instead.  It makes sparse complain:
    
    fs/nfs/callback_proc.c:232:8: error:
    	symbol 'nfs4_callback_layoutrecall' redeclared with different
    	type (originally declared at fs/nfs/callback.h:165) - different
    	base types
    
    Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

