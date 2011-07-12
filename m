Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24247 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840Ab1GLXbI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jul 2011 19:31:08 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jul 2011 19:30:52 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310513452.20931.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

Kudos to Ben Greear for finding a 4 year old bug in the rpcbind client code!

  Cheers,
    Trond

----
 fs/nfs/nfs4filelayout.c |    1 -
 fs/nfs/nfs4xdr.c        |    2 +-
 fs/nfs/write.c          |    2 ++
 net/sunrpc/rpcb_clnt.c  |    2 +-
 net/sunrpc/sched.c      |   27 +++++++++++----------------
 5 files changed, 15 insertions(+), 19 deletions(-)

commit ec0dd267bf7d08cb30e321e45a75fd40edd7e528
Author: Ben Greear <greearb@candelatech.com>
Date:   Tue Jul 12 10:27:55 2011 -0700

    SUNRPC: Fix use of static variable in rpcb_getport_async
    
    Because struct rpcbind_args *map was declared static, if two
    threads entered this method at the same time, the values
    assigned to map could be sent two two differen tasks.
    This could cause all sorts of problems, include use-after-free
    and double-free of memory.
    
    Fix this by removing the static declaration so that the map
    pointer is on the stack.
    
    Signed-off-by: Ben Greear <greearb@candelatech.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e5012d1f3861d18c7f3814e757c1c3ab3741dbcd
Author: Andy Adamson <andros@netapp.com>
Date:   Mon Jul 11 17:17:42 2011 -0400

    NFSv4.1: update nfs4_fattr_bitmap_maxsz
    
    Attribute IDs assigned in RFC 5661 now require three bitmaps.
    Fixes hitting a BUG_ON in xdr_shrink_bufhead when getting ACLs.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Cc:stable@kernel.org [2.6.39]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b55c59892e1f3b6c7d4b9ccffb4263e1486fb990
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 6 19:58:23 2011 -0400

    SUNRPC: Fix a race between work-queue and rpc_killall_tasks
    
    Since rpc_killall_tasks may modify the rpc_task's tk_action field
    without any locking, we need to be careful when dereferencing it.
    
    Reported-by: Ben Greear <greearb@candelatech.com>
    Tested-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 2bea038c52e88badbbd5b420c1de918f7f2579e9
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Thu Jun 16 11:35:46 2011 -0400

    pnfs: write: Set mds_offset in the generic layer - it is needed by all LDs
    
    In current pnfs tree, all the layouts set mds_offset in their
    .write_pagelist member.
    mds_offset is only used by generic layer and should be handled by it.
    
    This patch is for upstream. It is needed in this -rc series to fix a
    bug in objects layout_commit.
    
    I'll send patches for objects and blocks to be
    squashed into current pnfs tree.
    
    TODO: It looks like the read path needs the same patch.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

