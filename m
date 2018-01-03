Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751507AbeACNZg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Jan 2018 08:25:36 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4E7C882A
        for <linux-nfs@vger.kernel.org>; Wed,  3 Jan 2018 13:25:36 +0000 (UTC)
Message-ID: <1514985934.3551.2.camel@redhat.com>
Subject: [PATCH] nfs-utils: Update svcgssd so that it builds
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 03 Jan 2018 13:25:34 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since a15bd948 the --enable-svcgss option no longer builds
as svcgssd references functions which were changed at that time.
Fix those, and other function changes since then.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 utils/gssd/svcgssd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 3514ae1..23f0c0b 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -63,6 +63,8 @@
 #include "err_util.h"
 #include "conffile.h"
 
+struct state_paths etab;
+
 void
 sig_die(int signal)
 {
@@ -101,7 +103,7 @@ main(int argc, char *argv[])
 	char *principal = NULL;
 	char *s;
 
-	conf_init(NFS_CONFFILE); 
+	conf_init_file(NFS_CONFFILE);
 
 	s = conf_get_str("svcgssd", "principal");
 	if (!s)
-- 
1.8.3.1



