Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f176.google.com ([209.85.217.176]:39412 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786AbaHFGZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:20 -0400
Received: by mail-lb0-f176.google.com with SMTP id u10so1551092lbd.35
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:18 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 06/11] nfsstat: replace the legacy SA_ONESHOT with standard SA_RESETHAND
Date: Wed,  6 Aug 2014 08:25:01 +0200
Message-Id: <1407306306-29796-7-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 utils/nfsstat/nfsstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 70f8d10..3612bfe 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -336,7 +336,7 @@ main(int argc, char **argv)
 
 	struct sigaction act = {
 		.sa_handler = unpause,
-		.sa_flags = SA_ONESHOT,
+		.sa_flags = SA_RESETHAND,
 	};
 
 	if ((progname = strrchr(argv[0], '/')))
-- 
2.0.4

