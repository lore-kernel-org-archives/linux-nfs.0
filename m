Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:43409 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755825AbeEAPhL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 May 2018 11:37:11 -0400
Subject: [PATCH v1 0/2] NFS/RDMA fixes for v4.17-rc
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 May 2018 11:37:08 -0400
Message-ID: <20180501153109.5863.33183.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

These are fixes that might be appropriate for v4.17-rc. If not,
consider them the first items in my for-v4.18 series.

---

Chuck Lever (2):
      xprtrdma: Fix list corruption / DMAR errors during MR recovery
      sunrpc: Fix latency trace point crashes


 include/trace/events/sunrpc.h   |   16 ++++++----------
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 +----
 net/sunrpc/xprtrdma/frwr_ops.c  |    9 +++------
 net/sunrpc/xprtrdma/verbs.c     |    5 +++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 5 files changed, 16 insertions(+), 21 deletions(-)

--
Chuck Lever
