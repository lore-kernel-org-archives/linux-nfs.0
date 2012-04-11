Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9477 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813Ab2DKNdG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 09:33:06 -0400
Subject: [PATCH 0/4] nfsd: containerize id-to-name and name-to-id caches
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 11 Apr 2012 17:32:37 +0400
Message-ID: <20120411133139.26953.85254.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set depends on "nfsd: remove hard-coded dereferences to name-to-id
and id-to-name caches" patch.

The following series consists of:

---

Stanislav Kinsbursky (4):
      nfsd: pass network context to idmap init/exit functions
      nfsd: make id-to-name cache allocated per network namespace context
      nfsd: make name-to-id cache allocated per network namespace context
      nfsd: allocate id-to-name and name-to-id caches in per-net operations.


 fs/nfsd/idmap.h     |    8 +++----
 fs/nfsd/netns.h     |    3 +++
 fs/nfsd/nfs4idmap.c |   59 ++++++++++++++++++++++++++++++++++-----------------
 fs/nfsd/nfsctl.c    |   14 ++++++------
 4 files changed, 53 insertions(+), 31 deletions(-)

