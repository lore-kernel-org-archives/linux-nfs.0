Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE18C001DE
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Aug 2023 07:35:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231322AbjHBHfh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Aug 2023 03:35:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39998 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232869AbjHBHff (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Aug 2023 03:35:35 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0180F1BF1
        for <linux-nfs@vger.kernel.org>; Wed,  2 Aug 2023 00:35:04 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id B909E1F8A4;
        Wed,  2 Aug 2023 07:35:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1690961703; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=KEew3uv1dC1rzT83vlUoIJ+Jv8LW47z1hghGXJETLys=;
        b=fqRLDis8Og/JfvsWNPvlWyZqySa9C4RRUZKtXuT12z+K5L2vYBYrNY++RteJ+u8XYb+Zgj
        VlmUYicYDBsRGu9SEYKjyUstOKSogaB7vsyL0rPKAa0oepRq+8qO8R1k+JpsdBN0Own4q7
        vTrdYGk+iKZys3mbQvX97MR3sfsJjGE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1690961703;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=KEew3uv1dC1rzT83vlUoIJ+Jv8LW47z1hghGXJETLys=;
        b=ANDGXTqX+OXP3nz3sgWtTxNy20YqkznGnkLdszvOrwS4z1xUp8SZJQoG5qFh2Wkw/xdAMI
        G1mChXWsffRHWeCA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 7B0B513909;
        Wed,  2 Aug 2023 07:35:02 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id KTIrCCYHymTrIwAAMHmgww
        (envelope-from <neilb@suse.de>); Wed, 02 Aug 2023 07:35:02 +0000
From:   NeilBrown <neilb@suse.de>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] SUNRPC: move all of xprt handling into svc_xprt_handle()
Date:   Wed,  2 Aug 2023 17:34:38 +1000
Message-Id: <20230802073443.17965-2-neilb@suse.de>
X-Mailer: git-send-email 2.40.1
In-Reply-To: <20230802073443.17965-1-neilb@suse.de>
References: <20230802073443.17965-1-neilb@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

svc_xprt_handle() does lots of things itself, but leaves some to the
caller - svc_recv().  This isn't elegant.

Move that code out of svc_recv() into svc_xprt_handle()

Remove the calls to svc_xprt_release() from svc_send() and svc_drop()
(the two possible final steps in svc_process()) and from svc_recv() (in
the case where svc_process() wasn't called) into svc_xprt_handle().

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/svc_xprt.c | 53 ++++++++++++++++---------------------------
 1 file changed, 20 insertions(+), 33 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4cfe9640df48..60759647fee4 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -785,7 +785,7 @@ static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt
 	svc_xprt_received(newxpt);
 }
 
-static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
+static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 {
 	struct svc_serv *serv = rqstp->rq_server;
 	int len = 0;
@@ -826,11 +826,26 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+		if (len <= 0)
+			goto out;
+
+		trace_svc_xdr_recvfrom(&rqstp->rq_arg);
+
+		clear_bit(XPT_OLD, &xprt->xpt_flags);
+
+		rqstp->rq_chandle.defer = svc_defer;
+
+		if (serv->sv_stats)
+			serv->sv_stats->netcnt++;
+		percpu_counter_inc(&rqstp->rq_pool->sp_messages_arrived);
+		rqstp->rq_stime = ktime_get();
+		svc_process(rqstp);
 	} else
 		svc_xprt_received(xprt);
 
 out:
-	return len;
+	rqstp->rq_res.len = 0;
+	svc_xprt_release(rqstp);
 }
 
 /**
@@ -844,11 +859,9 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 void svc_recv(struct svc_rqst *rqstp)
 {
 	struct svc_xprt		*xprt = NULL;
-	struct svc_serv		*serv = rqstp->rq_server;
-	int			len;
 
 	if (!svc_alloc_arg(rqstp))
-		goto out;
+		return;
 
 	try_to_freeze();
 	cond_resched();
@@ -856,31 +869,9 @@ void svc_recv(struct svc_rqst *rqstp)
 		goto out;
 
 	xprt = svc_get_next_xprt(rqstp);
-	if (!xprt)
-		goto out;
-
-	len = svc_handle_xprt(rqstp, xprt);
-
-	/* No data, incomplete (TCP) read, or accept() */
-	if (len <= 0)
-		goto out_release;
-
-	trace_svc_xdr_recvfrom(&rqstp->rq_arg);
-
-	clear_bit(XPT_OLD, &xprt->xpt_flags);
-
-	rqstp->rq_chandle.defer = svc_defer;
-
-	if (serv->sv_stats)
-		serv->sv_stats->netcnt++;
-	percpu_counter_inc(&rqstp->rq_pool->sp_messages_arrived);
-	rqstp->rq_stime = ktime_get();
-	svc_process(rqstp);
+	if (xprt)
+		svc_handle_xprt(rqstp, xprt);
 out:
-	return;
-out_release:
-	rqstp->rq_res.len = 0;
-	svc_xprt_release(rqstp);
 }
 EXPORT_SYMBOL_GPL(svc_recv);
 
@@ -890,7 +881,6 @@ EXPORT_SYMBOL_GPL(svc_recv);
 void svc_drop(struct svc_rqst *rqstp)
 {
 	trace_svc_drop(rqstp);
-	svc_xprt_release(rqstp);
 }
 EXPORT_SYMBOL_GPL(svc_drop);
 
@@ -906,8 +896,6 @@ void svc_send(struct svc_rqst *rqstp)
 	int status;
 
 	xprt = rqstp->rq_xprt;
-	if (!xprt)
-		return;
 
 	/* calculate over-all length */
 	xb = &rqstp->rq_res;
@@ -920,7 +908,6 @@ void svc_send(struct svc_rqst *rqstp)
 	status = xprt->xpt_ops->xpo_sendto(rqstp);
 
 	trace_svc_send(rqstp, status);
-	svc_xprt_release(rqstp);
 }
 
 /*
-- 
2.40.1

