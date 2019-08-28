Return-Path: <SRS0=/9w8=WY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B788C3A5A1
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Aug 2019 07:10:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFFD220828
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Aug 2019 07:10:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="eGyMzw1g";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="MsoIXtvt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726449AbfH1HKn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Aug 2019 03:10:43 -0400
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48371 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726446AbfH1HKn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Aug 2019 03:10:43 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 76F7822138
        for <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2019 03:10:42 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute1.internal (MEProxy); Wed, 28 Aug 2019 03:10:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=from
        :to:cc:subject:date:message-id:in-reply-to:references
        :mime-version:content-transfer-encoding; s=fm1; bh=KlSKOXKRHQHQw
        +s21VcvqJBsmiq3FmwE2ig1q9YZLCs=; b=eGyMzw1gtb0Wj/78kVXqnBwKPa+WO
        SO2sbKMGdG6ORMH8e6l9fr+27+aFAXdNEN8wPLUjTdtSu4KShJ0hCXwqNrA7pJ8E
        HIWuUvZ92+TgWHKKx/TVXPlVw2I7QrwfrbBzXH3LmJwVmNEOOmB55yKx2lVAcQ0k
        m/egJnoGmDc+V5cHEghaj70dvuuk7oIqhWgirqBmIWTWqY8+QjFQPzUNX7VHlHzU
        89aArYye9atzmBswzlMB28Kg0MA5YvyrqKy45Z1Gq+fpySEgeTpjokzzL2psNXTo
        Q+PO+Ypb7IDVpesn0pNcO15DLXAjx99tGheOn/UJWcLAQzx3eN49BTZaw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:date:from
        :in-reply-to:message-id:mime-version:references:subject:to
        :x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
        fm3; bh=KlSKOXKRHQHQw+s21VcvqJBsmiq3FmwE2ig1q9YZLCs=; b=MsoIXtvt
        4uT1v/TIOCjL/FPMwPftXffVwiSm2mD+y2VDhGg00jiyxF5XmTFhR5chV70j6IBr
        UVDsTXrPByOkP0hhlH+m05CnDqiMaoMY3ORdIXPUfH3unF8OpkypXbfOjBL76PlI
        vk9XGj/z8GcZFG0RdLT1UdWFbu904f+ketBesVC/xAo4Xv4o9ptiS6twrcs1cDDr
        nM71omhRBcDu6/kuz2bVoUcqQL8ekde7aC1FPfFX2JnuiptD63A9g7Ksc5K0u8Ik
        nb/LNRBCauT4p6secgp/faMwBa4eMafBfu6sWqIWngkSvtPIbugFcrnfDndr2jfN
        K3EVfgA7mCy2DQ==
X-ME-Sender: <xms:8ihmXfZzkR7kBI00Wc0UM1N75vZTBW29Jc1GJfkU4YQfNc1pVPkZCw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrudehledgudduiecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecunecujfgurhephffvufffkffojghfggfgsedtke
    ertdertddtnecuhfhrohhmpefrrghtrhhitghkucfuthgvihhnhhgrrhguthcuoehpshes
    phhkshdrihhmqeenucfkphepjeejrdduuddrudehhedrvdehheenucfrrghrrghmpehmrg
    hilhhfrhhomhepphhssehpkhhsrdhimhenucevlhhushhtvghrufhiiigvpeeg
X-ME-Proxy: <xmx:8ihmXSpZCo595K8N83-CUz9Pn3bvx_72-DWDYGzJMfyxmp8xjxvxpQ>
    <xmx:8ihmXc-f5iYceG5VBx6jGdmr64rJMtEC04jSC7al51djZSvWnUwxRw>
    <xmx:8ihmXZ8Omaf-8pq7bFIenSt54jcxYiWkivBKgLPMYSGGJUWh5C2ZXg>
    <xmx:8ihmXQxqMV-Sv2zjNYz_CiEMMxrIc6QEP0mYp5TjlpI696MN2YY4wQ>
Received: from NSJAIL (x4d0b9bff.dyn.telefonica.de [77.11.155.255])
        by mail.messagingengine.com (Postfix) with ESMTPA id BFFC380059
        for <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2019 03:10:41 -0400 (EDT)
Received: from localhost (10.192.0.11 [10.192.0.11])
        by NSJAIL (OpenSMTPD) with ESMTPSA id a17a34ec (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO);
        Wed, 28 Aug 2019 07:10:41 +0000 (UTC)
From:   Patrick Steinhardt <ps@pks.im>
To:     linux-nfs@vger.kernel.org
Cc:     Patrick Steinhardt <ps@pks.im>
Subject: [PATCH 5/6] nfsd_path: Include missing header for `struct stat`
Date:   Wed, 28 Aug 2019 09:10:16 +0200
Message-Id: <c4efa52412e2ff0e9079bf88ab94d8e366bf8f8f.1566976047.git.ps@pks.im>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <cover.1566976047.git.ps@pks.im>
References: <cover.1566976047.git.ps@pks.im>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The header "nfsd_path.h" uses `struct stat` in its function signatures,
but doesn't include the <sys/stat.h> header. This may cause compiler
warnings if a compilation unit includes "nfsd_path.h" while not
transitively including <sys/stat.h>.

Fix the potential warning by including <sys/stat.h> in the header.

Signed-off-by: Patrick Steinhardt <ps@pks.im>
---
 support/include/nfsd_path.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/support/include/nfsd_path.h b/support/include/nfsd_path.h
index ca2570a9..b42416bb 100644
--- a/support/include/nfsd_path.h
+++ b/support/include/nfsd_path.h
@@ -4,6 +4,8 @@
 #ifndef NFSD_PATH_H
 #define NFSD_PATH_H
 
+#include <sys/stat.h>
+
 void 		nfsd_path_init(void);
 
 const char *	nfsd_path_nfsd_rootdir(void);
-- 
2.23.0

