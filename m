Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:22414 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657Ab2ASOtn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 09:49:43 -0500
Subject: [PATCH 0/5] SUNRPC: make caches network namespace aware
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 19 Jan 2012 18:48:56 +0400
Message-ID: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more step towards to "NFS in container".
With this patch set caches are allocated per network namespace.

The following series consists of:

---

Stanislav Kinsbursky (5):
      SUNRPC: cache creation and destruction routines introduced
      SUNRPC: create unix gid cache per network namespace
      SUNRPC: create GSS auth cache per network namespace
      SUNRPC: ip map cache per network namespace cleanup
      SUNRPC: generic cache register routines removed


 include/linux/sunrpc/cache.h       |    6 +
 include/linux/sunrpc/svcauth_gss.h |    2 
 net/sunrpc/auth_gss/auth_gss.c     |   21 +++++
 net/sunrpc/auth_gss/svcauth_gss.c  |  161 +++++++++++++++++++++++++-----------
 net/sunrpc/cache.c                 |   34 ++++++--
 net/sunrpc/netns.h                 |    3 +
 net/sunrpc/sunrpc_syms.c           |   15 ++-
 net/sunrpc/svcauth_unix.c          |  107 ++++++++++++++----------
 8 files changed, 240 insertions(+), 109 deletions(-)

