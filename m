Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:21298 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab2C1PJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:03 -0400
Subject: [PATCH 0/8] NFSd: precursor and cleanup patch set
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:08:53 +0400
Message-ID: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set prepares ground for making NFSd export and expkey caches
allocated and registered per network namespace context.
Mainly, it just replaces hard-coded pointers with dereferenced everywhere
required.

The following series consists of:

---

Stanislav Kinsbursky (8):
      nfsd: use passed cache_detail pointer expkey_parse()
      nfsd: add link to owner cache detail to svc_export structure
      nfsd: use cache detail pointer from svc_export structure on cache put
      nfsd: use exp_put() for svc_export_cache put
      nfsd: pass svc_export_cache pointer as private data to "exports" seq file ops
      nfsd: use hash table from cache detail in nfsd export seq ops
      nfsd: pass pointer to export cache down to stack wherever possible.
      nfsd: pass pointer to expkey cache down to stack wherever possible.


 fs/nfsd/export.c            |  102 ++++++++++++++++++++++++-------------------
 fs/nfsd/nfsctl.c            |   11 ++++-
 fs/nfsd/nfsfh.c             |    2 -
 include/linux/nfsd/export.h |    3 +
 4 files changed, 71 insertions(+), 47 deletions(-)

