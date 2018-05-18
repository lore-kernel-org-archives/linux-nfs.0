Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:45037 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbeERPjN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 11:39:13 -0400
Received: by mail-io0-f193.google.com with SMTP id d11-v6so6686054iof.11
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 08:39:13 -0700 (PDT)
Subject: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com
Date: Fri, 18 May 2018 11:39:11 -0400
Message-ID: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been experimenting with this series that modifies NFSD to
discover and use the correct GSS service principal when constructing
its NFSv4.0 callback channels. I'm interested in review of this
approach. There are a couple of code comments marked with XXX that
also need some attention.

The rpc.gssd change mentioned in 1/4 is unremarkable and will be
made available once there is consensus about the kernel changes
in this series. No gssproxy changes are necessary.

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
