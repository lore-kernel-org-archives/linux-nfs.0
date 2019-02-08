Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 648FDC169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 17:26:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1025220855
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 17:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="avzj3/6Y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727262AbfBHRZ7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 12:25:59 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:47298 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726522AbfBHRZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 12:25:59 -0500
X-Greylist: delayed 467 seconds by postgrey-1.27 at vger.kernel.org; Fri, 08 Feb 2019 12:25:58 EST
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [IPv6:2001:638:700:1038::1:a6])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id AAB7A280BC2
        for <linux-nfs@vger.kernel.org>; Fri,  8 Feb 2019 18:18:10 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de AAB7A280BC2
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1549646290; bh=8LCfsppLIonHz64GWMFrt8YiD4hiu4+8ssEjwsNFB7E=;
        h=From:To:Cc:Subject:Date:From;
        b=avzj3/6YL401/GGaHHNNEUa+cwSltyXOG05iHZIlZv3ZPuJ7RZ8M3SzlGKUabSbU5
         m+Ta33ugxz5OFxppKRb3ZRebeFauLELPCbZQJmlIqefWiPsT0OSOd6eCs7ly5x7Xd2
         4IqfcUP2u4r9wQKTLh8HAY/Uos/H+dO1gPbicgYo=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [131.169.56.131])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 8F27EA0040;
        Fri,  8 Feb 2019 18:18:10 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from ani.desy.de (zitpcx21033.desy.de [131.169.185.213])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 4B7E31029;
        Fri,  8 Feb 2019 18:18:10 +0100 (MET)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] st_getattr: do not expect server to return rdattr_error
Date:   Fri,  8 Feb 2019 18:18:08 +0100
Message-Id: <20190208171808.7861-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

rfc7530:
   5.8.1.12.  Attribute 11: rdattr_error

     Error returned from an attempt to retrieve attributes during a
     READDIR operation.

IOW, we do not expect rdattr_error to be returned in reply to regular
GETATTR operation.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/servertests/st_getattr.py | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
index 292fcd2..1c47ebf 100644
--- a/nfs4.0/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -1,12 +1,14 @@
 from xdrdef.nfs4_const import *
 from .environment import check
-from nfs4lib import get_attr_name
+from nfs4lib import get_attr_name, get_attrbitnum_dict
 import nfs_ops
 op = nfs_ops.NFS4ops()
 
 def _try_mandatory(t, env, path):
     c = env.c1
     mandatory = [attr.bitnum for attr in env.attr_info if attr.mandatory]
+    # don't expect rdattr_error to be a part of returned attributes
+    mandatory.remove(get_attrbitnum_dict()['rdattr_error'])
     ops = c.use_obj(path)
     ops += [c.getattr(mandatory)]
     res = c.compound(ops)
-- 
2.20.1

