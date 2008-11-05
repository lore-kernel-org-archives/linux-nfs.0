From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/13] kernel server-side IPv6 support
Date: Wed, 05 Nov 2008 12:28:21 -0500
Message-ID: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41575 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbYKER2j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:28:39 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here's the set of patches I've collected so far to enable IPv6 support
in the kernel's lockd and NFSD implementation.  These require the NSM
patches I just sent.

Please review and test that IPv4 has not been perturbed.  I've done
some testing for lockd already.  And, please consider these for 2.6.29.

I will also push the full set up to git.linux-nfs.org later today.

---

Aime Le Rouzic (1):
      NFSD: Support AF_INET6 in svc_addsock() function

Chuck Lever (12):
      NFSD: Enable NFS server use of AF_INET6
      NFSD: Support IPv6 addresses in write_failover_ip()
      NFS: Move NFS client's IP address parser to nfs_common/
      SUNRPC: Clean up one_sock_name()
      SUNRPC: Support AF_INET6 in one_sock_name()
      SUNRPC: Switch one_sock_name() to use snprintf()
      SUNRPC: pass buffer size to svc_addsock() and svc_sock_names()
      NFSD: Prevent a buffer overflow in svc_xprt_names()
      NFSD: Refactor __write_ports()
      NFSD: Add helper functions for __write_ports()
      NFSD: Add documenting comments for nfsctl interface
      lockd: Enable NLM use of AF_INET6


 fs/lockd/svc.c                 |   13 +
 fs/nfs/internal.h              |    3 
 fs/nfs/nfs4namespace.c         |    2 
 fs/nfs/super.c                 |  121 -------
 fs/nfs_common/Makefile         |    1 
 fs/nfs_common/nfs_addr_parse.c |  155 +++++++++
 fs/nfsd/nfsctl.c               |  723 +++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfssvc.c               |   13 +
 include/linux/nfs_addr_parse.h |   32 ++
 include/linux/sunrpc/svcsock.h |    6 
 net/sunrpc/svc_xprt.c          |   53 ++-
 net/sunrpc/svcsock.c           |   82 ++++-
 12 files changed, 911 insertions(+), 293 deletions(-)
 create mode 100644 fs/nfs_common/nfs_addr_parse.c
 create mode 100644 include/linux/nfs_addr_parse.h

-- 
Chuck Lever
