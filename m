Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BE2CC71153
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Sep 2023 16:50:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S241322AbjIDQuJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Sep 2023 12:50:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60268 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237790AbjIDQuI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Sep 2023 12:50:08 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CC897CC4
        for <linux-nfs@vger.kernel.org>; Mon,  4 Sep 2023 09:50:05 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 6337D61853
        for <linux-nfs@vger.kernel.org>; Mon,  4 Sep 2023 16:50:05 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9359CC433C8;
        Mon,  4 Sep 2023 16:50:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1693846204;
        bh=HZLmbN0yQUAbUMrfCujn9XLM+AN/DUfi1w/lk0dvxwY=;
        h=From:To:Cc:Subject:Date:From;
        b=ivWgFofvhICObVIDHkvvQ07uH4c3gEEmtXx/WAYdQh8iiqVIS4zopQ8Rp1YPiiOoZ
         ICTV0tN544oU0HdyYlMCKlVOqJdKOLomMRYeMdQtZxvhQddKtWXprhouWHCfrw7w9q
         CwhDt8xA/kTVqwYKU2TgRPn5RT1E4D00g+EIOsnWgt3JkGAbfzjbj4NrZJ9XW+PXBG
         F5NhgapH84/qEbulUoRIdZXq+yFaeDF9fcUzoLoBCrVILsVLQx8WrIxFiO00GMyt5w
         tTX8Ad+Xx1UUf1I5EwMXSwci7ZJ3vJcWGy2wE0eDGfMPiPrenxyByiaIkesJAdej+V
         +CGRAtbE1jjww==
From:   trondmy@kernel.org
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS/pNFS: Report EINVAL errors from connect() to the server
Date:   Mon,  4 Sep 2023 12:43:58 -0400
Message-ID: <20230904164358.12177-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.41.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

With IPv6, connect() can occasionally return EINVAL if a route is
unavailable. If this happens during I/O to a data server, we want to
report it using LAYOUTERROR as an inability to connect.

Fixes: dd52128afdde ("NFSv4.1/pnfs Ensure flexfiles reports all connection related errors")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7deb3cd76abe..a1dc33864906 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1235,6 +1235,7 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
 		case -EOPNOTSUPP:
+		case -EINVAL:
 		case -ECONNREFUSED:
 		case -ECONNRESET:
 		case -EHOSTDOWN:
-- 
2.41.0

