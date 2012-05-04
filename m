Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:34963 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125Ab2EDRk1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2012 13:40:27 -0400
Date: Fri, 4 May 2012 20:40:17 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] NFS: silence Sparse warning about a non-ANSI declaration
Message-ID: <20120504174017.GB18827@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sparse complains because without the "void", it means that the function
takes a variable number of arguments.

fs/nfs/read.c:38:43: warning: non-ANSI function declaration of function
	'nfs_readhdr_alloc'

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 37c9eb2..f23cf25 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -35,7 +35,7 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
-struct nfs_read_header *nfs_readhdr_alloc()
+struct nfs_read_header *nfs_readhdr_alloc(void)
 {
 	struct nfs_read_header *rhdr;
 
