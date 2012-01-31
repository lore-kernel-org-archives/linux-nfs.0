Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:37848 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695Ab2AaLH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 06:07:58 -0500
Subject: [PATCH 0/6] Lockd: make it network namespace aware
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 31 Jan 2012 15:07:38 +0400
Message-ID: <20120131105712.14364.88911.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With this patch set Lockd will be able to handle lock requests from different
network namespaces separately.

Main ideas of the patch set are:

1) per-net Lockd users counter and resources.

2) nlmsvc_users counter become global one (equal to sum of all per-net
counters).

3) On lockd_up() call:
a) if nlmsvc_users if equal to 0, then lockd thread is started.
b) if current per-net counter equal to 0, then per-net resources are allocated
(lockd_up_net() function).
c) global and current net users counters are increased by one.

4) On lockd_down() call:
a) global and current net users counters are decreased by one.
b) if current per-net counter become equal to 0, then per-net resources are
allocated (lockd_down_net() function).
c) if nlmsvc_users become equal to 0, then lockd thread is stopped.

The following series consists of:

---

Stanislav Kinsbursky (6):
      Lockd: create permanent lockd sockets in current network namespace
      Lockd: pernet usage counter introduced
      Lockd: per-net up and down routines introduced
      LockD: make nlm hosts network namespace aware
      LockD: make NSM network namespace aware
      Lockd: shutdown NLM hosts in network namespace context


 fs/lockd/clntlock.c         |    3 +
 fs/lockd/host.c             |   42 ++++++++++++---
 fs/lockd/mon.c              |   13 +++--
 fs/lockd/netns.h            |   12 ++++
 fs/lockd/svc.c              |  117 +++++++++++++++++++++++++++++++++++++------
 fs/nfs/client.c             |    1 
 include/linux/lockd/bind.h  |    1 
 include/linux/lockd/lockd.h |    5 +-
 include/linux/sunrpc/svc.h  |    2 +
 net/sunrpc/svc.c            |    3 +
 10 files changed, 166 insertions(+), 33 deletions(-)
 create mode 100644 fs/lockd/netns.h

