Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53687 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab2JAR12 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:27:28 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TIjmB-0007fJ-TB
	for linux-nfs@vger.kernel.org; Mon, 01 Oct 2012 13:27:27 -0400
Date: Mon, 1 Oct 2012 13:27:27 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] fix bind_conn_to_session xdr comment
Message-ID: <20121001172727.GA28616@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a trivial patch, queued up for 3.7.  (And I think returning 0
here is all we need to do to cleanly not support rdma, which closes one
of the minor 4.1 todo items.)

--b.

commit 6e67b5d1840b5788875ad561f2e76a1bf5facc86
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Sep 13 09:49:43 2012 -0400

    nfsd4: fix bind_conn_to_session xdr comment
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6322df3..fd548d1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2659,7 +2659,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 8);
 		WRITEMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 		WRITE32(bcts->dir);
-		/* XXX: ? */
+		/* Sorry, we do not yet support RDMA over 4.1: */
 		WRITE32(0);
 		ADJUST_ARGS();
 	}
