Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35488 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681AbaGVUAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 16:00:24 -0400
Received: by mail-ig0-f172.google.com with SMTP id h15so4430437igd.11
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 13:00:24 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] NFS/RDMA server patches for 3.17
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 16:00:22 -0400
Message-ID: <20140722195840.6011.87861.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Would you take these server patches for 3.17? Thank you!

---

Chuck Lever (2):
      svcrdma: Add zero padding if the client doesn't send it
      svcrdma: Increase credit limit to 32


 include/linux/sunrpc/svc_rdma.h         |    3 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 2 deletions(-)

-- 
Chuck Lever
