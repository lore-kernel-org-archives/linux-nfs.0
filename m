Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f181.google.com ([209.85.213.181]:34772 "EHLO
	mail-ye0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968137Ab3HIQrq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:47:46 -0400
Received: by mail-ye0-f181.google.com with SMTP id q2so1314395yen.12
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:47:45 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id b50sm20693156yhl.1.2013.08.09.09.47.42
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:47:43 -0700 (PDT)
Subject: [PATCH v2 00/33] Proposed migration patches for 3.12
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:47:40 -0400
Message-ID: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series implements NFSv4 migration.  I hope to get this
series merged into 3.12.  See also this topic branch:

 http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;\
		h=refs/heads/for-3.12


- Changes since v1 -

 o  Rebased on 3.11-rc4
 o  Review comments addressed
 o  Tighter integration with struct nfs4_slot_table
 o  Graceful failure when migration does not succeed
 o  Temporary kernel config option to disable NFSv4.1 migration


- Patch roadmap -

After a dprintk clean-up patch, patches "NFS: Rename
nfs41_call_sync_data as a common data structure" through "NFS:
Update session draining barriers for NFSv4.0 transport blocking"
implement a transport blocking scheme for NFSv4.0 based on
struct nfs4_slot_table.

Patches "SUNRPC: Modify synopsis of rpc_client_register()" through
"NFS: Add functions to swap transports during migration recovery"
provide a method of swapping an rpc_clnt's rpc_xprt by choosing
a location in an array.

Patches "NFS: Introduce a vector of migration recovery ops" through
"NFS: Add migration recovery callouts in nfs4proc.c" implement
support for recovering from NFS4ERR_MOVED.

Patches "NFS: Add method to detect whether an FSID is still on the
server" through "NFS: Implement NFSv4.1 support for
NFS4ERR_LEASE_MOVED" implement support for recovering from
NFS4ERR_LEASE_MOVED.

The final patch "NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR" adds a
provisional advertisement to NFSv4.1 servers that our client now
supports migration.


- Merge criteria -

I have three criteria for determining whether I believe this work is
ready to merge:

 1.  The series doesn't regress any non-migration related
     functionality

 2.  Everyone is happy with the architecture and APIs, such that
     subsequent patches will amount to bug fixes and enhancements
     rather than reworking anything

 3.  The series is ported to the tip of Linus' master (3.11-rc4
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

 Finish support for non-TSM migration

NFSv4.1 migration is almost sure not to work yet, so I've left the
default setting for the EXCHANGE_ID flags as "don't advertise".  We
may have a prototype server to test with soon.  I expect there are
some protocol issues to work out as well.  Once NFSv4.1 migration
is working, the new CONFIG option will be removed.

Migration without TSM showed our prototype server is not behaving
optimally.  However, the Linux client was able to recover open and
lock state successfully.  More testing is needed.


- Test plan -

This implementation still needs a lot of testing.  I've done some of
this list, plan to do more.

  x Builds and runs non-migration workload with CONFIG_NFS_V4_1
    disabled
  x Builds and runs non-migration workload with CONFIG_NFS_V4_1
    enabled
  x Single filesystem migration under load with TSM
  x Single filesystem migration under load without TSM
  x Single filesystem under load migrated twice
  * Active filesystem A while B is migrated (lease-moved recovery)
  * Active filesystem A while active filesystem B is migrated
  * Migrate filesystem A, reboot destination server, migrate B
  * Migration during lock-intensive workload
  x What happens when migration recovery fails?
  * How about migration with a Kerberos 5 mount?

---

Chuck Lever (32):
      NFS: When displaying session slot numbers, use "%u" consistently
      NFS: Rename nfs41_call_sync_data as a common data structure
      NFS: Clean up nfs4_setup_sequence()
      NFS: Common versions of sequence helper functions
      NFS: Add RPC callouts to start NFSv4.0 synchronous requests
      NFS: Remove unused call_sync minor version op
      NFS: Enable slot table helpers for NFSv4.0
      NFS: Add global helper to set up a stand-along nfs4_slot_table
      NFS: Add global helper for releasing slot table resources
      NFS: Add a slot table to struct nfs_client for NFSv4.0 transport blocking
      NFS: NFSv4.0 transport blocking
      NFS: Enable nfs4_setup_sequence() for DELEGRETURN
      NFS: Add nfs4_sequence calls for RELEASE_LOCKOWNER
      NFS: Add nfs4_sequence calls for OPEN_CONFIRM
      NFS: Update session draining barriers for NFSv4.0 transport blocking
      SUNRPC: Modify synopsis of rpc_client_register()
      NFS: Add nfs4_update_server
      NFS: Add functions to swap transports during migration recovery
      NFS: Introduce a vector of migration recovery ops
      NFS: Export _nfs_display_fhandle()
      NFS: Add method to retrieve fs_locations during migration recovery
      NFS: Add a super_block backpointer to the nfs_server struct
      NFS: Add basic migration support to state manager thread
      NFS: Re-use exit code in nfs4_async_handle_error()
      NFS: Rename "stateid_invalid" label
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Add method to detect whether an FSID is still on the server
      NFS: Implement support for NFS4ERR_LEASE_MOVED in state manager
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Implement NFSv4.1 support for NFS4ERR_LEASE_MOVED
      NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR

Trond Myklebust (1):
      SUNRPC: Add a helper to switch the transport of an rpc_clnt


 fs/nfs/Kconfig              |   11 +
 fs/nfs/Makefile             |    4 
 fs/nfs/callback_proc.c      |    8 -
 fs/nfs/client.c             |    3 
 fs/nfs/inode.c              |    2 
 fs/nfs/internal.h           |    3 
 fs/nfs/nfs4_fs.h            |   39 ++-
 fs/nfs/nfs4client.c         |  191 +++++++++++--
 fs/nfs/nfs4namespace.c      |  101 +++++++
 fs/nfs/nfs4proc.c           |  641 ++++++++++++++++++++++++++++++++++++-------
 fs/nfs/nfs4session.c        |   84 ++++--
 fs/nfs/nfs4session.h        |   31 +-
 fs/nfs/nfs4state.c          |  289 +++++++++++++++++--
 fs/nfs/nfs4xdr.c            |  126 +++++++-
 fs/nfs/super.c              |    1 
 include/linux/nfs4.h        |    1 
 include/linux/nfs_fs_sb.h   |   11 +
 include/linux/nfs_xdr.h     |   17 +
 include/linux/sunrpc/clnt.h |    4 
 net/sunrpc/clnt.c           |  102 ++++++-
 20 files changed, 1399 insertions(+), 270 deletions(-)

-- 
Chuck Lever
