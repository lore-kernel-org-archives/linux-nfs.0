Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18647 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756419Ab1KVOmw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 09:42:52 -0500
Subject: [PATCH 0/6] SUNPRC: cleanup PipeFS for network-namespace-aware users
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 22 Nov 2011 18:41:25 +0300
Message-ID: <20111122134514.479.9848.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch-set was created in context of clone of git
branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
tag: v3.1

This is cleanup precursor patch set. It's required for easier further
implementation of network-namespace-aware SUNRPC PipeFS pipes creators.
Generally, this patch set split SUNRPC PipeFS logic into two parts: working
with pipes (new rpc_pipe structure with link to PipeFS dentry) and
creating/destroying PipeFS dentries (old rpc_inode structure with link to
rpc_pipe).
With this patch-set kernel PipeFS pipes users initially creates
rpc_pipe data and then creates Pipefs dentries. Later these dentries will be
created in notifier callbacks on PipeFS mount event from user-space and in
network namespace operations for such modules like nfs and blocklayout.

The following series consists of:

---

Stanislav Kinsbursky (6):
      SUNRPC: replace inode lock with pipe lock for RPC PipeFS operations
      SUNRPC: split SUNPRC PipeFS pipe data and inode creation
      SUNRPC: cleanup PipeFS redundant RPC inode usage
      SUNPRC: cleanup RPC PipeFS pipes upcall interface
      SUNRPC: cleanup GSS pipes usage
      SUNRPC: split SUNPRC PipeFS dentry and private pipe data creation


 fs/nfs/blocklayout/blocklayout.c    |   16 ++
 fs/nfs/blocklayout/blocklayout.h    |    2 
 fs/nfs/blocklayout/blocklayoutdev.c |    2 
 fs/nfs/blocklayout/blocklayoutdm.c  |    2 
 fs/nfs/idmap.c                      |   28 +++-
 include/linux/sunrpc/rpc_pipe_fs.h  |   20 ++-
 net/sunrpc/auth_gss/auth_gss.c      |  130 ++++++++++--------
 net/sunrpc/rpc_pipe.c               |  258 +++++++++++++++++++----------------
 8 files changed, 262 insertions(+), 196 deletions(-)

-- 
Signature
