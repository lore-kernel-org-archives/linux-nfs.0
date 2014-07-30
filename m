Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f179.google.com ([209.85.217.179]:45598 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbaG3LXe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:34 -0400
Received: by mail-lb0-f179.google.com with SMTP id v6so748457lbi.38
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:32 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 06/11] nfsstat: replace the legacy SA_ONESHOT with standard SA_RESETHAND
Date: Wed, 30 Jul 2014 13:23:14 +0200
Message-Id: <1406719399-1735-7-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
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
2.0.3

