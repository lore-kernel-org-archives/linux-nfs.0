Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37227 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdHAP7n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 11:59:43 -0400
Received: by mail-it0-f65.google.com with SMTP id 77so1924162itj.4
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 08:59:43 -0700 (PDT)
Subject: [PATCH v1 0/4] NFS server clean ups for v4.14
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 11:59:41 -0400
Message-ID: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Follow-on to Christoph's const-ification of the proc arrays, and a
clean-up suggested by Dan Carpenter. More to come.

---

Chuck Lever (4):
      sunrpc: Const-ify instances of struct svc_xprt_ops
      nfsd: Const-ify NFSv4 encoding and decoding ops arrays
      sunrpc: Const-ify struct sv_serv_ops
      svcrdma: Clean up svc_rdma_build_read_chunk()


 fs/lockd/svc.c                           |    2 +-
 fs/nfs/callback.c                        |   10 +++++-----
 fs/nfsd/nfs4xdr.c                        |    4 ++--
 fs/nfsd/nfssvc.c                         |    2 +-
 include/linux/sunrpc/svc.h               |    6 +++---
 include/linux/sunrpc/svc_xprt.h          |    4 ++--
 net/sunrpc/svc.c                         |    6 +++---
 net/sunrpc/svcsock.c                     |    6 +++---
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |    8 +++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++--
 10 files changed, 27 insertions(+), 25 deletions(-)

--
Chuck Lever
