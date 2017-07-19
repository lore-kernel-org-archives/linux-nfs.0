Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3215 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754265AbdGSUyB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 16:54:01 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9D55C5BECD
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:54:01 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-174.rdu2.redhat.com [10.10.122.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 55C315D9C7
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:54:01 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/11] nfsdcltrack.c: remove a warning
Date: Wed, 19 Jul 2017 16:53:54 -0400
Message-Id: <20170719205354.10006-12-steved@redhat.com>
In-Reply-To: <20170719205354.10006-1-steved@redhat.com>
References: <20170719205354.10006-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsdcltrack.c:581:4: warning: this statement may fall through [-Wimplicit-fallthrough=]

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

