Return-Path: <SRS0=JCn4=V5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 802C4C433FF
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Aug 2019 10:59:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C247206A2
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Aug 2019 10:59:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731291AbfHAK7E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Aug 2019 06:59:04 -0400
Received: from mx1.redhat.com ([209.132.183.28]:45541 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726756AbfHAK7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Aug 2019 06:59:04 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 350443148090
        for <linux-nfs@vger.kernel.org>; Thu,  1 Aug 2019 10:59:04 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.114])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 89A8760BE0;
        Thu,  1 Aug 2019 10:59:03 +0000 (UTC)
Message-ID: <1564657141.8625.7.camel@redhat.com>
Subject: [PATCH] nfs-utils: Fix memory leak on error in nfs-server-generator
From:   Alice J Mitchell <ajmitchell@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     Steve Dickson <steved@redhat.com>
Date:   Thu, 01 Aug 2019 11:59:01 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 01 Aug 2019 10:59:04 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix the trivial memory leak in the error handling of nfs-server-generator

Signed-off-by: Alice J Mitchell <ajmitchell@redhat.com>
---
 systemd/nfs-server-generator.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
index 737f109..eec98fd 100644
--- a/systemd/nfs-server-generator.c
+++ b/systemd/nfs-server-generator.c
@@ -25,6 +25,7 @@
 #include <ctype.h>
 #include <stdio.h>
 #include <mntent.h>
+#include <alloca.h>
 
 #include "misc.h"
 #include "nfslib.h"
@@ -98,7 +99,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	path = malloc(strlen(argv[1]) + sizeof(dirbase) + sizeof(filebase));
+	path = alloca(strlen(argv[1]) + sizeof(dirbase) + sizeof(filebase));
 	if (!path)
 		exit(2);
 	if (export_read(_PATH_EXPORTS, 1) +
-- 
1.8.3.1

