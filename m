Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:42184 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757845Ab2DZPzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 11:55:06 -0400
Subject: [PATCH 00/10] NFS: callback threads containerization
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 26 Apr 2012 19:54:51 +0400
Message-ID: <20120426155250.3763.98748.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This aptch set depened on "SUNRPC: separate per-net data creation from service
creation" patch set sent earlier.

The following series consists of:

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
      NFS; callback per-net usage counting introduced
      NFS: add debug messages to callback down function


 fs/nfs/callback.c  |  288 ++++++++++++++++++++++++++++++++++------------------
 fs/nfs/callback.h  |    4 -
 fs/nfs/client.c    |    2 
 fs/nfs/netns.h     |    3 +
 fs/nfs/nfs4state.c |    7 +
 5 files changed, 201 insertions(+), 103 deletions(-)

