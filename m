Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:37779 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754653AbeATQQT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Jan 2018 11:16:19 -0500
Subject: [PATCH v3 0/2] Re-send with SPDX headers
From: Chuck Lever <chuck.lever@oracle.com>
To: jgg@ziepe.ca, dledford@redhat.com, anna.schumaker@netapp.com,
        leon@kernel.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 20 Jan 2018 11:16:16 -0500
Message-ID: <20180120161440.6488.4311.stgit@manet.1015granger.net>
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


Changes since v2:
- Commit the change to rpcrdma.h _before_ mailing

---

Chuck Lever (2):
      rdma/ib: Add trace point macros to display human-readable values
      rpcrdma: infrastructure for static trace points in rpcrdma.ko


 include/trace/events/rdma.h     |  129 +++++++++++++++++++++++++++++++++++++++
 include/trace/events/rpcrdma.h  |   16 +++++
 net/sunrpc/xprtrdma/module.c    |   12 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +
 4 files changed, 154 insertions(+), 5 deletions(-)
 create mode 100644 include/trace/events/rdma.h
 create mode 100644 include/trace/events/rpcrdma.h

--
Chuck Lever
