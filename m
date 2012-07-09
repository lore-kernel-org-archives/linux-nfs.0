Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47984 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab2GIPnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 11:43:42 -0400
Received: by gglu4 with SMTP id u4so10194450ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2012 08:43:42 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/14] Candidates for 3.6
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Jul 2012 11:43:38 -0400
Message-ID: <20120709153355.1604.14102.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Here are the TEST_STATEID clean-ups and patches to implement UCS.
These have been unit tested, but I'm sure I haven't tried every use
case.  I'd like you to consider these for 3.6.

There is one last bug to fix: rpcauth_create() returns -EEXIST when
replacing an RPC client's rpc_auth, if both the existing and new
rpc_auth are RPC_AUTH_GSS.  I'm actively working that now, and should
post a solution for review this week or next.

The final patch in this series is a hack, posted for discussion.

---

Chuck Lever (14):
      NFS: Slow down state manager after an unhandled error
      NFS: Clean up debugging messages in fs/nfs/client.c
      NFS: Add nfs4_unique_id boot parameter
      NFS: Discover NFSv4 server trunking when mounting
      NFS: Use the same nfs_client_id4 for every server
      NFS: Introduce "migration" mount option
      SUNRPC: Add rpcauth_list_flavors()
      NFS: Clean up nfs4_proc_setclientid() and friends
      NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
      NFS: nfs_getaclargs.acl_len is a size_t
      NFS: Refactor nfs41_check_expired_stateid()
      NFS: State reclaim clears OPEN and LOCK state
      NFS: Properly sort TEST_STATEID results
      NFS: Clean up TEST_STATEID and FREE_STATEID proc error reporting


 Documentation/filesystems/nfs/nfs.txt |   44 +++++
 Documentation/kernel-parameters.txt   |    5 +
 fs/nfs/client.c                       |  282 +++++++++++++++++++++++++++++++
 fs/nfs/idmap.c                        |    6 +
 fs/nfs/internal.h                     |    6 +
 fs/nfs/nfs4_fs.h                      |    8 +
 fs/nfs/nfs4proc.c                     |  296 +++++++++++++++++++++++++--------
 fs/nfs/nfs4state.c                    |  198 +++++++++++++++++++++-
 fs/nfs/super.c                        |   20 ++
 include/linux/nfs_fs_sb.h             |    5 -
 include/linux/sunrpc/auth.h           |    2 
 include/linux/sunrpc/gss_api.h        |    3 
 net/sunrpc/auth.c                     |   54 ++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 
 net/sunrpc/auth_gss/gss_mech_switch.c |   18 ++
 15 files changed, 852 insertions(+), 96 deletions(-)

-- 
Chuck Lever
