Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1980 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932712Ab2AKPSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 10:18:22 -0500
Subject: [PATCH v2 0/6] SUNRPC: make RPC clients use network-namespace-aware
 PipeFS routines
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 11 Jan 2012 19:17:52 +0400
Message-ID: <20120111151051.5891.1830.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set was created in context of clone of git
branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.

v2:
1) "over-put" of PipeFS mount point in 1st patch of the series fixed, which
allow allows to bisect the patch set.
2) rebased on tag v3.2

This patch set depends on previous patch sets titled:
1) "SUNRPC: initial part of making pipefs work in net ns"
2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"

This patch set is a first part of reworking SUNPRC PipeFS users.
It makes SUNRPC clients using PipeFS nofitications for directory and GSS pipes
dentries creation. With this patch set RPC clients and GSS auth creations
routines doesn't force SUNRPC PipeFS mount point creation which actually means,
that they now can work without PipeFS dentries.


The following series consists of:

---

Stanislav Kinsbursky (6):
      SUNRPC: handle RPC client pipefs dentries by network namespace aware routines
      SUNRPC: handle GSS AUTH pipes by network namespace aware routines
      SUNRPC: subscribe RPC clients to pipefs notifications
      SUNRPC: remove RPC client pipefs dentries after unregister
      SUNRPC: remove RPC pipefs mount point manipulations from RPC clients code
      SUNRPC: remove RPC PipeFS mount point reference from RPC client


 fs/nfs/idmap.c                 |    4 +
 fs/nfsd/nfs4callback.c         |    2 -
 include/linux/nfs.h            |    2 -
 include/linux/sunrpc/auth.h    |    2 +
 include/linux/sunrpc/clnt.h    |    2 -
 net/sunrpc/auth_gss/auth_gss.c |  101 +++++++++++++++++++++------
 net/sunrpc/clnt.c              |  150 +++++++++++++++++++++++++++++++---------
 net/sunrpc/rpc_pipe.c          |   19 +++--
 net/sunrpc/sunrpc.h            |    2 +
 9 files changed, 217 insertions(+), 67 deletions(-)

