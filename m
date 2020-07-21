Return-Path: <SRS0=ojZM=BA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 842D9C433E0
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 19:44:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2E103206C1
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 19:44:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="ZSsN3Eic"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730817AbgGUToC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Jul 2020 15:44:02 -0400
Received: from smtp-o-3.desy.de ([131.169.56.156]:52273 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730322AbgGUToC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Jul 2020 15:44:02 -0400
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [IPv6:2001:638:700:1038::1:a6])
        by smtp-o-3.desy.de (Postfix) with ESMTP id 6B445604B9
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2020 21:44:00 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 6B445604B9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1595360640; bh=b3PX4q+a14CUjCrFywSV0vdMplCkj4DKe7YfJDXVRoI=;
        h=From:To:Cc:Subject:Date:From;
        b=ZSsN3EicSmPsAq7weFs+4rk3JI0WivLf0rMVm5F5hPmjNOhbBdXECOe8kRzGhSrGf
         dampR/YPE9GbT8CoxSoAlOpDyc1KEvAz0BvCNEwK1oDKdgyvD7Bwt3tZC6R01F5HcU
         DQiiz8j7vm4jDAXdhg36Kw2SrMLScRT3jojdS6Cc=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [131.169.56.131])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 65E92A00C3;
        Tue, 21 Jul 2020 21:44:00 +0200 (CEST)
X-Virus-Scanned: amavisd-new at desy.de
Received: from ani.desy.de (zitpcx21033.desy.de [131.169.185.213])
        by smtp-intra-2.desy.de (Postfix) with ESMTP id 39A0810007B;
        Tue, 21 Jul 2020 21:44:00 +0200 (CEST)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs41client: fix raising an error when pnfs test hits non pnfs server
Date:   Tue, 21 Jul 2020 21:43:58 +0200
Message-Id: <20200721194358.18132-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

fail function is not defined

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/nfs4client.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index f06d9c5..3d55f96 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -1,7 +1,7 @@
 import use_local # HACK so don't have to rebuild constantly
 import rpc.rpc as rpc
 import nfs4lib
-from nfs4lib import NFS4Error, NFS4Replay, inc_u32
+from nfs4lib import NFS4Error, NFS4Replay, inc_u32, UnexpectedCompoundRes
 from xdrdef.nfs4_type import *
 from xdrdef.nfs4_const import *
 from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
@@ -331,7 +331,7 @@ class NFS4Client(rpc.Client, rpc.Server):
         # Make sure E_ID returns MDS capabilities
         c = self.new_client(name, flags=flags)
         if not c.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
-            fail("Server can not be used as pnfs metadata server")
+            raise UnexpectedCompoundRes("Server can not be used as pnfs metadata server")
         s = c.create_session(sec=sec)
         s.compound([op4.reclaim_complete(FALSE)])
         return s
-- 
2.26.2

