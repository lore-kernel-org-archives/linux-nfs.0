Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 169C1C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 14:11:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D52622075D
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 14:11:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728279AbfCZOLN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 10:11:13 -0400
Received: from mx1.redhat.com ([209.132.183.28]:55392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726277AbfCZOLN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 10:11:13 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 25FEE3092656;
        Tue, 26 Mar 2019 14:11:13 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.76.0.95])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1F8D05F9C9;
        Tue, 26 Mar 2019 14:11:11 +0000 (UTC)
From:   Kenneth D'souza <kdsouza@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     bfields@fieldses.org
Subject: [PATCH] nfs4_setfacl: Skip comment field while reading ACE(s).
Date:   Tue, 26 Mar 2019 19:41:09 +0530
Message-Id: <20190326141109.16844-1-kdsouza@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Tue, 26 Mar 2019 14:11:13 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

With commit 6630629bb661a7f48fb9856f7fd9616ce1499efa an additional field for filename
was added due to which nfs4_setfacl failed to handle comments while reading ACE(s)
from nfs4_getfacl output.
This patch resolves the issue by skipping comment header.

 With fix:

 $ nfs4_setfacl --test -s "$(nfs4_getfacl  file1)" file2
 Skipping comment # file: file1
 ## Test mode only - the resulting ACL for "/test/file2":
 A::OWNER@:rwatTcCy
 A:g:GROUP@:rtcy
 A::EVERYONE@:rtcy

 Without fix:

 $ nfs4_setfacl --test -s "$(nfs4_getfacl  file1)" file2
 Failed while inserting ACE(s).

Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
---
 libnfs4acl/nfs4_insert_string_aces.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/libnfs4acl/nfs4_insert_string_aces.c b/libnfs4acl/nfs4_insert_string_aces.c
index 5a482d5..50b7bbf 100644
--- a/libnfs4acl/nfs4_insert_string_aces.c
+++ b/libnfs4acl/nfs4_insert_string_aces.c
@@ -45,21 +45,25 @@ int nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned
 	if ((s = sp = strdup(acl_spec)) == NULL)
 		goto out_failed;
 
+
 	while ((ssp = strsep(&sp, ",\t\n\r")) != NULL) {
 		if (!strlen(ssp))
 			continue;
 
-		if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
-			goto out_failed;
+		if(*ssp == '#')
+			printf("Skipping comment %s\n", ssp);
+		else {
+			if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
+				goto out_failed;
 
-		if (nfs4_insert_ace_at(acl, ace, index++)) {
-			free(ace);
-			goto out_failed;
+			if (nfs4_insert_ace_at(acl, ace, index++)) {
+				free(ace);
+				goto out_failed;
+			}
 		}
 	}
 	if (acl->naces == 0)
 		goto out_failed;
-
 out:
 	if (s)
 		free(s);
-- 
2.20.1

