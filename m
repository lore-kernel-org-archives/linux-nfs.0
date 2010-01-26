Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:18971 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab0AZTDy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 14:03:54 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Repost of remaining server-side IPv6 patches
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Jan 2010 14:03:38 -0500
Message-ID: <20100126190214.3368.89388.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce-

Repost of last week's IPv6 patch set.  I've attempted to address your
comments.

---

Aime Le Rouzic (1):
      NFSD: Support AF_INET6 in svc_addsock() function

Chuck Lever (4):
      NFSD: Create PF_INET6 listener in write_ports
      SUNRPC: NFS kernel APIs shouldn't return ENOENT for "transport not found"
      SUNRPC: Bury "#ifdef IPV6" in svc_create_xprt()
      SUNRPC: Use rpc_pton() in ip_map_parse()


 fs/lockd/svc.c            |    2 --
 fs/nfs/callback.c         |    2 --
 fs/nfsd/nfsctl.c          |   24 ++++++++++++++++++-----
 net/sunrpc/svc_xprt.c     |    9 ++++++++-
 net/sunrpc/svcauth_unix.c |   47 +++++++++++++++++++++++++--------------------
 net/sunrpc/svcsock.c      |    2 +-
 6 files changed, 54 insertions(+), 32 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
