Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:26712 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753692Ab2AaKJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 05:09:17 -0500
Subject: [PATCH v2 0/4] SUNRPC: service release in network namespace context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 31 Jan 2012 14:08:50 +0400
Message-ID: <20120131100625.4342.34539.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2: Added comment to BUG_ON's in svc_destroy() to make code looks clearer.

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
 net/sunrpc/svc.c               |   38 ++++++++++++++++++++++++----------
 net/sunrpc/svc_xprt.c          |   45 ++++++++++++++++++++++++++++------------
 3 files changed, 59 insertions(+), 26 deletions(-)

