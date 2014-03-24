Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f49.google.com ([209.85.160.49]:33540 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaCXDyv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 23:54:51 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so4835281pbb.22
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 20:54:50 -0700 (PDT)
Message-ID: <532FAC85.20909@gmail.com>
Date: Mon, 24 Mar 2014 11:54:45 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5][RESEND]NFSD/SUNRPC: Fix memory leak for the backchannel
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using pynfs test-site, I found some memory leak for the backchannel.

Kinglong Mee (5):
  NFSD: Using free_conn free connection
  NFSD: Free backchannel xprt in bc_destroy
  SUNRPC: New helper for creating client with rpc_xprt
  NFSD/SUNRPC: Check rpc_xprt out of xs_setup_bc_tcp
  SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed

 fs/nfsd/nfs4callback.c      | 19 ++++++++++++++-
 fs/nfsd/nfs4state.c         |  3 ++-
 include/linux/sunrpc/clnt.h |  2 ++
 include/linux/sunrpc/xprt.h | 13 +++++++++-
 net/sunrpc/clnt.c           | 58 ++++++++++++++++++++++++++-------------------
 net/sunrpc/xprt.c           | 12 ----------
 net/sunrpc/xprtsock.c       | 15 +++++-------
 7 files changed, 73 insertions(+), 49 deletions(-)

-- 
1.8.5.3
