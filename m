From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 4/7] gssd: print full client directory being handled
Date: Wed, 29 Apr 2009 17:56:31 -0400
Message-ID: <20090429215631.25811.69164.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47715 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758390AbZD2V4b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:31 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

For convenience, add the full name of the upcall pipe being processed.
(Distinquishes between "normal" upcall, and a callback upcall.)

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 969d113..c1f0350 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -857,7 +857,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 	char			**dirname;
 	int			create_resp = -1;
 
-	printerr(1, "handling krb5 upcall\n");
+	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
 
 	token.length = 0;
 	token.value = NULL;
@@ -972,7 +972,7 @@ handle_spkm3_upcall(struct clnt_info *clp)
 	struct authgss_private_data pd;
 	gss_buffer_desc		token;
 
-	printerr(2, "handling spkm3 upcall\n");
+	printerr(2, "handling spkm3 upcall (%s)\n", clp->dirname);
 
 	token.length = 0;
 	token.value = NULL;

