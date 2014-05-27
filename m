Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:58689 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751406AbaE0Itg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 04:49:36 -0400
Date: Tue, 27 May 2014 08:50:26 +0000 (UTC)
From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org,
        Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomas.rasanen@opinsys.fi>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <41011674.48947.1401180626967.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <454183694.48823.1401178027425.JavaMail.zimbra@opinsys.fi>
Subject: [PATCH] gssd: Fix allocated buffer size for the scraped acceptor
 name  in do_downcall
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


In commit 51fda07a "gssd: scrape the acceptor name out of the context"
the allocated buffer size is not large enough to hold the actual data
that is written to the buffer. This fixes the allocated buffer size.

Signed-off-by: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
---
 utils/gssd/gssd_proc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 69bb3c6..40ff188 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -696,7 +696,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
 		sizeof(context_token->length) + context_token->length +
-		acceptor->length;
+		sizeof(acceptor->length) + acceptor->length;
 	p = buf = malloc(buf_size);
 	if (!buf)
 		goto out_err;
-- 
1.7.10.4
