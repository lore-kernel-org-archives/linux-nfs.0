Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33762 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab3H3VnF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Aug 2013 17:43:05 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1VFWTA-000084-Fb
	for linux-nfs@vger.kernel.org; Fri, 30 Aug 2013 17:43:04 -0400
Date: Fri, 30 Aug 2013 17:43:04 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: nfsd4_create_clid_dir prints uninitialized data
Message-ID: <20130830214304.GB32015@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Take the easy way out and just remove the printk.

Reported-by: David Howells <dhowells@redhat.com>
---
 fs/nfsd/nfs4recover.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 105a3b0..e0a65a9 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -173,8 +173,6 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	int status;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
-
 	if (test_and_set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
 	if (!nn->rec_file)
-- 
1.7.9.5

