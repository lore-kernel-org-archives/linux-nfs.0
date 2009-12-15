From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull a couple of extra bugfixes for the NFSv4.1
 client
Date: Tue, 15 Dec 2009 15:10:02 -0500
Message-ID: <1260907802.2883.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933206AbZLOUKe@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

These patches mainly fix issues with the NFSv4.1 session and state recovery code.

  Cheers,
    Trond

----
 fs/nfs/nfs4_fs.h             |    5 +
 fs/nfs/nfs4proc.c            |  203 ++++++++++++++++++++++++++++++++----------
 fs/nfs/nfs4state.c           |   61 ++++++++-----
 include/linux/sunrpc/sched.h |   14 +++-
 net/sunrpc/sched.c           |   15 +++
 5 files changed, 224 insertions(+), 74 deletions(-)

commit 72211dbe727f7c1451aa5adfcbd1197b090eb276
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 15 14:47:36 2009 -0500

    NFSv4: Release the sequence id before restarting a CLOSE rpc call
    
    If the CLOSE or OPEN_DOWNGRADE call triggers a state recovery, and has
    to be resent, then we must release the seqid. Otherwise the open
    recovery will wait for the close to finish, which causes a deadlock.
    
    This is mainly a NFSv4.1 problem, although it can theoretically happen
    with NFSv4.0 too, in a OPEN_DOWNGRADE situation.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 68bf05efb7facbcf4a7b8d6b48a0800a90895511
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Dec 15 12:55:02 2009 -0500

    nfs41: fix session fore channel negotiation
    
    If the rsize or wsize is not set on the mount command, negotiate the highest
    supported rsize and wsize in session creation.
    
    Fixes a bug where the client negotiated nfs41_maxwrite_overhead as
    ca_maxrequestsize and nfs41_maxread_overhead as ca_maxresponsesize resulting
    in NFS4ERR_REQ_TOO_BIG errors on writes.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a5523b84c40d34d2c30b45096fbb099b98e4b5a3
Author: Andy Adamson <andros@netapp.com>
Date:   Mon Dec 14 15:46:16 2009 -0500

    nfs41: do not zero seqid portion of stateid on close
    
    Remove code left over from a previous minorversion draft.
    which specified zeroing seqid portions of stateid's.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5601a00d671fe89f9b087513244abcd08ad67e7d
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Mon Dec 14 21:27:58 2009 -0800

    nfs: run state manager in privileged mode
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b257957e502a2c467c3c75005215a3f45ecb7f25
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Mon Dec 14 21:27:57 2009 -0800

    nfs: make recovery state manager operations privileged
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 689cf5c15baf603a8041565ff0bd0d65d1634fd7
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Mon Dec 14 21:27:56 2009 -0800

    nfs: enforce FIFO ordering of operations trying to acquire slot
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cf3b01b54880debb01ea7d471123da5887a7c2cb
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Mon Dec 14 21:27:55 2009 -0800

    rpc: add a new priority in RPC task
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 40ead580ae70bba1f66f426aeb938051e4e83900
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Mon Dec 14 21:27:54 2009 -0800

    nfs: remove rpc_task argument from nfs4_find_slot
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 48f186124220794fce85ed1439fc32f16f69d3e2
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Mon Dec 14 21:27:53 2009 -0800

    rpc: add rpc_queue_empty function
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit afe6c27ccb8cc31ce8ed0bd3589ce549f523c8e7
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Wed Dec 9 01:50:14 2009 -0800

    nfs: change nfs4_do_setlk params to identify recovery type
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f7e720694e88bacf808b525069fb72d1c237171
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Wed Dec 9 01:50:13 2009 -0800

    nfs: do not do a LOOKUP after open
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3bfb0fc59192f7fffae0a1caada8dc68af53997a
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Wed Dec 9 01:50:11 2009 -0800

    nfs: minor cleanup of session draining
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
