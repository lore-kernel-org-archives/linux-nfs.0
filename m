Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D201CC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 05:59:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 974F520675
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 05:59:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726426AbeLQF7W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 00:59:22 -0500
Received: from mail.windriver.com ([147.11.1.11]:53516 "EHLO
        mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726323AbeLQF7W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 00:59:22 -0500
Received: from ALA-HCB.corp.ad.wrs.com ([147.11.189.41])
        by mail.windriver.com (8.15.2/8.15.1) with ESMTPS id wBH5xH2k000352
        (version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
        for <linux-nfs@vger.kernel.org>; Sun, 16 Dec 2018 21:59:17 -0800 (PST)
Received: from pek-lpg-core2.corp.ad.wrs.com (128.224.153.41) by
 ALA-HCB.corp.ad.wrs.com (147.11.189.41) with Microsoft SMTP Server id
 14.3.408.0; Sun, 16 Dec 2018 21:59:16 -0800
From:   <mingli.yu@windriver.com>
To:     <linux-nfs@vger.kernel.org>
Subject: [PATCH] Makefile.am: update the path of libnfs.a
Date:   Mon, 17 Dec 2018 13:59:15 +0800
Message-ID: <1545026355-401179-1-git-send-email-mingli.yu@windriver.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Mingli Yu <Mingli.Yu@windriver.com>

The libnfs.a is under ../support/nfs/.libs/ now,
update the reference path accordingly to fix below
build error when run "make -C tests statdb_dump":
| make: *** No rule to make target '../support/nfs/libnfs.a', needed by 'statdb_dump'.  Stop.

And below error when run "make -C tests/nsm_client nsm_client"
| make: *** No rule to make target '../../support/nfs/libnfs.a', needed by 'nsm_client'.  Stop.

Signed-off-by: Mingli Yu <Mingli.Yu@windriver.com>
---
 tests/Makefile.am            | 2 +-
 tests/nsm_client/Makefile.am | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tests/Makefile.am b/tests/Makefile.am
index 1f96264..74aa629 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -3,7 +3,7 @@
 check_PROGRAMS = statdb_dump
 statdb_dump_SOURCES = statdb_dump.c
 
-statdb_dump_LDADD = ../support/nfs/libnfs.a \
+statdb_dump_LDADD = ../support/nfs/.libs/libnfs.a \
 		    ../support/nsm/libnsm.a $(LIBCAP)
 
 SUBDIRS = nsm_client
diff --git a/tests/nsm_client/Makefile.am b/tests/nsm_client/Makefile.am
index a8fc131..43db9c2 100644
--- a/tests/nsm_client/Makefile.am
+++ b/tests/nsm_client/Makefile.am
@@ -13,7 +13,7 @@ check_PROGRAMS	= nsm_client
 nsm_client_SOURCES = $(GENFILES) nsm_client.c
 
 BUILT_SOURCES = $(GENFILES)
-nsm_client_LDADD = ../../support/nfs/libnfs.a \
+nsm_client_LDADD = ../../support/nfs/.libs/libnfs.a \
 		   ../../support/nsm/libnsm.a $(LIBCAP) $(LIBTIRPC)
 
 if CONFIG_RPCGEN
-- 
2.7.4

