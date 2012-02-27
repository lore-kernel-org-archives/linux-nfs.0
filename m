Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:39103 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab2B0Nt2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 08:49:28 -0500
Subject: [PATCH 0/4] SUNRPC: several fixes around PipeFS objects
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 27 Feb 2012 17:48:43 +0400
Message-ID: <20120227134623.13371.61185.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First two pathes fixes lockdep warnings and next two - dereferencing of
released pipe data on eventfd close.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: replace per-net client lock by rw mutex
      NFS: replace per-net client lock by mutex
      SUNRPC: check RPC inode's pipe reference before dereferencing
      SUNRPC: move waitq from RPC pipe to RPC inode


 fs/nfs/client.c                    |   36 +++++++++---------
 fs/nfs/idmap.c                     |    4 +-
 fs/nfs/netns.h                     |    2 +
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/clnt.c                  |   16 ++++----
 net/sunrpc/netns.h                 |    2 +
 net/sunrpc/rpc_pipe.c              |   71 +++++++++++++++++++++++-------------
 net/sunrpc/sunrpc_syms.c           |    2 +
 8 files changed, 77 insertions(+), 58 deletions(-)

