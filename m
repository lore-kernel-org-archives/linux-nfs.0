Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:42030 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab2GKU3j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:29:39 -0400
Received: by ghrr11 with SMTP id r11so1691041ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:29:38 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/15] Candidates for 3.6 [v2]
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:29:36 -0400
Message-ID: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Here is a second crack at the TEST_STATEID fixes and patches to
implement UCS.  I've attempted to address the following review
comments:

  o  The changes have been reorganized to allow the meaty parts of
     the TEST_STATEID fixes to be applied to -stable.

  o  Additional in-code comments have been introduced.

  o  FREE_STATEID is now performed in all cases after TEST_STATEID
     except when the TEST_STATEID operation result is
     NFS4ERR_BAD_STATEID.

  o  The change to check clp->cl_cons_state in
     nfs4_wait_clnt_recover() is now a separate patch with its own
     justification.

As before, there is one last bug to fix: rpcauth_create() returns
-EEXIST when replacing an RPC client's rpc_auth, if both the
existing and new rpc_auth are RPC_AUTH_GSS.  I should be able to
post a solution for review next week.

The final patch in this series is a hack, posted for discussion.

---

Chuck Lever (15):
      NFS: Slow down state manager after an unhandled error
      NFS: Add nfs4_unique_id boot parameter
      NFS: Discover NFSv4 server trunking when mounting
      NFS: Use the same nfs_client_id4 for every server
      NFS: Introduce "migration" mount option
      SUNRPC: Add rpcauth_list_flavors()
      NFS: Clean up nfs4_proc_setclientid() and friends
      NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
      NFS: When state recovery fails, waiting tasks should exit
      NFS: nfs_getaclargs.acl_len is a size_t
      NFS: Clean up TEST_STATEID and FREE_STATEID error reporting
      NFS: Clean up nfs41_check_expired_stateid()
      NFS: State reclaim clears OPEN and LOCK state
      NFS: Don't free a state ID the server does not recognize
      NFS: Fix up TEST_STATEID and FREE_STATEID return code handling


 Documentation/filesystems/nfs/nfs.txt |   44 +++++
 Documentation/kernel-parameters.txt   |    5 +
 fs/nfs/client.c                       |  239 +++++++++++++++++++++++++++
 fs/nfs/internal.h                     |    6 +
 fs/nfs/nfs4_fs.h                      |    8 +
 fs/nfs/nfs4proc.c                     |  293 ++++++++++++++++++++++++---------
 fs/nfs/nfs4state.c                    |  198 ++++++++++++++++++++++
 fs/nfs/super.c                        |   20 ++
 include/linux/nfs_fs_sb.h             |    5 -
 include/linux/sunrpc/auth.h           |    2 
 include/linux/sunrpc/gss_api.h        |    3 
 net/sunrpc/auth.c                     |   54 ++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 
 net/sunrpc/auth_gss/gss_mech_switch.c |   18 ++
 14 files changed, 803 insertions(+), 93 deletions(-)

-- 
Chuck Lever
