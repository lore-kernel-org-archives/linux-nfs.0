Return-Path: <SRS0=VWn9=24=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2064BC282DD
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Jan 2020 21:28:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0D2E206F0
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Jan 2020 21:28:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727166AbgAGV2q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 7 Jan 2020 16:28:46 -0500
Received: from mail.aglaz.de ([136.243.236.236]:60517 "EHLO mail.aglaz.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727156AbgAGV2p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Jan 2020 16:28:45 -0500
X-Greylist: delayed 567 seconds by postgrey-1.27 at vger.kernel.org; Tue, 07 Jan 2020 16:28:44 EST
Received: from localhost (localhost [127.0.0.1])
        by mail.aglaz.de (Postfix) with ESMTP id 2A98D22B23
        for <linux-nfs@vger.kernel.org>; Tue,  7 Jan 2020 22:19:16 +0100 (CET)
X-Virus-Scanned: SPAM and virus check at tabarz165.aglaz.de
Received: from mail.aglaz.de ([127.0.0.1])
        by localhost (tabarz165.aglaz.de [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id k6-AYtRYJdUq; Tue,  7 Jan 2020 22:19:15 +0100 (CET)
Received: from cus (unknown [79.140.114.186])
        (Authenticated sender: christian.bartolomaeus@aglaz.de)
        by mail.aglaz.de (Postfix) with ESMTPSA;
        Tue,  7 Jan 2020 22:19:15 +0100 (CET)
Received: from christian by cus with local (Exim 4.80)
        (envelope-from <use_v6@aglaz.de>)
        id 1iowFu-0001ie-Uc; Tue, 07 Jan 2020 22:19:14 +0100
Date:   Tue, 7 Jan 2020 22:19:14 +0100
From:   Christian =?utf-8?Q?Bartolom=C3=A4us?= <use_v6@aglaz.de>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] mountd: Remove outdated/misleading comment
Message-ID: <20200107211914.GE4452@cus>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

It became wrong when commit 78240c41be17bd20d5fb5b70b6f470d8e779adee
("mountd: fix mount issue due to comparison with uninitialized uuid") was
applied back in 2015. The final case of the switch statement no longer ends
with a 'return true' and the final 'return false' is relevant now.

Signed-off-by: Christian Bartolomäus <use_v6@aglaz.de>
---
 utils/mountd/cache.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index e5186c7..8f54e37 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -672,7 +672,6 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
 				if (memcmp(u, parsed->fhuuid, parsed->uuidlen) == 0)
 					return true;
 	}
-	/* Well, unreachable, actually: */
 	return false;
 }

