Return-Path: <SRS0=5HTL=2Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBA7CC00523
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFF48206DB
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="VATCRjFY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728687AbgACV5x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Jan 2020 16:57:53 -0500
Received: from smtpcmd0997.aruba.it ([62.149.156.97]:57371 "EHLO
        smtpcmd0997.aruba.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728716AbgACV5x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jan 2020 16:57:53 -0500
Received: from ubuntu.localdomain ([89.164.7.165])
        by smtpcmd09.ad.aruba.it with bizsmtp
        id lxqg2101g3ZeEr501xqnee; Fri, 03 Jan 2020 22:50:48 +0100
From:   Giulio Benetti <giulio.benetti@benettiengineering.com>
To:     linux-nfs@vger.kernel.org
Cc:     Giulio Benetti <giulio.benetti@benettiengineering.com>
Subject: [nfs-utils PATCH 7/7] rpcgen: rpc_hout: fix indentation on f_print() argument separator
Date:   Fri,  3 Jan 2020 22:50:39 +0100
Message-Id: <20200103215039.27471-8-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
References: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=aruba.it; s=a1;
        t=1578088248; bh=rtzQ93BPe1MzD6QNoaREvwNimkV8DY1BsJDtAB87oIs=;
        h=From:To:Subject:Date:MIME-Version;
        b=VATCRjFYmPLeVafvj8WGdPxGj23Lab+w3JdSrLmNsC4Pk+0N7ZQB8lePMNCi3Weg0
         IlrC25r4BUHBMj73uCGHtSEu+M2cHAucf/wRbewZF6NHJhRYYKmpy8lWdI0lkoh03r
         bKqGxkaAn73jLgFlJNNO431CMRkxth/5A8Zzbr+MFPm9pG91nKwFieSSrgEiCD15OD
         B3xTPZDZmwzEClxYTTMVtg8r/kqdMOJY9bLw0xrFNLoeHxZwNObqYJscvSjCi03EwE
         wnPuQyP7b0JhH/BgQgIIMDLZ0SPvRfBOpeF4oDQ7NI17WgeAJrqnoJaPpxY3mh7OeU
         HzlEBtmSErcPQ==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Remove useless space before closing parenthesys.

Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
---
 tools/rpcgen/rpc_hout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/rpcgen/rpc_hout.c b/tools/rpcgen/rpc_hout.c
index 999c061f..ed668778 100644
--- a/tools/rpcgen/rpc_hout.c
+++ b/tools/rpcgen/rpc_hout.c
@@ -468,7 +468,7 @@ pdeclaration(char *name, declaration *dec, int tab, char *separator)
 		}
 	}
 #pragma GCC diagnostic ignored "-Wformat-security"
-	f_print(fout, separator );
+	f_print(fout, separator);
 #pragma GCC diagnostic warning "-Wformat-security"
 }
 
-- 
2.20.1

