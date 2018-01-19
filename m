Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37413 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756027AbeASUTc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jan 2018 15:19:32 -0500
Subject: [PATCH v2 0/2] Re-send with SPDX headers
From: Chuck Lever <chuck.lever@oracle.com>
To: jgg@ziepe.ca, dledford@redhat.com, anna.schumaker@netapp.com,
        leon@kernel.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 19 Jan 2018 15:19:30 -0500
Message-ID: <20180119201640.3084.73639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna and RDMA maintainers-

Here are the two patches in my "xprtrdma trace points" series for
v4.16 that introduce new files. These have been updated to include
SPDX headers in the new files.

RDMA maintainers, please ACK the first patch. Anna, can you replace
the corresponding patches in your tree with these?

Thanks!

---

Chuck Lever (2):
      rdma/ib: Add trace point macros to display human-readable values
      rpcrdma: infrastructure for static trace points in rpcrdma.ko


 include/trace/events/rdma.h     |  129 +++++++++++++++++++++++++++++++++++++++
 include/trace/events/rpcrdma.h  |   15 +++++
 net/sunrpc/xprtrdma/module.c    |   12 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +
 4 files changed, 153 insertions(+), 5 deletions(-)
 create mode 100644 include/trace/events/rdma.h
 create mode 100644 include/trace/events/rpcrdma.h

--
Chuck Lever
