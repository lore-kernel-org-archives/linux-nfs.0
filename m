Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50900 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751657AbeCTVFH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:05:07 -0400
Subject: [PATCH 0/3] Three short subjects for v4.17
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 20 Mar 2018 17:05:04 -0400
Message-ID: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I have a bunch of patches left, but it looks like -rc7 is going to
be the last -rc, and you are working on read delegation. So let's
draw to a close with these three simple fixes, and I can postpone
the rest until v4.18.

---

Chuck Lever (3):
      svcrdma: Use pr_err to report Receive errors
      svcrdma: Consult max_qp_init_rd_atom when accepting connections
      svcrdma: Clean up rdma_build_arg_xdr


 net/sunrpc/xprtrdma/svc_rdma.c           |    4 ++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   33 +++++++++++++++---------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   28 +++++++++++--------------
 3 files changed, 30 insertions(+), 35 deletions(-)

--
Chuck Lever
