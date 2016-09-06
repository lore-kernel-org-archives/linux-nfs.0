Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35379 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932870AbcIFPWn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 11:22:43 -0400
Received: by mail-oi0-f65.google.com with SMTP id 2so15182419oif.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Sep 2016 08:22:43 -0700 (PDT)
Subject: [PATCH 0/2] NFS/RDMA bug fixes for v4.8-rc
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2016 11:22:40 -0400
Message-ID: <20160906151843.4958.84689.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna, Trond-

Commit 3d4cf35bd4fa is wrong, as described in the patch description
of the revert commit below. It was submitted for v4.8, but needs to
be removed before v4.8 final, to avoid a regression.

The second patch below addresses the original problem that
3d4cf35bd4fa was attempting to fix.

Would you consider these for v4.8-rc ?

---

Chuck Lever (2):
      xprtrdma: Revert 3d4cf35bd4fa ("xprtrdma: Reply buffer exhaustion...")
      xprtrdma: Fix receive buffer accounting


 net/sunrpc/xprtrdma/verbs.c     |   45 ++++++++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 33 insertions(+), 13 deletions(-)

--
Chuck Lever
