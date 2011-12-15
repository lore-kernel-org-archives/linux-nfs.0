Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43326 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759036Ab1LOQAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 11:00:17 -0500
Subject: [PATCH 0/7] SUNRPC: register services with per-net rpcbind 
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 15 Dec 2011 19:59:42 +0300
Message-ID: <20111215155252.2434.39434.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set makes service registered with per-net rpcbind and required for
making Lockd and NFSd services able to handle requests from and to different
network namespaces.

The following series consists of:

---

Stanislav Kinsbursky (7):
      SUNRPC: create rpcbind client in passed network namespace context
      SUNRPC: register rpcbind programs in passed network namespase context
      SUNRPC: use proper network namespace in rpcbind RPCBPROC_GETADDR procedure
      SUNRPC: parametrize local rpcbind clients creation with net ns
      SUNRPC: pass network namespace to service registering routines
      SUNRPC: register service on creation in current network namespace
      SUNRPC: unregister service on creation in current network namespace


 fs/nfsd/nfssvc.c            |    4 +--
 include/linux/sunrpc/clnt.h |    9 ++++--
 include/linux/sunrpc/svc.h  |   11 ++++----
 net/sunrpc/rpcb_clnt.c      |   29 +++++++++++---------
 net/sunrpc/svc.c            |   61 +++++++++++++++++++++++--------------------
 net/sunrpc/svcsock.c        |    3 +-
 6 files changed, 63 insertions(+), 54 deletions(-)

-- 
Signature
