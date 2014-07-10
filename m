Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:65032 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbaGJRoU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 13:44:20 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] NFS/RDMA server patches for 3.17
To: swise@ogc.net
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Thu, 10 Jul 2014 13:44:17 -0400
Message-ID: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Can you include these two potential 3.17 candidate patches in
your testing branch?

---

Chuck Lever (2):
      svcrdma: Remove extra writeargs sanity check for NFSv2/3
      svcrdma: Increase credit limit to 32


 fs/nfsd/nfs3xdr.c               |   15 +--------------
 fs/nfsd/nfsxdr.c                |   16 +---------------
 include/linux/sunrpc/svc_rdma.h |    3 +--
 3 files changed, 3 insertions(+), 31 deletions(-)

-- 
Chuck Lever
