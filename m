Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:9006 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063AbcD0Pgj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:36:39 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 0/9] NFSV4.1,2 session trunking
Date: Wed, 27 Apr 2016 11:36:01 -0400
Message-ID: <1461771370-16375-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RFC patchset. 

Please review the code.

Main question: Do we want to use multiple hostnames on the mount command to
   communicate the NFSv4.1 session trunking addresses, or only use (yet
   to be coded) fs_locations_info?

This patch set uses multiple hostnames on the mount commnad and so requires
nfs-utils changes to mount.nfs from the Version 3 "Add multihostname support
for NFSv4.1,2" nfs-utils patchset.

Notes:

I did not call EXCHANGE_ID on the mulihostnames in the state
manager, as they are synchronous RPC calls that occur directly after
the nfs_client->cl_rpcclient has been established.  I can change this
if needed.

I do not have code to call BIND_CONN_TO_SESSION if sp4_how is not SP4_NONE.

I added a "multiaddr=" option to the mtab for each multiaddr successfully
added to the xprt_switch.

If we want to keep the multiple hostnames on the mount command method of
expressing NFSv4.1 session trunking addresses, we should fix this:
- v3 mounts with multiple hostnames succeeds but adds an mtab dev entry that
omits the ":/<exported dir> and so prints a warning at umount.

Please review. I will start the fs_locations_info method of expressing the
session trunking addresses.

Thanks

--> Andy


  NFS parse multiple hostnames
  NFS default callback ops
  NFS refactor nfs4_match_clientids
  NFS refactor nfs4_check_serverowner_major_id
  NFS detect session trunking
  NFS refactor _nfs4_proc_exchange_id for session trunking
  SUNRPC add flag to rpc_task_release_client
  NFS test and add multi-addrs for session trunking
  NFS add multiaddr to nfs_show_nfsv4_options

 fs/nfs/internal.h           |  19 ++++++
 fs/nfs/nfs4_fs.h            |   9 +++
 fs/nfs/nfs4client.c         | 141 ++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4proc.c           |  79 +++++++++++++++++++++----
 fs/nfs/super.c              |  64 ++++++++++++++++++++
 include/linux/sunrpc/clnt.h |   2 +-
 net/sunrpc/clnt.c           |   6 +-
 net/sunrpc/sched.c          |   2 +-
 net/sunrpc/xprtmultipath.c  |   4 ++
 9 files changed, 300 insertions(+), 26 deletions(-)

-- 
1.8.3.1

