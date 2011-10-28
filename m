Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51001 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab1J1TOV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2011 15:14:21 -0400
Message-ID: <4EAAFED8.7020600@panasas.com>
Date: Fri, 28 Oct 2011 12:13:28 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: [patchset 0/8] pnfs-obj: Move to ORE for v3.2 merge window
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond hi.

Now that both your NFS bits and ORE bits are in Linus tree. We can send in
the pnfs-objects layout driver patches.

How do you want to do this. Should I post them by email, or do you want
to pull them from git.open-osd.org?

The patches are available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus

Based on commit f362f98e7c445643d27c610bb7a86b79727b592e:
  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/hch/vfs-queue (2011-10-28 10:49:34 -0700)

Boaz Harrosh (8):
      pnfs-obj: Remove redundant EOF from objlayout_io_state
      pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of read/write_pagelist
      pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
      pnfs-obj: Rename objlayout_io_state => objlayout_io_res
      pnfs-obj: move to ore 01: ore_layout & ore_components
      pnfs-obj: move to ore 02: move to ORE
      pnfs-obj: move to ore 03: Remove old raid engine
      pnfs-obj: Support for RAID5 read-4-write interface.

 fs/exofs/Kconfig             |    2 +-
 fs/nfs/objlayout/objio_osd.c |  872 ++++++++++--------------------------------
 fs/nfs/objlayout/objlayout.c |  209 ++++-------
 fs/nfs/objlayout/objlayout.h |   48 ++--
 4 files changed, 302 insertions(+), 829 deletions(-)

---
List of commits:

commit dde406e58cd91b10233c40fa5ea86c1261a4d043
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Wed Oct 12 15:42:07 2011 +0200

    pnfs-obj: Support for RAID5 read-4-write interface.
    
    The ore need suplied a r4w_get_page/r4w_put_page API
    from Filesystem so it can get cache pages to read-into when
    writing parial stripes.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objio_osd.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

commit 48a5fbeedb4b9a80930e987a8f7bea4f784ae4e0
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 3 16:55:29 2011 +0200

    pnfs-obj: move to ore 03: Remove old raid engine
    
    Finally remove all the old raid engine, which is by now
    dead code.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objio_osd.c |  504 ------------------------------------------
 1 files changed, 0 insertions(+), 504 deletions(-)

commit b0f3d5f82fd8acefc0f2659cf1bb931942500db5
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 3 20:26:05 2011 +0200

    pnfs-obj: move to ore 02: move to ORE
    
    In this patch we are actually moving to the ORE.
    (Object Raid Engine).
    
    objio_state holds a pointer to an ore_io_state. Once
    we have an ore_io_state at hand we can call the ore
    for reading/writing. We register on the done path
    to kick off the nfs io_done mechanism.
    
    Again for Ease of reviewing the old code is "#if 0"
    but is not removed so the diff command works better.
    The old code will be removed in the next patch.
    
    fs/exofs/Kconfig::ORE is modified to also be auto-included
    if PNFS_OBJLAYOUT is set. Since we now depend on ORE.
    (See comments in fs/exofs/Kconfig)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/exofs/Kconfig             |    2 +-
 fs/nfs/objlayout/objio_osd.c |  133 +++++++++++++++++++-----------------------
 2 files changed, 60 insertions(+), 75 deletions(-)

commit 79ca7af7ec31cbf83a86e61c80ca0e24215244bf
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 3 15:57:55 2011 +0200

    pnfs-obj: move to ore 01: ore_layout & ore_components
    
    For Ease of reviewing I split the move to ore into 3 parts
    	move to ore 01: ore_layout & ore_components
    	move to ore 02: move to ORE
    	move to ore 03: Remove old raid engine
    
    This patch modifies the objio_lseg, layout-segment level
    and devices and components arrays to use the ORE types.
    
    Though it will be removed soon, also the raid engine
    is modified to actually compile, possibly run, with
    the new types. So it is the same old raid engine but
    with some new ORE types.
    
    For Ease of reviewing, some of the old code is
    "#if 0" but is not removed so the diff command works
    better. The old code will be removed in the 3rd patch.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objio_osd.c |  272 ++++++++++++++++++++----------------------
 1 files changed, 128 insertions(+), 144 deletions(-)

commit 67d896c6805004e1ca32c07d9c0a4df504eb7658
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Oct 3 17:21:47 2011 +0200

    pnfs-obj: Rename objlayout_io_state => objlayout_io_res
    
    * All instances of objlayout_io_state => objlayout_io_res
    * All instances of state => oir;
    * All instances of ol_state => oir;
    
    Big but nothing to it
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objio_osd.c |   17 +++++------
 fs/nfs/objlayout/objlayout.c |   63 ++++++++++++++++++++---------------------
 fs/nfs/objlayout/objlayout.h |   15 ++++++----
 3 files changed, 48 insertions(+), 47 deletions(-)

commit daaaebf9e448ad8a306333537dfabf1e878bd47d
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Tue Aug 16 17:34:59 2011 -0700

    pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
    
    This is part of moving objio_osd to use the ORE.
    
    objlayout_io_state had two functions:
    1. It was used in the error reporting mechanism at layout_return.
       This function is kept intact.
       (Later patch will rename objlayout_io_state => objlayout_io_res)
    2. Carrier of rw io members into the objio_read/write_paglist API.
       This is removed in this patch.
    
    The {r,w}data received from NFS are passed directly to the
    objio_{read,write}_paglist API. The io_engine is now allocating
    it's own IO state as part of the read/write. The minimal
    functionality that was part of the generic allocation is passed
    to the io_engine.
    
    So part of this patch is rename of:
    	ios->ol_state.foo => ios->foo
    
    At objlayout_{read,write}_done an objlayout_io_state is passed that
    denotes the result of the IO. (Hence the later name change).
    If the IO is successful objlayout calls an objio_free_result() API
    immediately (Which for objio_osd causes the release of the io_state).
    If the IO ended in an error it is hanged onto until reported in
    layout_return and is released later through the objio_free_result()
    API. (All this is not new just renamed and cleaned)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objio_osd.c |   94 ++++++++++++++++++++++----------
 fs/nfs/objlayout/objlayout.c |  124 +++++++++++-------------------------------
 fs/nfs/objlayout/objlayout.h |   36 ++++++-------
 3 files changed, 112 insertions(+), 142 deletions(-)

commit 1f1fe6e7fee0ee5e6ffa9807a0be763f4b6b01d8
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun Oct 2 17:23:29 2011 +0200

    pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of read/write_pagelist
    
    objlayout driver was always returning PNFS_ATTEMPTED from it's
    read/write_pagelist operations. Even on error. Fix that.
    
    Start by establishing an error return API from io-engine, by
    not returning ssize_t (length-or-error) but returning "int"
    0=OK, 0>Error. And clean up all return types in io-engine.
    
    Then if io-engine returned error return PNFS_NOT_ATTEMPTED
    to generic layer. (With a dprint)
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objio_osd.c |   32 ++++++++++++++++----------------
 fs/nfs/objlayout/objlayout.c |   36 +++++++++++++++++++-----------------
 fs/nfs/objlayout/objlayout.h |    4 ++--
 3 files changed, 37 insertions(+), 35 deletions(-)

commit 64a6725b53fad1f199e9cafa5634573b392e9b01
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Sun Oct 2 16:06:09 2011 +0200

    pnfs-obj: Remove redundant EOF from objlayout_io_state
    
    The EOF calculation was done on .read_pagelist(), cached
    in objlayout_io_state->eof, and set in objlayout_read_done()
    into nfs_read_data->res.eof.
    
    So set it directly into nfs_read_data->res.eof and avoid
    the extra member.
    
    This is a slight behaviour change because before eof was
    *not* set on an error update at objlayout_read_done(). But
    is that a problem? Is Generic layer so sensitive that it
    will miss the error IO if eof was set? From my testing
    I did not see such a problem.
    
    Benny please review.
    
    Which brings me to a more abstract problem. Why does the
    LAYOUT driver needs to do this eof calculation? .i.e we
    are inspecting generic i_size_read() and if spanned by
    offset + count which is received from generic layer we set
    eof. It looks like all this can/should be done in generic
    layer and not at LD. Where does NFS and files-LD do it?
    It looks like it can be promoted.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

 fs/nfs/objlayout/objlayout.c |   16 +++++++---------
 fs/nfs/objlayout/objlayout.h |    1 -
 2 files changed, 7 insertions(+), 10 deletions(-)

Thanks very much
Boaz
