Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BD37C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 16:08:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DC72320862
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 16:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="Nl8xgchF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC72320862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=desy.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726253AbeK0DDM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 26 Nov 2018 22:03:12 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:38916 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726224AbeK0DDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Nov 2018 22:03:12 -0500
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 9899E280713
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2018 17:08:37 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 9899E280713
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1543248517; bh=SoqRGdo+UM40UcRuCoSVPjRFe+cZNRkDPkt2HdgoSNg=;
        h=From:To:Cc:Subject:Date:From;
        b=Nl8xgchFhCuUx/tNTC3JmXzAu9T8gDX2rp9szWLdSqi2t4XvE18Ju+ltU+tvP8Fnv
         iVT6+/hhmIhTnyBP6649E3EuOlEkeaYFn0EqZMvgdEpduiKGYZ2vpi01D1Bbbjn9j3
         cIyUGo62yKqoh2OyqWDpY6ZfkVBg+t1WL2imyzTg=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [IPv6:2001:638:700:1038::1:83])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 92660A019A;
        Mon, 26 Nov 2018 17:08:37 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from ani.desy.de (zitpcx21033.desy.de [131.169.185.213])
        by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id 5F4A43E901;
        Mon, 26 Nov 2018 17:08:37 +0100 (MET)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     bfields@fieldses.org
Cc:     loghyr@gmail.com, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] pynfs: fix result array access in CSID7
Date:   Mon, 26 Nov 2018 17:08:27 +0100
Message-Id: <20181126160827.153240-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

fixes 6612354e

the result array look like

..., OPEN, GETFH, LAYOUTGET]
thus fh in -2, open stateid in -3

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/server41tests/st_current_stateid.py | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index 58f6e9b..a6671eb 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -147,12 +147,12 @@ def testOpenLayoutGet(t, env):
     sess = env.c1.new_pnfs_client_session(env.testname(t))
 
     open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
-    res = sess.compound( open_op + 
+    res = sess.compound( open_op +
            [op.layoutget(False, LAYOUT4_NFSV4_1_FILES, LAYOUTIOMODE4_RW,
                         0, 8192, 8192, current_stateid, 0xffff)])
     check(res, NFS4_OK)
-    fh = res.resarray[-1].object
-    stateid = res.resarray[-2].stateid
+    fh = res.resarray[-2].object
+    stateid = res.resarray[-3].stateid
     res = close_file(sess, fh, stateid=stateid)
     check(res)
 
-- 
2.19.1

