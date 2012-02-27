Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4905 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754320Ab2B0SFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 13:05:50 -0500
Subject: [PATCH v3 0/4] SUNRPC: several fixes around PipeFS objects
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 27 Feb 2012 22:05:20 +0400
Message-ID: <20120227180509.1089.29555.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
1) Lookup for client is performed from the beginning of the list on each PipeFS
event handling operation.

v2: 
1) Prior to calling PipeFS dentry rountines (for both type of clients - SUNPRC
and NFS) get the client and drop the list lock instead of replacing per-net
locks by mutexes.

First two pathes fixes lockdep warnings and next two - dereferencing of
released pipe data on eventfd close and in file operations.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: release per-net clients lock before calling PipeFS dentries creation
      NFS: release per-net clients lock before calling PipeFS dentries creation
      SUNRPC: check RPC inode's pipe reference before dereferencing
      SUNRPC: move waitq from RPC pipe to RPC inode


 fs/nfs/idmap.c                     |   30 ++++++++++++---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/clnt.c                  |   30 ++++++++++++---
 net/sunrpc/rpc_pipe.c              |   71 +++++++++++++++++++++++-------------
 4 files changed, 93 insertions(+), 40 deletions(-)

