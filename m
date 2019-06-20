Return-Path: <SRS0=L7au=UT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19A8BC48BE3
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E468D2083B
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726757AbfFTOvW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Jun 2019 10:51:22 -0400
Received: from fieldses.org ([173.255.197.46]:43452 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726551AbfFTOvW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jun 2019 10:51:22 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 2679264EE; Thu, 20 Jun 2019 10:51:21 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/16] nfsd: add more information to client info file
Date:   Thu, 20 Jun 2019 10:51:08 -0400
Message-Id: <1561042275-12723-10-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561042275-12723-1-git-send-email-bfields@redhat.com>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Add ip address, full client-provided identifier, and minor version.
There's much more that could possibly be useful but this is a start.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dd89dc05f6ee..430cea90a715 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/jhash.h>
+#include <linux/string_helpers.h>
 #include "xdr4.h"
 #include "xdr4cb.h"
 #include "vfs.h"
@@ -2214,6 +2215,13 @@ find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 	return s;
 }
 
+static void seq_quote_mem(struct seq_file *m, char *data, int len)
+{
+	seq_printf(m, "\"");
+	seq_escape_mem_ascii(m, data, len);
+	seq_printf(m, "\"");
+}
+
 static int client_info_show(struct seq_file *m, void *v)
 {
 	struct inode *inode = m->private;
@@ -2227,6 +2235,10 @@ static int client_info_show(struct seq_file *m, void *v)
 	clp = container_of(nc, struct nfs4_client, cl_nfsdfs);
 	memcpy(&clid, &clp->cl_clientid, sizeof(clid));
 	seq_printf(m, "clientid: 0x%llx\n", clid);
+	seq_printf(m, "address: \"%pISpc\"\n", (struct sockaddr *)&clp->cl_addr);
+	seq_printf(m, "name: ");
+	seq_quote_mem(m, clp->cl_name.data, clp->cl_name.len);
+	seq_printf(m, "\nminor version: %d\n", clp->cl_minorversion);
 	drop_client(clp);
 
 	return 0;
-- 
2.21.0

