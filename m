Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44214 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755379Ab2AYNrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 08:47:24 -0500
Subject: [PATCH 0/4] SUNRPC: service release in network namespace context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 25 Jan 2012 17:47:00 +0400
Message-ID: <20120125134132.13662.83447.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set is the final step towards to making LockD network namespace
aware.
I can't prove, that this patch set is enough for NFSd (just haven't try), by
Lockd works fine and patches for it will be send soon.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: clear svc pools lists helper introduced
      SUNRPC: clear svc transports lists helper introduced
      SUNRPC: service destruction in network namespace context
      SUNRPC: service shutdown function in network namespace context introduced


 include/linux/sunrpc/svcsock.h |    2 +-
 net/sunrpc/svc.c               |   36 +++++++++++++++++++++-----------
 net/sunrpc/svc_xprt.c          |   45 ++++++++++++++++++++++++++++------------
 3 files changed, 56 insertions(+), 27 deletions(-)

