From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/22] IPv6 support NFSD
Date: Fri, 12 Dec 2008 16:57:02 -0500
Message-ID: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30731 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757617AbYLLV53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:57:29 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

These 22 patches enable support for IPv6 in the kernel's NFSD.  Please
consider them for 2.6.29.

Special thanks to Aime Le Rouzic and the Bull team for their prototype
and testing efforts.

---

Aime Le Rouzic (1):
      NFSD: Support AF_INET6 in svc_addsock() function

Chuck Lever (21):
      NLM: Clean up flow of control in make_socks() function
      NLM: Refactor make_socks() function
      NFSD: Prevent buffer overflow in write_recoverydir()
      NFSD: Prevent buffer overflow in write_leasetime()
      NFSD: Prevent buffer overflow in write_maxblksize()
      NFSD: Prevent buffer overflow in write_versions()
      NFSD: Prevent buffer overflow in write_threads()
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
      NFSD: Replace open-coded integer with macro
      NFSD: Fix a handful of coding style issues in write_filehandle()
      NFSD: clean up failover sysctl function naming


 fs/lockd/svc.c                 |   49 +--
 fs/nfs/internal.h              |    3 
 fs/nfs/nfs4namespace.c         |    2 
 fs/nfs/super.c                 |  121 ------
 fs/nfs_common/Makefile         |    1 
 fs/nfs_common/nfs_addr_parse.c |  155 ++++++++
 fs/nfsd/nfsctl.c               |  773 ++++++++++++++++++++++++++++++++--------
 fs/nfsd/nfssvc.c               |   13 +
 include/linux/nfs_addr_parse.h |   32 ++
 include/linux/sunrpc/svcsock.h |    6 
 net/sunrpc/svc_xprt.c          |   53 ++-
 net/sunrpc/svcsock.c           |   82 +++-
 12 files changed, 960 insertions(+), 330 deletions(-)
 create mode 100644 fs/nfs_common/nfs_addr_parse.c
 create mode 100644 include/linux/nfs_addr_parse.h

-- 
Chuck Lever
