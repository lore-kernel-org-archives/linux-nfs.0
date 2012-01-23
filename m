Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24996 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab2AWR0U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 12:26:20 -0500
Subject: [PATCH 0/4] NFS: make internal list network namespace aware
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 23 Jan 2012 21:25:56 +0400
Message-ID: <20120123171404.29637.19810.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set moves static internal lists of NFS clients and NFS servers, as
well as static IDR's structure and lock, protecting all that stuff, to network
namespace context.

The following series consists of:

---

Stanislav Kinsbursky (4):
      NFS: make nfs_client_list per net ns
      NFS: make nfs_volume_list per net ns
      NFS: make cb_ident_idr per net ns
      NFS: make nfs_client_lock per net ns


 fs/nfs/callback_xdr.c |    2 -
 fs/nfs/client.c       |  137 +++++++++++++++++++++++++++++++------------------
 fs/nfs/idmap.c        |    9 +--
 fs/nfs/inode.c        |    3 +
 fs/nfs/internal.h     |    9 +--
 fs/nfs/netns.h        |    6 ++
 6 files changed, 104 insertions(+), 62 deletions(-)

