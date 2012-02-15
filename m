Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36997 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898Ab2BOPjV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:39:21 -0500
Received: by bkcjm19 with SMTP id jm19so1052711bkc.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 07:39:20 -0800 (PST)
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
To: trond.myklebust@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs41: Verify channel's attributes accordingly to RFC v2
Date: Wed, 15 Feb 2012 19:38:25 +0400
Message-Id: <1329320305-16111-1-git-send-email-gusev.vitaliy@nexenta.com>
In-Reply-To: <1329315756.3364.4.camel@lade.trondhjem.org>
References: <1329315756.3364.4.camel@lade.trondhjem.org>
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
 fs/nfs/nfs4proc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5da5355..233ed26 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5199,6 +5199,8 @@ static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args
 		return -EINVAL;
 	if (rcvd->max_reqs == 0)
 		return -EINVAL;
+	if (rcvd->max_reqs > NFS4_MAX_SLOT_TABLE)
+		rcvd->max_reqs = NFS4_MAX_SLOT_TABLE;
 	return 0;
 }
 
@@ -5214,9 +5216,9 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
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

