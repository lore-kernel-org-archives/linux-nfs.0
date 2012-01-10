Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44470 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756155Ab2AJMMv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 07:12:51 -0500
Subject: [PATCH v2 0/6] NFS: create clients and IDMAP pipes per network
 namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 10 Jan 2012 16:12:27 +0400
Message-ID: <20120110120946.7307.60098.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set was created in context of clone of git
branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.

v2:
1) Rebased on tag v3.2
2) Added "nfs_idmap_init" and "nfs_idmap_quit" definitions for kernels built
without CONFIG_NFS_V4 option set

This patch set depends on previous patch sets titled:
1) "SUNRPC: initial part of making pipefs work in net ns"
2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
3) "SUNRPC: make RPC clients use network-namespace-aware PipeFS routines"

Actually, this patch set consists of two tightly connected parts:
1) NFS clients creation per network namespace
2) IDMAP pipe dentries creation in owner client network namesapce context

This patch set is the third part of making "PipeFS per network namespace".


The following series consists of:

---

Stanislav Kinsbursky (6):
      SUNRPC: fix pipe->ops cleanup on pipe dentry unlink
      NFS: make NFS client allocated per network namespace context
      NFS: pass NFS client owner network namespace to RPC client creation routine
      NFS: create callback transports in parent transport network namespace
      NFS: handle NFS idmap pipe PipeFS dentries by network namespace aware routines
      NFS: idmap PipeFS notifier introduced


 fs/nfs/callback.c                  |   10 +--
 fs/nfs/client.c                    |   22 ++++--
 fs/nfs/idmap.c                     |  136 ++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h                  |    6 ++
 fs/nfs/mount_clnt.c                |    4 +
 fs/nfs/super.c                     |    4 +
 include/linux/nfs_fs_sb.h          |    1 
 include/linux/nfs_idmap.h          |   21 +++---
 include/linux/sunrpc/rpc_pipe_fs.h |    7 ++
 net/sunrpc/clnt.c                  |    1 
 net/sunrpc/rpc_pipe.c              |   67 ++++++++++--------
 11 files changed, 217 insertions(+), 62 deletions(-)

-- 
Signature
