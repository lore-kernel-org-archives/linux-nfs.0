Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:64580 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbaFZTNu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:13:50 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so3414165qgf.26
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 002/117] nfsd: fix return of nfs4_acl_write_who
Date: Thu, 26 Jun 2014 15:11:42 -0400
Message-Id: <1403810017-16062-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AFAICT, the only way to hit this error is to pass this function a bogus
"who" value. In that case, we probably don't want to return -1 as that
could get sent back to the client. Turn this into nfserr_serverfault,
which is a more appropriate error for a server bug like this.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4acl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index d714156a19fd..b0cf00d3ee7d 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -935,5 +935,5 @@ __be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
 		return 0;
 	}
 	WARN_ON_ONCE(1);
-	return -1;
+	return nfserr_serverfault;
 }
-- 
1.9.3

