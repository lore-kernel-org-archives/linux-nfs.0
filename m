Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35781 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbaAQTiB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 14:38:01 -0500
Received: by mail-ie0-f172.google.com with SMTP id e14so5904059iej.3
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jan 2014 11:38:01 -0800 (PST)
Received: from manet.1015granger.net (c-68-40-85-241.hsd1.mi.comcast.net. [68.40.85.241])
        by mx.google.com with ESMTPSA id l7sm4954939igx.2.2014.01.17.11.38.00
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jan 2014 11:38:00 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] NFS/RDMA bug fixes
To: linux-nfs@vger.kernel.org
Date: Fri, 17 Jan 2014 14:37:59 -0500
Message-ID: <20140117193555.3452.31437.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This brief series fixes some long-standing regressions in our
NFS/RDMA client implementation.  Comments / review?

---

Chuck Lever (3):
      SUNRPC: remove KERN_INFO from dprintk() call sites
      SUNRPC: Fix large reads on NFS/RDMA
      NFS: Fix READDIR oops with NFSv4 on RDMA


 fs/nfs/nfs4xdr.c                |    3 +--
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +---
 net/sunrpc/xprtrdma/transport.c |   10 +++++-----
 3 files changed, 7 insertions(+), 10 deletions(-)

-- 
Chuck Lever
