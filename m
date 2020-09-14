Return-Path: <SRS0=tdDw=CX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97EA4C43461
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 17:17:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6A297206B7
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 17:17:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725984AbgINRRj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Sep 2020 13:17:39 -0400
Received: from shelob.surriel.com ([96.67.55.147]:47246 "EHLO
        shelob.surriel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726045AbgINRQo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2020 13:16:44 -0400
X-Greylist: delayed 558 seconds by postgrey-1.27 at vger.kernel.org; Mon, 14 Sep 2020 13:16:43 EDT
Received: from [2603:3005:d05:2b00:6e0b:84ff:fee2:98bb] (helo=imladris.surriel.com)
        by shelob.surriel.com with esmtpsa  (TLS1.2) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.94)
        (envelope-from <riel@shelob.surriel.com>)
        id 1kHrwn-0006gu-1u; Mon, 14 Sep 2020 13:07:21 -0400
Date:   Mon, 14 Sep 2020 13:07:19 -0400
From:   Rik van Riel <riel@surriel.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
Subject: [PATCH] silence nfscache allocation warnings with kvzalloc
Message-ID: <20200914130719.247cccb0@imladris.surriel.com>
X-Mailer: Claws Mail 3.17.6 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

silence nfscache allocation warnings with kvzalloc

Currently nfsd_reply_cache_init attempts hash table allocation through
kmalloc, and manually falls back to vzalloc if that fails. This makes
the code a little larger than needed, and creates a significant amount
of serial console spam if you have enough systems.

Switching to kvzalloc gets rid of the allocation warnings, and makes
the code a little cleaner too as a side effect.

Freeing of nn->drc_hashtbl is already done using kvfree currently.

Signed-off-by: Rik van Riel <riel@surriel.com>
---
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 96352ab7bd81..5125b5ef25b6 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -164,14 +164,10 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 	if (!nn->drc_slab)
 		goto out_shrinker;
 
-	nn->drc_hashtbl = kcalloc(hashsize,
-				sizeof(*nn->drc_hashtbl), GFP_KERNEL);
-	if (!nn->drc_hashtbl) {
-		nn->drc_hashtbl = vzalloc(array_size(hashsize,
-						 sizeof(*nn->drc_hashtbl)));
-		if (!nn->drc_hashtbl)
-			goto out_slab;
-	}
+	nn->drc_hashtbl = kvzalloc(array_size(hashsize,
+				   sizeof(*nn->drc_hashtbl)), GFP_KERNEL);
+	if (!nn->drc_hashtbl)
+		goto out_slab;
 
 	for (i = 0; i < hashsize; i++) {
 		INIT_LIST_HEAD(&nn->drc_hashtbl[i].lru_head);

