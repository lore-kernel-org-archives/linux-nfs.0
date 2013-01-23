Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab3AWWzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:40 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMte7k022604
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:40 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/7] nfsd4: reserve space for integrity/privacy
Date: Wed, 23 Jan 2013 17:55:32 -0500
Message-Id: <1358981738-5649-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If a compound reply comes too close to filling up this first page, the
gss code may end up dropping it, resulting in a client hang in the
krb5i/krb5p case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9d1c5db..f45096e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1202,7 +1202,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->tagp = resp->p;
 	/* reserve space for: taglen, tag, and opcnt */
 	resp->p += 2 + XDR_QUADLEN(args->taglen);
-	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
+	/*
+	 * In the integrity and privacy cases we need to reserve a
+	 * little extra space for a tail (see svcauth_gss_wrap_resp_priv
+	 * and svcauth_gss_wrap_resp_integ):
+	 */
+	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE
+						- 2 * RPC_MAX_AUTH_SIZE;
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
 	resp->opcnt = 0;
-- 
1.7.11.7

