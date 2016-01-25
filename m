Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33321 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbcAYOJy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 09:09:54 -0500
Received: by mail-io0-f178.google.com with SMTP id q21so152632358iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2016 06:09:53 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4.x: Enforce the ca_maxresponsesize_cached on the back channel
Date: Mon, 25 Jan 2016 09:09:14 -0500
Message-Id: <1453730956-5325-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have no duplicate reply cache, so we always set the back channel
ca_maxresponsesize_cached to zero when negotiating the session.
That means we should always error out as soon as we see the server
set args->csa_cachethis.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e0844fdbd9ac..345df6309017 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -381,9 +381,8 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 		if (args->csa_cachethis == 0)
 			return htonl(NFS4ERR_RETRY_UNCACHED_REP);
 
-		/* The ca_maxresponsesize_cached is 0 with no DRC */
-		else if (args->csa_cachethis == 1)
-			return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);
+		/* Liar! We never allowed you to set csa_cachethis != 0 */
+		return htonl(NFS4ERR_SEQ_FALSE_RETRY);
 	}
 
 	/* Wraparound */
@@ -500,6 +499,10 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 
 	cps->slotid = args->csa_slotid;
 
+	/* The ca_maxresponsesize_cached is 0 with no DRC */
+	if (args->csa_cachethis != 0)
+		return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);
+
 	/*
 	 * Check for pending referring calls.  If a match is found, a
 	 * related callback was received before the response to the original
-- 
2.5.0

