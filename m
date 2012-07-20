Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:41135 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab2GTOH7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2012 10:07:59 -0400
Message-ID: <50096498.4080200@panasas.com>
Date: Fri, 20 Jul 2012 17:00:56 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Stable Tree <stable@kernel.org>
Subject: [GIT PULL] Important ORE and pnfs-objects Fixes for 3.5-rc8
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus

The following changes since Linux 3.5-rc5 [6887a413]

are available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus

for you to fetch changes up to c999ff68029ebd0f56ccae75444f640f6d5a27d2:

  pnfs-obj: Fix __r4w_get_page when offset is beyond i_size (2012-07-20 11:50:31 +0300)

These are catastrophic fixes to the pnfs objects-layout that were just discovered.
They are also destined for @stable.

I have found these and worked on them at around RC1 time but unfortunately went
to the hospital for kidney stones and had a very slow recovery. I refrained from
sending them as is, before proper testing, and surly I have found a bug just
yesterday.

So now they are all well tested, and have my sign-off. Other then fixing the
problem at hand, and assuming there are no bugs at the new code, there is
low risk to any surrounding code. And in anyway they affect only these paths
that are now broken. That is RAID5 in pnfs objects-layout code. It does also
affect exofs (which was not broken) but I have tested exofs and it is lower
priority then objects-layout because no one is using exofs, but objects-layout
has lots of users.

So please consider applying even though it is so late in the game. Do to
my personal special circumstances.

Thanks very much in advance
Boaz

----------------------------------------------------------------
Boaz Harrosh (5):
      ore: Fix NFS crash by supporting any unaligned RAID IO
      ore: Remove support of partial IO request (NFS crash)
      ore: Unlock r4w pages in exact reverse order of locking
      pnfs-obj: don't leak objio_state if ore_write/read fails
      pnfs-obj: Fix __r4w_get_page when offset is beyond i_size

 fs/exofs/ore.c               |  8 +-------
 fs/exofs/ore_raid.c          | 91 ++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------------------
 fs/nfs/objlayout/objio_osd.c | 25 ++++++++++++++++++++-----
 3 files changed, 69 insertions(+), 55 deletions(-)
----------------------------------------------------------------
Here is the git log:

commit 9ff19309a9623f2963ac5a136782ea4d8b5d67fb
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jun 8 01:19:07 2012 +0300

    ore: Fix NFS crash by supporting any unaligned RAID IO
    
    In RAID_5/6 We used to not permit an IO that it's end
    byte is not stripe_size aligned and spans more than one stripe.
    .i.e the caller must check if after submission the actual
    transferred bytes is shorter, and would need to resubmit
    a new IO with the remainder.
    
    Exofs supports this, and NFS was supposed to support this
    as well with it's short write mechanism. But late testing has
    exposed a CRASH when this is used with none-RPC layout-drivers.
    
    The change at NFS is deep and risky, in it's place the fix
    at ORE to lift the limitation is actually clean and simple.
    So here it is below.
    
    The principal here is that in the case of unaligned IO on
    both ends, beginning and end, we will send two read requests
    one like old code, before the calculation of the first stripe,
    and also a new site, before the calculation of the last stripe.
    If any "boundary" is aligned or the complete IO is within a single
    stripe. we do a single read like before.
    
    The code is clean and simple by splitting the old _read_4_write
    into 3 even parts:
    1._read_4_write_first_stripe
    2. _read_4_write_last_stripe
    3. _read_4_write_execute
    
    And calling 1+3 at the same place as before. 2+3 before last
    stripe, and in the case of all in a single stripe then 1+2+3
    is preformed additively.
    
    Why did I not think of it before. Well I had a strike of
    genius because I have stared at this code for 2 years, and did
    not find this simple solution, til today. Not that I did not try.
    
    This solution is much better for NFS than the previous supposedly
    solution because the short write was dealt  with out-of-band after
    IO_done, which would cause for a seeky IO pattern where as in here
    we execute in order. At both solutions we do 2 separate reads, only
    here we do it within a single IO request. (And actually combine two
    writes into a single submission)
    
    NFS/exofs code need not change since the ORE API communicates the new
    shorter length on return, what will happen is that this case would not
    occur anymore.
    
    hurray!!
    
    [Stable this is an NFS bug since 3.2 Kernel should apply cleanly]
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

commit 62b62ad873f2accad9222a4d7ffbe1e93f6714c1
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jun 8 04:30:40 2012 +0300

    ore: Remove support of partial IO request (NFS crash)
    
    Do to OOM situations the ore might fail to allocate all resources
    needed for IO of the full request. If some progress was possible
    it would proceed with a partial/short request, for the sake of
    forward progress.
    
    Since this crashes NFS-core and exofs is just fine without it just
    remove this contraption, and fail.
    
    TODO:
    	Support real forward progress with some reserved allocations
    	of resources, such as mem pools and/or bio_sets
    
    [Bug since 3.2 Kernel]
    CC: Stable Tree <stable@kernel.org>
    CC: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

commit 537632e0a54a5355cdd0330911d18c3b773f9cf7
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Wed Jul 11 15:27:13 2012 +0300

    ore: Unlock r4w pages in exact reverse order of locking
    
    The read-4-write pages are locked in address ascending order.
    But where unlocked in a way easiest for coding. Fix that,
    locks should be released in opposite order of locking, .i.e
    descending address order.
    
    I have not hit this dead-lock. It was found by inspecting the
    dbug print-outs. I suspect there is an higher lock at caller that
    protects us, but fix it regardless.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

commit 9909d45a8557455ca5f8ee7af0f253debc851f1a
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jun 8 05:29:40 2012 +0300

    pnfs-obj: don't leak objio_state if ore_write/read fails
    
    [Bug since 3.2 Kernel]
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

commit c999ff68029ebd0f56ccae75444f640f6d5a27d2
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jun 8 02:02:30 2012 +0300

    pnfs-obj: Fix __r4w_get_page when offset is beyond i_size
    
    It is very common for the end of the file to be unaligned on
    stripe size. But since we know it's beyond file's end then
    the XOR should be preformed with all zeros.
    
    Old code used to just read zeros out of the OSD devices, which is a great
    waist. But what scares me more about this situation is that, we now have
    pages attached to the file's mapping that are beyond i_size. I don't
    like the kind of bugs this calls for.
    
    Fix both birds, by returning a global zero_page, if offset is beyond
    i_size.
    
    TODO:
    	Change the API to ->__r4w_get_page() so a NULL can be
    	returned without being considered as error, since XOR API
    	treats NULL entries as zero_pages.
    
    [Bug since 3.2. Should apply the same way to all Kernels since]
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
