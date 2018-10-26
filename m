Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FBF1ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 18:10:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 02CA020834
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 18:10:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02CA020834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727727AbeJ0Csg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 22:48:36 -0400
Received: from youngberry.canonical.com ([91.189.89.112]:38503 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726949AbeJ0Csg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 22:48:36 -0400
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
        by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
        (Exim 4.76)
        (envelope-from <colin.king@canonical.com>)
        id 1gG6Z6-0001Xb-Ab; Fri, 26 Oct 2018 18:10:32 +0000
From:   Colin King <colin.king@canonical.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Cc:     kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: fix spelling mistake, EACCESS -> EACCES
Date:   Fri, 26 Oct 2018 19:10:31 +0100
Message-Id: <20181026181031.5366-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to a spelling mistake of the error access name EACCESS,
rename to EACCES

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index db84b4adbc49..867457d6dfbe 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3788,7 +3788,7 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	}
 
 	/*
-	 * -EACCESS could mean that the user doesn't have correct permissions
+	 * -EACCES could mean that the user doesn't have correct permissions
 	 * to access the mount.  It could also mean that we tried to mount
 	 * with a gss auth flavor, but rpc.gssd isn't running.  Either way,
 	 * existing mount programs don't handle -EACCES very well so it should
-- 
2.19.1

