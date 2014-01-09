Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f43.google.com ([209.85.160.43]:39567 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaAIKbZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 05:31:25 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so2854275pbb.2
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 02:31:25 -0800 (PST)
Message-ID: <52CE7A76.3080101@gmail.com>
Date: Thu, 09 Jan 2014 18:31:18 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] NFSD/SUNRPC: Fix some bugs which cause memory leak for
 the backchannel
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com>
In-Reply-To: <52CB8B79.6040907@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using pynfs test-site, I get some memory leak for the backchannel.
1,2,4,5 are bugfix, 3 adds a helper function for 4.

Kinglong Mee (5):
  NFSD: Using free_conn free connection
  NFSD: Free backchannel xprt in bc_destroy
  SUNRPC: New helper for creating client with rpc_xprt
  NFSD/SUNRPC: Check rpc_xprt out of  xs_setup_bc_tcp
  SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed

 fs/nfsd/nfs4callback.c      | 19 ++++++++++++++-
 fs/nfsd/nfs4state.c         |  3 ++-
 include/linux/sunrpc/clnt.h |  2 ++
 include/linux/sunrpc/xprt.h | 13 +++++++++-
 net/sunrpc/clnt.c           | 58 ++++++++++++++++++++++++++-------------------
 net/sunrpc/xprt.c           | 12 ----------
 net/sunrpc/xprtsock.c       | 16 +++++--------
 7 files changed, 73 insertions(+), 50 deletions(-)

-- 
1.8.4.2
