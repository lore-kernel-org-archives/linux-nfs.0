Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35394 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbdHRPMM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 11:12:12 -0400
Received: by mail-io0-f194.google.com with SMTP id h70so5830483ioi.2
        for <linux-nfs@vger.kernel.org>; Fri, 18 Aug 2017 08:12:12 -0700 (PDT)
Subject: [PATCH v1 0/3] Handle NFSv4 operations in xdr_buf tail
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 Aug 2017 11:12:10 -0400
Message-ID: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

A little light weekend reading. I got around to implementing
support in the NFSv4 WRITE decoder for dealing with trailing
operations that reside in the receiver buffer's tail iovec.
Let me know what you think of this solution.

---

Chuck Lever (3):
      nfsd: Limit end of page list when decoding NFSv4 WRITE
      nfsd: Incoming xdr_bufs may have content in tail buffer
      svcrdma: Populate tail iovec when receiving


 fs/nfsd/nfs4xdr.c                 |   26 ++++++++-
 fs/nfsd/xdr4.h                    |    1 
 net/sunrpc/xprtrdma/svc_rdma_rw.c |  108 +++++--------------------------------
 3 files changed, 38 insertions(+), 97 deletions(-)

--
Chuck Lever
