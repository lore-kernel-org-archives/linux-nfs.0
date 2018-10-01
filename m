Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f169.google.com ([209.85.166.169]:52114 "EHLO
        mail-it1-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725975AbeJBAyy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 20:54:54 -0400
Subject: [PATCH v1 0/4] NFS/RDMA server patches for v4.20
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:15:50 -0400
Message-ID: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

These four patches are ready for you to consider for the next merge
window. There are three clean up patches, and one patch to increase
the server's credit grant to the default size of the Linux client's
NFSv4.1 session slot table. I've measured modest performance
increases with this change.

---

Chuck Lever (4):
      svcrdma: Reduce max_send_sges
      svcrdma: Remove ->release_rqst call in bc reply handler
      svcrdma: Remove try_module_get from backchannel
      svcrdma: Increase the default connection credit limit


 include/linux/sunrpc/svc_rdma.h            |   13 +++++++------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   23 ++++-------------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   10 ++++++----
 3 files changed, 17 insertions(+), 29 deletions(-)

--
Chuck Lever
