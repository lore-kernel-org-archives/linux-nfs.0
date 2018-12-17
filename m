Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61F27C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 07:43:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 33DFD2084D
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 07:43:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726496AbeLQHnU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 02:43:20 -0500
Received: from mail.windriver.com ([147.11.1.11]:61824 "EHLO
        mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726323AbeLQHnU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 02:43:20 -0500
Received: from ALA-HCA.corp.ad.wrs.com ([147.11.189.40])
        by mail.windriver.com (8.15.2/8.15.1) with ESMTPS id wBH7hEV7011806
        (version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
        for <linux-nfs@vger.kernel.org>; Sun, 16 Dec 2018 23:43:15 -0800 (PST)
Received: from pek-lpg-core2.corp.ad.wrs.com (128.224.153.41) by
 ALA-HCA.corp.ad.wrs.com (147.11.189.40) with Microsoft SMTP Server id
 14.3.408.0; Sun, 16 Dec 2018 23:43:14 -0800
From:   <mingli.yu@windriver.com>
To:     <linux-nfs@vger.kernel.org>
Subject: [PATCH] configure.ac: Do not fatalize -Wmissing-prototypes
Date:   Mon, 17 Dec 2018 15:43:13 +0800
Message-ID: <1545032593-8622-1-git-send-email-mingli.yu@windriver.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Mingli Yu <Mingli.Yu@windriver.com>

There comes below error when run "make -C tests/nsm_client nsm_client"
| nlm_sm_inter_svc.c:20:1: error: no previous prototype for 'nlm_sm_prog_3' [-Werror=missing-prototypes]

It is because rpcgen doesn't generate -Wmissing-prototypes
free code for nlm_sm_inter_svc.c with below logic
in tests/nsm_client/Makefile.am
[snip]
GENFILES_SVC    = nlm_sm_inter_svc.c
[snip]
$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
        test -f $@ && rm -rf $@ || true
        $(RPCGEN) -m -o $@ $<

Signed-off-by: Mingli Yu <Mingli.Yu@windriver.com>
---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 4bf5aea..af86e4e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -552,7 +552,7 @@ my_am_cflags="\
  -Wall \
  -Wextra \
  $rpcgen_cflags \
- -Werror=missing-prototypes \
+ -Wmissing-prototypes \
  -Werror=missing-declarations \
  -Werror=format=2 \
  -Werror=undef \
-- 
2.7.4

