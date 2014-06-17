Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:35174 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbaFQKOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 06:14:14 -0400
Received: by mail-qc0-f178.google.com with SMTP id c9so9486066qcz.37
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 03:14:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix return of nfs4_acl_write_who
Date: Tue, 17 Jun 2014 06:14:08 -0400
Message-Id: <1403000048-31245-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AFAICT, the only way to hit this error is to pass this function a bogus
"who" value. In that case, we probably don't want to return -1 as that
could get sent back to the client. Turn this into nfserr_serverfault,
which is a more appropriate error for a server bug like this.

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

