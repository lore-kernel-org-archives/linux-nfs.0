Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:36856 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdAMRmv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 12:42:51 -0500
Subject: [PATCH v1 0/5] Fix "support large inline thresholds"
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 13 Jan 2017 12:42:48 -0500
Message-ID: <20170113173023.32692.30661.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've received a number of reports that v4.9 commit 655fec6987be
("xprtrdma: Use gathered Send for large inline messages") causes
NFS/RDMA mounts to fail for devices that have a small max_sge.

This series addresses that problem.

A much smaller fix was provided initially. It worked for devices
with as small as five send SGEs. However, additional research has
shown that there is at least one in-tree device that supports only
three send SGEs.

The current series should enable NFS/RDMA again on those devices.


Available in the "nfs-rdma-for-4.10-rc" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

And for online review:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.10-rc

---

Chuck Lever (5):
      xprtrdma: Fix Read chunk padding
      xprtrdma: Per-connection pad optimization
      xprtrdma: Disable pad optimization by default
      xprtrdma: Reduce required number of send SGEs
      xprtrdma: Shrink send SGEs array


 net/sunrpc/xprtrdma/rpc_rdma.c  |   59 ++++++++++++++++++++++++++-------------
 net/sunrpc/xprtrdma/transport.c |    2 +
 net/sunrpc/xprtrdma/verbs.c     |   15 ++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |   13 ++++++---
 4 files changed, 58 insertions(+), 31 deletions(-)

--
Chuck Lever
