Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82899C31D99
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 77D1320717
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728053AbfDYOE2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 10:04:28 -0400
Received: from fieldses.org ([173.255.197.46]:50958 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728162AbfDYOEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 10:04:25 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 06213254F; Thu, 25 Apr 2019 10:04:23 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        jlayton@redhat.com, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/10] nfsd: add more information to client info file
Date:   Thu, 25 Apr 2019 10:04:20 -0400
Message-Id: <1556201060-7947-11-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Add ip address, full client-provided identifier, and minor version.
There's much more that could possibly be useful but this is a start.

As with open owners, client identifiers are opaque binary data, but some
client happen to include some useful information in ascii.
---
 fs/nfsd/nfs4state.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f53621a65e60..39e1956b1bd2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2208,6 +2208,11 @@ static int client_info_show(struct seq_file *m, void *v)
 	clp = container_of(nc, struct nfs4_client, cl_nfsdfs);
 	memcpy(&clid, &clp->cl_clientid, sizeof(clid));
 	seq_printf(m, "clientid: %llx\n", clid);
+	seq_printf(m, "address: %pISpc\n", (struct sockaddr *)&clp->cl_addr);
+	seq_printf(m, "name: ");
+	seq_escape_mem(m, clp->cl_name.data, clp->cl_name.len,
+			ESCAPE_NP|ESCAPE_HEX|ESCAPE_NOHIGH, NULL);
+	seq_printf(m, "\nminor version: %d\n", clp->cl_minorversion);
 	drop_client(clp);
 
 	return 0;
-- 
2.20.1

