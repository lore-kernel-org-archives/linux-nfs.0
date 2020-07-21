Return-Path: <SRS0=ojZM=BA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE094C433E0
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 19:16:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6CACF20672
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 19:16:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="sojbYfqq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727801AbgGUTQi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Jul 2020 15:16:38 -0400
Received: from smtp-o-2.desy.de ([131.169.56.155]:44683 "EHLO smtp-o-2.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726960AbgGUTQi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Jul 2020 15:16:38 -0400
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
        by smtp-o-2.desy.de (Postfix) with ESMTP id 61860160D0F
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2020 21:16:31 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 61860160D0F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1595358991; bh=Tb7DEZfd1Rk8fIYdXnYCjyrjsLjVDTY/FC0irSUGX2Q=;
        h=From:To:Cc:Subject:Date:From;
        b=sojbYfqqUeez7Es1NZqnSJt+UCSREvc4VYQWW+5Yy7fk2UcHtVSxsbNkdrAZeo5se
         uIuEq0GkfL6bV6fE29K04VKElPwNp9uEGBwK2Ph7kCL54sgpjOIPQhCiGoneGYlFcn
         GUQJIkUD3AqnJT4EzroaCHlXwUSqk/ZgOkncFkqg=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
        by smtp-buf-2.desy.de (Postfix) with ESMTP id 55C8D1A00C4;
        Tue, 21 Jul 2020 21:16:31 +0200 (CEST)
X-Virus-Scanned: amavisd-new at desy.de
Received: from ani.desy.de (zitpcx21033.desy.de [131.169.185.213])
        by smtp-intra-2.desy.de (Postfix) with ESMTP id 2721D10007B;
        Tue, 21 Jul 2020 21:16:31 +0200 (CEST)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] generic currentstateid test of should not require pnfs-aware session
Date:   Tue, 21 Jul 2020 21:16:28 +0200
Message-Id: <20200721191628.16970-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

CSID8 doesn't depend on pnfs capability of a server, thus should not
create pnfs-aware session.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_current_stateid.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 8882e96..6480ae9 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -164,7 +164,7 @@ def testOpenSetattr(t, env):
     CODE: CSID8
     """
     size = 8
-    sess = env.c1.new_pnfs_client_session(env.testname(t))
+    sess = env.c1.new_client_session(env.testname(t))
 
     open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
     res = sess.compound( open_op +
-- 
2.26.2

