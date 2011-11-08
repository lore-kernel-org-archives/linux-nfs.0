Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:2436 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932111Ab1KHLNK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 06:13:10 -0500
Subject: [PATCH v2 0/7] SUNRPC: initial part of making pipefs work in net ns
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 08 Nov 2011 15:12:12 +0300
Message-ID: <20111108111056.6206.11410.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch-set was created in context of clone of git branch:
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.

v2:
1) Rebased of current repo state (i.e. all commits were pulled before apply)

This patch-set implements pipefs superblock creation per network namespace
context instead of using single one for all possible contexts. Also, it
provides pipefs dentries creation and destruction helpers for kernel routines.

Additional description of the idea about how to make RPC pipefs work per
network namespace context can be found in the letter titled "SUNRPC: "RPC
pipefs per network namespace" preparations", which has been sent already to
linux-nfs@vger.kernel.org.

The following series consists of:

---

Stanislav Kinsbursky (7):
      SUNRPC: create RPC pipefs superblock per network namespace context
      SUNRPC: hold current network namespace while pipefs superblock is active
      SUNRPC: send notification events on pipefs sb creation and destruction
      SUNRPC: pipefs dentry lookup helper introduced
      SUNRPC: put pipefs superblock link on network namespace
      SUNRPC: pipefs per-net operations helper introduced
      SUNRPC: added debug messages to RPC pipefs


 include/linux/sunrpc/rpc_pipe_fs.h |   14 ++++
 net/sunrpc/netns.h                 |    3 +
 net/sunrpc/rpc_pipe.c              |  113 +++++++++++++++++++++++++++++++++++-
 net/sunrpc/sunrpc_syms.c           |    1 
 4 files changed, 129 insertions(+), 2 deletions(-)

-- 
Signature
