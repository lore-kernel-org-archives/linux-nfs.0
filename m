Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4194 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753673Ab1LNKpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 05:45:07 -0500
Subject: [PATCH 00/11] SUNRPC: make sysctl per network namespcase context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 14 Dec 2011 14:44:39 +0300
Message-ID: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set make SUNRPC sysctl created per network namspace context.
It provides the following functionality:
1) Debug sysctl's ( {rpc,nfs,nlm,nfsd}_debug ) content is modifyable only from
init_net network context.
2) Write to rpc_debug prints active RPC tasks in sysctl's creator networks
context.
3) xs tunables are per-net now and modified through per-net sysctl's. IOW,
sysctl creator context is used to get tunable during sysctl read/write access
(not current tone).

The following series consists of:

---

Stanislav Kinsbursky (11):
      SYSCTL: export root ans set handling routines
      SUNRPC: use syctl path instead of dummy parent table
      SUNRPC: sysctl root for debug table introduced
      SUNRPC: per-net sysctl's set introduced
      SUNRPC: register debug sysctl table per network namespace
      SUNRPC: register xs_tunables sysctl table per network namespace
      SUNRPC: xs tunables per network namespace introduced
      SUNRPC: use per-net xs tunables instead of static ones
      SUNRPC: remove xs_tcp_fin_timeout variable
      SUNRPC: allow debug flags modifications only from init_net
      SUNRPC: sysctl table for rpc_debug introduced


 include/linux/sunrpc/debug.h    |    9 ++
 include/linux/sunrpc/sched.h    |    1 
 include/linux/sunrpc/xprtsock.h |    3 +
 include/linux/sysctl.h          |    1 
 kernel/sysctl.c                 |   11 +++
 net/sunrpc/netns.h              |   12 +++
 net/sunrpc/sunrpc_syms.c        |   27 ++++++-
 net/sunrpc/sysctl.c             |  160 ++++++++++++++++++++++++++++++++-------
 net/sunrpc/xprtrdma/transport.c |   11 ---
 net/sunrpc/xprtsock.c           |  147 ++++++++++++++++++++++++------------
 10 files changed, 293 insertions(+), 89 deletions(-)


