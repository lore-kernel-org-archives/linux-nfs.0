Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C34DC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 17:35:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB6AB20663
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 17:35:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="HVldFNbB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB6AB20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=desy.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726346AbeK0EaQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 26 Nov 2018 23:30:16 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:37837 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726253AbeK0EaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Nov 2018 23:30:16 -0500
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 4E99A280739
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2018 18:35:27 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 4E99A280739
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1543253727; bh=PV+MD0T7zt7uZs55cMpe6+RAYSHMeJjoJoOIt9pP0lY=;
        h=From:To:Cc:Subject:Date:From;
        b=HVldFNbBs76INVY4+Se7LWNaDVZfvPdiBbZeYEZaftDSIHrL00CGSmPyGx0tx41NL
         UKE/8s8vVilCsT1V6KWcGCHYALB31cBEnBXh7aVcgK0eTX/GWMVvLe2TDJnPAPbzIK
         WflfNilhHjZ0msHIPk88r2DA++l1WdYVuj3mwWrk=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [IPv6:2001:638:700:1038::1:82])
        by smtp-buf-2.desy.de (Postfix) with ESMTP id 47B171A03D7;
        Mon, 26 Nov 2018 18:35:27 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from anahit.desy.de (anahit.desy.de [131.169.185.68])
        by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id 1824B3E901;
        Mon, 26 Nov 2018 18:35:27 +0100 (MET)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     trondmy@hammerspace.com, Anna.Schumaker@Netapp.com
Cc:     linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/1] flexfiles: enforce per-mirror stateid only for v4 DSes
Date:   Mon, 26 Nov 2018 18:35:14 +0100
Message-Id: <20181126173514.11350-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.17.2
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since commit bb21ce0ad227 we always enforce per-mirror stateid.
However, this makes sense only for v4+ servers.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 74b36ed883ca..310d7500f665 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1733,7 +1733,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (fh)
 		hdr->args.fh = fh;
 
-	if (!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
+	if (vers == 4 &&
+		!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
 		goto out_failed;
 
 	/*
@@ -1798,7 +1799,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (fh)
 		hdr->args.fh = fh;
 
-	if (!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
+	if (vers == 4 &&
+		!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
 		goto out_failed;
 
 	/*
-- 
2.17.2

