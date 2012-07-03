Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19653 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181Ab2GCQWn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 12:22:43 -0400
Subject: [PATCH v3 00/11] Series short description
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 03 Jul 2012 20:19:23 +0400
Message-ID: <20120703161844.11911.92996.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3: Rebased on Bruce's tree, "for-3.6" branch

v2: Rebased on Bruce's tree, "for-3.5" branch

This patch set depeneds on "SUNRPC: separate per-net data creation from
service
creation" patch set sent earlier.

The following series implements...

---

Stanislav Kinsbursky (11):
      NFS: pass net to nfs_callback_down()
      NFS: callback service creation function introduced
      NFS: move per-net callback thread initialization to nfs_callback_up_net()
      NFS: callback up - transport backchannel cleanup
      NFS: callback service start function introduced
      NFS: callback up - users counting cleanup
      NFS: make nfs_callback_tcpport per network context
      NFS: make nfs_callback_tcpport6 per network context
      NFS; callback per-net usage counting introduced
      NFS: add debug messages to callback down function
      NFS: get net after idr allocation


 fs/nfs/callback.c  |  288 ++++++++++++++++++++++++++++++++++------------------
 fs/nfs/callback.h  |    4 -
 fs/nfs/client.c    |    5 +
 fs/nfs/netns.h     |    3 +
 fs/nfs/nfs4state.c |    6 +
 5 files changed, 202 insertions(+), 104 deletions(-)

