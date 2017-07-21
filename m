Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754548AbdGUQiM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:12 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A909A6F66B
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:12 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5F603183C0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:12 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/11] nfsdcltrack.c: remove a warning
Date: Fri, 21 Jul 2017 12:38:06 -0400
Message-Id: <20170721163806.15803-12-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsdcltrack.c:581:4: warning: this statement may fall through [-Wimplicit-fallthrough=]

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 124c923..0baaa3e 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -579,6 +579,7 @@ main(int argc, char **argv)
 		switch (arg) {
 		case 'd':
 			xlog_config(D_ALL, 1);
+			break;
 		case 'f':
 			xlog_syslog(0);
 			xlog_stderr(1);
-- 
2.13.3

