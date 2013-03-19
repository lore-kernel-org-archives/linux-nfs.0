Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f179.google.com ([209.85.210.179]:40959 "EHLO
	mail-ia0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab3CSTBg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 15:01:36 -0400
Received: by mail-ia0-f179.google.com with SMTP id x24so701036iak.38
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 12:01:35 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Negotiate NFSv3 mount security flavor
To: linux-nfs@vger.kernel.org
Date: Tue, 19 Mar 2013 15:01:19 -0400
Message-ID: <20130319185944.1203.38377.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For review, here is an implementation of NFSv3 security flavor
negotiation.

---

Chuck Lever (3):
      NFS: Use server-recommended security flavor by default (NFSv3)
      SUNRPC: Don't recognize RPC_AUTH_MAXFLAVOR
      SUNRPC: Remove extra xprt_put()


 fs/nfs/nfs4super.c |    2 +
 fs/nfs/super.c     |   80 +++++++++++++++++++++++++++-------------------------
 net/sunrpc/auth.c  |    5 +++
 net/sunrpc/clnt.c  |    4 +--
 4 files changed, 49 insertions(+), 42 deletions(-)

-- 
Chuck Lever
