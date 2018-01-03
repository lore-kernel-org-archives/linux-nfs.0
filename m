Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33047 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbeACUiD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:38:03 -0500
Subject: [PATCH 0/6] Final NFS/RDMA series for v4.16
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:38:01 -0500
Message-ID: <20180103203540.29209.4620.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Here are some minor fixes and clean ups to finish out the set of
patches for v4.16. Included are fixes for a few issues I noticed
in sunrpc.ko.

---

Chuck Lever (6):
      xprtrdma: Fix "bytes registered" accounting
      xprtrdma: Correct some documenting comments
      SUNRPC: Trace xprt_timer events
      sunrpc: Format RPC events consistently for display
      SUNRPC: task_run_action should display tk_callback
      SUNRPC: Micro-optimize __rpc_execute


 include/trace/events/sunrpc.h     |    8 ++++++--
 net/sunrpc/sched.c                |   26 ++++++++++++--------------
 net/sunrpc/xprt.c                 |    2 +-
 net/sunrpc/xprtrdma/backchannel.c |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c    |    4 ++--
 net/sunrpc/xprtrdma/transport.c   |    2 --
 net/sunrpc/xprtrdma/verbs.c       |    2 +-
 7 files changed, 23 insertions(+), 23 deletions(-)

--
Chuck Lever
