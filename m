Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab1LTGQA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Dec 2011 01:16:00 -0500
Message-ID: <1324361759.2694.14.camel@lade.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Tue, 20 Dec 2011 07:15:59 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/file.c      |    2 +-
 fs/nfs/nfs4proc.c  |   24 ++++++++++++++++--------
 fs/nfs/nfs4state.c |   33 +++++++++++++++++++++------------
 net/sunrpc/sched.c |   30 +++++++++++++++++++++++-------
 net/sunrpc/xprt.c  |   10 ++++------
 5 files changed, 65 insertions(+), 34 deletions(-)

commit 6c52961743f38747401b47127b82159ab6d8a7a4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 15 18:38:10 2011 -0500

    NFS: Fix a regression in nfs_file_llseek()
    
    After commit 06222e491e663dac939f04b125c9dc52126a75c4 (fs: handle
    SEEK_HOLE/SEEK_DATA properly in all fs's that define their own llseek)
    the behaviour of llseek() was changed so that it always revalidates
    the file size. The bug appears to be due to a logic error in the
    afore-mentioned commit, which always evaluates to 'true'.
    
    Reported-by: Roel Kluin <roel.kluin@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org [>=3.1]

commit 652f89f64fabcdae9143ee2b4253cfa838fb0279
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 9 19:05:58 2011 -0500

    NFSv4: Do not accept delegated opens when a delegation recall is in effect
    
    ...and report the servers that try to return a delegation when the client
    is using the CLAIM_DELEG_CUR open mode. That behaviour is explicitly
    forbidden in RFC3530.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b44b40e04a758e2242ff4a3f7c15982801ec8bc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 9 16:31:52 2011 -0500

    NFSv4: Ensure correct locking when accessing the 'lock_states' list
    
    There are currently 2 places in the state recovery code, where we do not
    take sufficient precautions before accessing the state->lock_states. In
    both cases, we should be holding the state->state_lock.
    
    Reported-by: Pascal Bouchareine <pascal@gandi.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 111d489f0fb431f4ae85d96851fbf8d3248c09d8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 1 16:37:42 2011 -0500

    NFSv4.1: Ensure that we handle _all_ SEQUENCE status bits.
    
    Currently, the code assumes that the SEQUENCE status bits are mutually
    exclusive. They are not...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org [>= 2.6.34]

commit 4f38e4aadcca319650c0de31edf7193d7c384de2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 1 16:31:34 2011 -0500

    NFSv4: Don't error if we handled it in nfs4_recovery_handle_error
    
    If we handled an error condition, then nfs4_recovery_handle_error should
    return '0' so that the state recovery thread can continue.
    Also ensure that nfs4_check_lease() continues to abort if we haven't got
    any credentials by having it return ENOKEY (which is not handled).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c25573b5134294c0be82bfaecc6d08136835b271
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 1 14:16:17 2011 -0500

    SUNRPC: Ensure we always bump the backlog queue in xprt_free_slot
    
    Whenever we free a slot, we know that the resulting xprt->num_reqs will
    be less than xprt->max_reqs, so we know that we can release at least one
    backlogged rpc_task.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org [>=3.1]

commit 7fdcf13b292e8b2e38e42de24be2503e37b2cf97
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 1 14:00:15 2011 -0500

    SUNRPC: Fix the execution time statistics in the face of RPC restarts
    
    If the rpc_task gets restarted, then we want to ensure that we don't
    double-count the execution time statistics, timeout data, etc.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

