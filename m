Return-Path: <SRS0=5HTL=2Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E22C4C00523
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A4A3B206DB
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="eGC4nYXQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728711AbgACV5v (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Jan 2020 16:57:51 -0500
Received: from smtpcmd0997.aruba.it ([62.149.156.97]:38623 "EHLO
        smtpcmd0997.aruba.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728687AbgACV5v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jan 2020 16:57:51 -0500
Received: from ubuntu.localdomain ([89.164.7.165])
        by smtpcmd09.ad.aruba.it with bizsmtp
        id lxqg2101g3ZeEr501xqie8; Fri, 03 Jan 2020 22:50:43 +0100
From:   Giulio Benetti <giulio.benetti@benettiengineering.com>
To:     linux-nfs@vger.kernel.org
Cc:     Giulio Benetti <giulio.benetti@benettiengineering.com>
Subject: [nfs-utils PATCH 1/7] rpcgen: rpc_cout: silence unused def parameter
Date:   Fri,  3 Jan 2020 22:50:33 +0100
Message-Id: <20200103215039.27471-2-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
References: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=aruba.it; s=a1;
        t=1578088243; bh=8+hIwXb7lCaAPNVVeeu2ue3i/EAnwhm8pWB2k3aLIvc=;
        h=From:To:Subject:Date:MIME-Version;
        b=eGC4nYXQbGS7oNfLXr0ROZsW6javEAsmdFwGsXuc69WiZZpmn89IZwx1opsMJt6Ne
         DcX5CVch+JGta+NIS/LjPsmoZ64LvhqV/YnrWYuWzopS9VyZQBZZNttvhXWyoLn/HM
         5qLZ6OVxrOffk5/VS5gdOUBwGcMrZAlX34HS5EO5TevldyNGwWvC6Zg+F5S5C7qDVW
         r3Kj8wwLkAVIHC9OgnkCKk9ECqdv91SRA2uWT/W9oprgbDf2huYY7ekIFZQNEtGNzO
         s+kI4WA/8KANqdex+1k2tew1JGprWtaoWyP2IJhmBmwPuOpUKJSGAlOnQJV0j5ZgNW
         y5QlxU5pBaUTA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In emit_enum() argument def is not used and can cause a warning. So
let's mark it with __attribute__((unused)).

Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
---
 tools/rpcgen/rpc_cout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/rpcgen/rpc_cout.c b/tools/rpcgen/rpc_cout.c
index a61214fd..f806a86a 100644
--- a/tools/rpcgen/rpc_cout.c
+++ b/tools/rpcgen/rpc_cout.c
@@ -53,7 +53,7 @@ static void	print_ifsizeof(char *prefix, char *type);
 static void	print_ifclose(int indent);
 static void	print_ifstat(int indent, char *prefix, char *type, relation rel,
 			char *amax, char *objname, char *name);
-static void	emit_enum(definition *def);
+static void	emit_enum(__attribute__((unused)) definition *def);
 static void	emit_program(definition *def);
 static void	emit_union(definition *def);
 static void	emit_struct(definition *def);
@@ -286,7 +286,7 @@ print_ifstat(int indent, char *prefix, char *type, relation rel,
 }
 
 static void
-emit_enum(definition *def)
+emit_enum(__attribute__((unused)) definition *def)
 {
 	print_ifopen(1, "enum");
 	print_ifarg("(enum_t *)objp");
-- 
2.20.1

