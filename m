Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:58296 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbcDQJLP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:11:15 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 3FFB5209A0
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:11:13 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:10:34 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] Consistently include <poll.h> instead of <sys/poll.h>
Message-ID: <20160417091034.GD2737@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

<poll.h> is the header specified by POSIX.

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/rtime.c   | 2 +-
 src/svc_run.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/src/rtime.c b/src/rtime.c
index b642840..32ab9f0 100644
--- a/src/rtime.c
+++ b/src/rtime.c
@@ -46,7 +46,7 @@
 #include <unistd.h>
 #include <errno.h>
 #include <sys/types.h>
-#include <sys/poll.h>
+#include <poll.h>
 #include <sys/socket.h>
 #include <sys/time.h>
 #include <netinet/in.h>
diff --git a/src/svc_run.c b/src/svc_run.c
index f40314b..7123d51 100644
--- a/src/svc_run.c
+++ b/src/svc_run.c
@@ -37,7 +37,7 @@
 #include <stdio.h>
 #include <string.h>
 #include <unistd.h>
-#include <sys/poll.h>
+#include <poll.h>
 
 
 #include <rpc/rpc.h>
-- 
2.7.3

