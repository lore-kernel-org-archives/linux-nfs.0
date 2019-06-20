Return-Path: <SRS0=L7au=UT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0020C48BE4
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA01B2083B
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726661AbfFTOvW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Jun 2019 10:51:22 -0400
Received: from fieldses.org ([173.255.197.46]:43462 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726786AbfFTOvW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jun 2019 10:51:22 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 2DF3167C7; Thu, 20 Jun 2019 10:51:21 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/16] nfsd: show lock and deleg stateids
Date:   Thu, 20 Jun 2019 10:51:10 -0400
Message-Id: <1561042275-12723-12-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561042275-12723-1-git-send-email-bfields@redhat.com>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

These entries are pretty minimal for now.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 59 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ad9487afd3c5..ab4302cee2d2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2338,12 +2338,66 @@ static int nfs4_show_open(struct seq_file *s, struct nfs4_stid *st)
 	seq_printf(s, ", ");
 	nfs4_show_owner(s, oo);
 	seq_printf(s, " }\n");
+	fput(file);
+
+	return 0;
+}
+
+static int nfs4_show_lock(struct seq_file *s, struct nfs4_stid *st)
+{
+	struct nfs4_ol_stateid *ols;
+	struct nfs4_file *nf;
+	struct file *file;
+	struct nfs4_stateowner *oo;
 
+	ols = openlockstateid(st);
+	oo = ols->st_stateowner;
+	nf = st->sc_file;
+	file = find_any_file(nf);
+
+	seq_printf(s, "- 0x%16phN: { type: lock, ", &st->sc_stateid);
+
+	/*
+	 * Note: a lock stateid isn't really the same thing as a lock,
+	 * it's the locking state held by one owner on a file, and there
+	 * may be multiple (or no) lock ranges associated with it.
+	 * (Same for the matter is true of open stateids.)
+	 */
+
+	nfs4_show_superblock(s, file);
+	/* XXX: open stateid? */
+	seq_printf(s, ", ");
+	nfs4_show_owner(s, oo);
+	seq_printf(s, " }\n");
 	fput(file);
 
 	return 0;
 }
 
+static int nfs4_show_deleg(struct seq_file *s, struct nfs4_stid *st)
+{
+	struct nfs4_delegation *ds;
+	struct nfs4_file *nf;
+	struct file *file;
+
+	ds = delegstateid(st);
+	nf = st->sc_file;
+	file = nf->fi_deleg_file;
+
+	seq_printf(s, "- 0x%16phN: { type: deleg, ", &st->sc_stateid);
+
+	/* Kinda dead code as long as we only support read delegs: */
+	seq_printf(s, "access: %s, ",
+		ds->dl_type == NFS4_OPEN_DELEGATE_READ ? "r" : "w");
+
+	/* XXX: lease time, whether it's being recalled. */
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
@@ -2351,9 +2405,14 @@ static int states_show(struct seq_file *s, void *v)
 	switch (st->sc_type) {
 	case NFS4_OPEN_STID:
 		return nfs4_show_open(s, st);
+	case NFS4_LOCK_STID:
+		return nfs4_show_lock(s, st);
+	case NFS4_DELEG_STID:
+		return nfs4_show_deleg(s, st);
 	default:
 		return 0; /* XXX: or SEQ_SKIP? */
 	}
+	/* XXX: copy stateids? */
 }
 
 static struct seq_operations states_seq_ops = {
-- 
2.21.0

