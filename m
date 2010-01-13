Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29955 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756398Ab0AMVLI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 16:11:08 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] NFSD IPv6 patches
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Wed, 13 Jan 2010 16:10:22 -0500
Message-ID: <20100113210650.19409.38009.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are the last few IPv6-related patches for NFSD that I have
outstanding.  There's been a enough light testing with my mountd
prototype to suggest we are close enough to enable the kernel
support.

Please consider these for 2.6.34.

---

Aime Le Rouzic (1):
      NFSD: Support AF_INET6 in svc_addsock() function

Chuck Lever (2):
      NFSD: Enable NFS server use of PF_INET6
      SUNRPC: Use rpc_pton() in ip_map_parse()


 fs/nfsd/nfsctl.c          |   36 ++++++++++++++++++++++++++++------
 fs/nfsd/nfssvc.c          |   27 +++++++++++++++++++++-----
 net/sunrpc/svcauth_unix.c |   47 +++++++++++++++++++++++++--------------------
 net/sunrpc/svcsock.c      |    2 +-
 4 files changed, 78 insertions(+), 34 deletions(-)

-- 
chuck[dot]lever[at]oracle[dot]com
