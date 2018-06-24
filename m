Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750851AbeFXSgV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 24 Jun 2018 14:36:21 -0400
Received: from smtp.corp.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5E0DC4A6F3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jun 2018 18:36:21 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-218.phx2.redhat.com [10.3.116.218])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 15A12916BB
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jun 2018 18:36:21 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsdcltrack: getopt_long() fails on a non x86_64 archs
Date: Sun, 24 Jun 2018 14:36:19 -0400
Message-Id: <20180624183619.59562-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

getopt_long() returns an int, not char, which
matters on non-x86_64 archs since a char is
signed on x86_64 arch but unsigned on other
archs.

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1551903

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 76b06d2..b45a904 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -553,7 +553,7 @@ find_cmd(char *cmdname)
 int
 main(int argc, char **argv)
 {
-	char arg;
+	int arg;
 	char *val;
 	int rc = 0;
 	char *progname, *cmdarg = NULL;
-- 
2.17.1

