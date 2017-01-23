Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36704 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdAWUwk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 15:52:40 -0500
Subject: [PATCH v2 0/5] Fix "support large inline thresholds"
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jan 2017 15:52:37 -0500
Message-ID: <20170123205159.21699.47373.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

I've received a number of reports that v4.9 commit 655fec6987be
("xprtrdma: Use gathered Send for large inline messages") causes
NFS/RDMA mounts to fail for devices that have a small max_sge.

This series addresses that problem. Would you consider this series
of bug fixes for v4.10-rc?


Available in the "nfs-rdma-for-4.10-rc" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

And for online review:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.10-rc


Changes since v1:
- Rebased on v4.10-rc5
- Renamed some variables for clarity
- Clarified patch descriptions
- Added Tested-by and Reviewed-by tags

---

Chuck Lever (5):
      xprtrdma: Fix Read chunk padding
      xprtrdma: Per-connection pad optimization
      xprtrdma: Disable pad optimization by default
      xprtrdma: Reduce required number of send SGEs
      xprtrdma: Shrink send SGEs array


 net/sunrpc/xprtrdma/rpc_rdma.c  |   62 +++++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/transport.c |    2 +
 net/sunrpc/xprtrdma/verbs.c     |   15 ++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h |   14 ++++++---
 4 files changed, 60 insertions(+), 33 deletions(-)

--
Chuck Lever
