Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37004 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458Ab2GaVAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 17:00:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] rpc.gssd: don't call printerr from signal handler
Date: Tue, 31 Jul 2012 17:00:47 -0400
Message-Id: <1343768449-32205-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20120731205931.GA32161@fieldses.org>
References: <20120731205931.GA32161@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

printerr() isn't actually safe to call from a signal handler.  It might
be possible to make it so, but I think this is the only case in
nfs-utils where we try to, and I'm not convince it's worth it.

This fixes a bug that would eventually cause mounts to hang when gssd
is run with -vv.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_main_loop.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 9954ffb..6914687 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -61,10 +61,8 @@ extern int pollsize;
 
 static volatile int dir_changed = 1;
 
-static void dir_notify_handler(int sig)
+static void dir_notify_handler(__attribute__((unused))int sig)
 {
-	printerr(2, "dir_notify_handler: sig %d\n", sig);
-
 	dir_changed = 1;
 }
 
-- 
1.7.9.5

