Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:44837 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992Ab3GLQb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:31:29 -0400
Received: by mail-yh0-f52.google.com with SMTP id f10so3699618yha.25
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:31:28 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id v32sm69001436yhc.12.2013.07.12.09.31.27
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:31:28 -0700 (PDT)
Subject: [PATCH v1 00/19] NFSv4 migration
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:31:26 -0400
Message-ID: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I hope to get basic NFSv4 migration support into 3.12.  This is the
patch series, still based on 3.10, posted here for review.  See also

  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=commit;
	h=8aa9aa847fdd073abe24789c5acb28b853755616


- Patch roadmap -

The first two patches are bug fixes.

Patches "NFS: Refactor nfs4_call_data_sequence()" through "NFS:
Implement a transport blocking scheme for migration" introduce a
mechanism that can plug and uncork an NFS transport.  NFSv4.0
migration uses this mechanism to block forward NFS operations while
migration recovery is occurring.  NFSv4.1 and following will use
session draining to accomplish the same.

Patch "NFS: Add functions to swap transports during migration
recovery" moves an nfs_server from one nfs_client to another, and
swaps out the nfs_server's RPC transport at the same time.  This
mechanism probably still needs some work.

Patches "NFS: Add method to retrieve fs_locations during migration
recovery" through "NFS: Add migration recovery callouts in
nfs4proc.c" add the bulk of support for recovering from NFS4ERR_MOVED.

Patches "NFS: Add method to detect whether an FSID is still on the
server" through "NFS: Implement support for NFS4ERR_LEASE_MOVED" add
support for recovering from NFS4ERR_LEASE_MOVED.

Patch "NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR" advertises migration
support for NFSv4.1.


- Merge criteria -

I have three criteria for determining whether I believe this work is
ready to merge:

  1.  The series doesn't regress any non-migration related
      functionality

  2.  Everyone is happy with the architecture and APIs, such that
      subsequent patches will amount to bug fixes and enhancements
      rather than reworking anything

  3.  The series is ported to the tip of Linus' master (3.11-rc1
      as of this writing)

I'd like to merge sooner rather than later so others can start to
build on this functionality, and so I don't have to keep forward
porting for another two years.

In addition, this is something that distributions want yesterday.
Including it now and then fixing it makes it easier for them to
include it in their kernels.

I expect bug fixes and enhancements after merge.  Enhancements might
include:

  Optimize LEASE_MOVED recovery by performing the fsid_present
  checks asynchronously

  Introduce support for fs_locations_info

  Finish NFSv4.1 migration support

One thing that hasn't been tested yet is NFSv4.1 migration.  There
are no server implementations yet, and we believe there may be some
(IETF) protocol work to do to get NFSv4.1 migration working
reliably.

We could drop that patch, or we could change it to add a CONFIG
option, default N, marked EXPERIMENTAL so that the flag can be
enabled conveniently for testing.


- Test plan -

This implementation still needs a lot of testing.  I've done some of
this list, plan to do more.

   * Single filesystem migration with TSM
   * Single filesystem migration without TSM
   * Active filesystem A while B is migrated (lease-moved recovery)
   * Active filesystem A while active filesystem B is migrated
   * Migrate filesystem A, reboot destination server, migrate B
   * Migration during lock-intensive workload
   * What happens when migration recovery fails?
   * How about migration with a Kerberos 5 mount?


---

Chuck Lever (18):
      NFS: Never use user credentials for lease renewal
      NFS: Fix return type of nfs4_end_drain_session() stub
      NFS: Introduce a vector of migration recovery ops
      NFS: Refactor nfs4_call_data_sequence()
      NFS: Rename nfs41_call_sync_data as a common data structure
      NFS: Clean up nfs4_setup_sequence()
      NFS: Fix compiler warning in nfs_setup_sequence()
      NFS: Use RPC callouts to start NFSv4.0 synchronous requests
      NFS: Add a "struct nfs_server *" argument to nfs4_sequence_done()
      NFS: Implement a transport blocking scheme for migration
      NFS: Add a super_block backpointer to the nfs_server struct
      NFS: Add functions to swap transports during migration recovery
      NFS: Add method to retrieve fs_locations during migration recovery
      NFS: Add basic migration support to state manager thread
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Add method to detect whether an FSID is still on the server
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR

Trond Myklebust (1):
      SUNRPC: Add a helper to switch the transport of an rpc_clnt


 fs/nfs/client.c             |    3 
 fs/nfs/internal.h           |    3 
 fs/nfs/nfs4_fs.h            |   36 +--
 fs/nfs/nfs4client.c         |   83 ++++++
 fs/nfs/nfs4namespace.c      |  114 +++++++++
 fs/nfs/nfs4proc.c           |  554 +++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfs4session.c        |    2 
 fs/nfs/nfs4state.c          |  318 +++++++++++++++++++++----
 fs/nfs/nfs4xdr.c            |  115 ++++++++-
 fs/nfs/super.c              |    1 
 include/linux/nfs4.h        |    1 
 include/linux/nfs_fs_sb.h   |   11 +
 include/linux/nfs_xdr.h     |   17 +
 include/linux/sunrpc/clnt.h |    4 
 net/sunrpc/clnt.c           |   83 ++++++
 15 files changed, 1183 insertions(+), 162 deletions(-)

-- 
Chuck Lever
