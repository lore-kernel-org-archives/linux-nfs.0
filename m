Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36885 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160998Ab3CVQws (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Mar 2013 12:52:48 -0400
Received: by mail-ie0-f177.google.com with SMTP id tp5so722349ieb.22
        for <linux-nfs@vger.kernel.org>; Fri, 22 Mar 2013 09:52:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 0/3] Negotiate NFSv3 mount security flavor
To: linux-nfs@vger.kernel.org
Date: Fri, 22 Mar 2013 12:52:50 -0400
Message-ID: <20130322165119.1678.97556.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is an implementation of NFSv3 security flavor negotiation.

Changes since v2;

 o  Actually commit the typo fix before posting (dang it)
 o  Correct use of Cc: stable in the first patch

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
