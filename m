Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45784 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473AbaGORyx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:54:53 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 0/2] NFS/RDMA server patches for 3.17
To: swise@opengridcomputing.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 15 Jul 2014 13:54:50 -0400
Message-ID: <20140715175144.3448.48674.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Can you include these 3.17 candidate patches in your testing branch?

v2:

- Second patch replaced with a lower-level fix

---

Chuck Lever (2):
      svcrdma: Add zero padding if the client doesn't send it
      svcrdma: Increase credit limit to 32


 include/linux/sunrpc/svc_rdma.h         |    3 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 2 deletions(-)

-- 
Chuck Lever
