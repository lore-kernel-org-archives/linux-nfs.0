Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33827 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322Ab0ATMWE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jan 2010 07:22:04 -0500
Message-ID: <4B56F565.7080104@suse.de>
Date: Wed, 20 Jan 2010 17:51:57 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: trond.myklebust@netapp.com, David Howells <dhowells@redhat.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC][PATCH] nfs: don't assume fscache_acquire_cookie will always
 succeed
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We seem to be assuming fscache_acquire_cookie will always succeed and will
obtain a valid cookie. But, under low memory conditions kmem_cache_alloc
could fail and that would leave nfsi->fscache being set to NULL.

This could lead to a possibility of a page with PG_fscache flag set but
cookie not set(i.e. NULL). This inconsistency could trigger a kernel BUG in
nfs_fscache_release_page() and other places as we do BUG_ON(!cookie), I think.

I'm aware that there are other places where we would need such checks, but
wanted to validate this patch before getting on to them.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---

 fs/nfs/client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee77713..7776e8a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -155,6 +155,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 		clp->cl_machine_cred = cred;
 
 	nfs_fscache_get_client_cookie(clp);
+	if (!clp->fscache)
+		goto error_cleanup;
 
 	return clp;
 
-- 
Suresh Jayaraman
