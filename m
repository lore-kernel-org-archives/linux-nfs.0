Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:54046 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2392162AbeHPTFQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 15:05:16 -0400
Received: by mail-it0-f68.google.com with SMTP id 72-v6so6979946itw.3
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2018 09:05:53 -0700 (PDT)
Subject: [PATCH v2 0/4] Use correct NFSv4.0 callback credential
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, simo@redhat.com
Date: Thu, 16 Aug 2018 12:05:48 -0400
Message-ID: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

This is the same series as I posted in May, merged up to v4.18. I
tested it again this morning. Can it be included in v4.19 ?

The previous thread claims Simo Ack'd these patches, but I can't
find the actual Acked-by. I've cc'd him on this repost in case he
has additional comments.

---

Chuck Lever (4):
      sunrpc: Enable the kernel to specify the hostname part of service principals
      sunrpc: Extract target name into svc_cred
      nfsd: Use correct credential for NFSv4.0 callback with GSS
      nfsd: Remove callback_cred


 fs/nfsd/nfs4callback.c               |   29 ++++----------
 fs/nfsd/nfs4state.c                  |   17 +++-----
 fs/nfsd/state.h                      |    2 -
 include/linux/sunrpc/svcauth.h       |    3 +
 net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
 net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
 6 files changed, 80 insertions(+), 61 deletions(-)

--
Chuck Lever
