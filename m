Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42593 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704Ab2INVXH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:23:07 -0400
Received: by yhmm54 with SMTP id m54so1133722yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:23:06 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] 3.7 candidates
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:23:03 -0400
Message-ID: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Please consider these patches for 3.7.  This series adds support for
uniform client strings and server trunking detection, in addition to
addressing the "rpcauth_create() returns EEXIST" issue, as discussed.
While the UCS work has seen some light testing, more review is
welcome.

Instead of changing the documented name for the new
nfs.nfs4_unique_id module parameter as we discussed, I moved the
parameter to the super.c module with most of the other parameters,
so it's name remains without the nfs4. prefix.  I haven't had a
chance to test this final change.

---

Chuck Lever (10):
      NFS: Add nfs4_unique_id boot parameter
      NFS: Discover NFSv4 server trunking when mounting
      NFS: Use the same nfs_client_id4 for every server
      NFS: Introduce "migration" mount option
      SUNRPC: Introduce rpc_clone_client_set_auth()
      SUNRPC: Refactor rpc_clone_client()
      SUNRPC: Use __func__ in dprintk() in auth_gss.c
      SUNRPC: Clean up dprintk messages in rpc_pipe.c
      NFS: Slow down state manager after an unhandled error
      NFS: nfs_parsed_mount_options can use unsigned int


 Documentation/filesystems/nfs/nfs.txt |   44 +++++-
 Documentation/kernel-parameters.txt   |    5 +
 fs/nfs/client.c                       |   18 +-
 fs/nfs/internal.h                     |   14 +-
 fs/nfs/nfs4_fs.h                      |   11 +
 fs/nfs/nfs4client.c                   |  253 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs4namespace.c                |   14 --
 fs/nfs/nfs4proc.c                     |   59 ++++++--
 fs/nfs/nfs4state.c                    |  183 ++++++++++++++++++++++++
 fs/nfs/super.c                        |   25 +++
 include/linux/nfs_fs_sb.h             |    3 
 include/linux/sunrpc/clnt.h           |    2 
 net/sunrpc/auth_gss/auth_gss.c        |   58 ++++----
 net/sunrpc/clnt.c                     |  105 ++++++++------
 net/sunrpc/rpc_pipe.c                 |    8 +
 15 files changed, 684 insertions(+), 118 deletions(-)

-- 
Chuck Lever
