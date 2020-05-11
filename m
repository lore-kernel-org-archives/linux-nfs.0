Return-Path: <SRS0=m7q9=6Z=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 944EAC54E4A
	for <linux-nfs@archiver.kernel.org>; Mon, 11 May 2020 23:17:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7618B20675
	for <linux-nfs@archiver.kernel.org>; Mon, 11 May 2020 23:17:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726415AbgEKXRS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 May 2020 19:17:18 -0400
Received: from fieldses.org ([173.255.197.46]:55176 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726106AbgEKXRR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 May 2020 19:17:17 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 676AF709; Mon, 11 May 2020 19:17:17 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: stid display should preserve on-the-wire byte order
Date:   Mon, 11 May 2020 19:17:16 -0400
Message-Id: <1589239036-17100-2-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1589239036-17100-1-git-send-email-bfields@redhat.com>
References: <1589239036-17100-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

When we decode the stateid we byte-swap si_generation.

But for simplicity's sake and ease of comparison with network traces,
it's better to display the whole thing in network order.

Reported-by: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ded08aeae497..6fed3bf00ca7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2424,7 +2424,8 @@ static void nfs4_show_owner(struct seq_file *s, struct nfs4_stateowner *oo)
 
 static void nfs4_show_stateid(struct seq_file *s, stateid_t *stid)
 {
-	seq_printf(s, "0x%16phN", stid);
+	seq_printf(s, "0x%.8x", stid->si_generation);
+	seq_printf(s, "%12phN", &stid->si_opaque);
 }
 
 static int nfs4_show_open(struct seq_file *s, struct nfs4_stid *st)
-- 
2.26.2

