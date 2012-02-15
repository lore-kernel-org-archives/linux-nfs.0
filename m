Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33560 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab2BOONX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 09:13:23 -0500
Received: by bkcjm19 with SMTP id jm19so958634bkc.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 06:13:22 -0800 (PST)
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
To: trond.myklebust@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs41: Verify channel's attributes accordingly to RFC
Date: Wed, 15 Feb 2012 18:13:02 +0400
Message-Id: <1329315182-12051-1-git-send-email-gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From RFC5661, 18.36.3:

   ca_maxoperations:

         For the backchannel, the server MUST
         NOT change the value the client offers.  For the fore channel,
         the server MAY change the requested value.

   ca_maxrequests:

         For the backchannel, the server MUST NOT change the
         value the client offers.  For the fore channel, the server MAY
         change the requested value.

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5da5355..b144ec3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5197,7 +5197,7 @@ static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args
 	 */
 	if (rcvd->max_ops < sent->max_ops)
 		return -EINVAL;
-	if (rcvd->max_reqs == 0)
+	if (rcvd->max_reqs == 0 || rcvd->max_reqs > NFS4_MAX_SLOT_TABLE)
 		return -EINVAL;
 	return 0;
 }
@@ -5214,9 +5214,9 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
 	if (rcvd->max_resp_sz_cached > sent->max_resp_sz_cached)
 		return -EINVAL;
 	/* These would render the backchannel useless: */
-	if (rcvd->max_ops  == 0)
+	if (rcvd->max_ops != sent->max_ops)
 		return -EINVAL;
-	if (rcvd->max_reqs == 0)
+	if (rcvd->max_reqs != sent->max_reqs)
 		return -EINVAL;
 	return 0;
 }
-- 
1.7.5.4

