Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29612 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754473Ab2JBKSp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 06:18:45 -0400
Subject: [PATCH 0/5] nfs: few cleanup patches inspired by sparse
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 02 Oct 2012 14:18:43 +0400
Message-ID: <20121002101649.15507.50466.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First two patched fixes problems reported by Fengguang Wu
<fengguang.wu@intel.com>.

The following series implements...

---

Stanislav Kinsbursky (5):
      nfs: include NFSv4 header in netns.h
      nfs: declare nfs_callback_tcp_port in header
      nfs: declare nfs_xdev_mount as static
      nfs: include nfs4_fh.h in nfs4sysctl.c
      nfs: include internah.h in getroot.h


 fs/nfs/callback.h   |    1 +
 fs/nfs/getroot.c    |    2 ++
 fs/nfs/netns.h      |    1 +
 fs/nfs/nfs4sysctl.c |    1 +
 fs/nfs/super.c      |    2 +-
 5 files changed, 6 insertions(+), 1 deletions(-)

