Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40494 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932152Ab2AJNFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 08:05:02 -0500
Subject: [PATCH v2 0/5] NFS: create blocklayout pipe per network namesapce
 context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 10 Jan 2012 17:04:07 +0400
Message-ID: <20120110130323.1672.97025.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set was created in context of clone of git
branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
tag: v3.2

v2:
1) rebased on tag v3.2

This patch set depends on previous patch sets titled:
1) "SUNRPC: initial part of making pipefs work in net ns"
2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
3) "SUNRPC: make RPC clients use network-namespace-aware PipeFS routines"
4) "NFS: create clients and IDMAP pipes per network namespace"

This patch set is the final part of making SUNRPC PipeFS and it's users work in
network namespace context.


The following series consists of:

---

Stanislav Kinsbursky (5):
      NFS: handle blocklayout pipe PipeFS dentry by network namespace aware routines
      NFS: blocklayout pipe creation per network namespace context introduced
      NFS: blocklayout PipeFS notifier introduced
      NFS: remove RPC PipeFS mount point reference from blocklayout routines
      SUNRPC: kernel PipeFS mount point creation routines removed


 fs/nfs/blocklayout/blocklayout.c    |  160 ++++++++++++++++++++++++++++-------
 fs/nfs/blocklayout/blocklayout.h    |    3 -
 fs/nfs/blocklayout/blocklayoutdev.c |    5 +
 fs/nfs/blocklayout/blocklayoutdm.c  |    7 +-
 fs/nfs/inode.c                      |    1 
 fs/nfs/netns.h                      |    1 
 include/linux/sunrpc/rpc_pipe_fs.h  |    2 
 net/sunrpc/rpc_pipe.c               |   21 -----
 8 files changed, 139 insertions(+), 61 deletions(-)

-- 
Signature
