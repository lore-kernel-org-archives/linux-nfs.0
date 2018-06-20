Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44896 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932077AbeFTMMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Jun 2018 08:12:20 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DCCE040200A7
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 12:12:19 +0000 (UTC)
Message-ID: <1529496736.7473.10.camel@redhat.com>
Subject: [PATCH 2/5] nfs-utils: Fix comparison check for subsection headers
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 20 Jun 2018 13:12:16 +0100
In-Reply-To: <1529496583.7473.8.camel@redhat.com>
References: <1529496583.7473.8.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When comparing two config section headers it incorrectly
handled matching section names where only one had a
subsection value

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index d20460e..51b85f2 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -727,6 +727,8 @@ retry:
 			continue;
 		if (arg && (cb->arg == NULL || strcasecmp(arg, cb->arg) != 0))
 			continue;
+		if (!arg && cb->arg)
+			continue;
 		if (strcasecmp(tag, cb->tag) != 0)
 			continue;
 		if (cb->value[0] == '$') {
-- 
1.8.3.1



