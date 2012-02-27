Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:48803 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753766Ab2B0PvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 10:51:13 -0500
Subject: [PATCH v2 0/4] SUNRPC: several fixes around PipeFS objects
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 27 Feb 2012 19:50:47 +0400
Message-ID: <20120227154713.7941.17963.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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


 fs/nfs/client.c                    |    2 +
 fs/nfs/idmap.c                     |    8 +++-
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/clnt.c                  |   10 ++++-
 net/sunrpc/rpc_pipe.c              |   71 +++++++++++++++++++++++-------------
 5 files changed, 60 insertions(+), 33 deletions(-)

