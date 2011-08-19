Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24708 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458Ab1HSBF7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2011 21:05:59 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Aug 2011 21:05:57 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1313715957.25064.1.camel@lade.trondhjem.org>
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
 fs/nfs/blocklayout/blocklayout.c    |    1 +
 fs/nfs/callback.h                   |    2 +-
 fs/nfs/callback_proc.c              |   25 +++++++++++++++++++------
 fs/nfs/callback_xdr.c               |   24 +++++++-----------------
 fs/nfs/objlayout/objio_osd.c        |   28 ++++++++++++----------------
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    3 +++
 6 files changed, 43 insertions(+), 40 deletions(-)

commit 910ac68a2b80c7de95bc8488734067b1bb15d583
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 2 14:46:52 2011 -0400

    NFSv4.1: Return NFS4ERR_BADSESSION to callbacks during session resets
    
    If the client is in the process of resetting the session when it receives
    a callback, then returning NFS4ERR_DELAY may cause a deadlock with the
    DESTROY_SESSION call.
    
    Basically, if the client returns NFS4ERR_DELAY in response to the
    CB_SEQUENCE call, then the server is entitled to believe that the
    client is busy because it is already processing that call. In that
    case, the server is perfectly entitled to respond with a
    NFS4ERR_BACK_CHAN_BUSY to any DESTROY_SESSION call.
    
    Fix this by having the client reply with a NFS4ERR_BADSESSION in
    response to the callback if it is resetting the session.
    
    Cc: stable@kernel.org [2.6.38+]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 55a673990ec04cf63005318bcf08c2b0046e5778
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 2 14:46:29 2011 -0400

    NFSv4.1: Fix the callback 'highest_used_slotid' behaviour
    
    Currently, there is no guarantee that we will call nfs4_cb_take_slot() even
    though nfs4_callback_compound() will consistently call
    nfs4_cb_free_slot() provided the cb_process_state has set the 'clp' field.
    The result is that we can trigger the BUG_ON() upon the next call to
    nfs4_cb_take_slot().
    
    This patch fixes the above problem by using the slot id that was taken in
    the CB_SEQUENCE operation as a flag for whether or not we need to call
    nfs4_cb_free_slot().
    It also fixes an atomicity problem: we need to set tbl->highest_used_slotid
    atomically with the check for NFS4_SESSION_DRAINING, otherwise we end up
    racing with the various tests in nfs4_begin_drain_session().
    
    Cc: stable@kernel.org [2.6.38+]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9af7db3228acc286c50e3a0f054ec982efdbc6c6
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Wed Aug 3 21:52:51 2011 -0700

    pnfs-obj: Fix the comp_index != 0 case
    
    There were bugs in the case of partial layout where olo_comp_index
    is not zero. This used to work and was tested but one of the later
    cleanup SQUASHMEs broke it and was not tested since.
    
    Also add a dprint that specify those received layout parameters.
    Everything else was already printed.
    
    [Needed in v3.0]
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 20618b21da0796115e81906d24ff1601552701b7
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Wed Aug 3 21:54:33 2011 -0700

    pnfs-obj: Bug when we are running out of bio
    
    When we have a situation that the number of pages we want
    to encode is bigger then the size of the bio. (Which can
    currently happen only when all IO is going to a single device
    .e.g group_width==1) then the IO is submitted short and we
    report back only the amount of bytes we actually wrote/read
    and all is fine. BUT ...
    
    There was a bug that the current length counter was advanced
    before the fail to add the extra page, and we come to a situation
    that the CDB length was one-page longer then the actual bio size,
    which is of course rejected by the osd-target.
    
    While here also fix the bio size calculation, in the case
    that we received more then one group of devices.
    
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 88c9e42196285a7c573e2abda11a4b5037c669bc
Author: Heiko Carstens <heiko.carstens@de.ibm.com>
Date:   Tue Aug 2 09:57:35 2011 +0200

    nfs: add missing prefetch.h include
    
    Fix this compile error on s390:
    
      CC [M]  fs/nfs/blocklayout/blocklayout.o
    fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_read':
    fs/nfs/blocklayout/blocklayout.c:201:4: error: implicit declaration of function 'prefetchw'
    
    Introduced with 9549ec01 "pnfsblock: bl_read_pagelist".
    
    Cc: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

