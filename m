Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35650 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970610AbeCSS4p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2018 14:56:45 -0400
Received: by mail-io0-f172.google.com with SMTP id e7so11576464iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 19 Mar 2018 11:56:45 -0700 (PDT)
Subject: [PATCH v1 0/2] NFS decoder clean-ups, redux
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Mon, 19 Mar 2018 14:56:43 -0400
Message-ID: <20180319184647.10100.25736.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

These two are pre-requisites for some transport level changes I'd
like to propose for v4.17.

I proposed these two for v4.16, you may recall. We had some
discussion about what changes you wanted but now I'm not sure I
recall your requests accurately.

I recall you felt OK with "NFSD: Clean up write argument XDR
decoders" but wanted some changes to "NFSD: Clean up symlink
argument XDR decoders".

Did you prefer that the symlink decoder should allocate a page
rather than pull it out of rq_pages[] ?

---

Chuck Lever (2):
      NFSD: Clean up write argument XDR decoders
      NFSD: Clean up symlink argument XDR decoders


 fs/nfsd/nfs3proc.c         |   18 ++++++-
 fs/nfsd/nfs3xdr.c          |   67 ++++++---------------------
 fs/nfsd/nfs4proc.c         |   37 +++++----------
 fs/nfsd/nfs4xdr.c          |   11 +++-
 fs/nfsd/nfsproc.c          |   23 ++++++---
 fs/nfsd/nfsxdr.c           |   63 +++++++++++++------------
 fs/nfsd/xdr.h              |    3 +
 fs/nfsd/xdr3.h             |    3 +
 fs/nfsd/xdr4.h             |    3 +
 include/linux/sunrpc/svc.h |    4 ++
 net/sunrpc/svc.c           |  109 ++++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 217 insertions(+), 124 deletions(-)

--
Chuck Lever
