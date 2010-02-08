Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389Ab0BHPCX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 10:02:23 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/2] Fix for the nfs_release_page() bug
To: linux-nfs@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, Suresh Jayaraman <sjayaraman@suse.de>
Date: Mon, 08 Feb 2010 09:59:42 -0500
Message-ID: <20100208145942.17581.81775.stgit@localhost.localdomain>
In-Reply-To: <1265635435.5235.4.camel@localhost>
References: <1265635435.5235.4.camel@localhost>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are the two proposed patches. The first is needed for both mainline
and stable@kernel.org. The second, being a cleanup, will be send to
mainline only.

Cheers
  Trond

---

Trond Myklebust (2):
      NFS: Remove a redundant check for PageFsCache in nfs_migrate_page()
      NFS: Fix a bug in nfs_fscache_release_page()


 fs/nfs/fscache.c |    9 ++++-----
 fs/nfs/write.c   |    3 +--
 2 files changed, 5 insertions(+), 7 deletions(-)

-- 
Signature
