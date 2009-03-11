From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/9] NFS client Bugfixes against kernel 2.6.29-rc7
Date: Wed, 11 Mar 2009 14:25:25 -0400
Message-ID: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755150AbZCKS3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:50 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIThEu008166
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:29:48 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series fixes a number of issues and regressions with the 
NFS client in kernel 2.6.29-rc7.

Cheers
  Trond

---

Chuck Lever (2):
      NLM: Fix GRANT callback address comparison when IPv6 is enabled
      NLM: Shrink the IPv4-only version of nlm_cmp_addr()

Ian Dall (1):
      Bug 11061, NFS mounts dropped

Suresh Jayaraman (1):
      NFS: Handle -ESTALE error in access()

Trond Myklebust (5):
      SUNRPC: xprt_connect() don't abort the task if the transport isn't bound
      SUNRPC: Fix an Oops due to socket not set up yet...
      NFSv3: Fix posix ACL code
      NFS: Fix misparsing of nfsv4 fs_locations attribute (take 2)
      SUNRPC: Tighten up the task locking rules in __rpc_execute()


 fs/lockd/clntlock.c         |   51 ++++++++++++++++++++++++++++++++++-
 fs/nfs/client.c             |   63 ++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/dir.c                |    8 +++++
 fs/nfs/nfs3acl.c            |   27 ++++++++++++++----
 fs/nfs/nfs3xdr.c            |   34 +++++++++--------------
 fs/nfs/nfs4namespace.c      |   15 +++++-----
 include/linux/lockd/lockd.h |    8 +++++
 include/linux/nfs_xdr.h     |    2 +
 include/linux/nfsacl.h      |    3 ++
 net/sunrpc/sched.c          |   33 ++++++++++++++---------
 net/sunrpc/xprt.c           |    2 +
 net/sunrpc/xprtsock.c       |   23 ++++++++++++----
 12 files changed, 213 insertions(+), 56 deletions(-)

-- 
Signature
