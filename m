Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:32202 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755195Ab2HTOBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 10:01:52 -0400
Subject: [PATCH v4 00/10] NFS: callback threads containerization
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 20 Aug 2012 17:59:59 +0400
Message-ID: <20120820134734.17404.53946.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4: rebased on trondmy/linux-next

Hi, Trond.
This patch set is the last significant part of client containerization.
It's pending for a long time already. And I really feel, that it's ready for
inclusion.
Without this patch set per-net callback resources management is broken.
Hoping you can take it for next kernel.

The following series implements...

---

Stanislav Kinsbursky (10):
      NFS: pass net to nfs_callback_down()
      NFS: callback service creation function introduced
      NFS: move per-net callback thread initialization to nfs_callback_up_net()
      NFS: callback up - transport backchannel cleanup
      NFS: callback service start function introduced
      NFS: callback up - users counting cleanup
      NFS: make nfs_callback_tcpport per network context
      NFS: make nfs_callback_tcpport6 per network context
      NFS: callback per-net usage counting introduced
      NFS: add debug messages to callback down function


 fs/nfs/callback.c   |  302 ++++++++++++++++++++++++++++++++++-----------------
 fs/nfs/callback.h   |    4 -
 fs/nfs/netns.h      |    3 +
 fs/nfs/nfs4client.c |    2 
 fs/nfs/nfs4state.c  |    6 +
 5 files changed, 211 insertions(+), 106 deletions(-)

