Return-Path: <SRS0=5HTL=2Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DF18C2D0CE
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 000F5206DB
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="J1JupHu1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728645AbgACV5v (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Jan 2020 16:57:51 -0500
Received: from smtpcmd0997.aruba.it ([62.149.156.97]:53995 "EHLO
        smtpcmd0997.aruba.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728698AbgACV5u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jan 2020 16:57:50 -0500
Received: from ubuntu.localdomain ([89.164.7.165])
        by smtpcmd09.ad.aruba.it with bizsmtp
        id lxqg2101g3ZeEr501xqleL; Fri, 03 Jan 2020 22:50:46 +0100
From:   Giulio Benetti <giulio.benetti@benettiengineering.com>
To:     linux-nfs@vger.kernel.org
Cc:     Giulio Benetti <giulio.benetti@benettiengineering.com>
Subject: [nfs-utils PATCH 4/7] rpcgen: rpc_parse: add get_definition() void argument
Date:   Fri,  3 Jan 2020 22:50:36 +0100
Message-Id: <20200103215039.27471-5-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
References: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=aruba.it; s=a1;
        t=1578088246; bh=s0/vXAJf5ErPcbRliVgrliOraulwcqeXI6IUq9DwmCc=;
        h=From:To:Subject:Date:MIME-Version;
        b=J1JupHu1xBJUOOP5dTV2vlIU7qv8tmfSVyGmsksaeSI/0NHf9+wRZsWZPQjTCqPpl
         jlDkGp+/41BCFdfyy8Hr61PC1f/qmriBazUM/f5wNcZL3sZqaJpKYXFW9eBQBRLSRz
         fckffpa9nwacVuCR0YZFBnNk+ObFUyMJ4KqFRONWnXXsf29UqAZ2usA1WIsZkMb72v
         klg2Zi1xbW0ct8mkLmtGtQ4w5e5GW8emmvSrMhxuxTQlPCa4iQfOhEdal1xxzch/x2
         JrwjXNVn5+kwxIByKegeWwjvc8RXXc8ll6pP1NHnmD+tZtm8hZwqCxclbiTFpQeo+k
         FyPTFSCnkSi7w==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

get_definition() prototype has no arguments and this can cause warnings
during building. Let's add void argument to prototype according to its
implementation.

Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
---
 tools/rpcgen/rpc_parse.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/rpcgen/rpc_parse.h b/tools/rpcgen/rpc_parse.h
index 2afae104..6c134dd8 100644
--- a/tools/rpcgen/rpc_parse.h
+++ b/tools/rpcgen/rpc_parse.h
@@ -153,7 +153,7 @@ struct definition {
 };
 typedef struct definition definition;
 
-definition *get_definition();
+definition *get_definition(void);
 
 
 struct bas_type
-- 
2.20.1

