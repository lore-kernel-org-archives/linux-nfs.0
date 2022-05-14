Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DBF9C433F5
	for <linux-nfs@archiver.kernel.org>; Sat, 14 May 2022 14:14:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233003AbiENOO3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 14 May 2022 10:14:29 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50972 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232464AbiENOOY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2022 10:14:24 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1FE4215815
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2022 07:14:24 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id C5D5AB802BD
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2022 14:14:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25AB4C340EE;
        Sat, 14 May 2022 14:14:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1652537661;
        bh=OlCPLbXrkK6bmzaCkwWaRsSFTZ0uG3nR6f6NwBQLJlQ=;
        h=From:To:Cc:Subject:Date:From;
        b=QaxVgG3XYPYw4n4M007M8QSRpdZrm/feJL2AfjvdjMZpW88zCAUsg2Qs9LzXLrsVI
         4SDbZrNpH5vB/cfhpmGBZP7qQoSMuwx0aaw/Grgf9D8VZ9VqginOOjtJzFc5HQ5iHE
         TqestSLBdVfqVXuaeepsM3uUuyuAG6etkatVPXpnTAcn0oxDgeADbgLX2RjVT8lmro
         wF66DpDI0s6KMnrE8Z/7+YtrLtNg8R9Q3rTDtN8q/PnwnQewUGdhung5MvwDx9Qch7
         Vk1iBBhfhFAAZV+zb+NFdb3kGZblKVDRWZHWXqiG7FaijveButbyB80PexdbBCbPz9
         zFTFCBvfv6H+Q==
From:   trondmy@kernel.org
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFS: Memory allocation failures are not server fatal errors
Date:   Sat, 14 May 2022 10:08:10 -0400
Message-Id: <20220514140814.3655-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.36.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We need to filter out ENOMEM in nfs_error_is_fatal_on_server(), because
running out of memory on our client is not a server error.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: 2dc23afffbca ("NFS: ENOMEM should also be a fatal error.")
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/internal.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7eefa16ed381..8f8cd6e2d4db 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -841,6 +841,7 @@ static inline bool nfs_error_is_fatal_on_server(int err)
 	case 0:
 	case -ERESTARTSYS:
 	case -EINTR:
+	case -ENOMEM:
 		return false;
 	}
 	return nfs_error_is_fatal(err);
-- 
2.36.1

