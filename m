Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91978C433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jun 2022 14:13:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1358023AbiFVONL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jun 2022 10:13:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34556 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1358055AbiFVOM6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2022 10:12:58 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id AD1F321A2;
        Wed, 22 Jun 2022 07:12:56 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 4575DB81F57;
        Wed, 22 Jun 2022 14:12:55 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B65FC3411B;
        Wed, 22 Jun 2022 14:12:53 +0000 (UTC)
Subject: [PATCH RFC 01/30] NFSD: Report filecache LRU size
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     david@fromorbit.com, tgraf@suug.ch, jlayton@redhat.com
Date:   Wed, 22 Jun 2022 10:12:52 -0400
Message-ID: <165590717261.75778.17678554642003559686.stgit@manet.1015granger.net>
In-Reply-To: <165590626293.75778.9843437418112335153.stgit@manet.1015granger.net>
References: <165590626293.75778.9843437418112335153.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Surface the NFSD filecache's LRU list length to help field
troubleshooters monitor filecache issues.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/filecache.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 9cb2d590c036..932db96f854a 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1089,6 +1089,7 @@ static int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
 
 	seq_printf(m, "total entries: %u\n", count);
 	seq_printf(m, "longest chain: %u\n", longest);
+	seq_printf(m, "lru entries:   %lu\n", list_lru_count(&nfsd_file_lru));
 	seq_printf(m, "cache hits:    %lu\n", hits);
 	return 0;
 }


