Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f180.google.com ([209.85.210.180]:53569 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab3CUATZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 20:19:25 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so1969857iae.11
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2013 17:19:24 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 0/3] Negotiate NFSv3 mount security flavor
To: linux-nfs@vger.kernel.org
Date: Wed, 20 Mar 2013 20:19:23 -0400
Message-ID: <20130321001753.12106.50688.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For review, here is an implementation of NFSv3 security flavor
negotiation.

Changes since v1:

  o  Corrected a typo in the third patch

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
