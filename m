Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:32224 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754308Ab2DKLNf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 07:13:35 -0400
Subject: [PATCH 0/4] nfsd: containerize export and expkey caches 
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 11 Apr 2012 15:13:07 +0400
Message-ID: <20120411111053.13840.66083.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set depends on "NFSd: precursor and cleanup patch set".

The following series consists of:

---

Stanislav Kinsbursky (4):
      nfsd: pass network context to export caches init/shutdown routines
      nfsd: make export cache allocated per network namespace context
      nfsd: make expkey cache allocated per network namespace context
      nfsd: allocate export and expkey caches in per-net operations.


 fs/nfsd/export.c               |   83 ++++++++++++++++++++++++++--------------
 fs/nfsd/netns.h                |    3 +
 fs/nfsd/nfsctl.c               |   32 ++++++++++++---
 fs/nfsd/nfssvc.c               |    2 -
 include/linux/nfsd/export.h    |   10 ++---
 include/linux/sunrpc/svcauth.h |    2 -
 net/sunrpc/svcauth_unix.c      |   13 ++----
 7 files changed, 90 insertions(+), 55 deletions(-)

