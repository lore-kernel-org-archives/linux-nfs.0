Return-Path: <SRS0=L7au=UT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2434C43613
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A5FD22083B
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731733AbfFTOvZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Jun 2019 10:51:25 -0400
Received: from fieldses.org ([173.255.197.46]:43464 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727040AbfFTOvW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jun 2019 10:51:22 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 31DDB67F6; Thu, 20 Jun 2019 10:51:21 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/16] nfsd4: show layout stateids
Date:   Thu, 20 Jun 2019 10:51:11 -0400
Message-Id: <1561042275-12723-13-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561042275-12723-1-git-send-email-bfields@redhat.com>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

These are also minimal for now, I'm not sure what information would be
useful.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ab4302cee2d2..7867372363ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2398,6 +2398,24 @@ static int nfs4_show_deleg(struct seq_file *s, struct nfs4_stid *st)
 	return 0;
 }
 
+static int nfs4_show_layout(struct seq_file *s, struct nfs4_stid *st)
+{
+	struct nfs4_layout_stateid *ls;
+	struct file *file;
+
+	ls = container_of(st, struct nfs4_layout_stateid, ls_stid);
+	file = ls->ls_file;
+
+	seq_printf(s, "- 0x%16phN: { type: layout, ", &st->sc_stateid);
+
+	/* XXX: What else would be useful? */
+
+	nfs4_show_superblock(s, file);
+	seq_printf(s, " }\n");
+
+	return 0;
+}
+
 static int states_show(struct seq_file *s, void *v)
 {
 	struct nfs4_stid *st = v;
@@ -2409,6 +2427,8 @@ static int states_show(struct seq_file *s, void *v)
 		return nfs4_show_lock(s, st);
 	case NFS4_DELEG_STID:
 		return nfs4_show_deleg(s, st);
+	case NFS4_LAYOUT_STID:
+		return nfs4_show_layout(s, st);
 	default:
 		return 0; /* XXX: or SEQ_SKIP? */
 	}
-- 
2.21.0

